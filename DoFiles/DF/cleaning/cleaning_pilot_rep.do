*Cleaning Phase 1 Data

/*******************************************************************************
This do file generates all previous variables and does some cleaning of the data
*******************************************************************************/

********************************************************************************

********************************************************************************

import delimited ".\Raw\pilot_casefiles.csv", clear

capture rename ao anio
capture rename exp expediente

capture destring salariodiario, replace force
capture destring jornadasemana, replace force
capture destring antigedad, replace force
capture destring horas, replace force

capture replace expediente=floor(expediente) //pq
capture tostring expediente, gen(s_expediente)
capture tostring anio, gen(s_anio)
capture gen slength=length(s_expediente)

capture replace s_expediente="0"+s_expediente if slength==3
capture replace s_expediente="00"+s_expediente if slength==2
capture replace s_expediiente="000"+s_expediente if slength==1

capture gen folio=s_expediente+"-"+s_anio

*Variable Homologation
rename  trabbase  trabajador_base
rename  antigüedad   c_antiguedad 
rename  salariodiariointegrado   salario_diario
rename  horas   horas_sem 
rename  tipodeabogado_1  abogado_pub 
rename  reinstalación reinst
rename  indemnizaciónconstitucional indem 
rename  salcaidostdummy sal_caidos 
rename  primaantigtdummy  prima_antig
rename  primavactdummy  prima_vac 
rename  horasextras  hextra 
rename  rec20diastdummy rec20
rename  primadominical prima_dom 
rename  descansosemanal  desc_sem 
rename  descansooblig desc_ob
rename  sarimssinfo  sarimssinf 
rename  utilidadest  utilidades
rename  nulidad  nulidad  
rename  codemandaimssinfo  codem 
rename  cuantificaciontrabajador c_total
rename comp_min min_ley

gen vac=.
gen ag=.
gen win=.
gen liq_total=.


save ".\DB\pilot_casefiles.dta", replace

*Lawyers name cleaning
do ".\DoFiles\cleaning\name_cleaning_pilot_rep.do"


*DB Calculadora without duplicates (WOD)
use ".\DB\pilot_casefiles.dta", clear
bysort junta expediente anio:  gen numActores = _N
by junta expediente anio: gen valorTotal = sum(c_total)

//duplicates tag folio, gen(tag)
//keep if tag==0
gen missingLiqLaudo = missing(liq_laudopos)
bysort junta expediente anio: egen noHayLaudo = max(missingLiqLaudo)
sort junta expediente anio noHayLaudo
bysort junta expediente anio: gen renglon = _n
drop if renglon > 1
save ".\DB\pilot_casefiles_wod.dta", replace
********************************************************************************

import delimited  ".\Raw\pilot_operation.csv", clear


*********************Generate variables
gen fecha=date(fechalista,"YMD")
order fecha
keep if inrange(fecha,date("2016/03/02","YMD"),date("2016/05/27","YMD")) 

gen fechaNext=date(fechasiguienteaudiencia,"DMY")
format fecha fechaNext %d
gen time_between=fechaNext-fecha
gen control=(tratamientoquelestoco==1)
gen calculator=(tratamientoquelestoco==2)
gen conciliator=(tratamientoquelestoco==3)

mvencode p_actor p_ractor p_demandado p_rdemandado, mv(0)
replace seconcilio=0 if seconcilio==.
replace sellevotratamiento=(sellevotratamiento>0) if !missing(sellevotratamiento)
replace sellevotratamiento=0 if missing(sellevotratamiento)

replace p_actor=(p_actor!=0)
replace p_ractor=(p_ractor!=0)
replace p_demandado=(p_demandado!=0)
replace p_rdemandado=(p_rdemandado!=0)

tostring expediente, gen(s_expediente)
tostring anio, gen(s_anio)
gen slength=length(s_expediente)

replace s_expediente="0"+s_expediente if slength==3
replace s_expediente="00"+s_expediente if slength==2
replace s_expediente="000"+s_expediente if slength==1

gen folio=s_expediente+"-"+s_anio
order folio
sort folio

label define tratamientoquelestoco 0 "Not in experiment" 1 "Control" 2 "Calculator" 3 "Conciliator"
label values tratamientoquelestoco tratamientoquelestoco

