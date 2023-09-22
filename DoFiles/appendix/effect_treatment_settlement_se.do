
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	effect_treatment_settlement
* Author:	Isaac M & Sergio Lopez
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: October. 25, 2021  
* Modifications:		
* Files used:     
		- phase_1.dta
		- phase_2.dta
		- phase_3.dta
* Files created:  
		- ritest.dta
		- effect_treatment_settlement.csv

* Purpose: This table estimates the main treatment effects  (ITT) for all experimental phases.

*******************************************************************************/
*/

clear all
set maxvar 32767
cap erase "./_aux/ritest.dta"

* Phase 3
********************************************************************************
use "./DB/phase_3.dta", clear
keep doble_convenio main_treatment gen c_antiguedad salario_diario fecha_alta phase
tempfile p3
save `p3', replace

* Phase 2
********************************************************************************
use "./DB/phase_2.dta", clear
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores time_hr phase
tempfile p2
save `p2', replace

* Phase 1
********************************************************************************
use "./DB/phase_1.dta" , clear	
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores time_hr phase
append using `p2'
append using `p3'

********************************************************************************
*Drop duplicates
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if (renglon==1 & inlist(phase,1,2)) | phase==3

********************************************************************************

*Treatment var
gen calculadora=treatment-1 if inlist(phase,1,2)

replace calculadora = main_treatment-1 if phase==3
replace calculadora = . if main_treatment==3 & phase==3

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
replace cluster_v=fecha_alta if phase==3

********************************************************************************

eststo clear
tab anioControl, gen(d_anioC)
tab numActores, gen(d_num)
tab fecha, gen(d_fecha)
tab junta, gen(d_junta)
gen calc_X_pactor = calculadora*p_actor


	*********************************
	*			PHASE 1				*
	********************************* 
	
	*Same day conciliation
