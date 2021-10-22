* TREATMENT EFFECTS - ITT - con merge a faltanP1
/*Table 4׺  Treatment Effects*/
/*
This table estimates the main treatment effects for both experimental phases.
Columns (1)-(8)
*/
********************************************************************************
****************************
local controls i.abogado_pub i.numActores i.missingCasefiles i.junta i.phase i.anio


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
gen fecha_filing=date(fecha_demanda, "YMD")
format fecha fecha_filing %td

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha_filing treatment p_actor abogado_pub ///
trabajador_base liq_total_convenio liq_total_laudo numActores

gen phase=2
tempfile p2
save `p2', replace

use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

gen fecha_filing=date(fecha_demanda, "YMD")
format  fecha_filing %td

gen liq_total_laudo =  liq_laudopos 

ren liq_convenio liq_total_convenio
keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha_filing treatment p_actor abogado_pub ///
trabajador_base liq_total_convenio liq_total_laudo numActores

append using `p2'
replace phase=1 if missing(phase)

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

********************************************************************************
merge 1:1 junta exp anio using ".\DB\seguimiento_m5m.dta", keep(1 3)
replace cant_convenio = cant_convenio_exp if missing(cant_convenio)
replace cant_convenio = cant_convenio_ofirec if missing(cant_convenio)
replace cant_convenio = 0 if modo_termino_expediente == 6 & missing(cant_convenio)
merge 1:1 junta exp anio using ".\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)
merge 1:1 junta exp anio using ".\DB\missingPredictionsP1_wod", gen(_mMissingPreds) keep(1 3)

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


gen fechaTerminoAux = date("$S_DATE", "DMY")
format fechaTerminoAux


replace modoTermino = modo_termino_expediente if missing(modoTermino)
replace modoTermino = 2 if missing(modoTermino)

egen fechaTermino = rowmax(fecha_termino_ofirec fecha_termino_exp fechaOfirec fechaExp)

gen ganancia = cant_convenio 
replace ganancia = cant_convenio_exp if missing(ganancia)
replace ganancia = cant_convenio_ofirec if missing(ganancia)
replace ganancia = cantidadPagada if missing(ganancia) & cantidadPagada != 0 //liq_convenio
replace ganancia = cantidadOtorgada if missing(ganancia)

replace ganancia = 0 if [modoTermino == 4 & missing(ganancia)]| modoTermino==5 | [modoTermino==6  & missing(ganancia)] ///
| [modoTermino==1  & missing(ganancia)]

gen ratioGananciaConvenio = ganancia/liq_total_convenio

gen length=fechaTermino-fecha_filing
gen timeTillTreat = fecha - fecha_filing

#delimit ;
*Graph only lower 99%;
twoway (kdensity liq_total_convenio if treatment==2 & liq_total_convenio<125000  & phase==2 & modoTermino==3,  lwidth(medthick) lpattern(solid) color(black)) ||
		(kdensity liq_total_convenio if treatment==1 & liq_total_convenio<125000  & phase==2 & modoTermino==3, lpattern(dash) lcolor(gs10) lwidth(medthick)), 
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("Caluculator predicted settlement")  ytitle("kdensity")
		scheme(s2mono) graphregion(color(white));
#delimit cr

graph export "./Figures/CalculatorVSettlements.pdf", replace 