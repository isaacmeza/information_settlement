/*Figure 2. :  Distribution of Amount Collected, by Type of Lawyer*/
/*
This Figure uses the historical data to show cumulative distributions and 
densities of the amount received in the historical data.
*/

******** Global variables 
global int=3.43			/* Interest rate */
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */
global pago_pri1=2000	/* Payment to private lawyer */
global pago_pri2=1000	/* Payment to private lawyer */
global pago_pri3=500	/* Payment to private lawyer */


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
gen npv_pri1=(liq_total_tope/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri1} if abogado_pub==0
gen npv_pri2=(liq_total_tope/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri2} if abogado_pub==0
gen npv_pri3=(liq_total_tope/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri3} if abogado_pub==0
gen npv_pub=(liq_total_tope/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1


*Homologation
rename fecha_ter fecha
cap drop anio 
cap drop mes
gen mes=month(fecha)
gen anio=year(fecha)

merge m:1 mes anio using "./Raw/inpc.dta", nogen keep(1 3) //indice nacional de precios

*NPV at constant prices (June 2016)
*foreach var of varlist npv_* {
*	replace `var'=(`var'/inpc)*118.901
*	}
*Trimming
foreach var of varlist npv_* {
	cap drop perc
	xtile perc=`var', nq(100)
	replace `var'=. if perc>=95
	}

********************************************************************************


*Thousand pesos
foreach var of varlist npv_* {
	replace `var'=`var'/1000
	}
	
*CDF
foreach var of varlist npv_* {
	cumul `var', equal gen(cdf_`var')
	}
	


twoway (line cdf_npv_pub npv_pub, sort lwidth(medthick) lpattern(solid) color(black)) ///
		(line cdf_npv_pri1 npv_pri1, sort lwidth(medthick) lpattern(dash) color(gs6)) ///
		(line cdf_npv_pri2 npv_pri2, sort lwidth(medthick) lpattern(dot) color(gs9)) ///
		(line cdf_npv_pri3 npv_pri3, sort lwidth(medthick) lpattern(dash_dot) color(gs12)) , ///
		scheme(s2mono) graphregion(color(white)) xtitle("") ytitle("Percent") ///
		legend(off) ///
		name(cdf, replace) title("CDF")


twoway (kdensity npv_pub, xline(0, lpattern(dash) lcolor(gs10) lwidth(medthick)) lwidth(medthick) lpattern(solid) color(black)) ///
		(kdensity npv_pri1, lwidth(medthick) lpattern(dash) color(gs6)) ///
		(kdensity npv_pri2, lwidth(medthick) lpattern(dot) color(gs9)) ///
		(kdensity npv_pri3, lwidth(medthick) lpattern(dash_dot) color(gs12)) , ///
		scheme(s2mono) graphregion(color(white)) xtitle("NPV") ytitle("Density") ///
		legend(order(1 "Pub" 2 "Pri 2000" 3 "Pri 1000" 4 "Pri 500") rows(1))  ///
		name(pdf, replace) title("PDF")
		

graph combine cdf pdf, xcommon cols(1) scheme(s2mono) graphregion(color(white))		
graph export ".\Figures\cdf_pdf_value_claims.pdf", replace 
 


		
		
