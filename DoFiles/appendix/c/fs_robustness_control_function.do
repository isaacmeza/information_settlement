
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	fs_robustness_control_function
* Author:	Isaac M 
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification:   
* Modifications:		
* Files used:     
		- phase_1.dta
		- phase_2.dta
* Files created:  
		- fs_robustness_control_function.csv
* Purpose: irst stage and robustness for the control function regression

*******************************************************************************/
*/

* Phase 2
********************************************************************************
use ".\DB\phase_2.dta", clear
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores time_hr phase
tempfile p2
save `p2', replace

* Phase 1
********************************************************************************
use ".\DB\phase_1.dta" , clear	
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores time_hr phase
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

eststo clear

	*********************************
	*			PHASE 1/2			*
	********************************* 


*"Reduced form" (OLS)
eststo : reg seconcilio i.time_hr i.anioControl i.numActores i.junta i.phase, cluster(cluster_v)
test 2.time_hr=3.time_hr=4.time_hr=5.time_hr=6.time_hr=7.time_hr=8.time_hr=0
local rp = r(p)
estadd scalar pval = `rp'

eststo : reg seconcilio i.time_hr i.anioControl i.numActores i.junta i.phase if p_actor==0, cluster(cluster_v)
test 2.time_hr=3.time_hr=4.time_hr=5.time_hr=6.time_hr=7.time_hr=8.time_hr=0
local rp = r(p)
estadd scalar pval = `rp'


*OLS FS
eststo : reg p_actor  i.time_hr i.calculadora i.anioControl i.numActores i.junta i.phase, cluster(cluster_v)	
test 2.time_hr=3.time_hr=4.time_hr=5.time_hr=6.time_hr=7.time_hr=8.time_hr=0
local rp = r(p)
su p_actor if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
estadd scalar DepVarMean = `DepVarMean'
estadd scalar pval = `rp'

*Probit (FS)
eststo : probit p_actor  i.time_hr i.calculadora i.anioControl i.numActores i.junta i.phase, cluster(cluster_v)
local rsq = e(r2_p)
test 2.time_hr=3.time_hr=4.time_hr=5.time_hr=6.time_hr=7.time_hr=8.time_hr=0
local rp = r(p)
estadd scalar rsq = `rsq'
estadd scalar pval = `rp'

*-------------------------------------------------------------------------------

*Save results	
esttab using "$directorio/Tables/appendix/c/fs_robustness_control_function.csv", se r2 ${star} b(a3) keep(1.calculadora 1.time_hr 2.time_hr 3.time_hr 4.time_hr 5.time_hr 6.time_hr 7.time_hr 8.time_hr) scalars("DepVarMean Control Mean" "rsq rsq" "pval pval") replace 
		