*Drop
drop if missing(expediente)
drop if missing(anio)
duplicates drop folio fecha, force

*Import sue date and generate conciliation variables
merge m:1 folio using ".\DB\pilot_casefiles_wod.dta", keep(1 3) nogen

*Persistent conciliation variable
gen fecha_con=date(c1_fecha_convenio,"DMY")
format fecha_con %td
********Conciliation dummy
replace seconcilio=1 if fecha_con==fecha
destring c1_se_concilio, replace force
replace c1_se_concilio=seconcilio if missing(c1_se_concilio)
replace c1_se_concilio=. if c1_se_concilio==2
bysort expediente anio : egen conciliation=max(c1_se_concilio)
********Conciliation amount
destring c1_cantidad_total_pagada_conveni, replace force
replace c1_cantidad_total_pagada_conveni=cantidaddeconvenio ///
	if missing(c1_cantidad_total_pagada_conveni) & c1_se_concilio==1
replace c1_cantidad_total_pagada_conveni=. if c1_se_concilio==0 | (c1_se_concilio==. & c1_cantidad_total_pagada_conveni==0 )


*Conciliation date
replace fecha_con=fecha if seconcilio==1 & c1_se_concilio==1
bysort expediente anio : egen fecha_convenio=max(fecha_con)
format fecha_convenio %td

*Treatment date
bysort expediente anio : egen fecha_treatment=min(fecha)
format fecha_treatment %td

*Time between settlement and sue
gen fechadem=date(fecha_demanda,"YMD")
gen case_duration=(fecha_convenio-fechadem)/30
replace case_duration=. if case_duration<0
xtile perc=case_duration, nq(99)
replace case_duration=. if perc>=99
drop perc

*Months after intial sue
gen months_after=(fecha_treatment-fechadem)/30
replace months_after=. if months_after<0
xtile perc=months_after, nq(99)
replace months_after=. if perc>=99
drop perc


*Months after treatment
gen months_after_treat=(fecha_convenio-fecha_treatment)/30
replace months_after_treat=. if months_after_treat<0
xtile perc=months_after_treat, nq(99)
replace months_after_treat=. if perc>=99
drop perc

*Conciliation
gen con=c1_se_concilio

*Conciliation after...
	*1 month
gen con_1m=(con==1 & fecha_convenio<=fechadem+31)
	*6 month
gen con_6m=(con==1 & fecha_convenio<=fechadem+186)

*Court ruling
gen cr_0=.
gen cr_m=.

*1 month after
gen convenio_1m=0
replace convenio_1m=1 if inrange(months_after_treat,0,1)

*2 month after
gen convenio_2m=0
replace convenio_2m=1 if inrange(months_after_treat,0,2)

*3 month after
gen convenio_3m=0
replace convenio_3m=1 if inrange(months_after_treat,0,3)

*4 month after
gen convenio_4m=0
replace convenio_4m=1 if inrange(months_after_treat,0,4)

*+5 month after
gen convenio_5m=conciliation

save ".\DB\pilot_operation.dta", replace


********************************************************************************
/*Data preparation (Surveys)*/	

use "./Raw/Append Encuesta Inicial Representante Actor.dta", clear
rename RA_fecha fecha
gen Age=(fecha-RA_1_1)/365
gen Tenure=2016-RA_1_5
rename RA_1_6 litigiosha
rename RA_1_7 litigiosesta
rename RA_3_1 numempleados
rename RA_4_1_2 porc_pago
rename RA_5_1 A_5_1
rename RA_5_2 probotro  
label var probotro "5.02 Si preguntaramos a la otra parte que probabilidad tienen ellos de ganar"
rename RA_5_3 A_5_3
rename RA_5_4 A_5_4
rename RA_5_5 A_5_5
gen comp_ra=A_5_5
rename RA_5_6 A_5_6
rename RA_5_7 A_5_7
rename RA_5_8 A_5_8
rename RA_5_9 A_5_9
rename RA_5_10 dineromerecetrab
save "./DB/Append Encuesta Inicial Representante Actor.dta", replace

