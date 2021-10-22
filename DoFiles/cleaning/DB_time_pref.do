*Generation of time/risk preference panel dataset with MxFLS and Phase1 data
********************************************************************************

use "$sharelatex/Raw/Append Encuesta Inicial Representante Actor.dta" , clear
merge m:1 folio using "$sharelatex\DB\pilot_casefiles_wod.dta", nogen keep(1 3)

*Time Preferences
gen beta_monthly=.
replace beta_monthly=1 if RA_6_2_1==2 & RA_6_2_2==. 
replace beta_monthly=10/12 if RA_6_2_1==1 & RA_6_2_2==2 & RA_6_2_3==.
replace beta_monthly=10/15 if RA_6_2_1==1 & RA_6_2_2==1 & RA_6_2_3==2 & RA_6_2_4==.
replace beta_monthly=10/20 if RA_6_2_1==1 & RA_6_2_2==1 & RA_6_2_3==1 & RA_6_2_4==2 & RA_6_2_5==.
replace beta_monthly=10/30 if RA_6_2_1==1 & RA_6_2_2==1 & RA_6_2_3==1 & RA_6_2_4==1 & !missing(RA_6_2_5)

*Risk preference
gen risk=.
replace risk=1 if RA_6_1_1==1 & RA_6_2==1 & RA_6_3==1
replace risk=2 if RA_6_1_1==1 & RA_6_2==1 & RA_6_3==2
replace risk=3 if RA_6_1_1==1 & RA_6_2==2 
replace risk=4 if RA_6_1_1==2 

replace risk=1 if RA_6_1==1 & RA_6_2==1 & RA_6_3==1
replace risk=2 if RA_6_1==1 & RA_6_2==1 & RA_6_3==2
replace risk=3 if RA_6_1==1 & RA_6_2==2 
replace risk=4 if RA_6_1==2 



*Categorical party: Party=1 - employee lawyer
gen party=2

keep folio beta_monthly risk* party gen trabajador_base c_antiguedad salario_diario horas_sem
tempfile temp_2
save `temp_2'


use "$sharelatex/Raw/Append Encuesta Inicial Representante Demandado.dta" , clear
merge m:1 folio using "$sharelatex\DB\pilot_casefiles_wod.dta", nogen keep(1 3)

*Time Preferences
gen beta_monthly=.
replace beta_monthly=1 if RD6_2_1==2 & RD6_2_2==. 
replace beta_monthly=10/12 if RD6_2_1==1 & RD6_2_2==2 & RD6_2_3==.
replace beta_monthly=10/15 if RD6_2_1==1 & RD6_2_2==1 & RD6_2_3==2 & RD6_2_4==.
replace beta_monthly=10/20 if RD6_2_1==1 & RD6_2_2==1 & RD6_2_3==1 & RD6_2_4==2 & RD6_2_5==.
replace beta_monthly=10/30 if RD6_2_1==1 & RD6_2_2==1 & RD6_2_3==1 & RD6_2_4==1 & !missing(RD6_2_5)

*Risk preference
gen risk=.
replace risk=1 if RD6_1_1==1 & RD6_1_2==1 & RD6_1_3==1
replace risk=2 if RD6_1_1==1 & RD6_1_2==1 & RD6_1_3==2
replace risk=3 if RD6_1_1==1 & RD6_1_2==2 
replace risk=4 if RD6_1_1==2 


*Categorical party: Party=3 - firm lawyer
gen party=3

keep folio beta_monthly risk* party gen trabajador_base c_antiguedad salario_diario horas_sem
tempfile temp_3
save `temp_3'



use "$sharelatex/Raw/Append Encuesta Inicial Actor.dta" , clear
merge 1:1 folio using "$sharelatex\DB\pilot_casefiles_wod.dta", nogen keep(1 3)


*Cleaning

*Age
gen age=(date(c(current_date),"DMY")-A_1_1)/365
replace age=year(date(c(current_date),"DMY"))-aonac if missing(age)

rename A_3_1 numempleados

rename A_1_2 education

destring c_utilidades, replace force

*Time Preferences
gen beta_monthly=.
replace beta_monthly=1 if A_10_2_1==2 & A_10_2_2==. 
replace beta_monthly=10/12 if A_10_2_1==1 & A_10_2_2==2 & A_10_2_3==.
replace beta_monthly=10/15 if A_10_2_1==1 & A_10_2_2==1 & A_10_2_3==2 & A_10_2_4==.
replace beta_monthly=10/20 if A_10_2_1==1 & A_10_2_2==1 & A_10_2_3==1 & A_10_2_4==2 & A_10_2_5==.
replace beta_monthly=10/30 if A_10_2_1==1 & A_10_2_2==1 & A_10_2_3==1 & A_10_2_4==1 & !missing(A_10_2_5)

*Risk preference
gen risk=.
replace risk=1 if A_10_1_1==1 & A_10_1_2==1 & A_10_1_3==1
replace risk=2 if A_10_1_1==1 & A_10_1_2==1 & A_10_1_3==2
replace risk=3 if A_10_1_1==1 & A_10_1_2==2 
replace risk=4 if A_10_1_1==2 

gen beta_monthly_a=beta_monthly

keep   gen education  numempleados salario_diario  horas_sem ///
	trabajador_base sarimssinf age c_antiguedad c_aguinaldo c_utilidades c_vacaciones ///
	c_horasextra  giro beta_* risk* folio expediente anio
	
*Categorical party: Party=1 - employee
gen party=1

*Appending
append using `temp_2'
append using `temp_3'

*Identify Datasets
gen experiment=1
	
append using "$sharelatex\DB\mxfls.dta"
replace experiment=0 if missing(experiment)
replace fac_3b=1 if missing(fac_3b)
replace party=0 if missing(party)

label define party  0 "MxFLS" 1 "E" 2 "EL" 3 "FL"
label values party party
	
********************************************************************************
********************************************************************************

levelsof beta_monthly, local(levels) 
local i=1
foreach l of local levels {
	gen tp_`i'=(beta_monthly==`l') if !missing(beta_monthly)
	gen a_`i'=`l'
	local i=`i'+1
	}
	
save "$sharelatex\DB\time_pref.dta", replace

