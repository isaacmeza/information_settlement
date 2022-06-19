*From Jan2020to do list we found out two different do files that make the same table,
* this version merges with pilot_operation while the other one does not


/* Table 2׺  Expectations Relative to Prediction*/
/*
The table regresses measures of expectation elicited in the baseline survey on 
dummies of who is the respondent of the survey. For some cases we could elicit 
the expectation of more than one party (employee, employee's lawyer, firm's lawyer).
The omitted variable is the employee dummy, so the interpretation of the 
employee's lawyer and firm's lawyer coefficients are relative to the employee 
who is captured in the constant. It combines two phases in one singled pooled 
dataset. 
*/

********************************************************************************
*						Keep correct observations							   *
********************************************************************************

use ".\DB\scaleup_operation.dta", clear
rename año anio
rename expediente exp
merge m:1 junta exp anio using ".\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

*Notified casefiles
keep if notificado==1

*Homologation
gen treatment=.
replace treatment=2 if dia_tratamiento==1
replace treatment=1 if dia_tratamiento==0
rename convenio seconcilio
rename convenio_seg_2m convenio_2m 
rename convenio_seg_5m convenio_5m
gen fecha=date(fecha_lista,"YMD")
format fecha %td

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub numActores
gen phase=2
tempfile p2
save `p2'

use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

merge m:1 junta exp anio using ".\p1_w_p3\out\inicialesP1Faltantes_wod.dta", ///
keep(1 3) gen(_mNuevasIniciales) keepusing(abogado_pubN numActoresN)
//keepusing(fechaDemanda_M tipodeabogado_M trabajadordeconfianza_M numActoresN)

//gen fechaDemanda = date(fecha, "YMD")
gen fechaDemanda = fecha

foreach var in numActores abogado_pub{
replace `var' = `var'N if missing(`var') & !missing(`var'N)
}


keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub numActores
append using `p2'
replace phase=1 if missing(phase)

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

keep junta exp anio 

tempfile correctSample 
save `correctSample'


*************************************EMPLOYEE***********************************
********************************************************************************

use ".\DB\pilot_casefiles_wod.dta", clear	
merge m:1 folio using  "./Raw/Append Encuesta Inicial Actor.dta" , keep(2 3) nogen
ren A_fecha fecha
merge 1:1 folio fecha using "./DB/pilot_operation.dta", keep(1 3) nogen

*Outliers
xtile perc=A_5_5, nq(100)
replace A_5_5=. if perc>=99

*Overconfidence amount
gen rel_oc_a=(A_5_5-comp_esp)/comp_esp
rename A_5_5 oc_a

*Outliers
xtile perc_rel=rel_oc_a, nq(100)
replace rel_oc_a=. if perc_rel>=98

*Overconfidence prob
gen Prob_win_calc=prob_laudopos/(prob_laudopos+prob_laudocero)
replace Prob_win_calc=Prob_win_calc*100

gen rel_oc_p=(A_5_1-Prob_win_calc)/Prob_win_calc
rename A_5_1 oc_p

*Outliers
xtile perc_rel_p=rel_oc_p, nq(100)
replace rel_oc_p=. if perc_rel_p>=95



*Dummy party
gen emp=1
ren expediente exp 
merge m:1 junta exp anio using `correctSample', nogen keep(3)
keep rel_oc_a oc_a rel_oc_p oc_p emp tratamientoquelestoco folio

tempfile temp_emp
save `temp_emp'


********************************EMPLOYEE'S LAWYER*******************************
********************************************************************************

use ".\DB\pilot_casefiles_wod.dta", clear	
merge 1:m folio using  "./Raw/Append Encuesta Inicial Representante Actor.dta" , keep(2 3) nogen
ren RA_fecha fecha
merge 1:1 folio fecha using "./DB/pilot_operation.dta", keep(1 3) nogen



*Outliers
xtile perc=RA_5_5, nq(100)
replace RA_5_5=. if perc>=99

*Overconfidence amount
gen rel_oc_a=(RA_5_5-comp_esp)/comp_esp
rename RA_5_5 oc_a

*Outliers
xtile perc_rel=rel_oc_a, nq(100)
replace rel_oc_a=. if perc_rel>=98

*Overconfidence prob
gen Prob_win_calc=prob_laudopos/(prob_laudopos+prob_laudocero)
replace Prob_win_calc=Prob_win_calc*100

gen rel_oc_p=(RA_5_1-Prob_win_calc)/Prob_win_calc
rename RA_5_1 oc_p

*Outliers
xtile perc_rel_p=rel_oc_p, nq(100)
replace rel_oc_p=. if perc_rel_p>=95

*Dummy party
gen emp_law=1
ren expediente exp 
merge m:1 junta exp anio using `correctSample', nogen keep(3)
keep rel_oc_a oc_a rel_oc_p oc_p emp_law tratamientoquelestoco folio 
tempfile temp_emp_law
save `temp_emp_law'



********************************FIRM'S LAWYER*******************************
********************************************************************************

use ".\DB\pilot_casefiles_wod.dta", clear	
merge 1:m folio using  "./Raw/Append Encuesta Inicial Representante Demandado.dta" , keep(2 3) nogen
ren RD_fecha fecha
merge m:1 folio fecha using "./DB/pilot_operation.dta", keep(1 3) nogen


*Outliers
xtile perc=RD5_5, nq(100)
replace RD5_5=. if perc>=99

