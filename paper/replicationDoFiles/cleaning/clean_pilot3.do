import excel ".\Raw\SEGUNDO SEGUIMIENTO CONTROL CAPTURA INICIALES.xlsx", firstr clear

drop S - AF
replace EXPEDIENTE = subinstr(EXPEDIENTE, ".pdf","",.)
replace EXPEDIENTE = subinstr(EXPEDIENTE, "J","",.)
tempfile base
ren IDACTOR id_actor
duplicates tag id_actor EXPEDIENTE, gen(dups)
drop if dups>0
drop dups
save `base', replace
replace id_actor = subinstr(id_actor, ",", ";",.)
split id_actor, parse(";")
drop id_actor

preserve
ren id_actor1 id_actor
keep id_actor EXPEDIENTE LUGAURL ESTATUS FECHADETERMINO MODODETERMINO UBICACIÓN CANTIDAD CANTIDADCOBRADA1SI0NO2NO COINCIDEACTOR1SI0NO2NOE OBSERVACIONES OBSERVACIONESDEIDACTOR TRATAMIENTO OBSERVACIONESGENERALESDELEXPE auxiliar junta expediente anio
save `base', replace
restore

forvalues i = 2/6{
preserve
keep id_actor`i' EXPEDIENTE LUGAURL ESTATUS FECHADETERMINO MODODETERMINO UBICACIÓN CANTIDAD CANTIDADCOBRADA1SI0NO2NO COINCIDEACTOR1SI0NO2NOE OBSERVACIONES OBSERVACIONESDEIDACTOR TRATAMIENTO OBSERVACIONESGENERALESDELEXPE auxiliar junta expediente anio
ren id_actor`i' id_actor
append using `base'
save `base', replace
restore 
}

use `base', clear
drop if id_actor==""

replace id_actor=stritrim(trim(itrim(upper(id_actor))))

drop LUGAURL junta expediente anio
gen date = date(FECHADETERMINO, "DMY")
drop FECHADETERMINO
ren date FECHADETERMINO
destring COINCIDEACTOR1SI0NO2NOE, force replace
gen source = 1
save `base', replace

import excel ".\Raw\TERCER SEGUIMIENTO CONTROL CAPTURA INICIALES.xlsx", firstr clear

drop if EXPEDIENTE =="" | missing(IDACTOR)
ren IDACTOR id_actor
drop N O P Q R S T U V W X Y Z AA AB AC AD AE
gen source = 2 
append using `base'
save `base', replace 

import excel ".\Raw\SEGUIMIENTO CONTROL CAPTURA INICIALES.xlsx", firstr clear
drop S T U V W X Y Z AA AB AC AD AE AF

replace EXPEDIENTE = subinstr(EXPEDIENTE, ".pdf","",.)
replace EXPEDIENTE = subinstr(EXPEDIENTE, "J","",.)
ren IDACTOR id_actor
duplicates drop
duplicates tag id_actor EXPEDIENTE, gen(dups)
drop if dups>0
drop dups
gen fechadate = date(FECHADETERMINO, "DMY")
format fechadate %td
drop FECHADETERMINO
rename fechadate FECHADETERMINO
*save `base', replace


replace id_actor = subinstr(id_actor, ",", ";",.)
split id_actor, parse(";")
drop id_actor

*tempfile base0 `base0'

*preserve
*ren id_actor1 id_actor
*keep id_actor EXPEDIENTE LUGAURL ESTATUS FECHADETERMINO MODODETERMINO UBICACIÓN CANTIDAD CANTIDADCOBRADA1SI0NO2NO COINCIDEACTOR1SI0NO2NOE OBSERVACIONES OBSERVACIONESDEIDACTOR TRATAMIENTO auxiliar junta expediente anio
*save `base0', replace
*restore

ren id_actor2 id_actor
keep id_actor EXPEDIENTE LUGAURL ESTATUS FECHADETERMINO MODODETERMINO UBICACIÓN CANTIDAD CANTIDADCOBRADA1SI0NO2NO COINCIDEACTOR1SI0NO2NOE OBSERVACIONES OBSERVACIONESDEIDACTOR TRATAMIENTO auxiliar junta expediente anio
*append using `base0'
drop if missing(id_actor)
gen source = 0
*gen fecha = date(FECHADETERMINO, "DMY")
*drop FECHADETERMINO
*ren fecha FECHADETERMINO
destring auxiliar, replace force

append using `base'
duplicates drop 
duplicates tag EXPEDIENTE id_actor, gen(dupsgraves)
drop if dups==1

save ".\DB\P3Outcomes.dta", replace
//export excel "$sharelatex\p1_w_p3\out\dulce_1911.xlsx", replace firstr(var)
