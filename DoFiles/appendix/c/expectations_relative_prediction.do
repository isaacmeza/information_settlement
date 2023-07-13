
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	expectations_relative_prediction
* Author:	Isaac M 
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- Append Encuesta Inicial Actor.dta
		- Append Encuesta Inicial Representante Actor.dta
		- Append Encuesta Inicial Representante Demandado.dta
		- phase_1.dta
		- phase_2.dta
* Files created:  
		- expectations_relative_prediction_a.csv
		- expectations_relative_prediction_b.csv


* Purpose: The table regresses measures of expectation elicited in the baseline survey on 
dummies of who is the respondent of the survey. For some cases we could elicit 
the expectation of more than one party (employee, employee's lawyer, firm's lawyer).
The omitted variable is the employee dummy, so the interpretation of the 
employee's lawyer and firm's lawyer coefficients are relative to the employee 
who is captured in the constant. It combines two phases in one singled pooled 
dataset. 

*******************************************************************************/
*/

*Plaintiff
********************************************************************************
use "./DB/Append Encuesta Inicial Actor.dta", clear
merge m:1 folio using ".\DB\phase_1.dta", keepusing(folio comp_esp prob_esp) keep(3) 

*Outliers
xtile perc=A_5_5, nq(100)
drop if perc>=99
*Amount
gen rel_oc_a=(A_5_5-comp_esp)/comp_esp
rename A_5_5 exp_a
*Probability
rename A_5_1 exp_p
gen rel_oc_p=(exp_p-prob_esp*100)/(prob_esp*100)
*Outliers
xtile perc_rel=rel_oc_a, nq(100)
replace rel_oc_a=. if perc_rel>=98
xtile perc_rel_p=rel_oc_p, nq(100)
replace rel_oc_p=. if perc_rel_p>=95

gen party=1
	
keep rel_oc_a exp_a rel_oc_p exp_p party  folio 
tempfile temp_party1
save `temp_party1'


*Plaintiff's Lawyer
********************************************************************************
use "./DB/Append Encuesta Inicial Representante Actor.dta", clear
merge m:1 folio using ".\DB\phase_1.dta", keepusing(folio comp_esp prob_esp) keep(3) 

*Outliers
xtile perc=RA_5_5, nq(100)
drop if perc>=99
*Amount
gen rel_oc_a=(RA_5_5-comp_esp)/comp_esp
rename RA_5_5 exp_a
*Probability
rename RA_5_1 exp_p
gen rel_oc_p=(exp_p-prob_esp*100)/(prob_esp*100)
*Outliers
xtile perc_rel=rel_oc_a, nq(100)
replace rel_oc_a=. if perc_rel>=98
xtile perc_rel_p=rel_oc_p, nq(100)
replace rel_oc_p=. if perc_rel_p>=95

gen party=2	

keep rel_oc_a exp_a rel_oc_p exp_p party  folio 
tempfile temp_party2
save `temp_party2'


*Defendant's Lawyer
********************************************************************************
use "./DB/Append Encuesta Inicial Representante Demandado.dta", clear
merge m:1 folio using ".\DB\phase_1.dta", keepusing(folio comp_esp prob_esp) keep(3) 

*Outliers
xtile perc=RD5_5, nq(100)
drop if perc>=99
*Amount
gen rel_oc_a=(RD5_5-comp_esp)/comp_esp
rename RD5_5 exp_a
*Probability
rename RD5_1_1 exp_p
gen rel_oc_p=(exp_p-prob_esp*100)/(prob_esp*100)
*Outliers
xtile perc_rel=rel_oc_a, nq(100)
replace rel_oc_a=. if perc_rel>=98
xtile perc_rel_p=rel_oc_p, nq(100)
replace rel_oc_p=. if perc_rel_p>=95

gen party=3

keep rel_oc_a exp_a rel_oc_p exp_p party  folio 
tempfile temp_party3
save `temp_party3'


********************************************************************************

use `temp_party1', clear
append using `temp_party2'
append using `temp_party3'

