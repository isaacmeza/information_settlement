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
	*			PHASE 1				*
	********************************* 
	
	*Same day conciliation
preserve
keep if phase==1
keep seconcilio altT anioControl numActores fecha
*Randomization Inference (Fisher)
qui ritest altT _b[altT], reps(10000) seed(9435) : areg seconcilio altT i.anioControl i.numActores, absorb(fecha)
local pval_ri = r(p)[1,1]
restore	
*Robust standard error (Eicker-Huber-White)
qui areg seconcilio altT i.anioControl i.numActores if phase==1, absorb(fecha) robust 
local pval_r=r(table)[4,1]
*Clustered std. errors (Liang-Zeger(1986))
qui areg seconcilio altT d_anioC* d_num* if phase==1, absorb(fecha) vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
*Modify the robust variance calculation (Davidson-MacKinnon(1993)) (Angrist-Pischke(2009))
qui reg seconcilio altT d_anioC* d_num* d_fecha* if phase==1, vce(hc2)
local pval_hc2=r(table)[4,1]
*Modify the robust variance calculation (Davidson-MacKinnon(1993)) (Angrist-Pischke(2009))
qui reg seconcilio altT d_anioC* d_num* d_fecha* if phase==1, vce(hc3)
local pval_hc3=r(table)[4,1]
*Jackknife
qui reg seconcilio altT d_anioC* d_num* d_fecha* if phase==1, vce(jackknife)
local pval_jk=r(table)[4,1]
*Bootstrap (student-t)
qui reg seconcilio altT d_anioC* d_num* d_fecha* if phase==1, vce(bootstrap, rep(10000))
local pval_bt=r(table)[4,1]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
qui reg seconcilio altT d_anioC* d_num* d_fecha* if phase==1, vce(bootstrap, rep(10000) bca)
local pval_bca=r(table)[4,1]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich seconcilio altT d_anioC* d_num* d_fecha* if phase==1, cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
su seconcilio if e(sample) & altT==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & altT==0 & p_actor == 1

estadd scalar DepVarMean = `DepVarMean'
estadd scalar pval_r = `pval_r'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_cl = `pval_cl'
estadd scalar pval_hc2 = `pval_hc2'
estadd scalar pval_hc3 = `pval_hc3'
estadd scalar pval_jk = `pval_jk'
estadd scalar pval_bt = `pval_bt'
estadd scalar pval_bca = `pval_bca'
estadd scalar pval_pt = `pval_pt'

*-------------------------------------------------------------------------------

	*Interaction employee present
