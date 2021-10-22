/*Table C16: Treatment generated updating in probability - Phase 1 - Panel (a)*/
/*
Regressions of overconfidence (AMOUNT) on case characteristics (exogenous) 
*/

***
*Trimming parameters

local t1=99 /*Trimming survey variable*/
local t2=95 /*Trimming update variable*/


********************************************************************************
********************************************************************************
*								Theta Updating
********************************************************************************
********************************************************************************


*************************************EMPLOYEE***********************************
********************************************************************************

use "$sharelatex\DB\pilot_casefiles_wod.dta", clear	
duplicates drop folio, force
merge 1:1 folio using  "$sharelatex/Raw/Append Encuesta Inicial Actor.dta" , keep(2 3) nogen
merge 1:1 folio using "$sharelatex/Raw/Merge_Actor_OC.dta", keep(2 3) nogen
merge 1:m folio using "$sharelatex/DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
drop _merge



duplicates drop folio tratamientoqueles secon, force
drop if tratamientoquelestoco==0

*Outliers
xtile perc=A_5_5, nq(100)
drop if perc>=`t1'

*Measure of update in beliefs:  |P-E_e|/|P-E_b|
gen update_comp=abs((ES_1_4-comp_esp)/(A_5_5-comp_esp))


*Keep same sample as in relative updating
gen rel=(ES_1_4-A_5_5)/(A_5_5)


*Outliers
xtile perc_up=rel, nq(100)
drop if perc_up>=`t2'

*Sample conditioning on overconfident
keep if A_5_5>comp_esp


/***********************
       REGRESSIONS
************************/

eststo clear
		
eststo: reg  c.update_comp ///
	i.tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem  ///
	i.A_7_3 i.A_1_2 i.A_6_1 , robust
estadd scalar Erre=e(r2)
qui su update_comp if e(sample)
estadd scalar OCMean=r(mean)
estadd scalar OCSD=r(sd)


keep update_comp tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem 
tempfile temp_emp
save `temp_emp'

********************************EMPLOYEE'S LAWYER*******************************
********************************************************************************

use "$sharelatex\DB\pilot_casefiles_wod.dta", clear	
duplicates drop folio, force
merge 1:m folio using  "$sharelatex/Raw/Append Encuesta Inicial Representante Actor.dta" , keep(2 3) nogen
merge m:m folio using "$sharelatex/Raw/Merge_Representante_Actor_OC.dta", keep(2 3) nogen
merge m:m folio using "$sharelatex/DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
drop _merge



duplicates drop folio tratamientoqueles secon, force
drop if tratamientoquelestoco==0


*Outliers
xtile perc=RA_5_5, nq(100)
drop if perc>=`t1'

*Measure of update in beliefs:  |P-E_e|/|P-E_b|
gen update_comp=abs((ES_1_4-comp_esp)/(RA_5_5-comp_esp))


*Keep same sample as in relative updating
gen rel=(ES_1_4-RA_5_5)/(RA_5_5)


*Outliers
xtile perc_up=rel, nq(100)
drop if perc_up>=`t2'

*Sample conditioning on overconfident
keep if RA_5_5>comp_esp


/***********************
       REGRESSIONS
************************/


eststo: reg  c.update_comp ///
	i.tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem  ///
	, robust
estadd scalar Erre=e(r2)
qui su update_comp if e(sample)
estadd scalar OCMean=r(mean)
estadd scalar OCSD=r(sd)


keep update_comp tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem 
tempfile temp_emp_law
save `temp_emp_law'

********************************FIRM'S LAWYER*******************************
********************************************************************************

use "$sharelatex\DB\pilot_casefiles_wod.dta", clear	
duplicates drop folio, force
merge 1:m folio using  "$sharelatex/Raw/Append Encuesta Inicial Representante Demandado.dta" , keep(2 3) nogen
merge m:m folio using "$sharelatex/Raw/Merge_Representante_Demandado_OC.dta", keep(2 3) nogen
merge m:m folio using "$sharelatex/DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
drop _merge



duplicates drop folio tratamientoqueles secon, force
drop if tratamientoquelestoco==0


*Outliers
xtile perc=RD5_5, nq(100)
drop if perc>=`t1'

*Measure of update in beliefs:  |P-E_e|/|P-E_b|
gen update_comp=abs((ES_1_4-comp_esp)/(RD5_5-comp_esp))


*Keep same sample as in relative updating
gen rel=(ES_1_4-RD5_5)/(RD5_5)


*Outliers
xtile perc_up=rel, nq(100)
drop if perc_up>=`t2'

*Sample conditioning on overconfident
keep if RD5_5<comp_esp


/***********************
       REGRESSIONS
************************/


eststo: reg  c.update_comp ///
	i.tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem  ///
	, robust
estadd scalar Erre=e(r2)
qui su update_comp if e(sample)
estadd scalar OCMean=r(mean)
estadd scalar OCSD=r(sd)


keep update_comp tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem 
tempfile temp_fir_law
save `temp_fir_law'

*************************

**************************************APPEND************************************


use `temp_emp', clear
append using `temp_emp_law'
append using `temp_fir_law'


/***********************
       REGRESSIONS
************************/


