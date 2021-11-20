use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment
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
by junta exp anio: gen renglon2 = _n
keep if renglon2==1

ren (exp treatment) (expediente tratamientoquelestoco)

tempfile selectedCasefiles
save `selectedCasefiles'

*Generation of time/risk preference panel dataset with MxFLS and Phase1 data
********************************************************************************

use "./Raw/Append Encuesta Inicial Representante Actor.dta" , clear
merge m:1 folio using ".\DB\pilot_casefiles_wod.dta", nogen keep(1 3)
merge m:1 junta expediente anio using `selectedCasefiles', nogen keep(3) keepusing(junta expediente anio)

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


use "./Raw/Append Encuesta Inicial Representante Demandado.dta" , clear
merge m:1 folio using ".\DB\pilot_casefiles_wod.dta", nogen keep(1 3)
merge m:1 junta expediente anio using `selectedCasefiles', nogen keep(3) keepusing(junta expediente anio)

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



use "./Raw/Append Encuesta Inicial Actor.dta" , clear
merge 1:1 folio using ".\DB\pilot_casefiles_wod.dta", nogen keep(1 3)
merge m:1 junta expediente anio using `selectedCasefiles', nogen keep(3) keepusing(junta expediente anio)

*Cleaning

*Age
gen age=(date(c(current_date),"DMY")-A_1_1)/365
replace age=year(date(c(current_date),"DMY"))-añonac if missing(age)

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
	
append using ".\DB\mxfls.dta"
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
	
save ".\DB\time_pref.dta", replace

