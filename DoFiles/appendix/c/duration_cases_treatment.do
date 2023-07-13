
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	duration_cases_treatment
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- phase_1.dta
		- phase_2.dta

* Files created:  
		- duration_cases_treatment.csv

* Purpose: The table shows the duration of cases in phases 1 and 2, measured in days from the date of filing to the date of the final resolution.

*******************************************************************************/
*/


* Phase 2
********************************************************************************
use ".\DB\phase_2.dta", clear
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores abogado_pub phase fecha* modoTermino
tempfile p2
save `p2', replace

* Phase 1
********************************************************************************
use ".\DB\phase_1.dta" , clear	
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores abogado_pub phase fecha* modoTermino
append using `p2'

********************************************************************************
*Drop duplicates
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if (renglon==1 & inlist(phase,1,2)) | phase==3

********************************************************************************

*Controls
gen anioControl=anio
replace anioControl=2010 if anio<2010
replace numActores=3 if numActores>3

*define clusters
egen gp=group(exp anio)
egen fechaJunta=group(junta fecha)
replace fechaJunta=fechaJunta+1481 
gen cluster_v=.
replace cluster_v=gp if phase==1
replace cluster_v=fechaJunta if phase==2 


********************************************************************************

*Duration
gen length=fechaTermino-fecha_filing
keep if inrange(length,0,2300)
gen unresolved = modoTermino!=2 if modoTermino!=. // failure = not completed

eststo clear 

*OLS
eststo : reg length i.treatment i.p_actor i.treatment#i.p_actor i.abogado_pub i.numActores i.anioControl i.phase i.junta, robust cluster(cluster_v)
su length if e(sample) 
estadd scalar DepVarMean = `r(mean)'

*Hazard model
stset length, failure(unresolved==1)

eststo : stcox i.treatment i.p_actor i.treatment#i.p_actor i.abogado_pub i.numActores i.anioControl i.phase i.junta, robust nohr cluster(cluster_v)

eststo : stcox i.treatment i.p_actor i.treatment#i.p_actor i.abogado_pub i.numActores i.anioControl i.phase i.junta if modoTermino!=3, robust nohr cluster(cluster_v)

*-------------------------------------------------------------------------------
esttab using "$directorio/Tables/appendix/c/duration_cases_treatment.csv", se r2 ${star} b(a2)  scalars("DepVarMean DepVarMean") keep(2.treatment 1.p_actor 2.treatment#1.p_actor) replace 

		
		
