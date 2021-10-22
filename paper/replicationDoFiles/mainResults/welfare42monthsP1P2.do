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

merge m:1 npv using `rankingNpvData', gen(mNPV)

#delimit ;
graph twoway scatter npv rankingNpv if npv < 400000,
xtitle("NPV of outcome") title("NPV of Outcomes against its ranking") ytitle("NPV ranking") 
		scheme(s2mono) graphregion(color(white));
#delimit cr
graph export "./Figures/npvAgainstRanking.pdf", replace 

*Predicted outcomes for continuing cases - Phase 2;
*Graph only lower 99%;

*replace npv = 0 if missing(npv) & !missing(modoTermino)

gen asinhNPV = asinh(npv)

gen asinhNPV_robust2 = asinh(npv_robust2)

gen gananciaImputed = ganancia
replace gananciaImputed = liq_total_laudo_avg if  ganancia==0 & modoTermino==2

///!missing(liq_total_laudo_avg) 
//& !missing(liq_laudopos) 

gen npvImputed=.
replace npvImputed=(gananciaImputed/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npvImputed=(gananciaImputed/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1

gen npvImputed_robust=.
replace npvImputed_robust=(gananciaImputed/(1+(${int2})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npvImputed_robust=(gananciaImputed/(1+(${int2})/100)^months)-${pago_pub} if abogado_pub==1

preserve
keep npvImputed
duplicates drop
drop if missing(npvImputed)
sort npvImputed
gen rankingNpvImputed = _n
tempfile rankingNpvData
save `rankingNpvData', replace
restore

merge m:1 npvImputed using `rankingNpvData', gen(mNPVI)

#delimit ;
graph twoway scatter npvImputed rankingNpvImputed if npv < 400000,
xtitle("Imputed NPV of outcome") title("Imputed NPV of Outcomes against its ranking") ytitle("Imputed NPV ranking") 
		scheme(s2mono) graphregion(color(white));
#delimit cr
graph export "./Figures/imputedNpvAgainstRanking.pdf", replace 

preserve
keep npvImputed_robust
duplicates drop
drop if missing(npvImputed_robust)
sort npvImputed_robust
gen rankingNpvImputed_robust = _n
tempfile rankingNpvData
save `rankingNpvData', replace
restore

merge m:1 npvImputed_robust using `rankingNpvData', gen(mNPVI_robust)

#delimit ;
graph twoway scatter npvImputed_robust rankingNpvImputed if npv < 400000,
xtitle("Imputed NPV of outcome") title("Imputed NPV of Outcomes against its ranking") ytitle("Imputed NPV ranking") 
		scheme(s2mono) graphregion(color(white));
#delimit cr
graph export "./Figures/imputedNpvRobustAgainstRanking.pdf", replace 

*replace npvImputed = 0 if missing(npv) & !missing(modoTermino)

gen asinhNPVImputed = asinh(npvImputed)
gen asinhNPVImputed_robust = asinh(npvImputed_robust)
replace numActores = 0 if missing(numActores)
replace numActores=1 if numActores==0
replace numActores=3 if numActores>3 & numActores~=.
gen anioControl = anio
replace anioControl = 2010 if anio < 2010

for var npv npvImputed: gen X_wz=X
for var npv npvImputed: egen X_wz_WZ=pctile(X), p(${winsorize})
for var npv_wz npvImputed_wz: replace X=X_WZ if X>X_WZ & X~=.

gen ratioGananciaConvenio = ganancia/liq_total_convenio

gen length=fechaTermino-fecha_filing
gen timeTillTreat = fecha - fecha_filing

gen altT = treatment-1
gen interactT = altT*p_actor

*********************************************************************************
*1) NPV winsorsized (0s)
ritest altT _b[altT] _b[c.altT#c.p_actor], samplingsourcefile("./_aux/samplePooled4.dta") samplingmatchvar(junta exp anio) reps(10000): reg npv_wz c.altT##c.p_actor  `controls'  if !missing(asinhNPVImputed), robust  cluster(fecha)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]
	local pvalInteract = pvalues[1,2]

reg npv_wz i.treatment i.p_actor i.treatment#i.p_actor `controls' if !missing(asinhNPVImputed), robust cluster(fecha)	
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su npv_wz if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su npv_wz if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12.xls" if !missing(asinhNPVImputed), replace ctitle("asinhNPV") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean', calcPVal, `testInteraction', pvalueRI, `pvalNoInteract', pvalueRIInteraction,  `pvalInteract') keep(2.treatment missingCasefiles 1.p_actor 2.treatment#1.p_actor)


