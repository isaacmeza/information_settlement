
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	npv_outcomes_treatment,
* Author: Isaac M & Sergio Lopez
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- 
* Files created:  

* Purpose: This figure shows the kernel density of the NPV of the amount awarded by treatment and phase of the intervention.

*******************************************************************************/
*/


global int=3.43			/* Interest rate */
global int2 = 2.22		/* Interest rate (ROBUSTNESS)*/
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */
global pago_pri=2000	/* Payment to private lawyer */
global courtcollect=1.0 /* Recovery / Award ratio for court judgments */
global winsorize=95 	/* winsorize level for NPV levels */


********************************************************************************
clear
set maxvar 30000

* Phase 2
********************************************************************************
use ".\DB\phase_2.dta", clear
keep junta exp anio fecha abogado_pub ganancia modoTermino duration_months treatment numActores phase liq_total_laudo_avg p_actor
tempfile p2
save `p2'

* Phase 1
********************************************************************************
use "./DB/phase_1.dta" , clear	
keep junta exp anio fecha abogado_pub ganancia modoTermino duration_months treatment numActores phase liq_total_laudo_avg p_actor
append using `p2'

********************************************************************************
*Drop duplicates
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

********************************************************************************


*Imputation
replace abogado_pub = 0 if missing(abogado_pub)
replace ganancia = 0 if missing(ganancia)
gen gananciaImputed = ganancia
replace gananciaImputed = liq_total_laudo_avg if  ganancia==0 & modoTermino==2


*Net Present Value - amount collected
gen npv=.

gen npvImputed=.
gen npvImputed_robust=.


*Amount in court ruling
replace ganancia=ganancia*${courtcollect} if modoTermino==6

replace npv=(ganancia/(1+(${int})/100)^duration_months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(ganancia/(1+(${int})/100)^duration_months)-${pago_pub} if abogado_pub==1 


replace npvImputed=(gananciaImputed/(1+(${int})/100)^duration_months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npvImputed=(gananciaImputed/(1+(${int})/100)^duration_months)-${pago_pub} if abogado_pub==1


replace npvImputed_robust=(gananciaImputed/(1+(${int2})/100)^duration_months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npvImputed_robust=(gananciaImputed/(1+(${int2})/100)^duration_months)-${pago_pub} if abogado_pub==1


*IHS
gen asinhNPV = asinh(npv)
gen asinhNPVImputed = asinh(npvImputed)
gen asinhNPVImputed_robust = asinh(npvImputed_robust)


*Winsorization
for var npv npvImputed: gen X_wz=X
for var npv npvImputed: egen X_wz_WZ=pctile(X), p(${winsorize})
for var npv_wz npvImputed_wz: replace X=X_WZ if X>X_WZ & X~=.

*********************************************************************************


* Phase 1
********************************************************************************
twoway (kdensity npvImputed if treatment==2 & asinhNPVImputed!=. & p_actor==1 & phase==1 , lwidth(medthick) lpattern(solid) color(black)) ///
		(kdensity npvImputed if treatment==1  & asinhNPVImputed!=. & p_actor==1  & phase==1, lpattern(dash) lcolor(gs10) lwidth(medthick)),  ///
		legend(lab(1 "Treatment") lab(2 "Control") rows(1) pos(6)) xtitle("NPV of outcome, winsorized 95%") title("NPV of Outcomes, Imputed for Unresolved Cases") subtitle("Plaintiff present at Treatment, Phase 1") ytitle("kdensity")  graphregion(color(white))
graph export "./Figures/appendix/c/OutcomesByTreatment_P1.tif", replace 

* Phase 2
********************************************************************************
twoway (kdensity npvImputed if treatment==2 & asinhNPVImputed~=. & p_actor==1 & phase==2  ,  lwidth(medthick) lpattern(solid) color(black)) ///
		(kdensity npvImputed if treatment==1  & asinhNPVImputed~=. & p_actor==1  & phase==2, lpattern(dash) lcolor(gs10) lwidth(medthick)), ///
		legend(lab(1 "Treatment") lab(2 "Control") rows(1) pos(6)) xtitle("NPV of outcome, winsorized 95%") title("NPV of Outcomes, Imputed for Unresolved Cases") subtitle("Plaintiff present at treatment, Phase 2") ytitle("kdensity") graphregion(color(white))
graph export "./Figures/appendix/c/OutcomesByTreatment_P2.tif", replace 