use "./Raw/Append Encuesta Inicial Representante Demandado.dta", clear
duplicates drop
rename RD_fecha fecha
gen Age=(fecha-RD1_1)/365
gen Tenure=2016-RD1_5
rename RD1_6 litigiosha
rename RD1_7 litigiosesta
rename RD3_1 numempleados
rename RD5_1_1 A_5_1
rename RD5_2_1 probotro  
label var probotro "5.02 Si preguntaramos a la otra parte que probabilidad tienen ellos de ganar"
rename RD5_3 A_5_3
rename RD5_4 A_5_4
rename RD5_5 A_5_5
gen comp_rd=A_5_5
rename RD5_6 A_5_6
rename RD5_7 A_5_7
rename RD5_8 A_5_8
rename RD5_9 A_5_9
rename RD5_10 dineromerecetrab
duplicates drop folio fecha, force
save "./DB/Append Encuesta Inicial Representante Demandado.dta", replace

use "./Raw/Append Encuesta Inicial Actor.dta", clear
rename A_fecha fecha
gen Age=(fecha-A_1_1)/365
rename A_3_1 numempleados
rename A_4_2_2 porc_pago
rename A_5_2 probotro  
gen comp_a=A_5_5
label var probotro "5.02 Si preguntaramos a la otra parte que probabilidad tienen ellos de ganar"
label var A_9_4 "9.04 ¿Qué tan de acuerdo está con el siguiente enunciado: En este momento no me"
save "./DB/Append Encuesta Inicial Actor.dta", replace

use "./Raw/Append Encuesta Inicial Demandado.dta", clear
rename D_fecha fecha
save "./DB/Append Encuesta Inicial Demandado.dta", replace

use "./Raw/Append Encuesta de Salida.dta", clear
rename ES_fecha fecha
*Drop duplicates
local vartitulo2: var label ES_1_2
local vartitulo3: var label ES_1_3
local vartitulo4: var label ES_1_4
local vartitulo5: var label ES_1_5
collapse ES_1_2-ES_1_5 , by(folio fecha ES_1_1)
drop if inlist(ES_1_2,1,2,3)!=1
label variable ES_1_2 "`vartitulo2'"
label variable ES_1_3 "`vartitulo3'"
label variable ES_1_4 "`vartitulo4'"
label variable ES_1_5 "`vartitulo5'"
save "./DB/Append Encuesta de Salida.dta", replace

*Dummy database only used for compliance in the exit survey
collapse ES_1_2, by(folio fecha)
save "./DB/exit_compliance.dta", replace

********************************************************************************
/*Homologation of variables in the 3 survey datasets*/

local varlist $varsurvey

local n=0
foreach var in `varlist' {
	local n=`n'+1
	}

