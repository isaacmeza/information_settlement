*****************************
*	Duration regressions 	*
*****************************
local controls i.abogado_pub i.numActores i.anioControl i.phase i.junta

* TREATMENT EFFECTS - ITT - con merge a faltanP1
/*Table 4׺  Treatment Effects*/
/*
This table estimates the main treatment effects for both experimental phases.
Columns (1)-(8)
*/
********************************************************************************
global int=3.43			/* Interest rate */
global int2 = 2.22		/* Interest rate (ROBUSTNESS)*/
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */
global pago_pri=2000	/* Payment to private lawyer */
global pago_pri2=0		/* Payment to private lawyer (Robustness)*/
global courtcollect=1.0 /* Recovery / Award ratio for court judgments */
global winsorize=95 	/* winsorize level for NPV levels */

local controls i.abogado_pub i.numActores i.anioControl i.phase i.junta
//local imputedControls i.tipodeabogadoImputed
********************************************************************************
clear all
set maxvar 30000
use ".\DB\scaleup_operation.dta", clear
rename año anio
rename expediente exp
merge m:1 junta exp anio using ".\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)
merge m:1 junta exp anio using ".\DB\scaleup_predictions.dta", nogen keep(1 3)


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
gen fecha_filing=date(fecha_demanda, "YMD")
format fecha fecha_filing %td

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
trabajador_base liq_total_laudo_avg numActores liq_total_convenio fecha_filing

gen phase=2
tempfile p2
save `p2'

use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

gen fecha_filing=date(fecha_demanda, "YMD")
format  fecha_filing %td

gen liq_total_laudo_avg =  liq_laudopos * (prob_laudopos/prob_laudos) 
ren liq_convenio liq_total_convenio
gen laudowin=prob_laudopos/prob_laudos

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
trabajador_base liq_total_laudo_avg numActores laudowin liq_total_convenio fecha_filing

append using `p2'
replace phase=1 if missing(phase)

*cap drop tipodeabogado
*ren abogado_pub tipodeabogado
*replace fechadem = fecha_treatment -90 if missing(fechadem)

*keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment ///
*p_actor abogado_pub fechadem

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

*32 drops
*drop if T1T2==1 & treatment == 1
*46 drops
drop if T1T3==1
*31 drops
drop if T2T3==1
*8 drops
drop if TAll==1

*bysort junta exp anio: gen DuplicatesPostdrop=_N

*44 drops
*sort junta exp anio fecha
*bysort junta exp anio: keep if _n==1
********************************************************************************
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

//Merge nuevas iniciales-----------------------------

merge 1:1 junta exp anio using ".\p1_w_p3\out\inicialesP1Faltantes_wod.dta", ///
keep(1 3) gen(_mNuevasIniciales) keepusing(abogado_pubN numActoresN)
//keepusing(fechaDemanda_M tipodeabogado_M trabajadordeconfianza_M numActoresN)

//gen fechaDemanda = date(fecha, "YMD")
gen fechaDemanda = fecha

