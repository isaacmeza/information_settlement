/*Import July 2020 P2 Followup*/

import excel ".\Raw\P2jul2020Followup.xlsx", firstr clear
drop if missing(Junta)
drop Muestra50 

foreach var of varlist Mododetérmino* {
replace `var' = subinstr(`var', " ","",.)
}

/*
foreach var of varlist Fechade* {
gen `var'_d = date(`var', "YMD")
}
*/

//gen FechadetérminoFechadeúlti_d = date(FechadetérminoFechadeúlti, "YMD")

foreach var in Cantidadotorgadaenlaudoaco CantidadpagadaINEGI CANTIDADOTORGADAENCONVENIOO Cantidadpagada{
destring `var', replace force 
}


replace MododetérminoEXPEDIENTE = "CONTINUA" if MododetérminoEXPEDIENTE == "CONTINUO"
replace MododetérminoEXPEDIENTE = "CONVENIO" if MododetérminoEXPEDIENTE == "CCONVENIO" | ///
MododetérminoEXPEDIENTE == "CONVENO"

*Nombres---------------
rename FechadetérminoFechadeúlti fechaOfirec
rename Junta junta
rename Expediente expediente
rename Año anio
rename Cantidadotorgadaenlaudoaco otorgadaOfirec
rename CantidadpagadaINEGI pagadaOfirec
rename MododetérminoOFIREC terminoOfirec
rename MododetérminoEXPEDIENTE terminoExp
rename DummylaudoconveniopagadoCOM pagoCompleto
rename OBSERVACIONESOFIREC comentariosOfirec
rename Observaciones comentariosExp
rename Cantidadpagada pagadaExp
ren CANTIDADOTORGADAENCONVENIOO otorgadaExp

//gen fechaExp = date(M, "DMY")
ren Fechaúltimomovimientoexpedien fechaExp_s

gen fechaExp = date(fechaExp_s, "DMY")
replace fechaExp = date(fechaExp_s, "MDY") if missing(fechaExp)

format fechaOfirec %td
format fechaExp %td
lab var fechaOfirec "Fecha de ultimo movimiento registrado en OFIREC"
lab var fechaExp "Fecha de ultimo movimiento registrado en expediente"

gen diff=fechaOfirec-fechaExp
gen fechaUltimoMov=fechaOfirec
replace fechaUltimoMov=fechaExp if diff<0 | missing(fechaOfirec)

gen cantidadPagada=pagadaExp
replace cantidadPagada=pagadaOfirec if missing(cantidadPagada)


gen cantidadOtorgada=otorgadaExp
replace cantidadOtorgada=otorgadaOfirec if missing(cantidadOtorgada)
*replace cantidadOtorgada=0 if missing(cantidadOtorgada)

replace cantidadOtorgada=cantidadPagada if missing(cantidadOtorgada) & !missing(cantidadPagada)

*Modo de termino--------
gen modoTermino_s=terminoExp

replace modoTermino_s=terminoOfirec if fechaOfirec>fechaExp & !missing(fechaOfirec)
replace modoTermino_s=terminoOfirec if missing(modoTermino_s)
replace modoTermino_s=terminoOfirec if modoTermino_s=="CONTINUA" & (cantidadPagada!=0 | cantidadOtorgada!=0)
replace modoTermino_s=terminoExp if modoTermino_s=="CONTINUA" & (cantidadPagada!=0 | cantidadOtorgada!=0)

encode modoTermino_s, gen(modoTermino)
sort junta exp anio NombreActor
by junta exp anio: keep if _n==1
keep junta expediente anio modoTermino cantidadOtorgada cantidadPagada fechaOfirec fechaExp fechaUltimoMov
rename expediente exp
gen phase = 2

append using ".\Terminaciones\Data\terminaciones.dta"
replace phase = 1 if missing(phase)
save ".\Terminaciones\Data\followUps2020.dta", replace

