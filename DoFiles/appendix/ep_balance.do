/*Table C7:  Balance regression on characteristics conditional on employee present*/
/*
The table shows results of regressions with the specification 
$y_i = \alpha_t + \sum_{j = 1,2}\beta_{j} T_{j} + \epsilon_{i}$, 
where j refers to the treatment assignment ${calculator, conciliator}$.
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
abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem abogado_pub
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
abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem abogado_pub
append using `temp_p2'
replace phase=1 if missing(phase)



********************************************************************************

*CONDITIONAL ON EP
keep if p_actor==1


tab junta, gen(junta)

for var abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem junta1-junta5: egen Xs=std(X)

local bvc abogado_pubs gens trabajador_bases c_antiguedads salario_diarios horas_sems

	eststo clear
	
	
foreach var of varlist `bvc' {	
	eststo: reg `var' i.treatment junta2s-junta5s if treatment!=0, robust  cluster(fecha)
	estadd scalar Erre=e(r2)	
	estadd scalar F_stat=e(F)
	estadd local Junta="YES"
	}
		
		
	*************************
	esttab using "$sharelatex/Tables/reg_results/ep_balance.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "F_stat F_stat" "Junta Court dummies") replace 

		