foreach var in numActores abogado_pub{
replace `var' = `var'N if missing(`var') & !missing(`var'N)
}


gen missingCasefiles = missing(numActores) | missing(abogado_pub)

*replace trabajador_base = abs(trabajadordeconfianza_M-1) if !missing(trabajadordeconfianza_M)
tostring anio, gen(s_anio)
gen fechaArtificial = s_anio + "-01-" + "01"
gen fechaDemandaImputed = fechaDemanda
replace fechaDemandaImputed = date(fechaArtificial, "YMD") if missing(fechaDemandaImputed) | fechaDemandaImputed <0 

gen trabajador_baseImputed = trabajador_base
replace trabajador_baseImputed = 2 if trabajador_baseImputed ==0
replace trabajador_baseImputed = 0 if missing(trabajador_baseImputed)

*gen tipodeabogadoImputed = tipodeabogado
*replace tipodeabogadoImputed = 0 if missing(tipodeabogadoImputed)

bysort anio exp: gen order = _n

*Drop conciliator observations
*drop if treatment==3
********************************************************************************

merge 1:1 junta exp anio using ".\DB\seguimiento_m5m.dta", keep(1 3)
replace cant_convenio = cant_convenio_exp if missing(cant_convenio)
replace cant_convenio = cant_convenio_ofirec if missing(cant_convenio)
replace cant_convenio = 0 if modo_termino_expediente == 6 & missing(cant_convenio)
merge 1:1 junta exp anio using ".\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)
merge 1:1 junta exp anio using ".\DB\missingPredictionsP1_wod", gen(_mMissingPreds) keep(1 3)
replace liq_total_laudo_avg = liq_total_laudo_avgM if missing(liq_total_laudo_avg)
/*
--------------+-----------------------------------
1)           AG |         18        5.70        5.70
2)     CONTINUA |         98       31.01       36.71
3)     CONVENIO |        130       41.14       77.85
4) DESISTIMIENTO |          5        1.58       79.43
5) INCOMPETENCIA |          5        1.58       81.01
6)        LAUDO |         60       18.99      100.00
--------------+-----------------------------------
*/


gen fechaTerminoAux = date("$S_DATE", "DMY") //date("$dateCode", "YMD") 
format fechaTerminoAux

replace modoTermino = modo_termino_expediente if missing(modoTermino)
replace modoTermino = 2 if missing(modoTermino)

egen fechaTermino = rowmax(fecha_termino_ofirec fecha_termino_exp fechaOfirec fechaExp)
*replace fechaTermino = fecha_termino_exp if missing(fechaTermino)
*replace fechaTermino = fechaOfirec if missing(fechaTermino)
*replace fechaTermino = fechaTerminoAux if missing(fechaTermino) | modo_termino_expediente==2 | fechaTermino<0
*
gen ganancia = cant_convenio 
replace ganancia = cant_convenio_exp if missing(ganancia)
replace ganancia = cant_convenio_ofirec if missing(ganancia)
replace ganancia = cantidadPagada if missing(ganancia) & cantidadPagada != 0 //liq_convenio
replace ganancia = cantidadOtorgada if missing(ganancia)

replace ganancia = 0 if [modoTermino == 4 & missing(ganancia)]| modoTermino==5 | [modoTermino==6  & missing(ganancia)] ///
| [modoTermino==1  & missing(ganancia)]

//egen tmp = rowmax(cantidaddedesistimiento c1_cantidad_total_pagada_conveni c2_cantidad_total_pagada_conveni)
//replace ganancia = tmp if modoTermino== 3 & missing(ganancia)
*replace ganancia = liq_convenio if modoTermino== 3 & missing(ganancia)
//drop tmp
replace ganancia = . if modoTermino == 2
replace abogado_pub = 0 if missing(abogado_pub)

// Ganancia imputing 0
replace ganancia = 0 if missing(ganancia) //& modoTermino==2

replace fechaTermino = fechaTerminoAux if missing(fechaTermino) 
format fechaTermino %td
gen months=(fechaTermino-fecha)/30
replace months = 0 if months<0
gen npv=.
gen npv_robust = .


replace ganancia=ganancia*${courtcollect} if modoTermino==6

replace npv=(ganancia/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(ganancia/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1 

replace npv_robust=(ganancia/(1+(${int2})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv_robust=(ganancia/(1+(${int2})/100)^months)-${pago_pub} if abogado_pub==1 

gen npv_robust2=npv_robust
replace npv_robust2=(ganancia/(1+(${int2})/100)^months)*(1-${perc_pag})-${pago_pri2} if abogado_pub==0

preserve

keep npv
duplicates drop
sort npv
gen rankingNpv = _n
tempfile rankingNpvData
save `rankingNpvData', replace
restore
gen anioControl = anio
replace anioControl = 2010 if anio < 2

merge m:1 npv using `rankingNpvData', gen(mNPV)
gen length=fechaTermino-fecha_filing

keep if length>0  & length < 2300
gen unresolved = modoTermino!=2 if modoTermino~=. // failure = not completed
stset length, failure(unresolved)


reg length i.treatment i.p_actor i.treatment#i.p_actor `controls' if  length>0  & length < 2300, robust cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su length if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su length if e(sample) & treatment == 1
	local DepVarMean=r(mean)
	outreg2 using  "./Tables/reg_results/durationTE.xls", replace ctitle("OLS")  ///
	addtext(Casefile Controls, Yes, Includes settled, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor) dec(3) 
*Bigger cases are sped up regardless of whether the plaintiff is present or not; The smaller cases are sped up only when the plaintiff is present.
gen settle=modoTermino==3 if modoTermino~=.
*Hazard model
gen unresolved = modoTermino!=2 if modoTermino~=. // failure = not completed
stset length, failure(unresolved==1)

*Table "Duration", column 2
stcox i.treatment i.p_actor i.treatment#i.p_actor `controls' if length<2300 & length>0 ,  robust nohr cluster(fecha)
outreg2 using  "./Tables/reg_results/durationTE.xls", append ctitle("Cox")  ///
	addtext(Casefile Controls, Yes, Includes settled, Yes) ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor) dec(3)
	 
stcox  i.treatment i.p_actor i.treatment#i.p_actor `controls' if length<2300 & length>0  & modoTermino != 3,  robust nohr cluster(fecha)
outreg2 using  "./Tables/reg_results/durationTE.xls", append ctitle("Cox")  ///
	addtext(Casefile Controls, Yes, Includes settled, No) ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor) dec(3) 
	
