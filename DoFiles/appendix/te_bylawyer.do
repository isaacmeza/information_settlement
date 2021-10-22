/*Table C14: Treatment Effects conditional on type of lawyer*/
/*
This dofile reproduces the main treatment effects but by type of lawyer
*/

********************************************************************************

use "$scaleup\DB\scaleup_operation.dta", clear
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$scaleup\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

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

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub
gen phase=2
tempfile temp_p2
save `temp_p2'

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub
append using `temp_p2'
replace phase=1 if missing(phase)


*Follow-up (more than 5 months)
merge m:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", nogen

*Settlement
replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1


********************************************************************************
	preserve
	keep if abogado_pub==0
	eststo clear
	
	
	
	*********************************
	*			POOLED				*
	*********************************
	
	*Same day
	eststo: reg seconcilio i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	estadd scalar Erre=e(r2)
	qui su seconcilio if e(sample)
	estadd scalar DepVarMean=r(mean)
	qui su p_actor if e(sample)
	estadd scalar IntMean=r(mean)
	qui  test 2.treatment#1.p_actor=3.treatment#1.p_actor
	estadd scalar Pvalue=r(p)
	
	*2 months
	eststo: reg convenio_2m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	estadd scalar Erre=e(r2)
	qui su convenio_2m if e(sample)
	estadd scalar DepVarMean=r(mean)
	qui su p_actor if e(sample)
	estadd scalar IntMean=r(mean)
	qui  test 2.treatment#1.p_actor=3.treatment#1.p_actor
	estadd scalar Pvalue=r(p)
	
	*5 months
	eststo: reg convenio_5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	estadd scalar Erre=e(r2)
	qui su convenio_5m if e(sample)
	estadd scalar DepVarMean=r(mean)
	qui su p_actor if e(sample)
	estadd scalar IntMean=r(mean)
	qui  test 2.treatment#1.p_actor=3.treatment#1.p_actor
	estadd scalar Pvalue=r(p)
	
	*5+ months
	eststo: reg convenio_m5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	estadd scalar Erre=e(r2)
	qui su convenio_5m if e(sample)
	estadd scalar DepVarMean=r(mean)
	qui su p_actor if e(sample)
	estadd scalar IntMean=r(mean)
	qui  test 2.treatment#1.p_actor=3.treatment#1.p_actor
	estadd scalar Pvalue=r(p)

	*************************
	esttab using "$sharelatex/Tables/reg_results/te_private.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "IntMean InteractionVarMean" "Pvalue Pvalue" "Pvalue_ Pvalue_") replace 

	restore
	

********************************************************************************	
	preserve
	keep if abogado_pub==1
	eststo clear

	
	
	
	*********************************
	*			POOLED				*
	*********************************
	
	*Same day
	eststo: reg seconcilio i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	estadd scalar Erre=e(r2)
	qui su seconcilio if e(sample)
	estadd scalar DepVarMean=r(mean)
	qui su p_actor if e(sample)
	estadd scalar IntMean=r(mean)
	qui  test 2.treatment#1.p_actor=3.treatment#1.p_actor
	estadd scalar Pvalue=r(p)
	
	*2 months
	eststo: reg convenio_2m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	estadd scalar Erre=e(r2)
	qui su convenio_2m if e(sample)
	estadd scalar DepVarMean=r(mean)
	qui su p_actor if e(sample)
	estadd scalar IntMean=r(mean)
	qui  test 2.treatment#1.p_actor=3.treatment#1.p_actor
	estadd scalar Pvalue=r(p)
	
	*5 months
	eststo: reg convenio_5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	estadd scalar Erre=e(r2)
	qui su convenio_5m if e(sample)
	estadd scalar DepVarMean=r(mean)
	qui su p_actor if e(sample)
	estadd scalar IntMean=r(mean)
	qui  test 2.treatment#1.p_actor=3.treatment#1.p_actor
	estadd scalar Pvalue=r(p)
	
	*5+ months
	eststo: reg convenio_m5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	estadd scalar Erre=e(r2)
	qui su convenio_5m if e(sample)
	estadd scalar DepVarMean=r(mean)
	qui su p_actor if e(sample)
	estadd scalar IntMean=r(mean)
	qui  test 2.treatment#1.p_actor=3.treatment#1.p_actor
	estadd scalar Pvalue=r(p)


	*************************
	esttab using "$sharelatex/Tables/reg_results/te_public.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "IntMean InteractionVarMean" "Pvalue Pvalue" ) replace 

	restore
		

	
