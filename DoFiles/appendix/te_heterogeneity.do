/*Table C15: Heterogeneity in treatment effects*/
/*
We test for heterogeneity of treatment effects by interacting treatment 
with the variable shown in the column header.
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

keep seconcilio convenio_2m convenio_5m fecha junta fecha treatment p_actor ///
 abogado_pub salario_diario gen c_antiguedad horas_sem min_ley
gen phase=2
tempfile temp_p2
save `temp_p2'

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

keep seconcilio convenio_2m convenio_5m fecha junta fecha treatment p_actor ///
 abogado_pub salario_diario gen c_antiguedad  horas_sem min_ley
append using `temp_p2'
replace phase=1 if missing(phase)

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
	eststo: reg seconcilio i.treatment##i.interaction i.junta if treatment!=0 & phase==1, robust  cluster(fecha)
	estadd scalar Erre=e(r2)
	qui su seconcilio if e(sample)
	estadd scalar DepVarMean=r(mean)
	
	
	*********************************
	*			PHASE 2				*
	*********************************
	
	*Same day conciliation
	eststo: reg seconcilio i.treatment##i.interaction i.junta if treatment!=0 & phase==2, robust  cluster(fecha)
	estadd scalar Erre=e(r2)
	qui su seconcilio if e(sample)
	estadd scalar DepVarMean=r(mean)

	
	*********************************
	*			POOLED				*
	*********************************
	
	*Interaction employee was present
	eststo: reg seconcilio i.treatment##i.p_actor##i.interaction i.junta if treatment!=0, robust  cluster(fecha)
	estadd scalar Erre=e(r2)
	qui su seconcilio if e(sample)
	
}	
	
	*************************
	esttab using "$sharelatex/Tables/reg_results/te_heterogeneity.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "DepVarMean DepVarMean" "IntMean InteractionVarMean" "Pvalue Pvalue" "Pvalue_ Pvalue_") replace 

	
