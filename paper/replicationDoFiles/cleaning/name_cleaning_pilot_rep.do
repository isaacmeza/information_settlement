*Cleaning of lawyer names and office

use ".\DB\pilot_casefiles.dta", clear


*************************
*		DESPACHO		*
*************************


*Remove blank spaces
gen despacho_actor=stritrim(trim(itrim(upper(despachoactor))))

*Remove special characters
gen newname = "" 
gen length = length(despacho_actor) 
su length, meanonly 

forval i = 1/`r(max)' { 
     local char substr(despacho_actor, `i', 1) 
     local OK inrange(`char', "a", "z") | inrange(`char', "A", "Z")  | `char'==" "
     replace newname = newname + `char' if `OK' 
}
replace despacho_actor=newname
drop newname length

*Basic name cleaning 
replace despacho_actor = subinstr(despacho_actor, ".", "", .)
replace despacho_actor = subinstr(despacho_actor, " & ", " ", .)
replace despacho_actor = subinstr(despacho_actor, "&", "", .)
replace despacho_actor = subinstr(despacho_actor, " Y ", " ", .)
replace despacho_actor = subinstr(despacho_actor, ",", "", .)
replace despacho_actor = subinstr(despacho_actor, "Ñ", "N", .)
replace despacho_actor = subinstr(despacho_actor, " S C", " SC", .)
replace despacho_actor = subinstr(despacho_actor, " SC", " ", .)
replace despacho_actor = subinstr(despacho_actor, " SA DE CV", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ABOGADOS", "", .)
replace despacho_actor = subinstr(despacho_actor, "ABOGADO", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ASOCIADOS", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ASOCIADO", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ASOSCIADO", " ", .)
replace despacho_actor = subinstr(despacho_actor, "LIC ", " ", .)
replace despacho_actor = subinstr(despacho_actor, "-", " ", .)

replace despacho_actor=stritrim(trim(itrim(upper(despacho_actor))))
replace despacho_actor="ABOGADOS ASOCIADOS" if missing(despacho_actor) & !missing(despacho_ac)

*Group according to Levenshtein distance
strgroup despacho_actor , gen(gp_despacho) threshold(.2) normalize(longer)

sort gp_despacho despacho_actor
by gp_despacho : replace despacho_actor=despacho_actor[1]

*Manual cleaning
replace despacho_actor="NO MENCIONA" if despacho_actor=="NO MECIONA" | despacho_actor=="NO ESPECIFICA"
replace despacho_actor="SALFRA" if despacho_actor=="AL RA"


*************************
*		 ABOGADO		*
*************************

forvalues j=1/3 {

	*Remove blank spaces
	gen nombre_abogado_`j'=stritrim(trim(itrim(upper(nombreabogado`j'))))
	
	*Remove special characters
	gen newname = "" 
	gen length = length(nombre_abogado_`j') 
	su length, meanonly 

	forval i = 1/`r(max)' { 
		 local char substr(nombre_abogado_`j', `i', 1) 
		 local OK inrange(`char', "a", "z") | inrange(`char', "A", "Z")  | `char'==" "
		 replace newname = newname + `char' if `OK' 
	}
	replace nombre_abogado_`j'=newname
	drop newname length

	*Basic name cleaning 
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "Ñ", "N", .)
	//replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', """, "", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "'", "", .)

	replace nombre_abogado_`j'=stritrim(trim(itrim(upper(nombre_abogado_`j'))))

	*Group according to Levenshtein distance
	strgroup nombre_abogado_`j' , gen(nombre_`j') threshold(.25) normalize(longer)

	sort nombre_`j' nombre_abogado_`j'
	by nombre_`j' : replace nombre_abogado_`j'=nombre_abogado_`j'[1]
	
	*Manual cleaning
	replace nombre_abogado_`j'="" if  nombre_abogado_`j'=="NO ESPECIFICA" | nombre_abogado_`j'=="NO MENCIONA"

	}

*No repetition
replace nombre_abogado_2="" if nombre_abogado_1==nombre_abogado_2
replace nombre_abogado_3="" if nombre_abogado_3==nombre_abogado_2 | nombre_abogado_3==nombre_abogado_1

	
* Here we group the name of the lawyers in alphabetical order and cluster them 
* according to 'office' (despacho)
	
gen order_1=.
gen order_2=.
gen order_3=.

*First lawyer name in alphabetical order
gen primer_nombre="NO MENCIONA" if nombre_abogado_1==""

