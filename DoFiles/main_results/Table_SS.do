/*Table 1—:  Summary Statistics*/
/* Summary statistics table for Outcomes, Basic and Strategic variables for the 3 pilots */


********************************************************************************
	*DB: Calculator:5005
use  "$sharelatex\DB\scaleup_hd.dta", clear


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
	
 
*PANEL A (Outcomes)
local n=5
local m=6
foreach var of varlist win liq_total c_total con cr_0 cr_m duracion  ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify
	*Obs
	qui putexcel B`n'=(r(N))  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel C`n'=("`mu'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel C`m'=("`sd'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel D`n'=("`range'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
		
	local n=`n'+2
	local m=`m'+2
	}

	
*PANEL B (Básicas)
local n=5
local m=6
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify
	*Obs
	qui putexcel B`n'=(r(N))  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel C`n'=("`mu'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify			
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel C`m'=("`sd'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify			
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel D`n'=("`range'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify			
		
	local n=`n'+2
	local m=`m'+2
	}
	

	

********************************************************************************
	*DB: Subcourt 7 
keep if junta==7
	
 
*PANEL A (Outcomes)
local n=5
local m=6
foreach var of varlist win liq_total c_total con cr_0 cr_m duracion  ///
	{
	qui su `var'

	*Obs
	qui putexcel H`n'=(r(N))  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel I`n'=("`mu'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel I`m'=("`sd'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel J`n'=("`range'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
		
	local n=`n'+2
	local m=`m'+2
	}

	
*PANEL B (Básicas)
local n=5
local m=6
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'

	*Obs
	qui putexcel H`n'=(r(N))  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel I`n'=("`mu'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify			
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel I`m'=("`sd'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify			
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel J`n'=("`range'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify			
		
	local n=`n'+2
	local m=`m'+2
	}
	


	

********************************************************************************
	*DB: March Pilot
use "$sharelatex\DB\pilot_operation.dta", clear
merge m:1 expediente anio using "$sharelatex\DB\pilot_casefiles_wod.dta", keep(1 3) nogen


*PANEL A (Outcomes)
local n=5
local m=6
foreach var of varlist win liq_total c_total con cr_0 cr_m  ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify
	*Obs
	qui putexcel E`n'=(r(N))  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel F`n'=("`mu'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel F`m'=("`sd'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel G`n'=("`range'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
		
	local n=`n'+2
	local m=`m'+2
	}

	
*PANEL B (Básicas)
local n=5
local m=6
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	
	*Obs
	qui putexcel E`n'=(r(N))  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel F`n'=("`mu'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify			
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel F`m'=("`sd'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify			
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel G`n'=("`range'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify		
		
	local n=`n'+2
	local m=`m'+2
	}
	



	
	
********************************************************************************
	*DB: March Pilot merged with surveys (Table 1A)
use "$sharelatex\DB\pilot_casefiles_wod.dta", clear	

preserve
*Employee
merge m:1 folio using  "$sharelatex/Raw/Append Encuesta Inicial Actor.dta" , keep(2 3)
rename A_5_1 masprob_employee
replace masprob=masprob/100
rename A_5_5 dineromasprob_employee
rename A_5_8 tiempomasprob_employee

*Drop outlier
xtile perc=tiempomasprob_employee, nq(99)
replace tiempomasprob_employee=. if perc>=98

local n=5
local m=6
foreach var of varlist masprob dineromasprob tiempomasprob ///
	{

	qui su `var' if tipodeabogado!=.
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel C`n'=("`mu'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("SS_A") modify			
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel C`m'=("`sd'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("SS_A") modify		

	local n=`n'+2
	local m=`m'+2
	}

	*Obs
	qui su masprob if tipodeabogado!=.
	qui putexcel C11=("`r(N)'")  using "$sharelatex/Tables/SS.xlsx", ///
	sheet("SS_A") modify

restore

preserve
*Employee's Lawyer
merge m:m folio using  "$sharelatex/Raw/Append Encuesta Inicial Representante Actor.dta" , keep(2 3)
rename RA_5_1 masprob_law_emp
replace masprob=masprob/100
rename RA_5_5 dineromasprob_law_emp
rename RA_5_8 tiempomasprob_law_emp
	
local n=5
local m=6
foreach var of varlist masprob dineromasprob tiempomasprob ///
	{

	qui su `var' if tipodeabogado!=.
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel D`n'=("`mu'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("SS_A") modify			
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel D`m'=("`sd'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("SS_A") modify	
		
	local n=`n'+2
	local m=`m'+2
	}

	*Obs
	qui su masprob if tipodeabogado!=.
	qui putexcel D11=("`r(N)'")  using "$sharelatex/Tables/SS.xlsx", ///
	sheet("SS_A") modify
	
restore


preserve
*Firm's Lawyer
merge m:m folio using  "$sharelatex/Raw/Append Encuesta Inicial Representante Demandado.dta" , keep(2 3)
rename RD5_1_1 masprob_law_firm
replace masprob=masprob/100
rename RD5_5 dineromasprob_law_firm
rename RD5_8 tiempomasprob_law_emp

local n=5
local m=6
foreach var of varlist masprob dineromasprob tiempomasprob ///
	{

	qui su `var' if tipodeabogado!=.
	
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel E`n'=("`mu'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("SS_A") modify			
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel E`m'=("`sd'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("SS_A") modify	
		
	local n=`n'+2
	local m=`m'+2
	}

	*Obs
	qui su masprob if tipodeabogado!=.
	qui putexcel E11=("`r(N)'")  using "$sharelatex/Tables/SS.xlsx", ///
	sheet("SS_A") modify
	
restore


********************************************************************************
	*DB: ScaleUp
use "$scaleup\DB\scaleup_operation.dta", clear
*Merge with iniciales DB
keep if num_actores==1 
rename expediente exp
rename ao anio
duplicates drop  exp anio junta, force

merge 1:1 exp anio junta  using "$scaleup\DB\scaleup_casefiles_wod.dta", keep(3)


	
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
foreach var of varlist win liq_total c_total con cr_0 cr_m  ///
	{
	qui su `var'
	*Variable 
	qui putexcel A`n'=("`var'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify
	*Obs
	qui putexcel K`n'=(r(N))  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel L`n'=("`mu'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel L`m'=("`sd'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel M`n'=("`range'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelA") modify			
		
	local n=`n'+2
	local m=`m'+2
	}

	
*PANEL B (Básicas)
local n=5
local m=6
foreach var of varlist abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem   ///
	{
	qui su `var'
	
	*Obs
	qui putexcel K`n'=(r(N))  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify		
	*Mean
	local mu=round(r(mean),0.01)
	qui putexcel L`n'=("`mu'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify			
	*Std Dev
	local std=round(r(sd),0.01)
	local sd="(`std')"
	qui putexcel L`m'=("`sd'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify			
	*Range
	local range="[`r(min)', `r(max)']"
	qui putexcel M`n'=("`range'")  using "$sharelatex/Tables/SS.xlsx", ///
		sheet("PanelB") modify		
		
	local n=`n'+2
	local m=`m'+2
	}
	



	

		
