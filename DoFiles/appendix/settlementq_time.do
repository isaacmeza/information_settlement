/*Table C3: Settlements against duration - Historical Data*/
/*
This table focuses on the sample of cases from the historical data (HD) 
that settled at any point in time (3080 casesout of 5005)
*/


******** 
local tasa=50			/* Interest rate (annually) */

*********************************HD DATA****************************************
use  "$sharelatex\DB\scaleup_hd.dta", clear

*Settlement cases
keep if modo_termino==1

*Dates
gen fechadem=date(fecha_demanda,"YMD")
gen fechater=date(fecha_termino,"YMD")


*Homologation
rename fechadem fecha
gen mes=month(fecha)
cap drop anio
gen anio=year(fecha)

*DEFLATION

gen months=(fechater-fecha)/30
xtile quintil_month=months, nq(5)

*Constant prices (June 2016)
gen liq_total_discount=(liq_total_tope/(1+(100*((`tasa'/100+1)^(1/12)-1))/100)^months)


	
***************************************************	
*********			REGRESSIONS          **********
***************************************************
***************************************************

	
xtile perc=liq_total_tope, nq(100)


eststo clear

foreach var of varlist liq_total_tope  liq_total_discount comp_convenio_p2 {


eststo: reg `var'  c.months   ///
/*Entitlement by law*/       min_ley ///
/*Basic variable contrlols*/ abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem , r

eststo: reg `var' i.quintil_month  ///
/*Entitlement by law*/       min_ley ///
/*Basic variable contrlols*/ abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem, r


}



*************************
	esttab using "$sharelatex/Tables/reg_results/settlementq_time.csv", se star(* 0.1 ** 0.05 *** 0.01)   r2(a2)  ///
	 replace 

	