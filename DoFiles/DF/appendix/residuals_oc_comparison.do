/*Figure C2: Subjective expectation minus prediction - Phase 1*/
/*
Overconfidence plots 
*/

use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment
drop renglon
********************************************************************************

bysort junta exp anio: gen DuplicatesPredrop=_N
forvalues i=1/3{
	gen T`i'_aux=[treatment==`i'] 
	bysort junta exp anio: egen T`i'=max(T`i'_aux)
}

gen T1T2=[T1==1 & T2==1]
gen T1T3=[T1==1 & T3==1]
gen T2T3=[T2==1 & T3==1]
gen TAll=[T1==1 & T2==1 & T3==1]

replace T1T2=0 if TAll==1
replace T1T3=0 if TAll==1
replace T2T3=0 if TAll==1

*32 drops
*drop if T1T2==1 & treatment == 1
*46 drops
drop if T1T3==1
*31 drops
drop if T2T3==1
*8 drops
drop if TAll==1

*bysort junta exp anio: gen DuplicatesPostdrop=_N

*44 drops
*sort junta exp anio fecha
*bysort junta exp anio: keep if _n==1
********************************************************************************
*Drop conciliator observations
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

ren (exp treatment) (expediente tratamientoquelestoco)

tempfile selectedCasefiles
save `selectedCasefiles'

************************************Employee************************************
use  ".\DB\pilot_casefiles.dta", clear
merge m:1 folio using `selectedCasefiles', keep(3) keepusing(tratamientoquelestoco seconcilio p_actor) nogen
merge m:1 folio using "./Raw/Append Encuesta Inicial Actor.dta", keep(2 3) nogen

replace seconcilio=0 if seconcilio==.
duplicates drop folio tratamientoqueles secon, force

*Outliers
xtile perc=A_5_5, nq(100)
drop if perc>=99

*We keep calculator treatment arm 
keep if tratamientoquelestoco==2

	*Amount
gen diff_amt=(A_5_5-exp_comp)/1000

	*Probability
rename A_5_1 Prob_win
gen Prob_win_calc=prob_laudopos/(prob_laudopos+prob_laudocero)
replace Prob_win_calc=Prob_win_calc*100
gen diff_prob=Prob_win-Prob_win_calc
	
