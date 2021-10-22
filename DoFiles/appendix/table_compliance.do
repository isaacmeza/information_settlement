/*Table C5:  Compliance Rate - Panel (a)*/
/*
Compliance rate for each phase, both for treatment and survey. Shows the 
percentage compliance with treatment and survey for plaintiff' side, 
defendant's side, both, and any. 
*/

***
use "$sharelatex/DB/Append Encuesta de Salida", clear
keep folio ES_1_1 fecha

bysort folio fecha: gen j=_n

reshape wide ES_1_1, i(folio fecha) j(j)
tempfile exit
save `exit'



/*Compliance table*/

use "$sharelatex\DB\pilot_operation.dta", clear

drop if tratamientoquelestoco==0
*Compliance rate
levelsof tratamientoquelestoco, local(levels)
foreach l of local levels { 
	
	local c=`l'+4
	qui count if tratamientoquelestoco==`l'
	qui putexcel B`c'=(r(N)) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify
	
	*Plaintiff
	qui su sellevotratamiento if tratamientoquelestoco==`l' & ( p_actor==1 | p_ractor==1)
	qui putexcel P`c'=(r(mean)) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify
	
	*Defendant
	qui su sellevotratamiento if tratamientoquelestoco==`l' & ( p_dem==1 | p_rdem==1)
	qui putexcel Q`c'=(r(mean)) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify
	
	*Both
	qui su sellevotratamiento if tratamientoquelestoco==`l' & ( p_dem==1 | p_rdem==1) & ( p_actor==1 | p_ractor==1)
	qui putexcel R`c'=(r(mean)) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify
	
	*Any
	qui su sellevotratamiento if tratamientoquelestoco==`l' & ( p_dem==1 | p_rdem==1) | ( p_actor==1 | p_ractor==1)
	qui putexcel S`c'=(r(mean)) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify
	
	}
********************************************************************************
*Compliance with baseline survey 

merge 1:1 folio fecha using "$sharelatex/DB/Append Encuesta Inicial Actor.dta", keep(1 3)
	*Identifies when employee answered
gen ans_A=(_merge==3)
drop _merge

merge 1:1 folio fecha using "$sharelatex/DB/Append Encuesta Inicial Demandado.dta", keep(1 3)
gen ans_D=(_merge==3)
drop _merge

merge 1:1 folio fecha using "$sharelatex/DB/Append Encuesta Inicial Representante Actor.dta", keep(1 3)
gen ans_RA=(_merge==3)
drop _merge

merge 1:1 folio fecha using "$sharelatex/DB/Append Encuesta Inicial Representante Demandado.dta", keep(1 3)
gen ans_RD=(_merge==3)
drop _merge


*Identificador Plaintiff answered
gen plaintiff_ans=max(ans_A, ans_RA)

*Identificador Defendant answered
gen defendant_ans=max(ans_D, ans_RD)

*Identificador Both answered
gen both_ans=plaintiff_ans*defendant_ans

*Identificador EE no vacía (anyone answered)
egen any_ans=rowtotal(ans*)
replace any_ans=(any_ans>0)


*Compliance rate Baseline Survey
*Plaintiff
qui tab tratamientoquelestoco plaintiff_ans, matcell(EE) 
qui putexcel T5=matrix(EE) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify

*Defendant
qui tab tratamientoquelestoco defendant_ans, matcell(EE) 
qui putexcel V5=matrix(EE) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify

*Both
qui tab tratamientoquelestoco both_ans, matcell(EE) 
qui putexcel X5=matrix(EE) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify

*Any
qui tab tratamientoquelestoco any_ans, matcell(EE) 
qui putexcel Z5=matrix(EE) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify


********************************************************************************
*Compliance with exit survey 

merge 1:m folio fecha using `exit', keep(1 3)
gen ans_ES=(_merge==3)

*Identificador Plaintiff answered
gen plaintiff_ans_e=ans_ES if inlist(ES_1_11,1,2) | inlist(ES_1_12,1,2) | inlist(ES_1_13,1,2)

*Identificador Defendant answered
*gen defendant_ans=max(ans_D, ans_RD)
gen defendant_ans_e=ans_ES if inlist(ES_1_11,3,4) | inlist(ES_1_12,3,4) | inlist(ES_1_13,3,4)

*Identificador Both answered
*gen both_ans=plaintiff_ans*defendant_ans
gen both_ans_e=ans_ES if (inlist(ES_1_11,1,2) | inlist(ES_1_12,1,2) | inlist(ES_1_13,1,2)) ///
		& (inlist(ES_1_11,3,4) | inlist(ES_1_12,3,4) | inlist(ES_1_13,3,4)) 

*Identificador EE no vacía (anyone answered)
*egen any_ans=rowtotal(ans*)
*replace any_ans=(any_ans>0)
gen any_ans_e=ans_ES


*Plaintiff
qui tab tratamientoquelestoco plaintiff_ans_e, matcell(EE) 
qui putexcel AB5=matrix(EE) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify

*Defendant
qui tab tratamientoquelestoco defendant_ans_e, matcell(EE) 
qui putexcel AD5=matrix(EE) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify

*Both
qui tab tratamientoquelestoco both_ans_e, matcell(EE) 
qui putexcel AF5=matrix(EE) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify

*Any
qui tab tratamientoquelestoco any_ans_e, matcell(EE) 
qui putexcel AH5=matrix(EE) using "$sharelatex/Tables/Compliance.xlsx", sheet("Compliance") modify

	

	
