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

	*Money
gen diff_amount=(A_5_5-exp_comp)/1000

qui su diff_amount

twoway (hist diff_amount if diff_amount<160 & diff_amount>=-50 , w(10) percent) ///
		(scatteri 0 `r(mean)' 20 `r(mean)', c(l) m(i) color(gs10) lwidth(vthick) )  ///
		, scheme(s2mono) graphregion(color(white)) ///
	title("Amount") xtitle("Survey - Calculator in thousand pesos") ///
	legend(off) name(amount, replace)
graph export "./Figures/diff_amt_e.pdf", replace 

	*Probability
rename A_5_1 Prob_win
gen Prob_win_calc=prob_laudopos/(prob_laudopos+prob_laudocero)
replace Prob_win_calc=Prob_win_calc*100

gen diff_prob=Prob_win-Prob_win_calc

qui su diff_prob

twoway (hist diff_prob, w(10) percent) ///
		(scatteri 0 `r(mean)' 20 `r(mean)', c(l) m(i) color(gs10) lwidth(vthick) )  ///
		, scheme(s2mono) graphregion(color(white)) ///
	title("Probability") xtitle("Survey -  Calculator in % points") ///
	legend(off) name(prob, replace)
graph export "./Figures/diff_prob_e.pdf", replace 
	



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

gen diff_amount=(RA_5_5-exp_comp)/1000

qui su diff_amount

twoway (hist diff_amount if diff_amount<160 & diff_amount>=-50 , w(10) percent) ///
		(scatteri 0 `r(mean)' 30 `r(mean)', c(l) m(i) color(gs10) lwidth(vthick) )  ///
		, scheme(s2mono) graphregion(color(white)) ///
	title("Amount") xtitle("Survey - Calculator in thousand pesos") ///
	legend(off) name(amount, replace)
graph export "./Figures/diff_amt_el.pdf", replace 

	*Probability
rename RA_5_1 Prob_win
gen Prob_win_calc=prob_laudopos/(prob_laudopos+prob_laudocero)
replace Prob_win_calc=Prob_win_calc*100

gen diff_prob=Prob_win-Prob_win_calc

qui su diff_prob

twoway (hist diff_prob, w(10) percent) ///
		(scatteri 0 `r(mean)' 30 `r(mean)', c(l) m(i) color(gs10) lwidth(vthick) )  ///
		, scheme(s2mono) graphregion(color(white)) ///
	title("Probability") xtitle("Survey -  Calculator in % points") ///
	legend(off) name(prob, replace)
graph export "./Figures/diff_prob_el.pdf", replace 
	


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

gen diff_amount=(RD5_5-exp_comp)/1000

qui su diff_amount

twoway (hist diff_amount if diff_amount<160 & diff_amount>=-50 , w(10) percent) ///
		(scatteri 0 `r(mean)' 25 `r(mean)', c(l) m(i) color(gs10) lwidth(vthick) )  ///
		, scheme(s2mono) graphregion(color(white)) ///
	title("Amount") xtitle("Survey - Calculator in thousand pesos") ///
	legend(off) name(amount, replace)
graph export "./Figures/diff_amt_fl.pdf", replace 
	
	*Probability
rename RD5_1_1 Prob_win
gen Prob_win_calc=prob_laudopos/(prob_laudopos+prob_laudocero)
replace Prob_win_calc=Prob_win_calc*100
		
gen diff_prob=Prob_win-Prob_win_calc

qui su diff_prob

twoway (hist diff_prob, w(10) percent) ///
		(scatteri 0 `r(mean)' 25 `r(mean)', c(l) m(i) color(gs10) lwidth(vthick) )  ///
		, scheme(s2mono) graphregion(color(white)) ///
	title("Probability") xtitle("Survey -  Calculator in % points") ///
	legend(off) name(prob, replace)
graph export "./Figures/diff_prob_fl.pdf", replace 

	
