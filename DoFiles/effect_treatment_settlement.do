
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


	*********************************
	*			PHASE 1				*
	********************************* 
	
	*Same day conciliation
preserve
keep if phase==1
keep seconcilio calculadora anioControl numActores fecha cluster_v
*Randomization Inference (Fisher)
qui ritest calculadora _b[calculadora], cluster(cluster_v) reps($reps) seed(9435) : areg seconcilio calculadora i.anioControl i.numActores, absorb(fecha)
local pval_ri = r(p)[1,1]
restore	

*Clustered std. errors (Liang-Zeger(1986))
eststo : areg seconcilio calculadora i.anioControl i.numActores if phase==1, absorb(fecha) vce(cluster cluster_v)
su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & calculadora==0 & p_actor == 1

estadd scalar DepVarMean = `DepVarMean'
estadd scalar pval_ri = `pval_ri'


*-------------------------------------------------------------------------------

	*Interaction employee present
preserve
keep if phase==1
keep seconcilio calculadora p_actor anioControl numActores fecha cluster_v
*Randomization Inference (Fisher)
qui ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], cluster(cluster_v) reps($reps) seed(9435) : areg seconcilio c.calculadora##c.p_actor i.anioControl i.numActores, absorb(fecha)
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore

*Clustered std. errors (Liang-Zeger(1986))
eststo : areg seconcilio c.calculadora##c.p_actor i.anioControl i.numActores if phase==1, absorb(fecha) vce(cluster cluster_v)
su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & calculadora==0 & p_actor == 1
local IntContMean = `r(mean)'
qui test calculadora + c.calculadora#c.p_actor = 0
local testInteraction=`r(p)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar IntContMean = `IntContMean'
estadd scalar testInteraction = `testInteraction'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_ri_int = `pval_ri_int'


	*********************************
	*			PHASE 2				*
	********************************* 
	
	*Same day conciliation
preserve
keep if phase==2
keep seconcilio calculadora cluster_v  numActores junta 
*Randomization Inference (Fisher)
qui ritest calculadora _b[calculadora], cluster(cluster_v) reps($reps) seed(9435) : reg seconcilio calculadora i.numActores i.junta
local pval_ri = r(p)[1,1]
restore

*Clustered std. errors (Liang-Zeger(1986))
eststo : reg seconcilio calculadora i.numActores i.junta if phase==2, vce(cluster cluster_v)
su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar pval_ri = `pval_ri'


*-------------------------------------------------------------------------------

	*Interaction employee present
preserve
keep if phase==2
keep seconcilio calculadora p_actor cluster_v numActores junta
*Randomization Inference (Fisher)
qui ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], cluster(cluster_v) reps($reps) seed(9435) : reg seconcilio c.calculadora##c.p_actor i.numActores i.junta
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore

*Clustered std. errors (Liang-Zeger(1986))
eststo : reg seconcilio c.calculadora##c.p_actor i.numActores i.junta if phase==2, vce(cluster cluster_v)

su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & calculadora==0 & p_actor == 1
local IntContMean = `r(mean)'
qui test calculadora + c.calculadora#c.p_actor = 0
local testInteraction=`r(p)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar IntContMean = `IntContMean'
estadd scalar testInteraction = `testInteraction'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_ri_int = `pval_ri_int'


	*********************************
	*			PHASE 1/2			*
	********************************* 

preserve
keep if inlist(phase,1,2)
keep seconcilio calculadora cluster_v  numActores junta phase anioControl
*Randomization Inference (Fisher)
qui ritest calculadora _b[calculadora], cluster(cluster_v) reps($reps) seed(9435) : reg seconcilio calculadora i.numActores i.junta i.phase i.anioControl
local pval_ri = r(p)[1,1]
restore

*Clustered std. errors (Liang-Zeger(1986))
eststo : reg seconcilio calculadora i.numActores i.junta i.anioControl i.phase if inlist(phase,1,2), vce(cluster cluster_v)
su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar pval_ri = `pval_ri'

	*Interaction employee present
preserve
keep if inlist(phase,1,2)
keep seconcilio calculadora p_actor cluster_v anioControl numActores phase junta exp anio 
*Randomization Inference (Fisher)
qui ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], cluster(cluster_v) reps($reps) seed(9435) saveresampling("./_aux/ritest.dta"): reg seconcilio c.calculadora##c.p_actor i.anioControl i.numActores i.junta i.phase
qui ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], cluster(cluster_v) reps($reps) seed(9435) : reg seconcilio c.calculadora##c.p_actor i.anioControl i.numActores i.junta i.phase
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore

*Clustered std. errors (Liang-Zeger(1986))
eststo : reg seconcilio c.calculadora##c.p_actor i.anioControl i.numActores i.junta i.phase if inlist(phase,1,2), vce(cluster cluster_v)
su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & calculadora==0 & p_actor == 1
local IntContMean = `r(mean)'
qui test calculadora + c.calculadora#c.p_actor = 0
local testInteraction=`r(p)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar IntContMean = `IntContMean'
estadd scalar testInteraction = `testInteraction'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_ri_int = `pval_ri_int'


*-------------------------------------------------------------------------------