local k=0
foreach var in `varlist' {
	local k=`k'+1
	
	qui use "./DB/Append Encuesta Inicial Actor.dta", clear
	qui capture confirm variable `var'
		*Variable is in dataset
	if !_rc!=0 {
		global vartitulo: var label `var'
		qui use "./DB/Append Encuesta Inicial Representante Actor.dta", clear
		qui capture confirm variable `var'
			*Variable is not in dataset
		if !_rc==0 {
			qui gen `var'=.
			label var `var' "$vartitulo"
			qui save "./DB/Append Encuesta Inicial Representante Actor.dta", replace
			}		
		qui use "./DB/Append Encuesta Inicial Representante Demandado.dta", clear
		qui capture confirm variable `var'
			*Variable is not in dataset
		if !_rc==0 {
			qui gen `var'=.
			label var `var' "$vartitulo"
			qui save "./DB/Append Encuesta Inicial Representante Demandado.dta", replace
			}				
		}
		*If variable is not in dataset it is somewhere else
	else {	
		qui use "./DB/Append Encuesta Inicial Representante Actor.dta", clear
		qui capture confirm variable `var'
			*Variable is in dataset
		if !_rc!=0 {
			global vartitulo: var label `var'
			qui use "./DB/Append Encuesta Inicial Actor.dta", clear
			qui capture confirm variable `var'
				*Variable is not in dataset
			if !_rc==0 {
				qui gen `var'=.
				label var `var' "$vartitulo"
				qui save "./DB/Append Encuesta Inicial Actor.dta", replace
				}		
			qui use "./DB/Append Encuesta Inicial Representante Demandado.dta", clear
			qui capture confirm variable `var'
				*Variable is not in dataset
			if !_rc==0 {
				qui gen `var'=.
				label var `var' "$vartitulo"
				qui save "./DB/Append Encuesta Inicial Representante Demandado.dta", replace
				}				
			}
			*If still variable is not in dataset it must be in last dataset
		else {	
			qui use "./DB/Append Encuesta Inicial Representante Demandado.dta", clear
			qui capture confirm variable `var'
				*Variable must be in dataset (If statement works only as a filter)
			if !_rc!=0 {
				global vartitulo: var label `var'
				qui use "./DB/Append Encuesta Inicial Representante Actor.dta", clear
				qui capture confirm variable `var'
					*Variable is not in dataset
				if !_rc==0 {
					qui gen `var'=.
					label var `var' "$vartitulo"
					qui save "./DB/Append Encuesta Inicial Representante Actor.dta", replace
					}		
				qui use "./DB/Append Encuesta Inicial Actor.dta", clear
				qui capture confirm variable `var'
					*Variable is not in dataset
				if !_rc==0 {
					qui gen `var'=.
					label var `var' "$vartitulo"
					qui save "./DB/Append Encuesta Inicial Actor.dta", replace
					}				
				}
			}
		}
		
		*Progress bar

	if `k'==1 {
		di "Progress"
		di "--------"
		}
	if `k'==floor(`n'/10) {
		di "10%"
		}
	if `k'==floor(`n'*2/10) {
		di "20%"
		}
	if `k'==floor(`n'*3/10) {
		di "30%"
		}
	if `k'==floor(`n'*4/10) {
		di "40%"
		}
	if `k'==floor(`n'*5/10) {
		di "50%"
		}
	if `k'==floor(`n'*6/10) {
		di "60%"
		}
	if `k'==floor(`n'*7/10) {
		di "70%"
		}
	if `k'==floor(`n'*8/10) {
		di "80%"
		}
	if `k'==floor(`n'*9/10) {
		di "90%"
		}
	if `k'==floor(`n') {
		di "100%"
		di "--------"
		di "        "
		}	
	}

********************************************************************************

********************************************************************************

import delimited  ".\Raw\placebo_operation.csv", clear

drop v1

rename se_concilio seconcilio
destring seconcilio, force replace
replace seconcilio=(seconcilio==1)

destring p_actor, force replace
replace p_actor=(p_actor==1)

gen treatment=4 if (placebo==1)
replace treatment=5 if (placebo==0)

keep seconcilio treatment p_actor

save ".\DB\placebo_operation.dta", replace

********************************************************************************
********************************************************************************

*Follow up - cleaning (phase 1 & 2) DIC 2018 - FALTA SEGUIMIENTO ENE 2020
import excel "./Raw/Seguimiento Expedientes sin Convenio Dic2018.xlsx", ///
	sheet("Nuevo Control") cellrange(A3:AD1392) firstrow clear

rename Año Ao
rename MododetérminoOFIREC MododetrminoOFIREC
rename MododetérminoEXPEDIENTE MododetrminoEXPEDIENTE
rename FechadetérminoFechadeúlti FechadetrminoFechadeltim
keep Junta Expediente Ao Phase MododetrminoOFIREC FechadetrminoFechadeltim MododetrminoEXPEDIENTE J ///
	Cantidadpagada K

*Cleaning
rename MododetrminoOFIREC modo_termino_ofirec
rename MododetrminoEXPEDIENTE modo_termino_expediente
rename FechadetrminoFechadeltim fecha_termino_ofirec
rename J fecha_termino_exp
rename Junta junta
rename Expediente exp
rename Ao anio
rename Cantidadpagada cant_convenio_ofirec
rename K cant_convenio_exp

foreach var of varlist fecha* {
	gen `var'_=date(`var',"DMY")
	format `var'_ %td
	drop `var'
	rename `var'_ `var'
	}

foreach var of varlist modo* {	
	replace `var'=stritrim(trim(itrim(upper(`var'))))
	replace `var'=stritrim(trim(itrim(`var')))
	egen `var'_=group(`var'), label
	drop `var'
	rename `var'_ `var'
	}

