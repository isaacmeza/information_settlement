*Cleaning of lawyer names and office


*************************
*		DESPACHO		*
*************************

*Remove blank spaces
gen despacho_actor=stritrim(trim(itrim(upper(despacho_ac))))

*Generate PROCURADURIA
replace despacho_actor="PROCURADURIA" if abogado_pub==1


*Basic name cleaning 
replace despacho_actor = subinstr(despacho_actor, ".", "", .)
replace despacho_actor = subinstr(despacho_actor, " & ", " ", .)
replace despacho_actor = subinstr(despacho_actor, "&", "", .)
replace despacho_actor = subinstr(despacho_actor, " Y ", " ", .)
replace despacho_actor = subinstr(despacho_actor, ",", "", .)
replace despacho_actor = subinstr(despacho_actor, "Ñ", "N", .)
replace despacho_actor = subinstr(despacho_actor, "-", " ", .)
replace despacho_actor = subinstr(despacho_actor, "á", "A", .)
replace despacho_actor = subinstr(despacho_actor, "é", "E", .)
replace despacho_actor = subinstr(despacho_actor, "í", "I", .)
replace despacho_actor = subinstr(despacho_actor, "ó", "O", .)
replace despacho_actor = subinstr(despacho_actor, "ú", "U", .)
replace despacho_actor = subinstr(despacho_actor, "Á", "A", .)
replace despacho_actor = subinstr(despacho_actor, "É", "E", .)
replace despacho_actor = subinstr(despacho_actor, "Í", "I", .)
replace despacho_actor = subinstr(despacho_actor, "Ó", "O", .)
replace despacho_actor = subinstr(despacho_actor, "Ú", "U", .)
replace despacho_actor = subinstr(despacho_actor, "â", "A", .)
replace despacho_actor = subinstr(despacho_actor, "ê", "E", .)
replace despacho_actor = subinstr(despacho_actor, "î", "I", .)
replace despacho_actor = subinstr(despacho_actor, "ô", "O", .)
replace despacho_actor = subinstr(despacho_actor, "ù", "U", .)
replace despacho_actor = subinstr(despacho_actor, "Â", "A", .)
replace despacho_actor = subinstr(despacho_actor, "Ê", "E", .)
replace despacho_actor = subinstr(despacho_actor, "Î", "I", .)
replace despacho_actor = subinstr(despacho_actor, "Ô", "O", .)
replace despacho_actor = subinstr(despacho_actor, "Û", "U", .)
replace despacho_actor = subinstr(despacho_actor, " S C", " SC", .)
replace despacho_actor = subinstr(despacho_actor, " SC", " ", .)
replace despacho_actor = subinstr(despacho_actor, " SA DE CV", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ABOGADOS", "", .)
replace despacho_actor = subinstr(despacho_actor, "ABOGADO", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ASOCIADOS", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ASOCIADO", " ", .)
replace despacho_actor = subinstr(despacho_actor, "ASOSCIADO", " ", .)
replace despacho_actor = subinstr(despacho_actor, "LIC ", " ", .)
replace despacho_actor = subinstr(despacho_actor, "LICENCIADA ", " ", .)
replace despacho_actor = subinstr(despacho_actor, "LICENCIADO ", " ", .)
replace despacho_actor = subinstr(despacho_actor, "-", " ", .)

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

replace despacho_actor=stritrim(trim(itrim(upper(despacho_actor))))
replace despacho_actor="ABOGADOS ASOCIADOS" if missing(despacho_actor) & !missing(despacho_ac)

*Group according to Levenshtein distance
strgroup despacho_actor , gen(gp_despacho) threshold(.2) normalize(longer)

sort gp_despacho despacho_actor
by gp_despacho : replace despacho_actor=despacho_actor[1]

*Manual cleaning
replace despacho_actor="NO MENCIONA" if despacho_actor=="" | despacho_actor=="NO ESPECIFICA"
replace despacho_actor="SALFRA" if despacho_actor=="AL RA"


*************************
*		 ABOGADO		*
*************************

forvalues j=1/3 {

	*Remove blank spaces
	gen nombre_abogado_`j'=stritrim(trim(itrim(upper(nombre_abogado`j'_ac))))
	

	*Basic name cleaning 
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', ".", "", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', " & ", " ", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "&", "", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', ",", "", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "ñ", "N", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "Ñ", "N", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "-", " ", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "á", "A", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "é", "E", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "í", "I", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "ó", "O", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "ú", "U", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "Á", "A", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "É", "E", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "Í", "I", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "Ó", "O", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "Ú", "U", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "â", "A", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "ê", "E", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "î", "I", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "ô", "O", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "ù", "U", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "Â", "A", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "Ê", "E", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "Î", "I", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "Ô", "O", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "Û", "U", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', " DE ", " ", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', " DEL ", " ", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', " LA ", " ", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', " LAS ", " ", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', " LO ", " ", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', " LOS ", " ", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "´", "", .)
	replace nombre_abogado_`j' = subinstr(nombre_abogado_`j', "'", "", .)

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
	
*Sort in rows
rowsort nombre_abogado_1 nombre_abogado_2 nombre_abogado_3, generate(order_names1-order_names3)

*Names of lawyers in alphabetical order
gen abogados_orden=order_names1 + " " + order_names2 + " " + order_names3

*Remove blank spaces
replace abogados_orden=stritrim(trim(itrim(upper(abogados_orden))))

*Group according to Levenshtein distance
strgroup abogados_orden , gen(gp_orden) threshold(.4) normalize(longer)

sort gp_orden abogados_orden
by gp_orden : replace abogados_orden=abogados_orden[1]


* We impute the name of the office when it is unknown and when a group of lawyers 
* (whose office name is known) work in given office

replace despacho_actor="" if despacho_actor=="NO MENCIONA"
gen despacho_plaintiff=despacho_actor
gsort gp_orden -despacho_actor
bysort gp_orden:  replace despacho_actor = despacho_actor[_n-1]  if missing(despacho_actor)

*When office name is not known we impute name of lawyers
bysort gp_orden : gen repeats=_N
replace despacho_actor=abogados_orden if missing(despacho_actor) & repeats>=5


*Ignore "NO MENCIONA" and "PROCURADURIA" cases
replace gp_despacho=. if inlist(gp_despacho,.) | abogado_pub==1

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

