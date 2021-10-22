/*Figure C4: Discount rate against welfare effects*/
/*
The graph shows the ATE effect of Table 5 column (4),
when using different discounting annual interest rates. 
*/

******** Global variables 
global int=3.43			/* Interest rate */
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */
global pago_pri=2000	/* Payment to private lawyer */




forvalues tasa=1/100 {
di `tasa'
qui {
*******************************PILOT 1 DATA*************************************
use "$sharelatex/DB/pilot_operation.dta" , clear	
qui merge m:1 folio using "$sharelatex\DB\pilot_casefiles_wod.dta" , nogen  keep(1 3)

*Not in experiment
drop if tratamientoquelestoco==0


*Outliers
foreach var of varlist min_ley c1_cantidad_total_pagada_conveni comp_esp {
	cap drop perc
	xtile perc=`var', nq(100)
	replace `var'=. if perc>=95
	}
	
	
*********
*Settlement amount for 'treated' files
keep if (c1_se_concilio==1 & (calculator==1 | conciliator==1))


*Date imputation
replace fecha_con=fechadem if missing(fecha_con)
replace fechadem=fecha_con if missing(fechadem)

*NPV
gen months=(fecha_con-fechadem)/30
replace months=72 if months>=72 & !missing(months)
gen npv=.
replace npv=(c1_cantidad_total_pagada_conveni/(1+(100*((`tasa'/100+1)^(1/12)-1))/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(c1_cantidad_total_pagada_conveni/(1+(100*((`tasa'/100+1)^(1/12)-1))/100)^months)-${pago_pub} if abogado_pub==1
drop if npv==.

keep npv fecha_con ///
/*Calculator prediction*/  	 comp_esp ///
/*Entitlement by law*/       min_ley ///
/*Basic variable contrlols*/ abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
	months

*Homologation
rename fecha_con fecha
gen mes=month(fecha)
gen anio=year(fecha)

qui merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

*NO DEFLATION
*NPV at constant prices (June 2016)
*replace npv=(npv/inpc)*118.901

*Treated dummy
gen treat=1

*Save file to append it with HD data
tempfile temp_conc_p1
save `temp_conc_p1'

*******************************PILOT 2 DATA*************************************
use "$scaleup/DB/scaleup_operation.dta" , clear	
rename ao anio
rename expediente exp
qui merge m:1 junta exp anio using "$scaleup\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)
qui merge m:1 junta exp anio using "$scaleup\DB\scaleup_predictions.dta", nogen keep (1 3)


*Expected compensation
gen comp_esp=liq_total_laudo_avg


*Outliers
foreach var of varlist min_ley cantidad_convenio comp_esp {
	cap drop perc
	xtile perc=`var', nq(100)
	replace `var'=. if perc>=95
	}
	
	
	
*********
*Settlement amount for 'treated' files
keep if (convenio==1 & (dia_tratamiento==1))


*Date 
gen fecha_con=date(fecha_lista, "YMD")
gen fechadem=date(fecha_demanda, "YMD")

*NPV
gen months=(fecha_con-fechadem)/30
replace months=72 if months>=72 & !missing(months)
gen npv=.
replace npv=(cantidad_convenio/(1+(100*((`tasa'/100+1)^(1/12)-1))/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(cantidad_convenio/(1+(100*((`tasa'/100+1)^(1/12)-1))/100)^months)-${pago_pub} if abogado_pub==1



keep npv fecha_con ///
/*Calculator prediction*/  	 comp_esp ///
/*Entitlement by law*/       min_ley ///
/*Basic variable contrlols*/ abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
	months
		
*Homologation
rename fecha_con fecha
gen mes=month(fecha)
gen anio=year(fecha)

qui merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

*NO DEFLATION
*NPV at constant prices (June 2016)
*replace npv=(npv/inpc)*118.901

*Treated dummy
gen treat=1

