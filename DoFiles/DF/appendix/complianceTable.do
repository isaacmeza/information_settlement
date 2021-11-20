/*Table C5:  Compliance Rate - Panel (a)*/
/*
Compliance rate for each phase, both for treatment and survey. Shows the 
percentage compliance with treatment and survey for plaintiff' side, 
defendant's side, both, and any. 
*/

***
use "./DB/Append Encuesta de Salida", clear
keep folio ES_1_1 fecha

bysort folio fecha: gen j=_n

reshape wide ES_1_1, i(folio fecha) j(j)
tempfile exit
save `exit'



/*Compliance table*/

use ".\DB\pilot_operation.dta", clear
drop if tratamientoquelestoco==0
gen exp = expediente
gen treatment = tratamientoquelestoco
drop renglon

********************************************************************************

bysort exp anio: gen DuplicatesPredrop=_N
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

bysort exp anio: gen DuplicatesPostdrop=_N

********************************************************************************
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1
putexcel set "./Tables/Compliance.xlsx", sheet("Compliance") modify

*Compliance rate
levelsof tratamientoquelestoco, local(levels)
foreach l of local levels { 
	
	local c=`l'+4
	qui count if tratamientoquelestoco==`l'
	qui putexcel B`c'=(r(N)) 
	
	*Plaintiff
	qui su sellevotratamiento if tratamientoquelestoco==`l' & ( p_actor==1 | p_ractor==1)
	qui putexcel P`c'=(r(mean)) 
	
	*Defendant
	qui su sellevotratamiento if tratamientoquelestoco==`l' & ( p_dem==1 | p_rdem==1)
	qui putexcel Q`c'=(r(mean)) 
	
	*Both
	qui su sellevotratamiento if tratamientoquelestoco==`l' & ( p_dem==1 | p_rdem==1) & ( p_actor==1 | p_ractor==1)
	qui putexcel R`c'=(r(mean)) 
	
	*Any
	qui su sellevotratamiento if tratamientoquelestoco==`l' & ( p_dem==1 | p_rdem==1) | ( p_actor==1 | p_ractor==1)
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

merge 1:1 folio fecha using "./DB/Append Encuesta Inicial Representante Demandado.dta", keep(1 3)
gen ans_RD=(_merge==3)
drop _merge


*Identificador Plaintiff answered
gen plaintiff_ans=max(ans_A, ans_RA)

*Identificador Defendant answered
gen defendant_ans=max(ans_D, ans_RD)

*Identificador Both answered
gen both_ans=plaintiff_ans*defendant_ans

*Identificador EE no vac(anyone answered)
egen any_ans=rowtotal(ans*)
replace any_ans=(any_ans>0)


*Compliance rate Baseline Survey
*Plaintiff
qui tab tratamientoquelestoco plaintiff_ans, matcell(EE) 
qui putexcel T5=matrix(EE) 

*Defendant
qui tab tratamientoquelestoco defendant_ans, matcell(EE) 
qui putexcel V5=matrix(EE) 

*Both
qui tab tratamientoquelestoco both_ans, matcell(EE) 
qui putexcel X5=matrix(EE) 

*Any
qui tab tratamientoquelestoco any_ans, matcell(EE) 
qui putexcel Z5=matrix(EE) 


********************************************************************************
*Compliance with exit survey 

merge 1:m folio fecha using `exit', keep(1 3)
gen ans_ES=(_merge==3)

*Identificador Plaintiff answered
gen plaintiff_ans_e=ans_ES if inlist(ES_1_11,1,2) | inlist(ES_1_12,1,2) | inlist(ES_1_13,1,2)
replace plaintiff_ans_e = -1 if missing(plaintiff_ans_e)
*Identificador Defendant answered
*gen defendant_ans=max(ans_D, ans_RD)
gen defendant_ans_e=ans_ES if inlist(ES_1_11,3,4) | inlist(ES_1_12,3,4) | inlist(ES_1_13,3,4)
replace defendant_ans_e = -1 if missing(defendant_ans_e)

*Identificador Both answered
*gen both_ans=plaintiff_ans*defendant_ans
gen both_ans_e=ans_ES if (inlist(ES_1_11,1,2) | inlist(ES_1_12,1,2) | inlist(ES_1_13,1,2)) ///
		& (inlist(ES_1_11,3,4) | inlist(ES_1_12,3,4) | inlist(ES_1_13,3,4)) 
replace both_ans_e = -1 if missing(both_ans_e)

*Identificador EE no vac(anyone answered)
*egen any_ans=rowtotal(ans*)
*replace any_ans=(any_ans>0)
gen any_ans_e=ans_ES


*Plaintiff
qui tab tratamientoquelestoco plaintiff_ans_e, matcell(EE) 
qui putexcel AB5=matrix(EE) 

*Defendant
qui tab tratamientoquelestoco defendant_ans_e, matcell(EE) 
qui putexcel AD5=matrix(EE) 

*Both
qui tab tratamientoquelestoco both_ans_e, matcell(EE) 
qui putexcel AF5=matrix(EE) 

*Any
qui tab tratamientoquelestoco any_ans_e, matcell(EE) 
qui putexcel AH5=matrix(EE) 

	

	
