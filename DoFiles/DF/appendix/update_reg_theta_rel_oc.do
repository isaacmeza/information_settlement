/*Table C16: Treatment generated updating in probability - Phase 1 - Panel (a)*/
/*
Regressions of overconfidence (AMOUNT) on case characteristics (exogenous) 
*/

***
*Trimming parameters

local t1=99 /*Trimming survey variable*/
local t2=95 /*Trimming update variable*/

********************************************************************************
* Correct observations

use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

gen fechaDemanda = fecha

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub numActores

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
ren exp expediente
keep junta exp anio

tempfile correctSample
save `correctSample'
********************************************************************************
********************************************************************************
*								Theta Updating
********************************************************************************
********************************************************************************


*************************************EMPLOYEE***********************************
********************************************************************************

merge 1:1 junta exp anio using ".\DB\pilot_casefiles_wod.dta", keep(3) nogen
duplicates drop folio, force
merge 1:1 folio using  "./Raw/Append Encuesta Inicial Actor.dta" , keep(2 3) nogen
merge 1:1 folio using "./Raw/Merge_Actor_OC.dta", keep(2 3) nogen
merge 1:m folio using "./DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
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

use `correctSample', clear
merge 1:1 junta exp anio using ".\DB\pilot_casefiles_wod.dta", keep(3) nogen
duplicates drop folio, force
merge 1:m folio using  "./Raw/Append Encuesta Inicial Representante Actor.dta" , keep(2 3) nogen
merge m:m folio using "./Raw/Merge_Representante_Actor_OC.dta", keep(2 3) nogen
merge m:m folio using "./DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
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

use `correctSample', clear
merge 1:1 junta exp anio using ".\DB\pilot_casefiles_wod.dta", keep(3) nogen
duplicates drop folio, force
merge 1:m folio using  "./Raw/Append Encuesta Inicial Representante Demandado.dta" , keep(2 3) nogen
merge m:m folio using "./Raw/Merge_Representante_Demandado_OC.dta", keep(2 3) nogen
merge m:m folio using "./DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
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

use `correctSample', clear
merge 1:1 junta exp anio using ".\DB\pilot_casefiles_wod.dta", keep(3) nogen
duplicates drop folio, force	
merge 1:1 folio using  "./Raw/Append Encuesta Inicial Actor.dta" , keep(2 3) nogen
merge 1:1 folio using "./Raw/Merge_Actor_OC.dta", keep(2 3) nogen
merge 1:m folio using "./DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
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

use `correctSample', clear
merge 1:1 junta exp anio using ".\DB\pilot_casefiles_wod.dta", keep(3) nogen
duplicates drop folio, force
merge 1:m folio using  "./Raw/Append Encuesta Inicial Representante Actor.dta" , keep(2 3) nogen
merge m:m folio using "./Raw/Merge_Representante_Actor_OC.dta", keep(2 3) nogen
merge m:m folio using "./DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
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

use `correctSample', clear
merge 1:1 junta exp anio using ".\DB\pilot_casefiles_wod.dta", keep(3) nogen
duplicates drop folio, force
merge 1:m folio using  "./Raw/Append Encuesta Inicial Representante Demandado.dta" , keep(2 3) nogen
merge m:m folio using "./Raw/Merge_Representante_Demandado_OC.dta", keep(2 3) nogen
merge m:m folio using "./DB/pilot_operation.dta", keep(1 3) keepusing(tratamientoquelestoco seconcilio p_actor)
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


esttab using ".\Tables\reg_results\update_reg_theta_rel_oc.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2)  ///
	scalars("Erre R-squared" "OCMean OC_Mean" "OCSD OCSD" ) replace 