*2) IHS NPV (0s)
ritest altT _b[altT] _b[c.altT#c.p_actor], samplingsourcefile("./_aux/samplePooled4.dta") samplingmatchvar(junta exp anio) reps(10000): reg asinhNPV c.altT##c.p_actor  `controls'  if !missing(asinhNPVImputed), robust  cluster(fecha)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]
	local pvalInteract = pvalues[1,2]

reg asinhNPV i.treatment i.p_actor i.treatment#i.p_actor `controls' if !missing(asinhNPVImputed), robust cluster(fecha)	
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su asinhNPV if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su asinhNPV if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12.xls" if !missing(asinhNPVImputed), append ctitle("asinhNPV") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean', calcPVal, `testInteraction', pvalueRI, `pvalNoInteract', pvalueRIInteraction,  `pvalInteract') keep(2.treatment missingCasefiles 1.p_actor 2.treatment#1.p_actor)

*3) NPV winsorsized (calculator)
ritest altT _b[altT] _b[c.altT#c.p_actor], samplingsourcefile("./_aux/samplePooled4.dta") samplingmatchvar(junta exp anio) reps(10000): reg npvImputed_wz c.altT##c.p_actor  `controls'  if !missing(asinhNPVImputed), robust  cluster(fecha)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]
	local pvalInteract = pvalues[1,2]

reg npvImputed_wz i.treatment i.p_actor i.treatment#i.p_actor `controls', robust cluster(fecha)	
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su npvImputed_wz if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su npvImputed_wz if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12.xls", append ctitle("asinhNPVImputed") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean', calcPVal, `testInteraction', pvalueRI, `pvalNoInteract', pvalueRIInteraction,  `pvalInteract') keep(2.treatment missingCasefiles 1.p_actor 2.treatment#1.p_actor)

*4) NPV winsorsized (calculator)
ritest altT _b[altT] _b[c.altT#c.p_actor], samplingsourcefile("./_aux/samplePooled4.dta") samplingmatchvar(junta exp anio) reps(10000): reg asinhNPVImputed c.altT##c.p_actor  `controls'  if !missing(asinhNPVImputed), robust  cluster(fecha)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]
	local pvalInteract = pvalues[1,2]

reg asinhNPVImputed i.treatment i.p_actor i.treatment#i.p_actor `controls', robust cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su asinhNPVImputed if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su asinhNPVImputed if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12.xls", append ctitle("asinhNPVImputed") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean',calcPVal, `testInteraction', pvalueRI, `pvalNoInteract', pvalueRIInteraction,  `pvalInteract') keep(2.treatment missingCasefiles 1.p_actor 2.treatment#1.p_actor)

*5) NPV winsorsized robust (calculator)
ritest altT _b[altT] _b[c.altT#c.p_actor], samplingsourcefile("./_aux/samplePooled4.dta") samplingmatchvar(junta exp anio) reps(10000): reg asinhNPVImputed_robust c.altT##c.p_actor  `controls'  if !missing(asinhNPVImputed), robust  cluster(fecha)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]
	local pvalInteract = pvalues[1,2]

reg asinhNPVImputed_robust i.treatment i.p_actor i.treatment#i.p_actor `controls', robust cluster(fecha)	
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su asinhNPVImputed_robust if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su asinhNPVImputed_robust if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12.xls", append ctitle("asinhNPVImputed") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean',calcPVal, `testInteraction', pvalueRI, `pvalNoInteract', pvalueRIInteraction,  `pvalInteract') keep(2.treatment missingCasefiles 1.p_actor 2.treatment#1.p_actor)

*6) Column 2 without interactions
ritest altT _b[altT], samplingsourcefile("./_aux/samplePooled4.dta") samplingmatchvar(junta exp anio) reps(10000): reg asinhNPV  `controls'  if !missing(asinhNPVImputed), robust  cluster(fecha)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]

reg asinhNPV i.treatment `controls' if !missing(asinhNPVImputed), robust cluster(fecha)	
	qui su asinhNPV if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12.xls" if !missing(asinhNPVImputed), append ctitle("asinhNPV") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean', pvalueRI, `pvalNoInteract') keep(2.treatment missingCasefiles)
**********************************************************************************************************

