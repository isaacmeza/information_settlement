/*******************************************************************************
This do file generates all previous variables and does some cleaning of the data
*******************************************************************************/

clear
set more off

********************************************************************************

********************************************************************************

import delimited ".\DB\scaleup_paired_courts.csv", clear

drop salario_diario
rename sueldo salario_diario

destring min_ley, force replace
rename antig c_antiguedad
destring c_antiguedad, force replace

save ".\DB\scaleup_paired_courts.dta", replace


********************************************************************************

import delimited ".\DB\scaleup_casefiles.csv", clear

/***********************
   CLEANING VARIABLES
************************/
drop salario_diario
rename sueldo salario_diario

*append using ".\DB\scaleup_paired_courts.dta", force
keep if inlist(junta, 2, 7, 9, 11, 16)

bysort junta exp anio:  gen numActores = _N
by junta exp anio: gen valorTotal = sum(c_total)

duplicates drop  exp anio junta, force


save ".\DB\scaleup_casefiles_wod.dta", replace

*Lawyers name cleaning
do ".\DoFiles\cleaning\name_cleaning_scaleup.do"

********************************************************************************
*Settlements - after treatment
*IMPORTANT: We only consider information regarding settlements

import excel ".\Raw\Expedientes archivados sin Modo de Termino.xlsx", sheet("Nuevo Control") cellrange(A2:AA951) firstrow case(lower) clear
drop if missing(junta) & missing(exp) & missing(año)

destring cantidadpagada, replace force
gen fecha_termino_ = date(fechatermino,"DMY")
format fecha_termino_ %td
gen convenio_seg_=(strpos(upper(modotermino), "CONVENIO")!=0)
gen cantidad_convenio_ = cantidadpagada if convenio_seg==1

keep junta exp año convenio_seg_ fecha_termino_ cantidad_convenio_
tempfile temp_con_
save `temp_con_'

import excel ".\Raw\Expedientes_Calculadora_y_Conciliacion_con_juntas_homologas_.xlsx", sheet("ListaSeguimientoIsaac") firstrow case(lower) clear
duplicates drop junta exp año, force

destring cantidadpagada, replace 
gen fecha_termino = date(substr(fechatermino,1,10),"YMD")
format fecha_termino %td
gen convenio_seg = (strpos(upper(modotermino), "CONVENIO")!=0)
gen cantidad_convenio = cantidadpagada if convenio_seg==1
merge 1:1 junta exp año using `temp_con_'
replace fecha_termino=fecha_termino_ if _merge==3
replace convenio_seg=convenio_seg_ if _merge==3
replace cantidad_convenio=cantidad_convenio_ if _merge==3
drop _merge

keep if convenio_seg==1 
keep junta expediente año convenio_seg cantidad_convenio  fecha_termino 

tempfile temp_con_seg
save  `temp_con_seg'

********************************************************************************
import delimited ".\DB\scaleup_operation.csv", clear 


*Checar con Moni Posili

drop update*
drop junta_2
drop v1
drop if num_actor=="0"

/***********************
   CLEANING VARIABLES
************************/

*Presence of parts
foreach var of varlist p_* {
	destring `var', replace force
	replace `var'=1 if !missing(`var') & `var'>1
	}
 
*Destring
foreach var of varlist num_actores {
	destring `var', replace force
	}
	
replace cantidad_convenio=. if convenio==0	

	
/***********************
   GENERATE VARIABLES
************************/


*Treatment variable
gen dia_tratamiento=(num_actor!=0 & num_actor!=.)


*Update in beleifs

foreach var of varlist ea8_prob_pago_s ea1_prob_pago ea9_cantidad_pago_s ea2_cantidad_pago ///
	era4_prob_pago_s era1_prob_pago era5_cantidad_pago_s era2_cantidad_pago ///
	erd4_prob_pago_s erd1_prob_pago erd5_cantidad_pago_s erd2_cantidad_pago {
	
	qui su `var'
	replace `var'= 10 if `var'==0 & `r(max)'==100
	qui xtile perc_`var'=`var', n(99)
	qui su `var'
	replace `var'=. if perc_`var'>=99 & `r(max)'!=100
	
	}

foreach var of varlist  ea2_cantidad_pago ea9_cantidad_pago_s ///
	era2_cantidad_pago	era5_cantidad_pago_s ///
	erd2_cantidad_pago erd5_cantidad_pago_s	 {
	
	gen `var'_m1=`var'+1
	gen log_`var'=log(`var'_m1)
	drop `var'_m1
		
	}		
	
gen diff_prob_a=(ea8_prob_pago_s-ea1_prob_pago)
gen diff_pago_a=(ea9_cantidad_pago_s-ea2_cantidad_pago)

gen diff_prob_ra=(era4_prob_pago_s-era1_prob_pago)
gen diff_pago_ra=(era5_cantidad_pago_s-era2_cantidad_pago)

gen diff_prob_rd=(erd4_prob_pago_s-erd1_prob_pago)
gen diff_pago_rd=(erd5_cantidad_pago_s-erd2_cantidad_pago)

	
foreach var of varlist diff_* {
	qui xtile perc_`var'=`var', n(99)
	replace `var'=. if perc_`var'>=95
	}
	
	