preserve
keep if phase==1
keep seconcilio altT p_actor anioControl numActores fecha
*Randomization Inference (Fisher)
qui ritest altT _b[altT] _b[c.altT#c.p_actor], reps(10000) seed(9435) : areg seconcilio c.altT##c.p_actor i.anioControl i.numActores, absorb(fecha)
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore
*Robust standard error (Eicker-Huber-White)
qui areg seconcilio altT p_actor interactT i.anioControl i.numActores if phase==1, absorb(fecha) robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
*Clustered std. errors (Liang-Zeger(1986))
qui areg seconcilio altT p_actor interactT d_anioC* d_num* if phase==1, absorb(fecha) vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
local pval_cl_int=r(table)[4,3]
*Modify the robust variance calculation (Davidson-MacKinnon(1993)) (Angrist-Pischke(2009))
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_fecha* if phase==1, vce(hc2)
local pval_hc2=r(table)[4,1]
local pval_hc2_int=r(table)[4,3]
*Modify the robust variance calculation (Davidson-MacKinnon(1993)) (Angrist-Pischke(2009))
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_fecha* if phase==1, vce(hc3)
local pval_hc3=r(table)[4,1]
local pval_hc3_int=r(table)[4,3]
*Jackknife
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_fecha* if phase==1, vce(jackknife)
local pval_jk=r(table)[4,1]
local pval_jk_int=r(table)[4,3]
*Bootstrap (student-t)
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_fecha* if phase==1, vce(bootstrap, rep(10000))
local pval_bt=r(table)[4,1]
local pval_bt_int=r(table)[4,3]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_fecha* if phase==1, vce(bootstrap, rep(10000) bca)
local pval_bca=r(table)[4,1]
local pval_bca_int=r(table)[4,3]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich seconcilio altT p_actor interactT d_anioC* d_num* d_fecha* if phase==1, cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
local pval_pt_int=2*ttail(e(dfs)[1,3], abs(e(b)[1,3]/sqrt(e(V)[3,3])))
su seconcilio if e(sample) & altT==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & altT==0 & p_actor == 1
local IntContMean = `r(mean)'
qui test altT + interactT = 0
local testInteraction=`r(p)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar IntContMean = `IntContMean'
estadd scalar testInteraction = `testInteraction'
estadd scalar pval_r = `pval_r'
estadd scalar pval_r_int = `pval_r_int'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_ri_int = `pval_ri_int'
estadd scalar pval_cl = `pval_cl'
estadd scalar pval_cl_int = `pval_cl_int'
estadd scalar pval_hc2 = `pval_hc2'
estadd scalar pval_hc2_int = `pval_hc2_int'
estadd scalar pval_hc3 = `pval_hc3'
estadd scalar pval_hc3_int = `pval_hc3_int'
estadd scalar pval_jk = `pval_jk'
estadd scalar pval_jk_int = `pval_jk_int'
estadd scalar pval_bt = `pval_bt'
estadd scalar pval_bt_int = `pval_bt_int'
estadd scalar pval_bca = `pval_bca'
estadd scalar pval_bca_int = `pval_bca_int'
estadd scalar pval_pt = `pval_pt'
estadd scalar pval_pt_int = `pval_pt_int'


	*********************************
	*			PHASE 2				*
	********************************* 
	
	*Same day conciliation
preserve
keep if phase==2
keep seconcilio altT cluster_v  numActores junta
*Randomization Inference (Fisher)
qui ritest altT _b[altT], cluster(cluster_v) reps(10000) seed(9435) : reg seconcilio altT i.numActores i.junta
local pval_ri = r(p)[1,1]
restore
*Robust standard error (Eicker-Huber-White)
qui reg seconcilio altT  i.numActores i.junta if phase==2, robust
local pval_r=r(table)[4,1]
*Clustered std. errors (Liang-Zeger(1986))
qui reg seconcilio altT d_num* d_junta* if phase==2, vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
*Jackknife
qui reg seconcilio altT d_num* d_junta* if phase==2, vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
*Bootstrap (student-t)
qui reg seconcilio altT d_num* d_junta* if phase==2, vce(bootstrap, cluster(cluster_v) rep(10000))
local pval_bt=r(table)[4,1]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
qui reg seconcilio altT d_num* d_junta* if phase==2, vce(bootstrap, cluster(cluster_v) rep(10000) bca)
local pval_bca=r(table)[4,1]
*Moulton (1986)
qui moulton seconcilio altT d_num* d_junta* if phase==2, cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
*Bias-reduced linearization ("clustered-HC2") (Bell-McCaffrey(2002))
qui brl seconcilio altT  d_num1 d_num2 d_junta1-d_junta4 if phase==2, cluster(cluster_v) 
local pval_brl=r(table)[4,1]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich seconcilio altT d_num* d_junta* if phase==2, cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
su seconcilio if e(sample) & altT==0 
local DepVarMean = `r(mean)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar pval_r = `pval_r'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_cl = `pval_cl'
estadd scalar pval_jk = `pval_jk'
estadd scalar pval_bt = `pval_bt'
estadd scalar pval_bca = `pval_bca'
estadd scalar pval_pt = `pval_pt'
estadd scalar pval_moulton = `pval_moulton'
estadd scalar pval_brl = `pval_brl'

*-------------------------------------------------------------------------------

	*Interaction employee present
preserve
keep if phase==2
keep seconcilio altT p_actor cluster_v numActores junta
*Randomization Inference (Fisher)
qui ritest altT _b[altT] _b[c.altT#c.p_actor], cluster(cluster_v) reps(10000) seed(9435) : reg seconcilio c.altT##c.p_actor i.numActores i.junta
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore
*Robust standard error (Eicker-Huber-White)
qui reg seconcilio altT p_actor interactT i.numActores i.junta if phase==2, robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
*Clustered std. errors (Liang-Zeger(1986))
qui reg seconcilio altT p_actor interactT d_num* d_junta* if phase==2, vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
local pval_cl_int=r(table)[4,3]
*Jackknife
qui reg seconcilio altT p_actor interactT d_num* d_junta* if phase==2, vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
local pval_jk_int=r(table)[4,3]
*Bootstrap (student-t)
qui reg seconcilio altT p_actor interactT d_num* d_junta* if phase==2, vce(bootstrap, cluster(cluster_v) rep(10000))
local pval_bt=r(table)[4,1]
local pval_bt_int=r(table)[4,3]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
qui reg seconcilio altT p_actor interactT d_num* d_junta* if phase==2, vce(bootstrap, cluster(cluster_v) rep(10000) bca)
local pval_bca=r(table)[4,1]
local pval_bca_int=r(table)[4,3]
*Moulton (1986)
qui moulton seconcilio altT p_actor interactT d_num* d_junta* if phase==2, cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
local pval_moulton_int=r(table)[4,3]
*Bias-reduced linearization ("clustered-HC2") (Bell-McCaffrey(2002))
qui brl seconcilio altT p_actor interactT  d_num1 d_num2 d_junta1-d_junta4 if phase==2, cluster(cluster_v) 
local pval_brl=r(table)[4,1]
local pval_brl_int=r(table)[4,3]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich seconcilio altT p_actor interactT d_num* d_junta* if phase==2, cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
local pval_pt_int=2*ttail(e(dfs)[1,3], abs(e(b)[1,3]/sqrt(e(V)[3,3])))	
su seconcilio if e(sample) & altT==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & altT==0 & p_actor == 1
local IntContMean = `r(mean)'
qui test altT + interactT = 0
local testInteraction=`r(p)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar IntContMean = `IntContMean'
estadd scalar testInteraction = `testInteraction'
estadd scalar pval_r = `pval_r'
estadd scalar pval_r_int = `pval_r_int'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_ri_int = `pval_ri_int'
estadd scalar pval_cl = `pval_cl'
estadd scalar pval_cl_int = `pval_cl_int'
estadd scalar pval_jk = `pval_jk'
estadd scalar pval_jk_int = `pval_jk_int'
estadd scalar pval_bt = `pval_bt'
estadd scalar pval_bt_int = `pval_bt_int'
estadd scalar pval_bca = `pval_bca'
estadd scalar pval_bca_int = `pval_bca_int'
estadd scalar pval_pt = `pval_pt'
estadd scalar pval_pt_int = `pval_pt_int'
estadd scalar pval_moulton = `pval_moulton'
estadd scalar pval_moulton_int = `pval_moulton_int'
estadd scalar pval_brl = `pval_brl'
estadd scalar pval_brl_int = `pval_brl_int'

	*********************************
	*			PHASE 1/2			*
	********************************* 

replace phase = phase - 1
	
	*Interaction employee present
preserve
keep seconcilio altT p_actor  cluster_v anioControl numActores phase junta exp anio 
*Randomization Inference (Fisher)
*qui ritest altT _b[altT] _b[c.altT#c.p_actor], cluster(cluster_v) reps(10000) seed(9435) saveresampling("./_aux/ritest.dta"): reg seconcilio c.altT##c.p_actor i.anioControl i.numActores i.junta i.phase
qui ritest altT _b[altT] _b[c.altT#c.p_actor], cluster(cluster_v) reps(10000) seed(9435) : reg seconcilio c.altT##c.p_actor i.anioControl i.numActores i.junta i.phase
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore
*Robust standard error (Eicker-Huber-White)
qui reg seconcilio altT p_actor interactT i.anioControl i.numActores i.junta i.phase, robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
*Clustered std. errors (Liang-Zeger(1986))
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase, vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
local pval_cl_int=r(table)[4,3]
*Jackknife
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase, vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
local pval_jk_int=r(table)[4,3]
*Bootstrap (student-t)
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase, vce(bootstrap, cluster(cluster_v) rep(10000))
local pval_bt=r(table)[4,1]
local pval_bt_int=r(table)[4,3]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase, vce(bootstrap, cluster(cluster_v) rep(10000) bca)
local pval_bca=r(table)[4,1]
local pval_bca_int=r(table)[4,3]
*Moulton (1986)
qui moulton seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase, cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
local pval_moulton_int=r(table)[4,3]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase, cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
local pval_pt_int=2*ttail(e(dfs)[1,3], abs(e(b)[1,3]/sqrt(e(V)[3,3])))	
su seconcilio if e(sample) & altT==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & altT==0 & p_actor == 1
local IntContMean = `r(mean)'
qui test altT + interactT = 0
local testInteraction=`r(p)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar IntContMean = `IntContMean'
estadd scalar testInteraction = `testInteraction'
estadd scalar pval_r = `pval_r'
estadd scalar pval_r_int = `pval_r_int'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_ri_int = `pval_ri_int'
estadd scalar pval_cl = `pval_cl'
estadd scalar pval_cl_int = `pval_cl_int'
estadd scalar pval_jk = `pval_jk'
estadd scalar pval_jk_int = `pval_jk_int'
estadd scalar pval_bt = `pval_bt'
estadd scalar pval_bt_int = `pval_bt_int'
estadd scalar pval_bca = `pval_bca'
estadd scalar pval_bca_int = `pval_bca_int'
estadd scalar pval_pt = `pval_pt'
estadd scalar pval_pt_int = `pval_pt_int'
estadd scalar pval_moulton = `pval_moulton'
estadd scalar pval_moulton_int = `pval_moulton_int'

*-------------------------------------------------------------------------------

*Probit (FS)
probit p_actor i.altT i.junta time_hr2-time_hr8 i.anioControl i.numActores i.junta i.phase, r cluster(fecha)

cap drop xb gen_resid_pr8
predict xb, xb
*Generalized residuals
gen gen_resid_pr8 = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*Probit - CF
ritest altT _b[altT] _b[c.altT#c.p_actor], samplingsourcefile("./_aux/samplePooled2.dta") samplingmatchvar(junta exp anio) reps(10000): reg seconcilio c.altT##c.p_actor i.anioControl i.numActores i.junta i.phase gen_resid_pr8, robust  cluster(fecha)
matrix pvalues=r(p)
local pvalNoInteract = pvalues[1,1]
local pvalInteract = pvalues[1,2]

*Probit (FS)
qui probit p_actor i.altT time_hr2-time_hr8 i.anioControl i.numActores i.junta i.phase
cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*Probit - Interaction
qui reg seconcilio altT p_actor interactT  i.anioControl i.numActores i.junta i.phase gen_resid_p , robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
qui test altT + interactT = 0
local testInteraction=`r(p)'
*Randomization inference
local pval_ri = `pval_ri'
local pval_ri_int = `pval_ri_int'
*Clustered std. errors (Liang-Zeger(1986))
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase gen_resid_p, vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
local pval_cl_int=r(table)[4,3]
*Jackknife
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase gen_resid_p, vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
local pval_jk_int=r(table)[4,3]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
qui reg seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase gen_resid_p, vce(bootstrap, cluster(cluster_v) rep(10000) bca)
local pval_bca=r(table)[4,1]
local pval_bca_int=r(table)[4,3]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
qui reg_sandwich seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase gen_resid_p, cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
local pval_pt_int=2*ttail(e(dfs)[1,3], abs(e(b)[1,3]/sqrt(e(V)[3,3])))
*Moulton (1986)
qui moulton seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase gen_resid_p, cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
local pval_moulton_int=r(table)[4,3]

*Bootstrap (student-t)
eststo : reg seconcilio altT p_actor interactT d_anioC* d_num* d_junta* phase gen_resid_p, vce(bootstrap, cluster(cluster_v) rep(10000))
local pval_bt=r(table)[4,1]
local pval_bt_int=r(table)[4,3]	
su seconcilio if e(sample) & altT==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & altT==0 & p_actor == 1
local IntContMean = `r(mean)'
qui test altT + interactT = 0
local testInteraction=`r(p)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar IntContMean = `IntContMean'
estadd scalar testInteraction = `testInteraction'
estadd scalar pval_r = `pval_r'
estadd scalar pval_r_int = `pval_r_int'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_ri_int = `pval_ri_int'
estadd scalar pval_cl = `pval_cl'
estadd scalar pval_cl_int = `pval_cl_int'
estadd scalar pval_jk = `pval_jk'
estadd scalar pval_jk_int = `pval_jk_int'
estadd scalar pval_bt = `pval_bt'
estadd scalar pval_bt_int = `pval_bt_int'
estadd scalar pval_bca = `pval_bca'
estadd scalar pval_bca_int = `pval_bca_int'
estadd scalar pval_pt = `pval_pt'
estadd scalar pval_pt_int = `pval_pt_int'
estadd scalar pval_moulton = `pval_moulton'
estadd scalar pval_moulton_int = `pval_moulton_int'

*-------------------------------------------------------------------------------

	*Long run
preserve
keep convenio_m5m altT p_actor interactT cluster_v anioControl numActores phase junta exp anio 
*Randomization Inference (Fisher)
qui ritest altT _b[altT] _b[c.altT#c.p_actor], cluster(cluster_v) reps(10000) seed(9435) : reg convenio_m5m c.altT##c.p_actor i.anioControl i.numActores i.junta i.phase
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore
*Robust standard error (Eicker-Huber-White)
qui reg convenio_m5m altT p_actor interactT i.anioControl i.numActores i.junta i.phase, robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
*Clustered std. errors (Liang-Zeger(1986))
qui reg convenio_m5m altT p_actor interactT i.anioControl i.numActores i.junta i.phase, vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
local pval_cl_int=r(table)[4,3]
*Jackknife
qui reg convenio_m5m altT p_actor interactT d_anioC* d_num* d_junta* phase, vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
local pval_jk_int=r(table)[4,3]
*Bootstrap (student-t)
qui reg convenio_m5m altT p_actor interactT d_anioC* d_num* d_junta* phase, vce(bootstrap, cluster(cluster_v) rep(10000))
local pval_bt=r(table)[4,1]
local pval_bt_int=r(table)[4,3]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
qui reg convenio_m5m altT p_actor interactT d_anioC* d_num* d_junta* phase, vce(bootstrap, cluster(cluster_v) rep(10000) bca)
local pval_bca=r(table)[4,1]
local pval_bca_int=r(table)[4,3]
*Moulton (1986)
qui moulton convenio_m5m altT p_actor interactT d_anioC* d_num* d_junta* phase, cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
local pval_moulton_int=r(table)[4,3]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich convenio_m5m altT p_actor interactT d_anioC* d_num* d_junta* phase, cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
local pval_pt_int=2*ttail(e(dfs)[1,3], abs(e(b)[1,3]/sqrt(e(V)[3,3])))	
su convenio_m5m if e(sample) & altT==0 
local DepVarMean = `r(mean)'
su convenio_m5m if e(sample) & altT==0 & p_actor == 1
local IntContMean = `r(mean)'
qui test altT + interactT = 0
local testInteraction=`r(p)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar IntContMean = `IntContMean'
estadd scalar testInteraction = `testInteraction'
estadd scalar pval_r = `pval_r'
estadd scalar pval_r_int = `pval_r_int'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_ri_int = `pval_ri_int'
estadd scalar pval_cl = `pval_cl'
estadd scalar pval_cl_int = `pval_cl_int'
estadd scalar pval_jk = `pval_jk'
estadd scalar pval_jk_int = `pval_jk_int'
estadd scalar pval_bt = `pval_bt'
estadd scalar pval_bt_int = `pval_bt_int'
estadd scalar pval_bca = `pval_bca'
estadd scalar pval_bca_int = `pval_bca_int'
estadd scalar pval_pt = `pval_pt'
estadd scalar pval_pt_int = `pval_pt_int'
estadd scalar pval_moulton = `pval_moulton'
estadd scalar pval_moulton_int = `pval_moulton_int'


*-------------------------------------------------------------------------------

* Phase 3
********************************************************************************
use ".\DB\P3Outcomes.dta", clear
merge m:1 id_actor using ".\DB\treatment_data.dta", keep(2 3) nogen
merge m:1 id_actor using ".\DB\survey_data_2m.dta", nogen keep(1 3)

*Outcome
gen convenio = (MODODETERMINO == "CONVENIO")
gen doble_convenio = convenio ==1 | conflicto_arreglado == 1

*Treatment var
gen altT = main_treatment-1
replace altT = . if main_treatment==3

*Drop 
bysort fecha_alta: egen minT = min(altT)
bysort fecha_alta: egen maxT = max(altT)
gen indicadora = (minT != maxT)
drop if indicadora == 1

	*********************************
	*			PHASE 3				*
	********************************* 
	
preserve
keep doble_convenio altT fecha_alta mujer antiguedad salario_diario
*Randomization Inference (Fisher)
qui ritest altT _b[altT], cluster(fecha_alta) reps(10000) seed(9435) : reg doble_convenio altT mujer antiguedad salario_diario
local pval_ri = r(p)[1,1]
restore
*Robust standard error (Eicker-Huber-White)
reg doble_convenio altT mujer antiguedad salario_diario, robust 
local pval_r=r(table)[4,1]
*Clustered std. errors (Liang-Zeger(1986))
qui reg doble_convenio altT mujer antiguedad salario_diario, vce(cluster fecha_alta)
local pval_cl=r(table)[4,1]
*Jackknife
qui reg doble_convenio altT mujer antiguedad salario_diario, vce(jackknife, cluster(fecha_alta))
local pval_jk=r(table)[4,1]
*Bootstrap (student-t)
qui reg doble_convenio altT mujer antiguedad salario_diario, vce(bootstrap, cluster(fecha_alta) rep(10000))
local pval_bt=r(table)[4,1]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
qui reg doble_convenio altT mujer antiguedad salario_diario, vce(bootstrap, cluster(fecha_alta) rep(10000) bca)
local pval_bca=r(table)[4,1]
*Moulton (1986)
qui moulton doble_convenio altT mujer antiguedad salario_diario, cluster(fecha_alta) 
local pval_moulton=r(table)[4,1]
*Bias-reduced linearization ("clustered-HC2") (Bell-McCaffrey(2002))
qui brl doble_convenio altT mujer antiguedad salario_diario, cluster(fecha_alta)
local pval_brl=r(table)[4,1]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich doble_convenio altT mujer antiguedad salario_diario, cluster(fecha_alta)
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
su doble_convenio if e(sample) & altT==0
local DepVarMean = `r(mean)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar pval_r = `pval_r'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_cl = `pval_cl'
estadd scalar pval_jk = `pval_jk'
estadd scalar pval_bt = `pval_bt'
estadd scalar pval_bca = `pval_bca'
estadd scalar pval_pt = `pval_pt'
estadd scalar pval_moulton = `pval_moulton'
estadd scalar pval_brl = `pval_brl'

*-------------------------------------------------------------------------------

*Save results	
esttab using "./Tables/reg_results/treatment_effect_itt.csv", se r2 ${star} b(a3) ///
		scalars("DepVarMean DepVarMean" "IntContMean IntContMean" "testInteraction testInteraction" ///
		"pval_r pval_r" ///
		"pval_r_int pval_r_int" ///
		"pval_ri pval_ri" ///
		"pval_ri_int pval_ri_int" ///
		"pval_cl pval_cl" ///
		"pval_cl_int pval_cl_int" ///
		"pval_hc2 pval_hc2" ///
		"pval_hc2_int pval_hc2_int" ///
		"pval_hc3 pval_hc3" ///
		"pval_hc3_int pval_hc3_int" ///
		"pval_jk pval_jk" ///
		"pval_jk_int pval_jk_int" ///
		"pval_bt pval_bt" ///
		"pval_bt_int pval_bt_int" ///
		"pval_bca pval_bca" ///
		"pval_bca_int pval_bca_int" ///
		"pval_pt pval_pt" ///
		"pval_pt_int pval_pt_int" ///
		"pval_moulton pval_moulton" ///
		"pval_moulton_int pval_moulton_int" ///
		"pval_brl pval_brl" ///
		"pval_brl_int pval_brl_int" ///
		) replace 
	
