
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	treatment_effects_interactions
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: October. 25, 2021  
* Modifications:		
* Files used:     
		- phase_1.dta
		- phase_2.dta

* Files created:  
		- treatment_effects_interactions.csv

* Purpose: This table estimates the main treatment effects with controls and interactions with this controls

*******************************************************************************/
*/


global balance_var trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley gen p_ractor p_dem p_rdem

* Phase 2
********************************************************************************
use "./DB/phase_2.dta", clear
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores phase $balance_var
tempfile p2
save `p2', replace

* Phase 1
********************************************************************************
use "./DB/phase_1.dta" , clear	
keep seconcilio convenio_m5m fecha junta exp anio fecha treatment p_actor numActores phase $balance_var
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

*define clusters
egen gp=group(exp anio)
egen fechaJunta=group(junta fecha)
replace fechaJunta=fechaJunta+1481 
gen cluster_v=.
replace cluster_v=gp if phase==1
replace cluster_v=fechaJunta if phase==2 

********************************************************************************
********************************************************************************

	*********************************
	*			PHASE 1/2			*
	********************************* 
eststo clear	

* Clustered std. errors (Liang-Zeger(1986))
eststo :  reg seconcilio i.calculadora##i.p_actor i.numActores i.junta i.anioControl i.phase, vce(cluster cluster_v)


* Adding controls 
eststo : reg seconcilio i.calculadora##i.p_actor  $balance_var i.numActores i.junta i.anioControl i.phase, vce(cluster cluster_v)
test $balance_var


* Adding interaction with controls 
eststo : reg seconcilio i.calculadora##i.p_actor  i.calculadora##(i.trabajador_base i.abogado_pub  i.indem i.prima_antig i.p_ractor i.p_dem i.p_rdem i.gen) ///
i.calculadora##(c.c_antiguedad c.salario_diario c.min_ley) ///
 i.numActores i.junta i.anioControl i.phase, vce(cluster cluster_v)

test 1.calculadora#1.trabajador_base 1.calculadora#1.abogado_pub  1.calculadora#1.indem 1.calculadora#1.prima_antig 1.calculadora#1.p_ractor 1.calculadora#1.p_dem 1.calculadora#1.p_rdem 1.calculadora#1.gen ///
1.calculadora#c.c_antiguedad   1.calculadora#c.salario_diario 1.calculadora#c.min_ley 
estadd scalar F_stat = `r(F)'
estadd scalar pval_F = `r(p)'


*********************Private Lawywer sample************************

* Clustered std. errors (Liang-Zeger(1986))
eststo : reg seconcilio i.calculadora##i.p_actor i.numActores i.junta i.anioControl i.phase if abogado_pub==0, vce(cluster cluster_v)


* Adding controls 
eststo : reg seconcilio i.calculadora##i.p_actor  $balance_var i.numActores i.junta i.anioControl i.phase if abogado_pub==0, vce(cluster cluster_v)
test $balance_var


* Adding interaction with controls 
eststo : reg seconcilio i.calculadora##i.p_actor  i.calculadora##(i.trabajador_base i.abogado_pub  i.indem i.prima_antig i.p_ractor i.p_dem i.p_rdem i.gen) ///
i.calculadora##(c.c_antiguedad  c.salario_diario c.min_ley) ///
 i.numActores i.junta i.anioControl i.phase if abogado_pub==0, vce(cluster cluster_v)

test 1.calculadora#1.trabajador_base 1.calculadora#1.indem 1.calculadora#1.prima_antig 1.calculadora#1.p_ractor 1.calculadora#1.p_dem 1.calculadora#1.p_rdem 1.calculadora#1.gen ///
1.calculadora#c.c_antiguedad 1.calculadora#c.salario_diario 1.calculadora#c.min_ley 
estadd scalar F_stat = `r(F)'
estadd scalar pval_F = `r(p)'



*-------------------------------------------------------------------------------
esttab using "$directorio/Tables/appendix/c/treatment_effects_interactions.csv", se r2 ${star} b(a2) scalars("F_stat F_stat" "pval_F pval_F") keep(1.calculadora 1.p_actor 1.calculadora#1.p_actor) replace 

		
		