preserve
keep if phase==1
keep seconcilio calculadora anioControl numActores fecha
*Randomization Inference (Fisher)
ritest calculadora _b[calculadora], reps($reps) seed(9435) : areg seconcilio calculadora i.anioControl i.numActores, absorb(fecha)
local pval_ri = r(p)[1,1]
restore	
*Robust standard error (Eicker-Huber-White)
areg seconcilio calculadora i.anioControl i.numActores if phase==1, absorb(fecha) robust 
local pval_r=r(table)[4,1]
*Clustered std. errors (Liang-Zeger(1986))
areg seconcilio calculadora d_anioC* d_num* if phase==1, absorb(fecha) vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
*Modify the robust variance calculation (Davidson-MacKinnon(1993)) (Angrist-Pischke(2009))
reg seconcilio calculadora d_anioC* d_num* d_fecha* if phase==1, vce(hc2)
local pval_hc2=r(table)[4,1]
*Modify the robust variance calculation (Davidson-MacKinnon(1993)) (Angrist-Pischke(2009))
reg seconcilio calculadora d_anioC* d_num* d_fecha* if phase==1, vce(hc3)
local pval_hc3=r(table)[4,1]
*Jackknife
reg seconcilio calculadora d_anioC* d_num* d_fecha* if phase==1, vce(jackknife)
local pval_jk=r(table)[4,1]
*Bootstrap (student-t)
reg seconcilio calculadora d_anioC* d_num* d_fecha* if phase==1, vce(bootstrap, rep($reps))
local pval_bt=r(table)[4,1]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
reg seconcilio calculadora d_anioC* d_num* d_fecha* if phase==1, vce(bootstrap, rep($reps) bca)
local pval_bca=r(table)[4,1]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich seconcilio calculadora d_anioC* d_num* d_fecha* if phase==1, cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & calculadora==0 & p_actor == 1

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
keep seconcilio calculadora p_actor anioControl numActores fecha
*Randomization Inference (Fisher)
ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], reps($reps) seed(9435) : areg seconcilio c.calculadora##c.p_actor i.anioControl i.numActores, absorb(fecha)
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore
*Robust standard error (Eicker-Huber-White)
areg seconcilio calculadora p_actor calc_X_pactor i.anioControl i.numActores if phase==1, absorb(fecha) robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
*Clustered std. errors (Liang-Zeger(1986))
areg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* if phase==1, absorb(fecha) vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
local pval_cl_int=r(table)[4,3]
*Modify the robust variance calculation (Davidson-MacKinnon(1993)) (Angrist-Pischke(2009))
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_fecha* if phase==1, vce(hc2)
local pval_hc2=r(table)[4,1]
local pval_hc2_int=r(table)[4,3]
*Modify the robust variance calculation (Davidson-MacKinnon(1993)) (Angrist-Pischke(2009))
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_fecha* if phase==1, vce(hc3)
local pval_hc3=r(table)[4,1]
local pval_hc3_int=r(table)[4,3]
*Jackknife
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_fecha* if phase==1, vce(jackknife)
local pval_jk=r(table)[4,1]
local pval_jk_int=r(table)[4,3]
*Bootstrap (student-t)
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_fecha* if phase==1, vce(bootstrap, rep($reps))
local pval_bt=r(table)[4,1]
local pval_bt_int=r(table)[4,3]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_fecha* if phase==1, vce(bootstrap, rep($reps) bca)
local pval_bca=r(table)[4,1]
local pval_bca_int=r(table)[4,3]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_fecha* if phase==1, cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
local pval_pt_int=2*ttail(e(dfs)[1,3], abs(e(b)[1,3]/sqrt(e(V)[3,3])))
su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & calculadora==0 & p_actor == 1
local IntContMean = `r(mean)'
test calculadora + calc_X_pactor = 0
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
keep seconcilio calculadora cluster_v  numActores junta
*Randomization Inference (Fisher)
ritest calculadora _b[calculadora], cluster(cluster_v) reps($reps) seed(9435) : reg seconcilio calculadora i.numActores i.junta
local pval_ri = r(p)[1,1]
restore
*Robust standard error (Eicker-Huber-White)
reg seconcilio calculadora  i.numActores i.junta if phase==2, robust
local pval_r=r(table)[4,1]
*Clustered std. errors (Liang-Zeger(1986))
reg seconcilio calculadora d_num* d_junta* if phase==2, vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
*Jackknife
reg seconcilio calculadora d_num* d_junta* if phase==2, vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
*Bootstrap (student-t)
reg seconcilio calculadora d_num* d_junta* if phase==2, vce(bootstrap, cluster(cluster_v) rep($reps))
local pval_bt=r(table)[4,1]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
reg seconcilio calculadora d_num* d_junta* if phase==2, vce(bootstrap, cluster(cluster_v) rep($reps) bca)
local pval_bca=r(table)[4,1]
*Moulton (1986)
moulton seconcilio calculadora d_num* d_junta* if phase==2, cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
*Bias-reduced linearization ("clustered-HC2") (Bell-McCaffrey(2002))
brl seconcilio calculadora  d_num1 d_num2 d_junta1-d_junta4 if phase==2, cluster(cluster_v) 
local pval_brl=r(table)[4,1]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich seconcilio calculadora d_num* d_junta* if phase==2, cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
su seconcilio if e(sample) & calculadora==0 
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
keep seconcilio calculadora p_actor cluster_v numActores junta
*Randomization Inference (Fisher)
ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], cluster(cluster_v) reps($reps) seed(9435) : reg seconcilio c.calculadora##c.p_actor i.numActores i.junta
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore
*Robust standard error (Eicker-Huber-White)
reg seconcilio calculadora p_actor calc_X_pactor i.numActores i.junta if phase==2, robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
*Clustered std. errors (Liang-Zeger(1986))
reg seconcilio calculadora p_actor calc_X_pactor d_num* d_junta* if phase==2, vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
local pval_cl_int=r(table)[4,3]
*Jackknife
reg seconcilio calculadora p_actor calc_X_pactor d_num* d_junta* if phase==2, vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
local pval_jk_int=r(table)[4,3]
*Bootstrap (student-t)
reg seconcilio calculadora p_actor calc_X_pactor d_num* d_junta* if phase==2, vce(bootstrap, cluster(cluster_v) rep($reps))
local pval_bt=r(table)[4,1]
local pval_bt_int=r(table)[4,3]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
reg seconcilio calculadora p_actor calc_X_pactor d_num* d_junta* if phase==2, vce(bootstrap, cluster(cluster_v) rep($reps) bca)
local pval_bca=r(table)[4,1]
local pval_bca_int=r(table)[4,3]
*Moulton (1986)
moulton seconcilio calculadora p_actor calc_X_pactor d_num* d_junta* if phase==2, cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
local pval_moulton_int=r(table)[4,3]
*Bias-reduced linearization ("clustered-HC2") (Bell-McCaffrey(2002))
brl seconcilio calculadora p_actor calc_X_pactor  d_num1 d_num2 d_junta1-d_junta4 if phase==2, cluster(cluster_v) 
local pval_brl=r(table)[4,1]
local pval_brl_int=r(table)[4,3]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich seconcilio calculadora p_actor calc_X_pactor d_num* d_junta* if phase==2, cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
local pval_pt_int=2*ttail(e(dfs)[1,3], abs(e(b)[1,3]/sqrt(e(V)[3,3])))	
su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & calculadora==0 & p_actor == 1
local IntContMean = `r(mean)'
test calculadora + calc_X_pactor = 0
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