gen update_prob_a=diff_prob_a/ea1_prob_pago
gen update_pago_a=diff_pago_a/ea2_cantidad_pago

gen update_prob_ra=diff_prob_ra/era1_prob_pago
gen update_pago_ra=diff_pago_ra/era2_cantidad_pago

gen update_prob_rd=diff_prob_rd/erd1_prob_pago
gen update_pago_rd=diff_pago_rd/erd2_cantidad_pago

	
foreach var of varlist update_* {
	qui xtile perc_`var'=`var', n(99)
	replace `var'=. if perc_`var'>=95
	}
	
*Conciliators
gen ANA=(conciliadores=="ANA")
gen LUCIA=(conciliadores=="LUCIA")
gen JACQUIE=(conciliadores=="JACQUIE")
gen MARINA=(conciliadores=="MARINA")
gen KARINA=(conciliadores=="KARINA")
gen MARIBEL=(conciliadores=="MARIBEL")
gen DEYANIRA=(conciliadores=="DEYANIRA")
gen GUSTAVO=(conciliadores=="GUSTAVO")
gen CORRAL=(conciliadores=="CORRAL")
gen AGUSTIN=(conciliadores=="AGUSTIN")
gen MARGARITA=(conciliadores=="MARGARITA")
gen LUPITA=(conciliadores=="LUPITA")
gen ISAAC=(conciliadores=="ISAAC")
gen HIGUERA=(conciliadores=="HIGUERA")
gen DOCTOR=(conciliadores=="DOCTOR")
gen CESAR=(conciliadores=="CESAR")


egen ANA_D = noccur(conciliadores), string("ANA")
egen LUCIA_D = noccur(conciliadores), string("LUCIA")
egen JACQUIE_D = noccur(conciliadores), string("JACQUIE")
egen MARINA_D = noccur(conciliadores), string("MARINA")
egen KARINA_D = noccur(conciliadores), string("KARINA")
egen MARIBEL_D = noccur(conciliadores), string("MARIBEL")
egen DEYANIRA_D = noccur(conciliadores), string("DEYANIRA")
egen GUSTAVO_D = noccur(conciliadores), string("GUSTAVO")
egen CORRAL_D = noccur(conciliadores), string("CORRAL")
egen AGUSTIN_D = noccur(conciliadores), string("AGUSTIN")
egen MARGARITA_D = noccur(conciliadores), string("MARGARITA")
egen LUPITA_D = noccur(conciliadores), string("LUPITA")
egen ISAAC_D = noccur(conciliadores), string("ISAAC")
egen HIGUERA_D = noccur(conciliadores), string("HIGUERA")
egen DOCTOR_D = noccur(conciliadores), string("DOCTOR")
egen CESAR_D = noccur(conciliadores), string("CESAR")


replace ANA=1 if ANA_D==1
replace LUCIA=1 if LUCIA_D==1
replace JACQUIE=1 if JACQUIE_D==1
replace MARINA=1 if MARINA_D==1
replace KARINA=1 if KARINA_D==1
replace MARIBEL=1 if MARIBEL_D==1
replace DEYANIRA=1 if DEYANIRA_D==1
replace GUSTAVO=1 if GUSTAVO_D==1
replace CORRAL=1 if CORRAL_D==1
replace AGUSTIN=1 if AGUSTIN_D==1
replace MARGARITA=1 if MARGARITA_D==1
replace LUPITA=1 if LUPITA_D==1
replace ISAAC=1 if ISAAC_D==1
replace HIGUERA=1 if HIGUERA_D==1
replace DOCTOR=1 if DOCTOR_D==1
replace CESAR=1 if CESAR_D==1


