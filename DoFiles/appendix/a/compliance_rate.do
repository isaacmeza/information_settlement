
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	compliance_rate
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: June. 26, 2023
* Modifications:		
* Files used:     
		- phase_1.dta
		- phase_2.dta
		- Append Encuesta de Salida.dta
		- Append Encuesta Inicial Actor.dta
		- Append Encuesta Inicial Demandado.dta
		- Append Encuesta Inicial Representante Actor.dta
		- Append Encuesta Inicial Representante Demandado.dta
* Files created:  
		- compliance_rate.xlsx
		
* Purpose: Compliance rate for each phase, both for treatment and survey.

*******************************************************************************/
*/



* Phase 1
********************************************************************************

use "./DB/Append Encuesta de Salida.dta", clear
keep folio ES_1_1 fecha
bysort folio fecha: gen j=_n
reshape wide ES_1_1, i(folio fecha) j(j)
tempfile exit
save `exit'

use ".\DB\phase_1.dta", clear

********************************************************************************
*Shows up
putexcel set "./Tables/appendix/a/compliance_rate.xlsx", sheet("show_up") modify

levelsof treatment , local(levels)
foreach l of local levels {  
	
	if `l'==1 {
		local Col="H"
		}
	if `l'==2 {
		local Col="I"
		}	
	local rr=4
	foreach var of varlist p_actor p_ractor p_rdem {
		qui su `var' if treatment==`l'
		qui putexcel `Col'`rr'=(r(mean)) 
		local rr=`rr'+1
		}
	}
	
********************************************************************************
*Compliance rate
putexcel set "./Tables/appendix/a/compliance_rate.xlsx", sheet("compliance_p1") modify

levelsof treatment, local(levels)
foreach l of local levels { 
	
	local c=`l'+4
	qui count if treatment==`l'
	qui putexcel B`c'=(r(N)) 
	
	*Plaintiff
	qui su sellevotratamiento if treatment==`l' & ( p_actor==1 | p_ractor==1)
	qui putexcel P`c'=(r(mean)) 
	
	*Defendant
	qui su sellevotratamiento if treatment==`l' & ( p_dem==1 | p_rdem==1)
	qui putexcel Q`c'=(r(mean)) 
	
	*Both
	qui su sellevotratamiento if treatment==`l' & ( p_dem==1 | p_rdem==1) & ( p_actor==1 | p_ractor==1)
	qui putexcel R`c'=(r(mean)) 
	
	*Any
	qui su sellevotratamiento if treatment==`l' & ( p_dem==1 | p_rdem==1) | ( p_actor==1 | p_ractor==1)
	qui putexcel S`c'=(r(mean)) 
	
	}
	
********************************************************************************
*Compliance with baseline survey 

merge 1:1 folio fecha using "./DB/Append Encuesta Inicial Actor.dta", keep(1 3)
	*Identifies when employee answered
gen ans_A=(_merge==3)
drop _merge

merge 1:1 folio fecha using "./DB/Append Encuesta Inicial Demandado.dta", keep(1 3)
gen ans_D=(_merge==3)
drop _merge

merge 1:1 folio fecha using "./DB/Append Encuesta Inicial Representante Actor.dta", keep(1 3)
gen ans_RA=(_merge==3)
drop _merge

merge 1:m folio fecha using "./DB/Append Encuesta Inicial Representante Demandado.dta", keep(1 3)
gen ans_RD=(_merge==3)
drop _merge


*Plaintiff answered
gen plaintiff_ans=max(ans_A, ans_RA)
*Defendant answered
gen defendant_ans=max(ans_D, ans_RD)
*Both answered
gen both_ans=plaintiff_ans*defendant_ans
*Anyone answered
egen any_ans=rowtotal(ans*)
replace any_ans=(any_ans>0)