preserve
keep if inlist(phase,1,2)
keep seconcilio calculadora cluster_v  numActores junta
*Randomization Inference (Fisher)
ritest calculadora _b[calculadora], cluster(cluster_v) reps($reps) seed(9435) : reg seconcilio calculadora i.numActores i.junta
local pval_ri = r(p)[1,1]
restore
*Robust standard error (Eicker-Huber-White)
reg seconcilio calculadora i.anioControl i.numActores i.junta if inlist(phase,1,2), robust
local pval_r=r(table)[4,1]
*Clustered std. errors (Liang-Zeger(1986))
reg seconcilio calculadora d_anioC* d_num* d_junta* if inlist(phase,1,2), vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
*Jackknife
reg seconcilio calculadora d_anioC* d_num* d_junta* if inlist(phase,1,2), vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
*Bootstrap (student-t)
reg seconcilio calculadora d_anioC* d_num* d_junta* if inlist(phase,1,2), vce(bootstrap, cluster(cluster_v) rep($reps))
local pval_bt=r(table)[4,1]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
reg seconcilio calculadora d_anioC* d_num* d_junta* if inlist(phase,1,2), vce(bootstrap, cluster(cluster_v) rep($reps) bca)
local pval_bca=r(table)[4,1]
*Moulton (1986)
moulton seconcilio calculadora d_anioC* d_num* d_junta* if inlist(phase,1,2), cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
*Bias-reduced linearization ("clustered-HC2") (Bell-McCaffrey(2002))
brl seconcilio calculadora d_anioC1-d_anioC7 d_num1 d_num2 d_junta1-d_junta4 if inlist(phase,1,2), cluster(cluster_v) 
local pval_brl=r(table)[4,1]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich seconcilio calculadora d_anioC* d_num* d_junta* if inlist(phase,1,2), cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
su seconcilio if e(sample) & calculadora==0 
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

	
	*Interaction employee present