*****************************
*	Ranking regressions 	*
*****************************
/*
*1) NPV winsorsized (0s)

reg npv_wz i.treatment i.p_actor i.treatment#i.p_actor `controls' if !missing(asinhNPVImputed), robust cluster(fecha)	
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su npv_wz if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su npv_wz if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12_ranking.xls" if !missing(asinhNPVImputed), replace ctitle("asinhNPV") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean', calcPVal, `testInteraction') keep(2.treatment missingCasefiles 1.p_actor 2.treatment#1.p_actor)


*2) IHS NPV (0s)
reg rankingNpv i.treatment i.p_actor i.treatment#i.p_actor `controls' if !missing(asinhNPVImputed), robust cluster(fecha)	
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su asinhNPV if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su asinhNPV if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12_ranking.xls" if !missing(asinhNPVImputed), append ctitle("NPV Ranking") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean', calcPVal, `testInteraction') keep(2.treatment missingCasefiles 1.p_actor 2.treatment#1.p_actor)

*3) NPV winsorsized (calculator)
reg npvImputed_wz i.treatment i.p_actor i.treatment#i.p_actor `controls', robust cluster(fecha)	
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su npvImputed_wz if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su npvImputed_wz if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12_ranking.xls", append ctitle("asinhNPVImputed") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean', calcPVal, `testInteraction') keep(2.treatment missingCasefiles 1.p_actor 2.treatment#1.p_actor)

*4) NPV winsorsized (calculator)
reg rankingNpvImputed i.treatment i.p_actor i.treatment#i.p_actor `controls', robust cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su asinhNPVImputed if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su asinhNPVImputed if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12_ranking.xls", append ctitle("Imputed NPV Ranking") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean',calcPVal, `testInteraction') keep(2.treatment missingCasefiles 1.p_actor 2.treatment#1.p_actor)

*5) NPV winsorsized robust (calculator)
reg rankingNpvImputed_robust i.treatment i.p_actor i.treatment#i.p_actor `controls', robust cluster(fecha)	
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su asinhNPVImputed_robust if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su asinhNPVImputed_robust if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12_ranking.xls", append ctitle("Robust NPV ranking") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean',calcPVal, `testInteraction') keep(2.treatment missingCasefiles 1.p_actor 2.treatment#1.p_actor)

*6) Column 2 without interactions
reg rankingNpv i.treatment `controls' if !missing(asinhNPVImputed), robust cluster(fecha)	
	qui su asinhNPV if e(sample) & treatment == 1
	local DepVarMean=r(mean)
outreg2 using ".\Tables\reg_results\welfareEffectsP12_ranking.xls" if !missing(asinhNPVImputed), append ctitle("NPV Ranking") ///
addtext(Casefile Controls, Yes) addstat(DepVarMean, `DepVarMean') keep(2.treatment missingCasefiles)
/*
*****************************
*	Duration regressions 	*
*****************************

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
stset length, failure(unresolved)

*Table "Duration", column 2
stcox  i.treatment i.p_actor i.treatment#i.p_actor `controls' if length<2300 & length>0 ,  robust nohr cluster(fecha)
outreg2 using  "./Tables/reg_results/durationTE.xls", append ctitle("Cox")  ///
	addtext(Casefile Controls, Yes, Includes settled, Yes) ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor) dec(3) 
stcox  i.treatment i.p_actor i.treatment#i.p_actor `controls' if length<2300 & length>0  & modoTermino != 3,  robust nohr cluster(fecha)
outreg2 using  "./Tables/reg_results/durationTE.xls", append ctitle("Cox")  ///
	addtext(Casefile Controls, Yes, Includes settled, No) ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor) dec(3) 
	

*****************************************************************************
*							GRAPHS											*
*****************************************************************************

#delimit ;
*Predicted outcomes for continuing cases - Phase 2;
*Graph only lower 99%;
twoway (kdensity npvImputed if treatment==2 & asinhNPVImputed!=. & p_actor==1 & phase==1 , lwidth(medthick) lpattern(solid) color(black)) ||
		(kdensity npvImputed if treatment==1  & asinhNPVImputed!=. & p_actor==1  & phase==1, lpattern(dash) lcolor(gs10) lwidth(medthick)), 
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("NPV of outcome, winsorized 95%") title("NPV of Outcomes, Imputed for Unresolved Cases") subtitle("Plaintiff present at Treatment, Phase 1") ytitle("kdensity") 
		scheme(s2mono) graphregion(color(white));
#delimit cr
graph export "./Figures/OutcomesByTreatment_P1.pdf", replace 

#delimit ;
*Predicted outcomes for continuing cases - Phase 2;
*Graph only lower 99%;
twoway (kdensity npvImputed if treatment==2 & asinhNPVImputed~=. & p_actor==1 & phase==2  ,  lwidth(medthick) lpattern(solid) color(black)) ||
		(kdensity npvImputed if treatment==1  & asinhNPVImputed~=. & p_actor==1  & phase==2, lpattern(dash) lcolor(gs10) lwidth(medthick)), 
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("NPV of outcome, winsorized 95%") title("NPV of Outcomes, Imputed for Unresolved Cases") subtitle("Plaintiff present at treatment, Phase 2") ytitle("kdensity") 
		scheme(s2mono) graphregion(color(white));
#delimit cr
graph export "./Figures/OutcomesByTreatment_P2.pdf", replace 