preserve
keep if inlist(phase,1,2)
*Probit (FS)
qui probit p_actor i.calculadora time_hr2-time_hr8 i.anioControl i.numActores i.junta i.phase if inlist(phase,1,2)
cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*Probit - Interaction
qui reg seconcilio c.calculadora##c.p_actor  i.anioControl i.numActores i.junta i.phase gen_resid_p if inlist(phase,1,2), robust
local pval_r=r(table)[4,1]
local pval_r_int=r(table)[4,3]
local tau1=_b[calculadora]
local tau2=_b[c.calculadora#c.p_actor]

drop calculadora
merge 1:1 junta exp anio using "./_aux/ritest.dta", nogen keepusing(calculadora*)
drop calculadora
local rank1=0
local rank2=0
local M=0
*Randomization Inference (Fisher)
foreach var of varlist calculadora* {
	cap drop treat_p_actor
	qui gen treat_p_actor=`var'*p_actor
	qui probit p_actor `var' time_hr2-time_hr8 i.anioControl i.numActores i.junta i.phase if inlist(phase,1,2)
	cap drop xb
	qui predict xb, xb
	*Generalized residuals
	cap drop gen_resid_pr
	qui gen gen_resid_pr = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	
	*CF : Probit - Interaction
	qui reg seconcilio `var' p_actor treat_p_actor  i.anioControl i.numActores i.junta i.phase gen_resid_p if inlist(phase,1,2)
	if abs(_b[`var'])>=abs(`tau1') {
		local rank1=`rank1'+1
	}
	if abs(_b[treat_p_actor])>=abs(`tau2')  {
		local rank2=`rank2'+1
	}
	local M=`M'+1
}
local pval_ri=`rank1'/`M'
local pval_ri_int=`rank2'/`M'
restore

*Probit (FS)
qui probit p_actor i.calculadora time_hr2-time_hr8 i.anioControl i.numActores i.junta i.phase if inlist(phase,1,2)
cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*Randomization inference
local pval_ri = `pval_ri'
local pval_ri_int = `pval_ri_int'

*Bootstrap (student-t)
eststo : reg seconcilio c.calculadora##c.p_actor i.anioControl i.numActores i.junta i.phase gen_resid_p if inlist(phase,1,2), vce(bootstrap, cluster(cluster_v) rep($reps))

su seconcilio if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su seconcilio if e(sample) & calculadora==0 & p_actor == 1
local IntContMean = `r(mean)'
qui test calculadora + c.calculadora#c.p_actor = 0
local testInteraction=`r(p)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar IntContMean = `IntContMean'
estadd scalar testInteraction = `testInteraction'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_ri_int = `pval_ri_int'

*-------------------------------------------------------------------------------

	*Long run
preserve
keep if inlist(phase,1,2)
keep convenio_m5m calculadora p_actor cluster_v anioControl numActores phase junta exp anio 
*Randomization Inference (Fisher)
qui ritest calculadora _b[calculadora] _b[c.calculadora#c.p_actor], cluster(cluster_v) reps($reps) seed(9435) : reg convenio_m5m c.calculadora##c.p_actor i.anioControl i.numActores i.junta i.phase
local pval_ri = r(p)[1,1]
local pval_ri_int = r(p)[1,2]
restore

*Clustered std. errors (Liang-Zeger(1986))
eststo : reg convenio_m5m c.calculadora##c.p_actor i.anioControl i.numActores i.junta i.phase if inlist(phase,1,2), vce(cluster cluster_v)
su convenio_m5m if e(sample) & calculadora==0 
local DepVarMean = `r(mean)'
su convenio_m5m if e(sample) & calculadora==0 & p_actor == 1
local IntContMean = `r(mean)'
qui test calculadora + c.calculadora#c.p_actor = 0
local testInteraction=`r(p)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar IntContMean = `IntContMean'
estadd scalar testInteraction = `testInteraction'
estadd scalar pval_ri = `pval_ri'
estadd scalar pval_ri_int = `pval_ri_int'

*-------------------------------------------------------------------------------


	*********************************
	*			PHASE 3				*
	********************************* 
	
preserve	
keep if phase==3
keep doble_convenio calculadora gen c_antiguedad salario_diario cluster_v phase 
*Randomization Inference (Fisher)
qui ritest calculadora _b[calculadora], cluster(cluster_v) reps($reps) seed(9435) : reg doble_convenio calculadora gen c_antiguedad salario_diario 
local pval_ri = r(p)[1,1]
restore

*Clustered std. errors (Liang-Zeger(1986))
eststo : reg doble_convenio calculadora gen c_antiguedad salario_diario if phase==3, vce(cluster cluster_v)
su doble_convenio if e(sample) & calculadora==0
local DepVarMean = `r(mean)'

estadd scalar DepVarMean = `DepVarMean'
estadd scalar pval_ri = `pval_ri'

*-------------------------------------------------------------------------------

*Save results	
esttab using "$directorio/Tables/effect_treatment_settlement.csv", se r2 ${star} b(a2) ///
		keep(calculadora p_actor c.calculadora#c.p_actor gen_resid_pr) ///
		scalars("DepVarMean DepVarMean" "IntContMean IntContMean" "testInteraction testInteraction" ///
		"pval_ri pval_ri" ///
		"pval_ri_int pval_ri_int") replace 
	