*Who showed up
gen v0=0
replace v0=1 if p_actor==0 & p_ractor==0 & p_dem==0 & p_rdem==0 
gen v1=0
replace v1=1 if p_actor==1 & p_ractor==0 & p_dem==0 & p_rdem==0 
gen v2=0
replace v2=1 if p_actor==0 & p_ractor==1 & p_dem==0 & p_rdem==0 
gen v3=0
replace v3=1 if p_actor==0 & p_ractor==0 & p_dem==1 & p_rdem==0 
gen v4=0
replace v4=1 if p_actor==0 & p_ractor==0 & p_dem==0 & p_rdem==1 
gen v12=0
replace v12=1 if p_actor==1 & p_ractor==1 & p_dem==0 & p_rdem==0 
gen v13=0
replace v13=1 if p_actor==1 & p_ractor==0 & p_dem==1 & p_rdem==0 
gen v14=0
replace v14=1 if p_actor==1 & p_ractor==0 & p_dem==0 & p_rdem==1 
gen v23=0
replace v23=1 if p_actor==0 & p_ractor==1 & p_dem==1 & p_rdem==0 
gen v24=0
replace v24=1 if p_actor==0 & p_ractor==1 & p_dem==0 & p_rdem==1 
gen v34=0
replace v34=1 if p_actor==0 & p_ractor==0 & p_dem==1 & p_rdem==1 
gen v123=0
replace v123=1 if p_actor==1 & p_ractor==1 & p_dem==1 & p_rdem==0 
gen v124=0
replace v124=1 if p_actor==1 & p_ractor==1 & p_dem==0 & p_rdem==1 
gen v134=0
replace v134=1 if p_actor==1 & p_ractor==0 & p_dem==1 & p_rdem==1 
gen v234=0
replace v234=1 if p_actor==0 & p_ractor==1 & p_dem==1 & p_rdem==1 
gen v1234=0
replace v1234=1 if p_actor==1 & p_ractor==1 & p_dem==1 & p_rdem==1

**********

*Label var
label var convenio "Convenio"
label define convenio 0 "No concilio" 1 "Concilio" 
label values convenio convenio	

label var calcu_p_actora "Calculadora Actora"
label define calc 0 "No" 1 "Yes" 
label values calcu_p_actora calc	

label var calcu_p_dem "Calculadora Demandado" 
label values calcu_p_dem calc	

label var registro_p_actora "Survey Plaintiff"
label define surv 0 "No" 1 "Yes" 
label values registro_p_actora surv	

label var registro_p_dem "Survey Defendant" 
label values registro_p_dem surv	

label variable ea1_prob_pago "Initial prob employee"
label variable ea2_cantidad_pago "Initial amount employee"
label variable ea8_prob_pago_s "Exit prob employee"
label variable ea9_cantidad_pago_s "Exit amount employee"

label variable era1_prob_pago "Initial prob employee's lawyer"
label variable era2_cantidad_pago "Initial amount employee's lawyer"
label variable era4_prob_pago_s "Exit prob employee's lawyer"
label variable era5_cantidad_pago_s "Exit amount employee's lawyer"

label variable erd1_prob_pago "Initial prob firm's lawyer"
label variable erd2_cantidad_pago "Initial amount firm's lawyer"
label variable erd4_prob_pago_s "Exit prob firm's lawyer"
label variable erd5_cantidad_pago_s "Exit amount firm's lawyer"

label variable ea4_compra "Buys goods"
label variable ea6_trabaja "Works"
label variable ea7_busca_trabajo "Looking for a job"

****************************************************
*IMPORTANT: Until we check the data we restrict it
****************************************************

*No court 1
drop if inlist(junta,1)
*No paired courts
drop if inlist(junta,8,10,12)


*Paired courts have treatment==0


*Subsample for where num_conciliator in avg is steady
sort fecha_lista
egen dte=group(fecha_lista)
keep if dte<=14

*Merge with settlements after treatment
merge m:1 junta exp año using `temp_con_seg', keep(1 3) nogen 

*Months after treatment
gen fecha_treat=date(fecha_lista, "YMD")
gen months_after_treat=(fecha_termino-fecha_treat)/30
replace months_after_treat=0 if convenio==1
replace months_after_treat=. if months_after_treat<0

*Homologation with Phase 1
replace convenio_seg=1 if convenio==1
replace convenio_seg=0 if months_after_treat>7.1
replace convenio_seg=0 if missing(convenio_seg)

*Conciliation after...
	*2 months
gen convenio_seg_2m=0
replace convenio_seg_2m=1 if inrange(months_after_treat,0,2)	
	*5+ months
gen convenio_seg_5m=convenio_seg 


save ".\DB\scaleup_operation.dta", replace



********************************************************************************
import delimited ".\DB\scaleup_predictions.csv", clear

duplicates drop  exp anio junta, force

save ".\DB\scaleup_predictions.dta", replace

********************************************************************************

