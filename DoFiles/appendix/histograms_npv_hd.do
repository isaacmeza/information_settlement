/*Figure C1: Compensation histograms - Historical Data*/
/*
Distribution of compensation in present value at the time of suing
*/


******** Global variables 
global int=3.43			/* Interest rate */
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */
global pago_pri=2000	/* Payment to private lawyer */


*********************************HD DATA****************************************
use  "$sharelatex\DB\scaleup_hd.dta", clear

*Dates
gen fechadem=date(fecha_demanda,"YMD")
gen fechater=date(fecha_termino,"YMD")

*NPV
gen months=(fechater-fechadem)/30
gen npv=.
replace npv=(liq_total_tope/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(liq_total_tope/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1
drop if npv==.

gen mes=month(fechadem)


merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

*NPV at constant prices (June 2016)
replace npv=(npv/inpc)*118.901

xtile perc=npv, nq(100)
replace npv=. if perc>=98


*************
***Histograms
*************


hist  npv if modo_termino==1, percent lwidth(thick) scheme(s2mono) graphregion(color(none)) ///
	xtitle("Compensation") title("Settlement") xlabel(0(25000)100000) w(5000) name(fd, replace)
	
twoway (hist npv if modo_termino==3, percent lwidth(thick) w(5000)) ///
		, scheme(s2mono) graphregion(color(none)) ///
	xtitle("Compensation") title("Court Ruling") xlabel(0(25000)100000) ///
	 name(dd, replace)
	
graph combine fd dd, xcommon cols(1) graphregion(color(white)) scheme(s2mono)
graph export "$sharelatex\Figuras\hist_npv_hd.pdf", replace 
 	
