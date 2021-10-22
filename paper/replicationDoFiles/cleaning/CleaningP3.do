

********************************************************************************
*									  ARM 2							  		   *
********************************************************************************
*Revisa si arm2 sucedio en dia A o B
import excel ".\Raw\base_control_encuestas.xlsx", sheet("ALEATORIZACIONES") ///
	firstrow clear
rename tratamiento tratamiento_grupo
rename fechas date
save ".\_aux\randomization_arm2.dta", replace



********************************************************************************
*						   	Names of 'demandados'					  		   *
********************************************************************************
import excel ".\Raw\base_control_encuestas.xlsx", sheet("T_DEMANDADOS") ///
	firstrow clear
*Drop example row	
drop if _n==1	
drop if missing(id_main)
keep id_main nombre_demandado

*Reshape to wide
bysort id_main : gen j=_n
reshape wide nombre_demandado, i(id_main) j(j)

save ".\_aux\demandados_tr.dta", replace



********************************************************************************
*									  TD							  		   *
********************************************************************************
*Guarda la informacion de treatment data y limpia fechas
import delimited ".\Raw\treatment_data.csv", clear
duplicates drop
drop if missing(fecha_alta)
drop if id_main<16 & !missing(id_main)


gen date=date(fecha_alta, "YMD")
drop if date<date("01-01-2017","DMY")
format date %td
label variable date fecha_alta

foreach var of varlist fecha_alta fecha_salida fecha_entrada c_fecha_entrada cita_fecha {
	gen `var'_=date(`var', "YMD")
	drop `var'
	rename `var'_ `var'
	}

save ".\_aux\treatment_data.dta", replace



********************************************************************************
*									  2W			   				  		   *
********************************************************************************
do ".\DoFiles\cleaning\cleaning_2w_survey.do"



********************************************************************************
*									  2M			   				  		   *
********************************************************************************
do ".\DoFiles\cleaning\cleaning_2m_survey.do"



********************************************************************************
*									  TD							  		   *
********************************************************************************
use ".\_aux\treatment_data.dta", clear


*Join nivel_educativo
merge 1:1 id_actor using ".\DB\survey_data_2w.dta", nogen keep(1 3) keepusing(id_actor grado_de_estudios)
replace nivel_educativo=grado_de_estudios if missing(nivel_educativo)
drop grado_de_estudios

*Covariates

gen na_prob=0
replace na_prob=1 if missing(prob_ganar)

gen na_cant=0
replace na_cant=1 if missing(cantidad_ganar)

gen na_prob_mayor=0
replace na_prob_mayor=1 if missing(prob_mayor)

gen na_cant_mayor=0
replace na_cant_mayor=1 if missing(cant_mayor)

gen retail=(giro==46) if !missing(giro)

gen outsourcing=(giro==56) if !missing(giro)

gen mujer=(genero=="Mujer") if !missing(genero)

gen high_school=inlist(nivel_educativo, 3, 4) if !missing(nivel_educativo)

gen diurno=(tipo_jornada=="Diurno") if !missing(tipo_jornada)

gen top_sue=(top_demandado==1) if !missing(top_demandado)

gen big_size=inrange(tamanio_establecimiento,3,4) if !missing(tamanio_establecimiento)


*Predicting covariates of attrition
gen telefono_fijo_=(length(telefono_fijo)>=5)
drop telefono_fijo
rename telefono_fijo_ telefono_fijo

gen telefono_cel_=(length(telefono_cel)>=5)
drop telefono_cel
rename telefono_cel_ telefono_cel

gen email_=!missing(email)
drop email
rename email_ email

gen colonia_=!missing(colonia)
drop colonia
rename colonia_ colonia

destring codigo_postal, replace force
gen m_cp=missing(codigo_postal)

*Dummy Monday | Tuesday
gen dow = dow( date )
gen mon_tue=inrange(dow,1,2)


*Separate arm 2 into 2A & 2B
merge m:1 date using ".\_aux\randomization_arm2.dta", nogen keep(1 3)
replace grupo_tratamiento=tratamiento_grupo if grupo_tratamiento=="2" & !missing(tratamiento_grupo)
replace grupo_tratamiento="2A" if grupo_tratamiento=="2"

egen treatment=group(grupo_tratamiento)

*Treatment
gen tratamiento=substr(grupo_tratamiento,1,1)
egen main_treatment=group(tratamiento)

*Keep sample when experiment was ran for the 3 treatments
replace main_treatment=. if fecha_alta>=date("20/08/2018","DMY")
drop tratamiento

*A vs B
gen grupo=substr(grupo_tratamiento,2,1)
egen group=group(grupo)
drop grupo

*Fix NEW A/B (replacing 'pre-earthquake')

replace group=. if inrange(date,date("19-09-2017","DMY"),date("20-08-2018","DMY"))

*NEW A/B!!!
*replace group=. if date<date("20-08-2018","DMY")


*Paste names of 'demandados'
merge m:1 id_main using ".\_aux\demandados_tr.dta", nogen keep(1 3)
replace nombre_demandado1=nombre_empresa if missing(nombre_demandado1)
drop nombre_empresa

*Baseline expectations
replace prob_ganar=prob_ganar/100 if prob_ganar>1
replace prob_ganar_treat=prob_ganar_treat/100 if prob_ganar_treat>1


*IMPORTANT!!!: Comment this line to get full dataset
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*keep if inrange(date,date("01-01-2015","DMY"),date("01-02-2018","DMY"))
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

save ".\DB\treatment_data.dta", replace


/*
********************************************************************************
*						     	Base informatica					  		   *
********************************************************************************
do ".\DoFiles\expedientes_cleaning.do"

*Name cleaning
do ".\DoFiles\clean_exact_match.do"
global threshold_similscore = 0.94
do ".\DoFiles\clean_fuzzy_match.do"


*do ".\DoFiles\merge_diagnostics.do"

