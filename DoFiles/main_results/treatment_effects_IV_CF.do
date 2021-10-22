/*Table 4—:  Treatment Effects*/
/*
We add a control for potential endogeneity of the presence of the employee
Column (9)
*/
********************************************************************************

use "$scaleup/DB/scaleup_operation.dta", clear
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$scaleup/DB/scaleup_casefiles_wod.dta" , nogen  keep(1 3)

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

keep seconcilio convenio_2m convenio_5m fecha junta fecha treatment p_actor abogado_pub ///
	time_hearing time_hr /* addresses_* distance  duration */
gen phase=2
tempfile temp_p2
save `temp_p2'

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)

*Presence employee
replace p_actor=(p_actor==1)
*Not in experiment
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment


*Time hearing (Instrument)
gen time_hearing=substr(horarioaudiencia,strpos(horarioaudiencia," "),length(horarioaudiencia))
egen time_hr=group(time_hearing)

keep seconcilio convenio_2m convenio_5m fecha junta fecha treatment p_actor abogado_pub ///
	time_hearing time_hr /*addresses_*  distance duration */
append using `temp_p2'
replace phase=1 if missing(phase)




********************************************************************************
********************************************************************************
********************************************************************************
*REGRESSIONS
*
*Instrument
gen time_instrument=inlist(time_hr,1,2,7,8) if !missing(time_hr) 
gen time_actor=time_instrument*p_actor

gen treat_inst=treatment*time_instrument
gen treat_p_actor=treatment*p_actor


*********************************************

eststo clear

*OLS (FS)
eststo: reg p_actor i.treatment time_instrument i.junta, r cluster(fecha)
qui  test 2.treatment=3.treatment
estadd scalar Pvalue_c=r(p)	

*Probit (FS)
eststo: probit p_actor i.treatment time_instrument i.junta, r cluster(fecha)
qui  test 2.treatment=3.treatment
estadd scalar Pvalue_c=r(p)	

cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*Probit - Interaction
eststo: reg seconcilio i.treatment##i.p_actor i.junta gen_resid_pr, vce(bootstrap, reps(1000)) cluster(fecha)
qui su seconcilio if e(sample)
estadd scalar DepVarMean=r(mean)
qui su p_actor if e(sample)
estadd scalar IntMean=r(mean)
qui  test 2.treatment=3.treatment
estadd scalar Pvalue_c=r(p)	
qui  test 2.treatment#1.p_actor=3.treatment#1.p_actor
estadd scalar Pvalue=r(p)
	

*Now use dummy variables for time groups
tab time_hr, gen(time_hr)
foreach var of varlist time_hr2-time_hr8 {
	gen treat_`var'=treatment*`var'
	}
	
*Probit (FS)
eststo: probit p_actor i.treatment i.junta time_hr2-time_hr8, r cluster(fecha)
qui  test 2.treatment=3.treatment
estadd scalar Pvalue_c=r(p)	

cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr8 = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*Probit - Interaction
eststo: reg seconcilio i.treatment##i.p_actor i.junta  gen_resid_pr8, vce(bootstrap, reps(1000)) cluster(fecha)
qui su seconcilio if e(sample)
estadd scalar DepVarMean=r(mean)
qui su p_actor if e(sample)
estadd scalar IntMean=r(mean)
qui  test 2.treatment=3.treatment
estadd scalar Pvalue_c=r(p)	
qui  test 2.treatment#1.p_actor=3.treatment#1.p_actor
estadd scalar Pvalue=r(p)	

		*************************
		esttab using "$sharelatex/Tables/reg_results/treatment_effects_IV_CF.csv", se r2 star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
		 scalars("DepVarMean DepVarMean" "IntMean InteractionVarMean" "Pvalue_c Pvalue_c" "Pvalue Pvalue" ) replace 
