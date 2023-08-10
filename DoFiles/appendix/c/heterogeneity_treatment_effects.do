
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	heterogeneity_treatment_effects
* Author:	Isaac M 
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification:
* Modifications:		
* Files used:     
		- phase_1.dta
		- phase_2.dta

* Files created:  
		- heterogeneity_treatment_effects.csv

* Purpose: We test for heterogeneity of treatment effects by interacting treatment with the variable shown in the column header.

*******************************************************************************/
*/

* Phase 2
********************************************************************************
use "./DB/phase_2.dta", clear
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores time_hr phase abogado_pub salario_diario gen c_antiguedad horas_sem min_ley
tempfile p2
save `p2', replace

* Phase 1
********************************************************************************
use "./DB/phase_1.dta" , clear	
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores time_hr phase abogado_pub salario_diario gen c_antiguedad horas_sem min_ley
append using `p2'

********************************************************************************
*Drop duplicates
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if (renglon==1 & inlist(phase,1,2)) | phase==3

********************************************************************************

*Treatment var
gen calculadora=treatment-1 if inlist(phase,1,2)


*Controls
gen anioControl=anio
replace anioControl=2010 if anio<2010
replace numActores=3 if numActores>3
tab time_hr, gen(time_hr)

*define clusters
egen gp=group(exp anio)
egen fechaJunta=group(junta fecha)
replace fechaJunta=fechaJunta+1481 
gen cluster_v=.
replace cluster_v=gp if phase==1
replace cluster_v=fechaJunta if phase==2 

********************************************************************************


****************************************
*INTERACTION  VARIABLES 

foreach var of varlist salario_diario c_antiguedad  horas_sem min_ley  {
	qui su `var', d
	gen median_`var'=(`var'<=r(p50)) if !missing(`var')
	}

********************************************************************************

eststo clear

foreach var of varlist median_salario_diario median_c_antiguedad median_horas_sem gen abogado_pub median_min_ley {

	*********************************
	*			PHASE 1				*
	*********************************
	cap drop interaction
	gen interaction=`var'
	
	*Same day conciliation
	eststo: reg seconcilio i.treatment##i.interaction i.junta if treatment!=0 & phase==1, robust  cluster(cluster_v)
	estadd scalar Erre=e(r2)
	qui su seconcilio if e(sample)
	estadd scalar DepVarMean=r(mean)
	
	
	*********************************
	*			PHASE 2				*
	*********************************
	
	*Same day conciliation
	eststo: reg seconcilio i.treatment##i.interaction i.junta if treatment!=0 & phase==2, robust  cluster(cluster_v)
	estadd scalar Erre=e(r2)
	qui su seconcilio if e(sample)
	estadd scalar DepVarMean=r(mean)

	
	*********************************
	*			POOLED				*
	*********************************
	
	*Interaction employee was present
	eststo: reg seconcilio i.treatment##i.p_actor##i.interaction i.junta if treatment!=0, robust  cluster(cluster_v)
	estadd scalar Erre=e(r2)
	qui su seconcilio if e(sample)
	
}	
	
	*************************
	esttab using "$directorio/Tables/appendix/c/heterogeneity_treatment_effects.csv", se r2 ${star} b(a2) replace 

	