*Compliance rate Baseline Survey
*Plaintiff
qui tab treatment plaintiff_ans, matcell(EE) 
qui putexcel T5=matrix(EE) 
*Defendant
qui tab treatment defendant_ans, matcell(EE) 
qui putexcel V5=matrix(EE) 
*Both
qui tab treatment both_ans, matcell(EE) 
qui putexcel X5=matrix(EE) 
*Any
qui tab treatment any_ans, matcell(EE) 
qui putexcel Z5=matrix(EE) 


********************************************************************************
*Compliance with exit survey 

merge m:m folio fecha using `exit', keep(1 3)
gen ans_ES=(_merge==3)

*Plaintiff answered
gen plaintiff_ans_e=ans_ES if inlist(ES_1_11,1,2) | inlist(ES_1_12,1,2) | inlist(ES_1_13,1,2)
replace plaintiff_ans_e = -1 if missing(plaintiff_ans_e)
*Defendant answered
gen defendant_ans_e=ans_ES if inlist(ES_1_11,3,4) | inlist(ES_1_12,3,4) | inlist(ES_1_13,3,4)
replace defendant_ans_e = -1 if missing(defendant_ans_e)
*Both answered
gen both_ans_e=ans_ES if (inlist(ES_1_11,1,2) | inlist(ES_1_12,1,2) | inlist(ES_1_13,1,2)) ///
		& (inlist(ES_1_11,3,4) | inlist(ES_1_12,3,4) | inlist(ES_1_13,3,4)) 
replace both_ans_e = -1 if missing(both_ans_e)

*Anyone answered
gen any_ans_e=ans_ES


*Plaintiff
qui tab treatment plaintiff_ans_e, matcell(EE) 
qui putexcel AB5=matrix(EE) 
*Defendant
qui tab treatment defendant_ans_e, matcell(EE) 
qui putexcel AD5=matrix(EE) 
*Both
qui tab treatment both_ans_e, matcell(EE) 
qui putexcel AF5=matrix(EE) 
*Any
qui tab treatment any_ans_e, matcell(EE) 
qui putexcel AH5=matrix(EE) 

	
* Phase 2
********************************************************************************
use ".\DB\phase_2.dta", clear 

********************************************************************************
*Shows up
putexcel set "./Tables/appendix/a/compliance_rate.xlsx", sheet("show_up") modify

levelsof treatment, local(levels)
foreach l of local levels {  
	
	if `l'==1 {
		local Col="K"
		}
	if `l'==2 {
		local Col="L"
		}	
	local rr=4
	foreach var of varlist p_actor p_ractor p_rdem {
		qui su `var' if treatment==`l'
		qui putexcel `Col'`rr'=(r(mean)) 
		local rr=`rr'+1
		}
	local r=`r'+1	
	}
	
	
********************************************************************************
*Compliance rate	
putexcel set  "./Tables/appendix/a/compliance_rate.xlsx", modify sheet("compliance_p2")

gen calcu_both = calcu_p_actora*calcu_p_dem
gen calcu_any = calcu_p_actora + calcu_p_dem > 0
gen registro_both = registro_p_actora*registro_p_dem2
gen registro_any = registro_p_actora + registro_p_dem2 > 0
********************************************************************************

count if treatment == 1
putexcel P3 = (r(N))
count if treatment == 2
putexcel P4 = (r(N))

********************************************************************************
*Compliance with treatment
sum calcu_p_actora if treatment == 2
putexcel Q4 = (r(mean))
sum calcu_p_dem if treatment == 2 
putexcel R4 = (r(mean))
sum calcu_both if treatment == 2 
putexcel S4 = (r(mean))
sum calcu_any  if treatment == 2
putexcel T4 = (r(mean))

********************************************************************************
*Compliance with survey
sum registro_p_actora if treatment == 2 
putexcel U4 = (r(mean))
sum registro_p_dem2 if treatment == 2
putexcel V4 = (r(mean))
sum registro_both if treatment == 2
putexcel W4 = (r(mean))
sum registro_any  if treatment == 2 
putexcel X4 = (r(mean))
	
	