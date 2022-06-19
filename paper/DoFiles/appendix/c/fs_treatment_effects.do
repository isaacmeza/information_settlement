/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M & Sergio Lopez
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: October. 25, 2021  
* Modifications:		
* Files used:     
		- 
* Files created:  

* Purpose: This table estimates the main treatment effects  (ITT) for both experimental phases.

*******************************************************************************/
*/

clear all
set maxvar 32767
*cap erase "./_aux/ritest.dta"
* Phase 2
********************************************************************************
use ".\DB\scaleup_operation.dta", clear
rename año anio
rename expediente exp
merge m:1 junta exp anio using ".\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

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
format fecha %td

*Time hearing (Instrument)
gen time_hearing=substr(horario_aud,strpos(horario_aud," "),length(horario_aud))
egen time_hr=group(time_hearing)

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub numActores time_hr
gen phase=2
tempfile p2
save `p2', replace

* Phase 1
********************************************************************************
use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

*Time hearing (Instrument)
gen time_hearing=substr(horarioaudiencia,strpos(horarioaudiencia," "),length(horarioaudiencia))
egen time_hr=group(time_hearing)

merge m:1 junta exp anio using ".\p1_w_p3\out\inicialesP1Faltantes_wod.dta", ///
keep(1 3) keepusing(abogado_pubN numActoresN)

foreach var in numActores abogado_pub{
replace `var' = `var'N if missing(`var') & !missing(`var'N)
}

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub numActores time_hr
append using `p2'
replace phase=1 if missing(phase)

********************************************************************************

*Duplicate contaminated observations
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

*46 drops
drop if T1T3==1
*31 drops
drop if T2T3==1
*8 drops
drop if TAll==1


********************************************************************************
*Drop conciliator observations
drop if treatment==3 

*Drop duplicates by casefile
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1



*Follow-up (more than 5 months)
merge 1:1 junta exp anio using ".\DB\seguimiento_m5m.dta", nogen keep(1 3)
merge 1:1 junta exp anio using ".\Terminaciones\Data\followUps2020.dta",  keep(1 3)

*Settlement
replace convenio_2m=seconcilio if seconcilio==1
replace convenio_5m=convenio_2m if convenio_2m==1

replace modo_termino_expediente=3 if missing(modo_termino_expediente) & convenio_m5m==1
replace modo_termino_expediente=2 if missing(modo_termino_expediente)

replace modoTermino = modo_termino_expediente if missing(modoTermino)

replace convenio_m5m=convenio_5m if convenio_5m==1
replace convenio_m5m=1 if modoTermino==3
replace convenio_m5m=0 if modoTermino!=3 & !missing(modoTermino)
replace seconcilio=0 if modoTermino!=3 & !missing(modoTermino)

replace convenio_m5m=. if modoTermino==5
replace seconcilio=. if modoTermino==5

********************************************************************************

*Controls
gen anioControl=anio
replace anioControl=2010 if anio<2010
replace numActores=3 if numActores>3
gen altT=treatment-1
gen interactT=altT*p_actor

*define dummies
tab anioControl, gen(d_anioC)
tab fecha, gen(d_fecha)
tab numActores, gen(d_num)
tab junta, gen(d_junta)

*define clusters
egen gp=group(exp anio)
egen fechaJunta=group(junta fecha)
replace fechaJunta=fechaJunta+1481 
gen cluster_v=.
replace cluster_v=gp if phase==1
replace cluster_v=fechaJunta if phase==2 

*Instrument
gen time_instrument=inlist(time_hr,1,2,7,8) if !missing(time_hr) 
*Now use dummy variables for time groups
tab time_hr, gen(time_hr)
gen treat_inst=altT*time_instrument
gen treat_p_actor=altT*p_actor
********************************************************************************

loneway seconcilio cluster_v 
loneway seconcilio fechaJunta if phase==2
loneway seconcilio fecha if phase==1
eststo clear



	*********************************
	*			PHASE 1/2			*
	********************************* 


*Probit ITT
eststo : probit seconcilio i.altT p_actor interactT  i.anioControl i.numActores i.junta i.phase , cluster(cluster_v) 
local rsq = e(r2_p)
su seconcilio if e(sample) & altT==0 
local DepVarMean = `r(mean)'
estadd scalar DepVarMean = `DepVarMean'
estadd scalar rsq = `rsq'

*"Reduced form" (OLS)
eststo : reg seconcilio i.time_hr i.anioControl i.numActores i.junta i.phase, cluster(cluster_v)
test 2.time_hr=3.time_hr=4.time_hr=5.time_hr=6.time_hr=7.time_hr=8.time_hr=0
local rp = r(p)
estadd scalar pval = `rp'

eststo : reg seconcilio i.time_hr i.anioControl i.numActores i.junta i.phase if p_actor==0, cluster(cluster_v)
test 2.time_hr=3.time_hr=4.time_hr=5.time_hr=6.time_hr=7.time_hr=8.time_hr=0
local rp = r(p)
estadd scalar pval = `rp'

*"Reduced form" (Probit)
eststo :  probit seconcilio i.time_hr i.anioControl i.numActores i.junta i.phase, cluster(cluster_v)
local rsq = e(r2_p)
test 2.time_hr=3.time_hr=4.time_hr=5.time_hr=6.time_hr=7.time_hr=8.time_hr=0
local rp = r(p)
estadd scalar rsq = `rsq'
estadd scalar pval = `rp'
eststo :  probit seconcilio i.time_hr i.anioControl i.numActores i.junta i.phase if p_actor==0, cluster(cluster_v)
local rsq = e(r2_p)
test 2.time_hr=3.time_hr=4.time_hr=5.time_hr=6.time_hr=7.time_hr=8.time_hr=0
local rp = r(p)
estadd scalar rsq = `rsq'
estadd scalar pval = `rp'

*OLS FS
eststo : reg p_actor  i.time_hr i.altT i.anioControl i.numActores i.junta i.phase, cluster(cluster_v)	
test 2.time_hr=3.time_hr=4.time_hr=5.time_hr=6.time_hr=7.time_hr=8.time_hr=0
local rp = r(p)
su p_actor if e(sample) & altT==0 
local DepVarMean = `r(mean)'
estadd scalar DepVarMean = `DepVarMean'
estadd scalar rsq = `rsq'
estadd scalar pval = `rp'

*Probit (FS)
eststo : probit p_actor  i.time_hr i.altT i.anioControl i.numActores i.junta i.phase, cluster(cluster_v)
local rsq = e(r2_p)
test 2.time_hr=3.time_hr=4.time_hr=5.time_hr=6.time_hr=7.time_hr=8.time_hr=0
local rp = r(p)
estadd scalar rsq = `rsq'
estadd scalar pval = `rp'

*-------------------------------------------------------------------------------

*Save results	
esttab using "./Tables/reg_results/fs_treatment_effects.csv", se r2 ${star} b(a3) ///
		scalars("DepVarMean Control Mean" "rsq rsq" "pval pval") replace 
		