*Overconfidence amount
gen rel_oc_a=-(RD5_5-comp_esp)/comp_esp
rename RD5_5 oc_a

*Outliers
xtile perc_rel=-rel_oc_a, nq(100)
replace rel_oc_a=. if perc_rel>=98

*Overconfidence prob
gen Prob_win_calc=prob_laudopos/(prob_laudopos+prob_laudocero)
replace Prob_win_calc=Prob_win_calc*100

gen rel_oc_p=(RD5_1_1-Prob_win_calc)/Prob_win_calc
rename RD5_1_1 oc_p

*Outliers
xtile perc_rel_p=rel_oc_p, nq(100)
replace rel_oc_p=. if perc_rel_p>=95

*Dummy party
gen fir_law=1
ren expediente exp 
merge m:1 junta exp anio using `correctSample', nogen keep(3)
keep rel_oc_a oc_a rel_oc_p oc_p fir_law tratamientoquelestoco folio
tempfile temp_fir_law
save `temp_fir_law'


********************************************************************************

use `temp_emp', clear
append using `temp_emp_law'
*append using `temp_fir'
append using `temp_fir_law'

foreach var of varlist emp emp_law  fir_law {
	replace `var'=0 if missing(`var')
	}
	


*HOMOLOGATION
rename folio id_exp
gen party=.
replace party=1 if emp==1
replace party=2 if emp_law==1
replace party=3 if fir_law==1
rename rel_oc_a rel_oca_
rename rel_oc_p rel_ocp_
rename oc_p pr_
rename oc_a exp_	
gen phase=1
drop if tratamientoquelestoco==3
drop tratamientoquelestoco
*merge m:m folio expediente anio using ".\DB\pilot_operation.dta", keep(1 3) nogen

tempfile phase1
save `phase1'

********************************************************************************


use ".\DB\scaleup_operation.dta", clear
rename expediente exp
rename año anio
duplicates drop  exp anio junta, force
merge 1:1 junta exp anio using ".\DB\scaleup_predictions.dta", nogen keep (1 3)


*Expected compensation
gen comp_esp=liq_total_laudo_avg


*Outliers
cap drop perc
xtile perc=ea2_cantidad_pago, nq(100)
replace ea2_cantidad_pago=. if perc>=98

cap drop perc
xtile perc=era2_cantidad_pago, nq(100)
replace era2_cantidad_pago=. if perc>=98

cap drop perc
xtile perc=erd2_cantidad_pago, nq(100)
replace erd2_cantidad_pago=. if perc>=98


rename ea2_cantidad_pago exp_1
rename era2_cantidad_pago exp_2
rename erd2_cantidad_pago exp_3

rename ea1_prob_pago pr_1
rename era1_prob_pago pr_2
rename erd1_prob_pago pr_3


*Overconfidence amount
gen rel_oca_1=(exp_1-comp_esp)/comp_esp
gen rel_oca_2=(exp_2-comp_esp)/comp_esp
gen rel_oca_3=-(exp_3-comp_esp)/comp_esp

*Overconfidence prob
replace x1=x1*100
gen rel_ocp_1=(pr_1-x1)/x1
gen rel_ocp_2=(pr_2-x1)/x1
gen rel_ocp_3=(pr_3-x1)/x1


*Outliers oc
foreach var of varlist rel_oca_1 rel_oca_2 rel_ocp* {
	cap drop perc
	xtile perc=`var', nq(100)
	replace `var'=. if perc>=96
	}
	cap drop perc
	xtile perc=-rel_oca_3, nq(100)
	replace rel_oca_3=. if perc>=96

merge m:1 junta exp anio using `correctSample', nogen keep(3)

keep id_exp exp_* pr_* rel_oc*

drop if missing(id_exp)

reshape long exp_ pr_ rel_oca_ rel_ocp_ , i(id_exp) j(party)

gen phase=2
append using `phase1'



replace pr_=pr_/100	


/***********************
       REGRESSIONS
************************/

eststo clear


*************************
*		Expectation		*

*PROBABILITY

eststo : areg pr_ i.party, absorb(id_exp)
estadd scalar Erre=e(r2)
test _cons+2.party=0
estadd scalar p_el=r(p)
test _cons+3.party=0
estadd scalar p_fl=r(p)

*AMOUNT

eststo : areg exp_ i.party, absorb(id_exp)
estadd scalar Erre=e(r2)
test _cons+2.party=0
estadd scalar p_el=r(p)
test _cons+3.party=0
estadd scalar p_fl=r(p)

*************************
*		Expectation		*


*PROBABILITY

eststo : areg rel_ocp_ i.party, absorb(id_exp)
estadd scalar Erre=e(r2)
test _cons+2.party=0
estadd scalar p_el=r(p)
test _cons+3.party=0
estadd scalar p_fl=r(p)

*AMOUNT

eststo : areg rel_oca_ i.party, absorb(id_exp)
estadd scalar Erre=e(r2)
test _cons+2.party=0
estadd scalar p_el=r(p)
test _cons+3.party=0
estadd scalar p_fl=r(p)



esttab using ".\Tables\reg_results\prediction_cases_pooled.csv", se star(* 0.1 ** 0.05 *** 0.01)  b(a2)  ///
	scalars("Erre R-squared" "p_el p-value:Emp Law"  "p_fl p-value:Firm Law") replace
