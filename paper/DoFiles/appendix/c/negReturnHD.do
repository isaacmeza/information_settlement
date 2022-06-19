/*Table C10:  Balance of casefiles having negative recovery amount.*/
/*
There are many small claims that should not be sueing.
Expected compensation in npv distributions
*/

******** Global variables 
global int=3.43			/* Interest rate */
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */
global pago_pri=2000	/* Payment to private lawyer */


*********************************HD DATA****************************************
use  ".\DB\scaleup_hd.dta", clear


*Outliers
cap drop perc
xtile perc=liq_total_tope, nq(100)
replace liq_total_tope=. if perc>=95


*Date 
gen fecha_ter=date(fecha_termino, "DMY")
gen fechadem=date(fecha_demanda, "DMY")


*NPV
gen months=(fecha_ter-fechadem)/30
gen npv_pri=(liq_total_tope/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
gen npv_pub=(liq_total_tope/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1


********************************************************************************

*Integrate npv
egen npv=rowtotal(npv_*)

gen negative_returners=(npv<0) if !missing(npv) 
keep if abogado_pub==0

******************************
*		REGRESSIONS			 *
******************************


local bvc gen trabajador_base c_antiguedad salario_diario horas_sem

	eststo clear
	foreach var of varlist `bvc' {	
		eststo: reg negative_returners `var'  i.junta , robust
		estadd scalar Erre=e(r2)	
		estadd scalar F_stat=e(F)
		estadd local Junta="YES"
		}	
	
	*************************
	esttab using "./Tables/reg_results/negative_returners_balance_changed.csv", se star(* 0.1 ** 0.05 *** 0.01) b(3) ///
	scalars("Erre R-squared" "F_stat F_stat" "Junta Court dummies") drop(*.junta) replace 

		
