**Limpiar base terminaciones**

import excel ".\Raw\terminoExpedientes.xlsx", sheet("seguimiento_31enero2020") cellrange(A3:U357) firstrow clear

*Nombres---------------
rename FechadetérminoFechadeúlti fechaOfirec_s
rename Junta junta
rename Expediente expediente
rename Año anio
rename Cantidadotorgadaenlaudoaco otorgadaOfirec
rename CantidadpagadaINEGI pagadaOfirec
rename MododetérminoOFIREC terminoOfirec
rename MododetérminoEXPEDIENTE terminoExp
rename K fechaExp_s
rename L otorgadaExp
rename DummylaudoconveniopagadoCOM pagoCompleto
rename OBSERVACIONESOFIREC comentariosOfirec
rename Observaciones comentariosExp
rename Cantidadpagada pagadaExp

*Fechas
gen fechaOfirec=date(fechaOfirec_s,"DMY")
gen fechaExp=date(fechaExp_s,"DMY")

format fechaOfirec %td
format fechaExp %td
lab var fechaOfirec "Fecha de ultimo movimiento registrado en OFIREC"
lab var fechaExp "Fecha de ultimo movimiento registrado en expediente"

gen diff=fechaOfirec-fechaExp
gen fechaUltimoMov=fechaOfirec
replace fechaUltimoMov=fechaExp if diff<0 | missing(fechaOfirec)
*gen today=date("16/02/2020","DMY")//Fecha hoy
*gen diff2=today-fechaUltimoMov

drop REVISAR 

*Cantidad pagada--------
gen cantidadPagada=pagadaExp

replace cantidadPagada=pagadaOfirec if missing(cantidadPagada)
// Esto se quita para poder imputar posteriormente
*replace cantidadPagada=0 if missing(cantidadPagada)

*Cantidad otorgada------
gen nonnum=real(otorgadaExp)==.
replace otorgadaExp="" if nonnum==1
destring otorgadaExp, replace
drop nonnum

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
replace modoTermino_s="LAUDO" if modoTermino_s=="LAUDO "
replace modoTermino_s="CONVENIO" if modoTermino_s=="CONVENIO "

encode modoTermino_s, gen(modoTermino)

keep junta expediente anio modoTermino cantidadOtorgada cantidadPagada fechaOfirec fechaExp fechaUltimoMov
rename expediente exp
save ".\DB\terminaciones.dta", replace

