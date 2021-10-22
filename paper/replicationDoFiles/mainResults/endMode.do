* FOLLOW UP TABLE
********************************************************************************

use ".\DB\scaleup_operation.dta", clear //phase2
rename año anio
rename expediente exp
merge m:1 junta exp anio using ".\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

*Notified casefiles
keep if notificado==1

*Homologation - TREATMENT
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

use "./DB/pilot_operation.dta" , clear	//PHASE 1		
replace junta=7 if missing(junta) //phase 1 solo en J7
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor ///
abogado_pub c1_cantidad_total_pagada_conveni
append using `temp_p2'
replace phase=1 if missing(phase)


merge m:1 junta exp anio using ".\DB\seguimiento_m5m.dta", keep(1 3) 
merge m:1 junta exp anio using ".\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)
gen modoTermino2 = modoTermino
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
*Drop conciliator observations
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1


gen ganancia = c1_cantidad_total_pagada_conveni
replace ganancia = cant_convenio_exp if missing(ganancia)
replace ganancia = cantidadOtorgada if missing(ganancia)

replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1

replace modo_termino_expediente=3 if missing(modo_termino_expediente) & convenio_m5m==1
//replace modo_termino_expediente = modoTermino if missing(modo_termino_expediente) | [modo_termino_expediente == 3 & !missing(modoTermino)]
replace modo_termino_expediente=2 if missing(modo_termino_expediente)

//replace modo_termino_expediente = modoTermino  if missing(modo_termino_expediente)

replace modoTermino = modo_termino_expediente if missing(modoTermino)

replace modoTermino = 7 if modoTermino==6 & missing(ganancia) | ganancia == 0
replace modoTermino = 1 if modoTermino == 4

label define finales 1 "Expired / dropped" 2 "Continues" 3 "Settled" 4 "Dropped" 5 "" 6 "Court ruling with payment" 7 "Court ruling without payment", modify
label val modoTermino finales
********************************************************************************

*Follow-up (more than 5 months)

tab modoTermino treatment if (modoTermino != 5 & modoTermino != 4), matcell(valores)
putexcel set ".\Tables\Table5_December2018Followup.xlsx", mod sheet("Table5_December2018Followup")

putexcel C1 = ("Control") D1 = ("Calculator")
putexcel B2 =("Expired / Dropped") B3 = ("Continues") B4 = ("Settled") B5 = ("Court ruling with payment") B6 = ("Court ruling without payment")
putexcel C2 = matrix(valores)

	
