clear all 
set maxvar 30000
*Set controls.
local controls i.anioControl i.junta i.phase i.numActores
//local balance_var gen trabajador_base horas_sem c_antiguedad abogado_pub reinst indem salario_diario sal_caidos prima_antig hextra rec20  prima_dom  desc_sem desc_ob sarimssinf utilidades nulidad min_ley 
local balance_var trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley 
//p_actor p_ractor p_dem p_rdem

use "./DB/scaleup_operation.dta", clear
rename año anio
rename expediente exp
merge m:1 junta exp anio using "./DB/scaleup_casefiles_wod.dta" , nogen  keep(1 3)

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

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub time_hearing time_hr numActores `balance_var'
gen phase=2
tempfile p2
save `p2'

use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)

*Presence employee
replace p_actor=(p_actor==1)
*Not in experiment
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment
rename expediente exp

*Time hearing (Instrument)
gen time_hearing=substr(horarioaudiencia,strpos(horarioaudiencia," "),length(horarioaudiencia))
egen time_hr=group(time_hearing)

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub time_hearing time_hr numActores `balance_var'
append using `p2'
replace phase=1 if missing(phase)

merge m:1 junta exp anio using ".\DB\seguimiento_m5m.dta", nogen
merge m:1 junta exp anio using ".\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)
replace seconcilio = 0 if modoTermino != 3 & !missing(modoTermino)
********************************************************************************

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

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

*Drop conciliator observations
drop if treatment==3

gen anioControl = anio
replace anioControl = 2010 if anio < 2010
replace numActores = 3 if numActores>3

replace convenio_2m=seconcilio if seconcilio==1

//replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace modo_termino_expediente=3 if missing(modo_termino_expediente) & convenio_m5m==1
//replace modo_termino_expediente = modoTermino if missing(modo_termino_expediente) | [modo_termino_expediente == 3 & !missing(modoTermino)]
replace modo_termino_expediente=2 if missing(modo_termino_expediente)

//replace modo_termino_expediente = modoTermino  if missing(modo_termino_expediente)

replace modoTermino = modo_termino_expediente if missing(modoTermino)


//replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1
replace convenio_m5m = 1 if modoTermino == 3
replace convenio_m5m = 0 if modoTermino != 3 & !missing(modoTermino)
replace seconcilio = 0 if modoTermino != 3 & !missing(modoTermino)

replace convenio_m5m = . if modoTermino == 5
replace seconcilio = . if modoTermino == 5


*Instrument
gen time_instrument=inlist(time_hr,1,2,7,8) if !missing(time_hr) 
gen time_actor=time_instrument*p_actor

gen treat_inst=treatment*time_instrument
gen treat_p_actor=treatment*p_actor

*Balance Tables

*define clusters
egen gp=group(exp anio)
egen fechaJunta=group(junta fecha)
replace fechaJunta=fechaJunta+1481 
gen cluster_v=.
replace cluster_v=gp if phase==1
replace cluster_v=fechaJunta if phase==2 

************************************PHASE 1/2***********************************
********************************************************************************

local balance_var trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley 

eststo clear
foreach var of varlist `balance_var' {
	eststo : reg `var' i.time_hr, vce(cluster cluster_v)
	test 2.time_hr==3.time_hr==4.time_hr==5.time_hr==6.time_hr==7.time_hr==8.time_hr=0
	estadd scalar Fpval = `r(p)'
}
 
*Save results	
esttab using "./Tables/reg_results/balance_instrument.csv", se r2 ${star} b(a3) ///
		scalars("Fpval F p-value") replace 
