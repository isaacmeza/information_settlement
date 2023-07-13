
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	treatment_settlement_cases
* Author: Isaac M 
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- phase_1.dta
* Files created:  

* Purpose:  This Figure shows the distribution of amounts predicted by the calculator for treatment and control cases ending in settlement.

*******************************************************************************/
*/



use "./DB/phase_1.dta" , clear	
keep comp_esp treatment modoTermino


*******************************
* 		 	 PDF	    	  *
*******************************

*Graph only lower 99%;
twoway (kdensity comp_esp if treatment==2  & modoTermino==3 ,  lwidth(medthick) lpattern(solid) color(black)) ///
		(kdensity comp_esp if treatment==1 & modoTermino==3 , lpattern(dash) lcolor(gs10) lwidth(medthick)) ///
		, legend(lab(1 "Treatment") lab(2 "Control") pos(6) rows(1)) xtitle("Value of the case")  ytitle("kdensity") 
graph export "./Figures/pdf_valordecaso.tif", replace 



*******************************
* 		 	 CDF	    	  *
*******************************

*ECDF
cumul comp_esp if  treatment==2 & modoTermino==3, gen(fc_cdf_1)
cumul comp_esp if  treatment==1 & modoTermino==3, gen(fc_cdf_0)
*Function to obtain significance difference region
distcomp comp_esp , by(treatment) alpha(0.1) p 
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
*Significant region
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
twoway (line fc_cdf_1 fc if fc<=`r(p95)', color(black) lpattern(solid) ///
	sort ylab(, grid)) ///
	(line fc_cdf_0 fc if fc<=`r(p95)', color(gray) lpattern(dash) ///
	sort ylab(, grid)) ///
	(line  dif fc if fc<=`r(p95)', color(black) lpattern(dot) ///
	sort ylab(, grid)) ///
	(scatter sig_range fc if fc<=`r(p95)', msymbol(Oh) msize(tiny) lcolor(navy)), ///
	ytitle("") xtitle("Pesos") ///
	legend(order(1 "Treatment" 2 "Control" 3 "T-C") rows(1) pos(6)) xtitle("Value of the case") 

graph export "./Figures/cdf_valordecaso.tif", replace 