*End mode
label define modo_termino_exp 1 "Expiry" 2 "Continue" ///
	3 "Settlement" 4 "Drop" 5 "Not competent" 6 "Court ruling"	
label values modo_termino_exp modo_termino_exp
	
*Settlement 	
gen convenio_m5m=0
replace convenio_m5m=1 if modo_termino_exp==3
replace convenio_m5m=1 if modo_termino_ofirec==4 & modo_termino_exp==2 
replace convenio_m5m=0 if (modo_termino_ofirec==4 & modo_termino_exp==2) & ///
	(fecha_termino_ofirec<fecha_termino_exp)

replace modo_termino_exp=3 if modo_termino_ofirec==4 & modo_termino_exp==2	
replace modo_termino_exp=2 if (modo_termino_ofirec==4 & modo_termino_exp==2) & ///
	(fecha_termino_ofirec<fecha_termino_exp)
	
*Court ruling
gen cr_m5m=0
replace cr_m5m=1 if modo_termino_exp==6
replace cr_m5m=1 if modo_termino_ofirec==7 & modo_termino_exp==2	
replace cr_m5m=0 if (modo_termino_ofirec==7 & modo_termino_exp==2) & ///
	(fecha_termino_ofirec<fecha_termino_exp) 

replace modo_termino_exp=6 if modo_termino_ofirec==7 & modo_termino_exp==2	
replace modo_termino_exp=2 if (modo_termino_ofirec==7 & modo_termino_exp==2) & ///
	(fecha_termino_ofirec<fecha_termino_exp)
	
*Expiry
gen exp_m5m=0
replace exp_m5m=1 if modo_termino_exp==1
replace exp_m5m=1 if modo_termino_ofirec==2 & modo_termino_exp==2	
replace exp_m5m=0 if (modo_termino_ofirec==2 & modo_termino_exp==2) & ///
	(fecha_termino_ofirec<fecha_termino_exp) 

replace modo_termino_exp=1 if modo_termino_ofirec==2 & modo_termino_exp==2	
replace modo_termino_exp=2 if (modo_termino_ofirec==2 & modo_termino_exp==2) & ///
	(fecha_termino_ofirec<fecha_termino_exp)

*Drop
gen drop_m5m=0
replace drop_m5m=1 if modo_termino_exp==4
replace drop_m5m=1 if modo_termino_ofirec==5 & modo_termino_exp==2	
replace drop_m5m=0 if (modo_termino_ofirec==5 & modo_termino_exp==2) & ///
	(fecha_termino_ofirec<fecha_termino_exp) 

replace modo_termino_exp=4 if modo_termino_ofirec==5 & modo_termino_exp==2	
replace modo_termino_exp=2 if (modo_termino_ofirec==5 & modo_termino_exp==2) & ///
	(fecha_termino_ofirec<fecha_termino_exp)	
	
	
*Settlement amount
gen cant_convenio=cant_convenio_exp
replace cant_convenio=cant_convenio_ofirec if missing(cant_convenio)
replace cant_convenio=. if convenio_m5m==0
	
save ".\DB\seguimiento_m5m.dta", replace


********************************************************************************
********************************************************************************
*Drop 'incompetencias'
	
	*PHASE 1
use "./DB/pilot_operation.dta", clear
rename expediente exp
	
*Follow-up (more than 5 months)
merge m:1 junta exp anio using ".\DB\seguimiento_m5m.dta", nogen keep(1 3) ///DUDA AQUI<---------------------------------------
	keepusing(junta exp anio modo_termino_ofirec)
drop if modo_termino_ofirec==6
drop modo_termino_ofirec
rename exp expediente

save "./DB/pilot_operation.dta", replace

/*
	*PHASE 2
use "$scaleup\DB\scaleup_operation.dta", clear
rename ao anio
rename expediente exp
	
*Follow-up (more than 5 months)
merge m:1 junta exp anio using ".\DB\seguimiento_m5m.dta", nogen keep(1 3) ///AQUI TAMBIEN<----------------------------------
	keepusing(junta exp anio modo_termino_ofirec)
drop if modo_termino_ofirec==6
drop modo_termino_ofirec
rename anio ao
rename exp expediente

save "$scaleup\DB\scaleup_operation.dta", replace



