
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	
* Author: Sergio Lopez
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- 
* Files created:  

* Purpose: Summary statistics table for Outcomes, Basic and Strategic variables for the 3 pilots

*******************************************************************************/
*/

********************************************************************************
	*DB: Calculator:5005
use  ".\DB\scaleup_hd.dta", clear


*Variables
	*We define win as liq_total>0
	gen win=(liq_total>0)
	*Salario diario
	destring salario_diario, force replace
	*Conciliation
	gen con=(modo_termino==1)
	*Court ruling
	gen cr_0=(modo_termino==3 & liq_total==0)
	gen cr_m=(modo_termino==3 & liq_total>0)
	foreach var in liq_total c_tota{
		replace `var' = `var'/1000
		} 
	

*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "./paper/Tables/SS.xlsx", sheet("PanelA") modify
foreach var of varlist win liq_total c_total con cr_0 cr_m duracion  ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")
	*Obs
	 
	qui putexcel B`n'=(r(N))  
	*Mean
	 
	local mu=round(r(mean),0.01)
	qui putexcel C`n'=("`mu'") 		
	*Std Dev
	 
	local std=round(r(sd),0.01)
	local sd="(`std')"
	
	qui putexcel C`m'=("`sd'") 		
	*Range
	local range="[`r(min)', `r(max)']"
	 
	qui putexcel D`n'=("`range'")		

	local n=`n'+2
	local m=`m'+2
	}

	

*PANEL B (B⴩cas)
local n=5
local m=6
putexcel set  "./paper/Tables/SS.xlsx", sheet("PanelB") modify
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")
	*Obs
	
	qui putexcel B`n'=(r(N))		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel C`n'=("`mu'")			
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel C`m'=("`sd'")
		
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel D`n'=("`range'")
		
	local n=`n'+2
	local m=`m'+2
	}
	

	

********************************************************************************
	*DB: Subcourt 7 
keep if junta==7
	

 
*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "./paper/Tables/SS.xlsx", sheet("PanelA") modify	
foreach var of varlist win liq_total c_total con cr_0 cr_m duracion  ///
	{
	qui su `var'

	*Obs
	qui putexcel H`n'=(r(N))  
		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel I`n'=("`mu'") 		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel I`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel J`n'=("`range'")		
		
	local n=`n'+2
	local m=`m'+2
	}


	
*PANEL B (B⴩cas)
local n=5
local m=6
putexcel set "./paper/Tables/SS.xlsx", sheet("PanelB") modify		
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'

	*Obs
	qui putexcel H`n'=(r(N))
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel I`n'=("`mu'")  		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel I`m'=("`sd'")  		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel J`n'=("`range'")	
		
	local n=`n'+2
	local m=`m'+2
	}
	


	

********************************************************************************
	*DB: March Pilot
use ".\DB\pilot_operation.dta", clear
drop if tratamientoquelestoco==0
merge m:1 expediente anio using ".\DB\pilot_casefiles_wod.dta", keep(1 3)
ren expediente exp
merge m:1 exp anio using ".\DB\inicialesP1Faltantes_wod.dta", keep(1 3) gen(_mNuevasIniciales) force

foreach var of varlist abogado_pub gen trabajador_base salario_diario horas_sem   ///
	{
	replace `var' = `var'N if missing(`var')
	}
foreach var in liq_total c_tota{
		replace `var' = `var'/1000
		} 
//drop if tratamientoquelestoco==3
replace junta=7 if missing(junta)
rename tratamientoquelestoco treatment

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
********************************************************************************
*Drop conciliator observations
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon2 = _n
keep if renglon2==1

*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "./paper/Tables/SS.xlsx", sheet("PanelA") modify
foreach var of varlist win liq_total c_total con cr_0 cr_m  ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")
	*Obs
	
	qui putexcel E`n'=(r(N))  		
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel F`n'=("`mu'") 		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel F`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel G`n'=("`range'")  
		
	local n=`n'+2
	local m=`m'+2
	}

*PANEL B (B⴩cas)
local n=5
local m=6
putexcel set "./paper/Tables/SS.xlsx", sheet("PanelB") modify		
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	
	*Obs
	qui putexcel E`n'=(r(N))
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel F`n'=("`mu'")  		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel F`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel G`n'=("`range'") 
	
	local n=`n'+2
	local m=`m'+2
	}
	