local i=1
count if missing(primer_nombre)
while `r(N)'>0 	{

	replace order_1=strpos("ABCDEFGHIJKLMNOPQRSTUVWXYZ", substr(nombre_abogado_1,`i',1)) if !missing(nombre_abogado_1)
	replace order_2=strpos("ABCDEFGHIJKLMNOPQRSTUVWXYZ", substr(nombre_abogado_2,`i',1)) if !missing(nombre_abogado_2)
	replace order_3=strpos("ABCDEFGHIJKLMNOPQRSTUVWXYZ", substr(nombre_abogado_3,`i',1)) if !missing(nombre_abogado_3)

	replace primer_nombre=nombre_abogado_1  if order_1<min(order_2, order_3) & missing(primer_nombre)
	replace primer_nombre=nombre_abogado_2  if order_2<min(order_1, order_3) & missing(primer_nombre)
	replace primer_nombre=nombre_abogado_3  if order_3<min(order_2, order_1) & missing(primer_nombre)
	
	local i=`i'+1
	count if missing(primer_nombre)
	}

	
*Last lawyer name in alphabetical order	
gen tercer_nombre="NO MENCIONA" if nombre_abogado_1==""
replace tercer_nombre="NO MENCIONA" if nombre_abogado_2=="" & nombre_abogado_3==""

local i=1
count if missing(tercer_nombre)
while `r(N)'>0 	{

	replace order_1=strpos("ABCDEFGHIJKLMNOPQRSTUVWXYZ", substr(nombre_abogado_1,`i',1)) if !missing(nombre_abogado_1)
	replace order_2=strpos("ABCDEFGHIJKLMNOPQRSTUVWXYZ", substr(nombre_abogado_2,`i',1)) if !missing(nombre_abogado_2)
	replace order_3=strpos("ABCDEFGHIJKLMNOPQRSTUVWXYZ", substr(nombre_abogado_3,`i',1)) if !missing(nombre_abogado_3)

	replace tercer_nombre=nombre_abogado_1  if order_1>max(order_2, order_3) & missing(tercer_nombre)
	replace tercer_nombre=nombre_abogado_2  if order_2>max(order_1, order_3) & missing(tercer_nombre)
	replace tercer_nombre=nombre_abogado_3  if order_3>max(order_2, order_1) & missing(tercer_nombre)
	
	local i=`i'+1
	count if missing(tercer_nombre)
	}
	

*Middle lawyer name in alphabetical order	
gen segundo_nombre=""

replace segundo_nombre=nombre_abogado_1 if nombre_abogado_1!=primer_nombre & nombre_abogado_1!=tercer_nombre
replace segundo_nombre=nombre_abogado_2 if nombre_abogado_2!=primer_nombre & nombre_abogado_2!=tercer_nombre
replace segundo_nombre=nombre_abogado_3 if nombre_abogado_3!=primer_nombre & nombre_abogado_3!=tercer_nombre


replace primer_nombre="" if primer_nombre=="NO MENCIONA"
replace segundo_nombre="" if segundo_nombre=="NO MENCIONA"
replace tercer_nombre="" if tercer_nombre=="NO MENCIONA"


*Names of lawyers in alphabetical order
gen abogados_orden=primer_nombre + " " + segundo_nombre + " " + tercer_nombre

*Remove blank spaces
replace abogados_orden=stritrim(trim(itrim(upper(abogados_orden))))

*Group according to Levenshtein distance
strgroup abogados_orden , gen(gp_orden) threshold(.4) normalize(longer)

sort gp_orden abogados_orden
by gp_orden : replace abogados_orden=abogados_orden[1]


* We impute the name of the office when it is unknown and when a group of lawyers 
* (whose office name is known) work in given office

replace despacho_actor="" if despacho_actor=="NO MENCIONA"
gsort gp_orden -despacho_actor
bysort gp_orden:  replace despacho_actor = despacho_actor[_n-1]  if missing(despacho_actor)

*When office name is not known we impute name of lawyers
bysort gp_orden : gen repeats=_N
replace despacho_actor=abogados_orden if missing(despacho_actor) & repeats>=5


*Ignore "NO MENCIONA" and "PROCURADURIA" cases
replace gp_despacho=. if inlist(gp_despacho,1,5,32)

*Encodes the gp_despacho id that are essentially the same
*later on we recode them
preserve

collapse repeats, by(gp_orden gp_despacho)
drop if missing(gp_despacho)
bysort gp_orden : egen counts=nvals(gp_despacho)
qui su counts
forvalues k=1/`r(max)' {
	bysort gp_orden: gen m_`k'=gp_despacho[`k']  if counts>=2
	}
duplicates drop gp_orden, force
drop if missing(m_1)
keep gp_orden m_*
tempfile temp
save `temp'

restore

merge m:1 gp_orden using `temp', nogen
	
*Dummy procedure to get the unique recoding values

replace gp_despacho=-1 if missing(gp_despacho)

qui egen unique=group(m_*), missing
qui su unique
local max=`r(max)'-1
forvalues i=1/`max' {
	local j=1
	foreach var of varlist m_* {
		qui su m_`j' if unique==`i'
		local m_`j'=r(mean)
		recode gp_despacho (`m_`j'' = `m_1') 
		local j=`j'+1
		}
	}

*Homologation names
bysort  gp_despacho : gen office_emp_law=despacho_actor[1] if !missing(despacho_actor) 
*Replace missing values
replace office_emp_law=despacho_actor if gp_despacho==-1

*Numerical identifier
egen gp_office_emp_law=group(office_emp_law)

*Flag identifying how many casefiles each office manages
bysort gp_office_emp_law : replace repeats=_N
replace repeats=. if missing(gp_office_emp_law)

********************************************************************************
***								FINAL VARIABLES  			   			     ***
********************************************************************************

/*
 office_emp_law gp_office_emp_law nombre_abogado_* abogados_orden gp_orden repeats
*/

save ".\DB\pilot_casefiles.dta", replace