tempfile phase1
save `phase1'

********************************************************************************

*Phase 2
********************************************************************************
use ".\DB\phase_2.dta", clear

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

rename (ea2_cantidad_pago era2_cantidad_pago erd2_cantidad_pago) (exp_a1 exp_a2 exp_a3)
rename (ea1_prob_pago era1_prob_pago erd1_prob_pago) (exp_p1 exp_p2 exp_p3)

*Overconfidence amount
gen rel_oc_a1=(exp_a1-liq_total_laudo_avg)/liq_total_laudo_avg
gen rel_oc_a2=(exp_a2-liq_total_laudo_avg)/liq_total_laudo_avg
gen rel_oc_a3=-(exp_a3-liq_total_laudo_avg)/liq_total_laudo_avg

*Overconfidence prob
gen rel_oc_p1=(exp_p1-prob_esp*100)/(prob_esp*100)
gen rel_oc_p2=(exp_p2-prob_esp*100)/(prob_esp*100)
gen rel_oc_p3=(exp_p3-prob_esp*100)/(prob_esp*100)


*Outliers oc
foreach var of varlist rel_oc_p* rel_oc_a1 rel_oc_a2 {
	cap drop perc
	xtile perc=`var', nq(100)
	replace `var'=. if perc>=96
	}
	cap drop perc
	xtile perc=-rel_oc_a3, nq(100)
	replace rel_oc_a3=. if perc>=96

	
egen folio = group(junta exp)	
tostring folio, replace
keep folio exp_* rel_oc_*

drop if missing(folio)
reshape long exp_a exp_p rel_oc_a rel_oc_p , i(folio) j(party)
append using `phase1'

replace exp_p=exp_p/100	


********************************************************************************

/***********************
       PANEL A
************************/

eststo clear

*************************
*		Expectation		*

*PROBABILITY
eststo : areg exp_p i.party, absorb(folio)
test _cons+2.party=0
estadd scalar p_el=r(p)
test _cons+3.party=0
estadd scalar p_fl=r(p)

*AMOUNT
eststo : areg exp_a i.party, absorb(folio)
test _cons+2.party=0
estadd scalar p_el=r(p)
test _cons+3.party=0
estadd scalar p_fl=r(p)


*************************
*	  Overconfidence	*

*PROBABILITY
eststo : areg rel_oc_p i.party, absorb(folio)
test _cons+2.party=0
estadd scalar p_el=r(p)
test _cons+3.party=0
estadd scalar p_fl=r(p)

*AMOUNT
eststo : areg rel_oc_a i.party, absorb(folio)
test _cons+2.party=0
estadd scalar p_el=r(p)
test _cons+3.party=0
estadd scalar p_fl=r(p)

*-------------------------------------------------------------------------------
esttab using "$directorio/Tables/appendix/c/expectations_relative_prediction_a.csv", se r2 ${star} b(a2) scalars("p_el p-value:Emp Law"  "p_fl p-value:Firm Law") replace 


********************************************************************************
********************************************************************************
********************************************************************************


*Phase 3
********************************************************************************
use ".\DB\phase_3.dta", clear


************************  Calculator phase 3 prediction  ***********************

gen quadrant="NE"
replace quadrant="NW" if c_antiguedad>2.61 & salario_diario<207.66
replace quadrant="SE" if c_antiguedad<2.61 & salario_diario>207.66
replace quadrant="SW" if c_antiguedad<2.61 & salario_diario<207.66

gen min_prediction=61.03 if quadrant=="NE"
replace min_prediction=69.87 if quadrant=="NW"
replace min_prediction=42.24 if quadrant=="SE"
replace min_prediction=51.22 if quadrant=="SW"

gen max_prediction=90.08 if quadrant=="NE"
replace max_prediction=98.69 if quadrant=="NW"
replace max_prediction=59.22 if quadrant=="SE"
replace max_prediction=67.36 if quadrant=="SW"

gen mid_prediction=(max_prediction+min_prediction)/2

foreach pred in min max mid{
	replace `pred'_prediction=`pred'_prediction*salario_diario
	gen `pred'_overconfidenceAmmount=(cantidad_ganar-`pred'_prediction)/`pred'_prediction
}

gen na_prob = missing(prob_ganar)
gen na_cant = missing(cantidad_ganar)

/***********************
       PANEL B
************************/

eststo clear

*************************
*		Expectation		*

*PROBABILITY
eststo : reg prob_ganar
su prob_ganar
estadd scalar sd=r(sd)
su na_prob
estadd scalar ignores=r(mean)*100

*AMOUNT
eststo : reg cantidad_ganar
su cantidad_ganar
estadd scalar sd=r(sd)
su na_cant
estadd scalar ignores=r(mean)*100

*************************
*	  Overconfidence	*

*PROBABILITY
eststo : reg mid_overconfidenceAmmount
su mid_overconfidenceAmmount
estadd scalar sd=r(sd)

*AMOUNT
eststo : reg max_overconfidenceAmmount
su max_overconfidenceAmmount
estadd scalar sd=r(sd)

*-------------------------------------------------------------------------------
esttab using "$directorio/Tables/appendix/c/expectations_relative_prediction_b.csv", se r2 ${star} b(a2) scalars("sd sd" "ignores ignores") replace 




