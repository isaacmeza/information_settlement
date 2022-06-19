
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	
* Author: Isaac M 
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- 
* Files created:  

* Purpose:  This Figure shows the distribution of amounts predicted by the calculator for treatment and control cases ending in settlement.

*******************************************************************************/
*/


use ".\DB\scaleup_operation.dta", clear
rename año anio
rename expediente exp
merge m:1 junta exp anio using ".\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)
merge m:1 junta exp anio using ".\DB\scaleup_predictions.dta", nogen keep(1 3)

*Notified casefiles
keep if notificado==1

*Homologation
gen treatment=.
replace treatment=2 if dia_tratamiento==1
replace treatment=1 if dia_tratamiento==0
rename convenio seconcilio
rename convenio_seg_2m convenio_2m 
rename convenio_seg_5m convenio_5m
gen fecha=date(fecha_lista,"YMD")
gen fecha_filing=date(fecha_demanda, "YMD")
format fecha fecha_filing %td

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha_filing treatment p_actor abogado_pub ///
trabajador_base liq_total_convenio liq_total_laudo numActores liq_total_laudo_avg

gen phase=2
tempfile p2
save `p2', replace

use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

gen fecha_filing=date(fecha_demanda, "YMD")
format  fecha_filing %td

gen liq_total_laudo =  liq_laudopos 

ren liq_convenio liq_total_convenio
keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha_filing treatment p_actor abogado_pub ///
trabajador_base liq_total_convenio liq_total_laudo numActores comp_esp

append using `p2'
replace phase=1 if missing(phase)

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
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

********************************************************************************
merge 1:1 junta exp anio using ".\DB\seguimiento_m5m.dta", keep(1 3)
replace cant_convenio = cant_convenio_exp if missing(cant_convenio)
replace cant_convenio = cant_convenio_ofirec if missing(cant_convenio)
replace cant_convenio = 0 if modo_termino_expediente == 6 & missing(cant_convenio)
merge 1:1 junta exp anio using ".\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)

merge 1:1 junta exp anio using ".\DB\missingPredictionsP1_wod", gen(_mMissingPreds) keep(1 3)

/*
--------------+-----------------------------------
1)           AG |         18        5.70        5.70
2)     CONTINUA |         98       31.01       36.71
3)     CONVENIO |        130       41.14       77.85
4) DESISTIMIENTO |          5        1.58       79.43
5) INCOMPETENCIA |          5        1.58       81.01
6)        LAUDO |         60       18.99      100.00
--------------+-----------------------------------
*/


gen fechaTerminoAux = date("$S_DATE", "DMY")
format fechaTerminoAux


replace modoTermino = modo_termino_expediente if missing(modoTermino)
replace modoTermino = 2 if missing(modoTermino)



#delimit ;
*Graph only lower 99%;
twoway (kdensity comp_esp if treatment==2   & modoTermino==3 ,  lwidth(medthick) lpattern(solid) color(black)) ||
		(kdensity comp_esp if treatment==1  & modoTermino==3 , lpattern(dash) lcolor(gs10) lwidth(medthick)), 
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("Value of the case")  ytitle("kdensity")
		scheme(s2mono) graphregion(color(white));
#delimit cr
graph export "./Figures/pdf_valordecaso.pdf", replace 


*cumulative distribution 

*ECDF
cumul comp_esp if  treatment==2 & modoTermino==3, gen(fc_cdf_1)
cumul comp_esp if  treatment==1 & modoTermino==3, gen(fc_cdf_0)
*Function to obtain significance difference region
distcomp comp_esp  , by(treatment) alpha(0.1) p 
mat ranges = r(rej_ranges)

*To plot both ECDF
stack  fc_cdf_1 comp_esp  fc_cdf_0 comp_esp, into(c fc) ///
	wide clear
keep if !missing(fc_cdf_1) | !missing(fc_cdf_0)
tempfile temp
save `temp'
*Get difference of the CDF
duplicates drop fc _stack, force
keep c fc _stack
reshape wide c, i(fc) j(_stack)
*Interpolate
ipolate c2 fc, gen(c2_i) epolate
ipolate c1 fc, gen(c1_i) epolate
gen dif=c2_i-c1_i
tempfile temp_dif
save `temp_dif'
use `temp', clear
merge m:1 fc using `temp_dif', nogen 
*Signifficant region
gen sig_range = .
local rr = rowsof(ranges)
forvalues i=1/`rr' {
	local lo = ranges[`i',1]
	local hi = ranges[`i',2]
	if !missing(`lo') {
	replace sig_range = 0.01 if inrange(fc,`lo',`hi')
	}
	}
*Plot
su fc, d	
twoway (line fc_cdf_1 fc_cdf_0 dif fc if fc<=`r(p95)', ///
	sort ylab(, grid)) ///
	(scatter sig_range fc if fc<=`r(p95)', msymbol(Oh) msize(tiny) lcolor(navy)), ///
	ytitle("") xtitle("Pesos") ///
	legend(order(1 "Treatment" 2 "Control" 3 "T-C") rows(1)) xtitle("Value of the case") scheme(s2mono) graphregion(color(white)) 

graph export "./Figures/cdf_valordecaso.pdf", replace 