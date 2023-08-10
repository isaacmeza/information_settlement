
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	recovery_after_42_months,
* Author: Isaac M & Sergio Lopez
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- 
* Files created:  

* Purpose: Recovery after 42 months, Phase 1/2 samples

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
clear all
set maxvar 30000

* Phase 2
********************************************************************************
use "./DB/phase_2.dta", clear
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

*Treatment var
gen calculadora=treatment-1 if inlist(phase,1,2)

*Controls
gen anioControl=anio
replace anioControl=2010 if anio<2010
replace numActores = 0 if missing(numActores)
replace numActores=1 if numActores==0
replace numActores=3 if numActores>3 & numActores~=.

*define clusters
egen gp=group(exp anio)
egen fechaJunta=group(junta fecha)
replace fechaJunta=fechaJunta+1481 
gen cluster_v=.
replace cluster_v=gp if phase==1
replace cluster_v=fechaJunta if phase==2 

*********************************************************************************


foreach var of varlist npvImputed_wz asinhNPVImputed asinhNPVImputed_robust npv_wz asinhNPV {

	*Randomization Inference (Fisher)
	qui ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], cluster(cluster_v) reps($reps) seed(9435) : reg `var' c.calculadora##c.p_actor i.abogado_pub i.numActores i.anioControl i.phase i.junta if !missing(asinhNPVImputed)
	local pval_ri = r(p)[1,1]
	local pval_ri_int = r(p)[1,2]


	*Clustered std. errors (Liang-Zeger(1986))
	eststo : reg `var' c.calculadora##c.p_actor i.abogado_pub i.numActores i.anioControl i.phase i.junta if !missing(asinhNPVImputed), vce(cluster cluster_v)
	su `var' if e(sample) & calculadora==0 
	local DepVarMean = `r(mean)'
	su `var' if e(sample) & calculadora==0 & p_actor == 1
	local IntContMean = `r(mean)'
	qui test calculadora + c.calculadora#c.p_actor = 0
	local testInteraction=`r(p)'

	estadd scalar DepVarMean = `DepVarMean'
	estadd scalar IntContMean = `IntContMean'
	estadd scalar testInteraction = `testInteraction'
	estadd scalar pval_ri = `pval_ri'
	estadd scalar pval_ri_int = `pval_ri_int'
}
		
		
*Save results	
esttab using "$directorio/Tables/recovery_after_42_months.csv", se r2 ${star} b(a2) ///
		keep(calculadora p_actor c.calculadora#c.p_actor ) ///
		scalars("DepVarMean DepVarMean" "IntContMean IntContMean" "testInteraction testInteraction" ///
		"pval_ri pval_ri" ///
		"pval_ri_int pval_ri_int") replace 
		
		