preserve
keep if inlist(phase,1,2)
keep seconcilio calculadora p_actor  cluster_v anioControl numActores phase junta exp anio 
*Randomization Inference (Fisher)
ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], cluster(cluster_v) reps($reps) seed(9435) saveresampling("./_aux/ritest.dta"): reg seconcilio c.calculadora##c.p_actor i.anioControl i.numActores i.junta i.phase
ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], cluster(cluster_v) reps($reps) seed(9435) : reg seconcilio c.calculadora##c.p_actor i.anioControl i.numActores i.junta i.phase
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore
*Robust standard error (Eicker-Huber-White)
reg seconcilio calculadora p_actor calc_X_pactor i.anioControl i.numActores i.junta i.phase if inlist(phase,1,2), robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
*Clustered std. errors (Liang-Zeger(1986))
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase if inlist(phase,1,2), vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
local pval_cl_int=r(table)[4,3]
*Jackknife
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase if inlist(phase,1,2), vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
local pval_jk_int=r(table)[4,3]
*Bootstrap (student-t)
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase if inlist(phase,1,2), vce(bootstrap, cluster(cluster_v) rep($reps))
local pval_bt=r(table)[4,1]
local pval_bt_int=r(table)[4,3]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase if inlist(phase,1,2), vce(bootstrap, cluster(cluster_v) rep($reps) bca)
local pval_bca=r(table)[4,1]
local pval_bca_int=r(table)[4,3]
*Moulton (1986)
moulton seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase if inlist(phase,1,2), cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
local pval_moulton_int=r(table)[4,3]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase if inlist(phase,1,2), cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
local pval_pt_int=2*ttail(e(dfs)[1,3], abs(e(b)[1,3]/sqrt(e(V)[3,3])))	
su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & calculadora==0 & p_actor == 1
local IntContMean = `r(mean)'
test calculadora + calc_X_pactor = 0
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

preserve
keep if inlist(phase,1,2)
*Probit (FS)
probit p_actor i.calculadora time_hr2-time_hr8 i.anioControl i.numActores i.junta i.phase
cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*Probit - Interaction
reg seconcilio calculadora p_actor calc_X_pactor  i.anioControl i.numActores i.junta i.phase gen_resid_p , robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
local tau1=_b[calculadora]
local tau2=_b[calc_X_pactor]

drop calculadora
merge 1:1 junta exp anio using "./_aux/ritest.dta", nogen keepusing(calculadora*)
drop calculadora
local rank1=0
local rank2=0
local M=0
*Randomization Inference (Fisher)
foreach var of varlist calculadora* {
	cap drop calc_X_pactor
	gen calc_X_pactor=`var'*p_actor
	probit p_actor `var' time_hr2-time_hr8 i.anioControl i.numActores i.junta i.phase
	cap drop xb
	predict xb, xb
	*Generalized residuals
	cap drop gen_resid_pr
	gen gen_resid_pr = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	
	*CF : Probit - Interaction
	reg seconcilio `var' p_actor calc_X_pactor  i.anioControl i.numActores i.junta i.phase gen_resid_p
	if abs(_b[`var'])>=abs(`tau1') {
		local rank1=`rank1'+1
	}
	if abs(_b[calc_X_pactor])>=abs(`tau2')  {
		local rank2=`rank2'+1
	}
	local M=`M'+1
}
local pval_ri=`rank1'/`M'
local pval_ri_int=`rank2'/`M'
restore
*Probit (FS)
probit p_actor i.calculadora time_hr2-time_hr8 i.anioControl i.numActores i.junta i.phase if inlist(phase,1,2)
cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*Probit - Interaction
reg seconcilio calculadora p_actor calc_X_pactor  i.anioControl i.numActores i.junta i.phase gen_resid_p if inlist(phase,1,2), robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
test calculadora + calc_X_pactor = 0
local testInteraction=`r(p)'
*Randomization inference
local pval_ri = `pval_ri'
local pval_ri_int = `pval_ri_int'
*Clustered std. errors (Liang-Zeger(1986))
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase gen_resid_p if inlist(phase,1,2), vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
local pval_cl_int=r(table)[4,3]
*Jackknife
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase gen_resid_p if inlist(phase,1,2), vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
local pval_jk_int=r(table)[4,3]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase gen_resid_p if inlist(phase,1,2), vce(bootstrap, cluster(cluster_v) rep($reps) bca)
local pval_bca=r(table)[4,1]
local pval_bca_int=r(table)[4,3]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
reg_sandwich seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase gen_resid_p if inlist(phase,1,2), cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
local pval_pt_int=2*ttail(e(dfs)[1,3], abs(e(b)[1,3]/sqrt(e(V)[3,3])))
*Moulton (1986)
moulton seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase gen_resid_p if inlist(phase,1,2), cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
local pval_moulton_int=r(table)[4,3]

*Bootstrap (student-t)
eststo : reg seconcilio calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase gen_resid_p if inlist(phase,1,2), vce(bootstrap, cluster(cluster_v) rep($reps))
local pval_bt=r(table)[4,1]
local pval_bt_int=r(table)[4,3]	
su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & calculadora==0 & p_actor == 1
local IntContMean = `r(mean)'
test calculadora + calc_X_pactor = 0
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
keep if inlist(phase,1,2)
keep convenio_m5m calculadora p_actor calc_X_pactor cluster_v anioControl numActores phase junta exp anio 
*Randomization Inference (Fisher)
ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], cluster(cluster_v) reps($reps) seed(9435) : reg convenio_m5m c.calculadora##c.p_actor i.anioControl i.numActores i.junta i.phase
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore
*Robust standard error (Eicker-Huber-White)
reg convenio_m5m calculadora p_actor calc_X_pactor i.anioControl i.numActores i.junta i.phase if inlist(phase,1,2), robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
*Clustered std. errors (Liang-Zeger(1986))
reg convenio_m5m calculadora p_actor calc_X_pactor i.anioControl i.numActores i.junta i.phase if inlist(phase,1,2), vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
local pval_cl_int=r(table)[4,3]
*Jackknife
reg convenio_m5m calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase if inlist(phase,1,2), vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
local pval_jk_int=r(table)[4,3]
*Bootstrap (student-t)
reg convenio_m5m calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase if inlist(phase,1,2), vce(bootstrap, cluster(cluster_v) rep($reps))
local pval_bt=r(table)[4,1]
local pval_bt_int=r(table)[4,3]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
reg convenio_m5m calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase if inlist(phase,1,2), vce(bootstrap, cluster(cluster_v) rep($reps) bca)
local pval_bca=r(table)[4,1]
local pval_bca_int=r(table)[4,3]
*Moulton (1986)
moulton convenio_m5m calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase if inlist(phase,1,2), cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
local pval_moulton_int=r(table)[4,3]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich convenio_m5m calculadora p_actor calc_X_pactor d_anioC* d_num* d_junta* phase if inlist(phase,1,2), cluster(cluster_v) 
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
local pval_pt_int=2*ttail(e(dfs)[1,3], abs(e(b)[1,3]/sqrt(e(V)[3,3])))	
su convenio_m5m if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su convenio_m5m if e(sample) & calculadora==0 & p_actor == 1
local IntContMean = `r(mean)'
test calculadora + calc_X_pactor = 0
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


	*********************************
	*			PHASE 3				*
	********************************* 
	
preserve	
keep if phase==3
keep doble_convenio calculadora gen c_antiguedad salario_diario cluster_v phase 
*Randomization Inference (Fisher)
ritest calculadora _b[calculadora], cluster(cluster_v) reps($reps) seed(9435) : reg doble_convenio calculadora gen c_antiguedad salario_diario 
local pval_ri = r(p)[1,1]
restore
*Robust standard error (Eicker-Huber-White)
reg doble_convenio calculadora gen c_antiguedad salario_diario if phase==3, robust 
local pval_r=r(table)[4,1]
*Clustered std. errors (Liang-Zeger(1986))
reg doble_convenio calculadora gen c_antiguedad salario_diario  if phase==3, vce(cluster cluster_v)
local pval_cl=r(table)[4,1]
*Jackknife
reg doble_convenio calculadora gen c_antiguedad salario_diario  if phase==3, vce(jackknife, cluster(cluster_v))
local pval_jk=r(table)[4,1]
*Bootstrap (student-t)
reg doble_convenio calculadora gen c_antiguedad salario_diario  if phase==3, vce(bootstrap, cluster(cluster_v) rep($reps))
local pval_bt=r(table)[4,1]
*Bootstrap (BCa) (Efron (1987), Efron-Tibshirani(1993))
reg doble_convenio calculadora gen c_antiguedad salario_diario  if phase==3, vce(bootstrap, cluster(cluster_v) rep($reps) bca)
local pval_bca=r(table)[4,1]
*Moulton (1986)
moulton doble_convenio calculadora gen c_antiguedad salario_diario  if phase==3, cluster(cluster_v) 
local pval_moulton=r(table)[4,1]
*Bias-reduced linearization ("clustered-HC2") (Bell-McCaffrey(2002))
brl doble_convenio calculadora gen c_antiguedad salario_diario  if phase==3, cluster(cluster_v)
local pval_brl=r(table)[4,1]
*Small sample CRVE (Pustejovsky-Tipton(2018), Imbens-Kolesar(2016))
eststo : reg_sandwich doble_convenio calculadora gen c_antiguedad salario_diario  if phase==3, cluster(cluster_v)
local pval_pt=2*ttail(e(dfs)[1,1], abs(e(b)[1,1]/sqrt(e(V)[1,1])))
su doble_convenio if e(sample) & calculadora==0
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
esttab using "$directorio/Tables/effect_treatment_settlement_se.csv", se r2 ${star} b(a3) ///
		keep(calculadora p_actor calc_X_pactor gen_resid_pr) scalars("DepVarMean DepVarMean" "IntContMean IntContMean" "testInteraction testInteraction" ///
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
	