local i = 1	
*Residual analysis
foreach var of varlist diff_amt diff_prob {
	qui cvlasso `var' gen horas_sem reinstalaciontdummy indemconsttdummy nulidad salario_diario  abogado_pub c_antiguedad min_indem A_7_3 A_7_1  exp_comp, lopt alpha( 0.001 0.01 0.1(0.2)0.9 1) maxiter(60000)

	cap drop resid
	predict resid, lopt residuals
	cap drop ssr 
	cap drop sst
	qui egen ssr = sum(resid^2)
	su `var',  meanonly
	qui egen sst = sum((`var'-`r(mean)')^2)
	* R2
	di "R2"
	di 1-ssr[1]/sst[1]

	cap drop out
	qui bacon resid, gen(out) percentile(1)
	su resid, meanonly
	hist resid if out!=1, w(10) percent color(navy%70) xline(`r(mean)') scheme(s2mono) graphregion(color(white)) xtitle("Residual")
	graph export "./Figures/`var'_e_.pdf", replace 
	preserve
	keep resid
	rename resid resid`i'
	tempfile temp`i'
	save `temp`i''
	restore
	local i = `i' + 1 
}

	
************************************Employe's Lawyer****************************
use  ".\DB\pilot_casefiles.dta", clear
merge m:1 folio using `selectedCasefiles', keep(3) keepusing(tratamientoquelestoco seconcilio p_actor) nogen
merge m:m folio using "./Raw/Append Encuesta Inicial Representante Actor.dta", keep(2 3) nogen

replace seconcilio=0 if seconcilio==.
duplicates drop folio tratamientoqueles secon, force

*Outliers
xtile perc=RA_5_5, nq(100)
drop if perc>=99

*We keep calculator treatment arm 
keep if tratamientoquelestoco==2

	*Amount
gen diff_amt=(RA_5_5-exp_comp)/1000

	*Probability
rename RA_5_1 Prob_win
gen Prob_win_calc=prob_laudopos/(prob_laudopos+prob_laudocero)
replace Prob_win_calc=Prob_win_calc*100
gen diff_prob=Prob_win-Prob_win_calc

*Residual analysis
foreach var of varlist diff_amt diff_prob {
	qui cvlasso `var' gen horas_sem reinstalaciontdummy indemconsttdummy nulidad salario_diario  abogado_pub c_antiguedad min_indem RA_5_8  exp_comp, lopt alpha( 0.001 0.01 0.1(0.2)0.9 1) maxiter(50000)

	cap drop resid
	predict resid, lopt residuals
	cap drop ssr 
	cap drop sst
	qui egen ssr = sum(resid^2)
	su `var',  meanonly
	qui egen sst = sum((`var'-`r(mean)')^2)
	* R2
	di "R2"
	di 1-ssr[1]/sst[1]

	cap drop out
	qui bacon resid, gen(out) percentile(1)
	su resid, meanonly
	hist resid if out!=1, w(10) percent color(navy%70) xline(`r(mean)') scheme(s2mono) graphregion(color(white)) xtitle("Residual")
	graph export "./Figures/`var'_el_.pdf", replace 
	preserve
	keep resid
	rename resid resid`i'
	tempfile temp`i'
	save `temp`i''
	restore
	local i = `i' + 1 	
}
 
	


************************************Firm's Lawyer*******************************
use  ".\DB\pilot_casefiles.dta", clear
merge m:1 folio using `selectedCasefiles', keep(3) keepusing(tratamientoquelestoco seconcilio p_actor) nogen
merge m:m folio using "./Raw/Append Encuesta Inicial Representante Demandado.dta", keep(2 3) nogen

replace seconcilio=0 if seconcilio==.
duplicates drop folio tratamientoqueles secon, force

*Outliers
xtile perc=RD5_5, nq(100)
drop if perc>=99

*We keep calculator treatment arm 
keep if tratamientoquelestoco==2

	*Amount
gen diff_amt=(RD5_5-exp_comp)/1000

	*Probability
rename RD5_1_1 Prob_win
gen Prob_win_calc=prob_laudopos/(prob_laudopos+prob_laudocero)
replace Prob_win_calc=Prob_win_calc*100		
gen diff_prob=Prob_win-Prob_win_calc

*Residual analysis
foreach var of varlist diff_amt diff_prob {
	qui cvlasso `var' gen horas_sem reinstalaciontdummy indemconsttdummy nulidad salario_diario  abogado_pub c_antiguedad min_indem RD5_5  exp_comp, lopt alpha( 0.001 0.01 0.1(0.2)0.9 1) maxiter(50000)

	cap drop resid
	predict resid, lopt residuals
	cap drop ssr 
	cap drop sst
	qui egen ssr = sum(resid^2)
	su `var',  meanonly
	qui egen sst = sum((`var'-`r(mean)')^2)
	* R2
	di "R2"
	di 1-ssr[1]/sst[1]

	cap drop out
	qui bacon resid, gen(out) percentile(1)
	su resid, meanonly
	hist resid if out!=1, w(10) percent color(navy%70) xline(`r(mean)') scheme(s2mono) graphregion(color(white)) xtitle("Residual")
	graph export "./Figures/`var'_fl_.pdf", replace 
	preserve
	keep resid
	rename resid resid`i'
	tempfile temp`i'
	save `temp`i''
	restore
	local i = `i' + 1 	
}

use `temp1', clear
forvalues i = 2/6 {
	append using `temp`i''
}
save "./_aux/resid.dta", replace