*Save file to append it with HD data
tempfile temp_conc_p2
save `temp_conc_p2'

*********************************HD DATA****************************************
use  "$sharelatex\DB\scaleup_hd.dta", clear

*Compare with ONLY those who end case by COURT RULING
keep if modo_termino==3


*Dates
gen fechadem=date(fecha_demanda,"YMD")
gen fechater=date(fecha_termino,"YMD")

*NPV
gen months=(fechater-fechadem)/30
gen npv=.
replace npv=(liq_total_tope/(1+(100*((`tasa'/100+1)^(1/12)-1))/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(liq_total_tope/(1+(100*((`tasa'/100+1)^(1/12)-1))/100)^months)-${pago_pub} if abogado_pub==1
drop if npv==.


keep npv fechadem ///
/*Calculator prediction*/  	 comp_esp_p1 ///
/*Entitlement by law*/       min_ley ///
/*Basic variable contrlols*/ abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
	months

	
*Homologation
rename comp_esp_p1 comp_esp
rename fechadem fecha
gen mes=month(fecha)
gen anio=year(fecha)

qui merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

*NO DEFLATION
*NPV at constant prices (June 2016)
*replace npv=(npv/inpc)*118.901



append using `temp_conc_p1'
append using `temp_conc_p2'
replace treat=0 if missing(treat)


*Residuals 
qui reg npv comp_esp ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem, r
predict npv_hat
gen residual=npv-npv_hat

		
*Trimming
foreach var of varlist residual {
	capture drop perc
	xtile perc=`var', nq(100)
	}



********************************************************************************
*************************************NN Match***********************************
********************************************************************************

forvalues i=1/3 {
	gen ate_`i'=.
	gen rcap_lo_`i'=.
	gen rcap_hi_`i'=.
}

local j=1
	
******************************************

 qui teffects nnmatch (npv  ///
	/*Calculator prediction*/  	 comp_esp ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  gen trabajador_base c_antiguedad salario_diario horas_sem ///
					) (treat) if perc<95 , ///
	ematch(abogado_pub) biasadj( min_ley c_antiguedad salario_diario horas_sem)

mat def ate=e(b)
mat def var=e(V)
qui replace ate_1=ate[1,1] in `j'
qui replace rcap_lo_1=ate[1,1] - invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'
qui replace rcap_hi_1=ate[1,1] + invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'	
	
******************************************

qui teffects nnmatch (npv  ///
	/*Calculator prediction*/  	 comp_esp ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  gen trabajador_base c_antiguedad salario_diario horas_sem ///
					) (treat) if perc<97 , ///
	ematch(abogado_pub) biasadj( min_ley c_antiguedad salario_diario horas_sem)

mat def ate=e(b)
mat def var=e(V)
qui replace ate_2=ate[1,1] in `j'
qui replace rcap_lo_2=ate[1,1] - invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'
qui replace rcap_hi_2=ate[1,1] + invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'	
	
******************************************
		
qui teffects nnmatch (npv  ///
	/*Calculator prediction*/  	 comp_esp ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  gen trabajador_base c_antiguedad salario_diario horas_sem ///
					) (treat) if perc<99 , ///
	ematch(abogado_pub) biasadj( min_ley c_antiguedad salario_diario horas_sem)

mat def ate=e(b)
mat def var=e(V)
qui replace ate_3=ate[1,1] in `j'
qui replace rcap_lo_3=ate[1,1] - invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'
qui replace rcap_hi_3=ate[1,1] + invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'	

******************************************

tempfile temp_`tasa'
keep ate_* rcap_*
gen tasa=`tasa'
keep if _n==1
save `temp_`tasa''
}
}


*DB
use `temp_1', clear
forvalues tasa=2/100 {
append using `temp_`tasa''
}


gen zero=0

twoway rarea rcap_hi_3 rcap_lo_3 tasa, color(gs10)  || line ate_3 tasa, lwidth(thick) lpattern(solid) lcolor(black) || line zero tasa , lpattern(solid) lcolor(navy) ///
		, scheme(s2mono) graphregion(color(white))  ///
	xtitle("Interest rate (annually)") ytitle("ATE (Pesos)") legend(off) 	
graph export "$sharelatex\Figuras\atematch_intrate.pdf", replace 
	