********************************************************************************
	*DB: ScaleUp
use ".\DB\scaleup_operation.dta", clear
rename año anio
rename expediente exp
merge m:1 junta exp anio using ".\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

*Notified casefiles
keep if notificado==1

sort junta exp anio fecha_treat
by junta exp anio: gen renglon = _n
keep if renglon==1

*Variable homologation
rename convenio con


*Generate missing variables
foreach var in ///
	win liq_total c_total con cr_0 cr_m  ///
	abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	reinst indem sal_caidos prima_antig prima_vac hextra ///
	rec20 prima_dom desc_sem desc_ob sarimssinf utilidades nulidad  ///
	vac ag codem ///
	{
		capture confirm variable  `var'
		if !_rc {
               qui di ""
               }
        else {
               gen `var'=.
               }
	}	



*PANEL A (Outcomes)
local n=5
local m=6
foreach var in c_total{
		replace `var' = `var'/1000
		} 
putexcel set "./paper/Tables/SS.xlsx", sheet("PanelA") modify
foreach var of varlist win liq_total c_total con cr_0 cr_m  ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")
	*Obs
	
	qui putexcel K`n'=(r(N)) 		
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel L`n'=("`mu'") 		
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel L`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel M`n'=("`range'")	
		
	local n=`n'+2
	local m=`m'+2
	}


*PANEL B (B⴩cas)
local n=5
local m=6
putexcel set "./paper/Tables/SS.xlsx", sheet("PanelB") modify		
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	
	*Obs
	qui putexcel K`n'=(r(N))
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel L`n'=("`mu'") 		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel L`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel M`n'=("`range'")
		
	local n=`n'+2
	local m=`m'+2
	}
	

********************************************************************************




*DB: Pilot3

use ".\DB\P3Outcomes.dta", clear
*/
merge m:1 id_actor using ".\DB\treatment_data.dta", keep(2 3) nogen
merge m:1 id_actor using ".\DB\survey_data_2m.dta", nogen keep(1 3)
drop if missing(main_treatment) | main_treatment == 3

*Variable homologation

gen convenio = MODODETERMINO == "CONVENIO"
gen con = convenio ==1 | conflicto_arreglado == 1

ren (demando_con_abogado_publico mujer antiguedad)(abogado_pub gen c_antiguedad)
replace abogado_pub= 0 if entablo_demanda==1 & missing(abogado_pub)
*Generate missing variables
foreach var in ///
	win liq_total c_total con cr_0 cr_m  ///
	abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	reinst indem sal_caidos prima_antig prima_vac hextra ///
	rec20 prima_dom desc_sem desc_ob sarimssinf utilidades nulidad  ///
	vac ag codem ///
	{
		capture confirm variable  `var'
		if !_rc {
               qui di ""
               }
        else {
               gen `var'=.
               }
	}	


*PANEL A (Outcomes)
local n=5
local m=6
putexcel set "./paper/Tables/SS.xlsx", sheet("PanelA") modify
foreach var of varlist win liq_total c_total con cr_0 cr_m  ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")
	*Obs
	
	qui putexcel N`n'=(r(N)) 		
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel O`n'=("`mu'")		
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel O`m'=("`sd'") 		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel P`n'=("`range'")		
		
	local n=`n'+2
	local m=`m'+2
	}


*PANEL B (B⴩cas)
local n=5
local m=6
putexcel set "./paper/Tables/SS.xlsx", sheet("PanelB") modify		
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	
	*Obs
	qui putexcel N`n'=(r(N))
	*Mean
	
	local mu=round(r(mean),0.01)
	qui putexcel O`n'=("`mu'")  		
	*Std Dev
	
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel O`m'=("`sd'")  		
	*Range
	
	local range="[`r(min)', `r(max)']"
	qui putexcel P`n'=("`range'") 
	
	local n=`n'+2
	local m=`m'+2
	}
	

	

		