eststo: reg  c.update_comp ///
	i.tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem  ///
	, robust
estadd scalar Erre=e(r2)
qui su update_comp if e(sample)
estadd scalar OCMean=r(mean)
estadd scalar OCSD=r(sd)



********************************************************************************
********************************************************************************
*								Relative Updating
********************************************************************************
********************************************************************************



*************************************EMPLOYEE***********************************
********************************************************************************

use "$sharelatex\DB\pilot_casefiles_wod.dta", clear
duplicates drop folio, force	
merge 1:1 folio using  "$sharelatex/Raw/Append Encuesta Inicial Actor.dta" , keep(2 3) nogen
merge 1:1 folio using "$sharelatex/Raw/Merge_Actor_OC.dta", keep(2 3) nogen
merge 1:m folio using "$sharelatex/DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
drop _merge



duplicates drop folio tratamientoqueles secon, force
drop if tratamientoquelestoco==0


*Outliers
xtile perc=A_5_5, nq(100)
drop if perc>=`t1'

*Measure of update in beliefs:  (E_e-E_b)/E_b
gen update_comp=(ES_1_4-A_5_5)/(A_5_5)


*Outliers
xtile perc_up=update_comp, nq(100)
drop if perc_up>=`t2'

*Sample conditioning on overconfident
keep if A_5_5>comp_esp


/***********************
       REGRESSIONS
************************/


eststo: reg  c.update_comp ///
	i.tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem  ///
	i.A_7_3 i.A_1_2 i.A_6_1 , robust
estadd scalar Erre=e(r2)
qui su update_comp if e(sample)
estadd scalar OCMean=r(mean)
estadd scalar OCSD=r(sd)


keep update_comp tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem 
tempfile temp_emp
save `temp_emp'


********************************EMPLOYEE'S LAWYER*******************************
********************************************************************************

use "$sharelatex\DB\pilot_casefiles_wod.dta", clear	
duplicates drop folio, force
merge 1:m folio using  "$sharelatex/Raw/Append Encuesta Inicial Representante Actor.dta" , keep(2 3) nogen
merge m:m folio using "$sharelatex/Raw/Merge_Representante_Actor_OC.dta", keep(2 3) nogen
merge m:m folio using "$sharelatex/DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
drop _merge



duplicates drop folio tratamientoqueles secon, force
drop if tratamientoquelestoco==0


*Outliers
xtile perc=RA_5_5, nq(100)
drop if perc>=`t1'

*Measure of update in beliefs:  (E_e-E_b)/E_b
gen update_comp=(ES_1_4-RA_5_5)/(RA_5_5)


*Outliers
xtile perc_up=update_comp, nq(100)
drop if perc_up>=`t2'


*Sample conditioning on overconfident
keep if RA_5_5>comp_esp

/***********************
       REGRESSIONS
************************/


eststo: reg  c.update_comp ///
	i.tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem  ///
	, robust
estadd scalar Erre=e(r2)
qui su update_comp if e(sample)
estadd scalar OCMean=r(mean)
estadd scalar OCSD=r(sd)


keep update_comp tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem 
tempfile temp_emp_law
save `temp_emp_law'


********************************FIRM'S LAWYER*******************************
********************************************************************************

use "$sharelatex\DB\pilot_casefiles_wod.dta", clear	
duplicates drop folio, force
merge 1:m folio using  "$sharelatex/Raw/Append Encuesta Inicial Representante Demandado.dta" , keep(2 3) nogen
merge m:m folio using "$sharelatex/Raw/Merge_Representante_Demandado_OC.dta", keep(2 3) nogen
merge m:m folio using "$sharelatex/DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
drop _merge



duplicates drop folio tratamientoqueles secon, force
drop if tratamientoquelestoco==0


*Outliers
xtile perc=RD5_5, nq(100)
drop if perc>=`t1'

*Measure of update in beliefs:  (E_e-E_b)/E_b
gen update_comp=(ES_1_4-RD5_5)/(RD5_5)


*Outliers
xtile perc_up=update_comp, nq(100)
drop if perc_up>=`t2'


*Sample conditioning on overconfident
keep if RD5_5<comp_esp


/***********************
       REGRESSIONS
************************/


eststo: reg  c.update_comp ///
	i.tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem  ///
	, robust
estadd scalar Erre=e(r2)
qui su update_comp if e(sample)
estadd scalar OCMean=r(mean)
estadd scalar OCSD=r(sd)


keep update_comp tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem 
tempfile temp_fir_law
save `temp_fir_law'


*************************

**************************************APPEND************************************


use `temp_emp', clear
append using `temp_emp_law'
append using `temp_fir_law'


/***********************
       REGRESSIONS
************************/


eststo: reg  c.update_comp ///
	i.tratamientoqueles gen trabajador_base c_antiguedad salario_diario horas_sem  ///
	, robust
estadd scalar Erre=e(r2)
qui su update_comp if e(sample)
estadd scalar OCMean=r(mean)
estadd scalar OCSD=r(sd)






*************************
*************************
*************************
*************************


esttab using "$sharelatex\Tables\reg_results\update_reg_theta_rel_oc.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2)  ///
	scalars("Erre R-squared" "OCMean OC_Mean" "OCSD OCSD" ) replace 
