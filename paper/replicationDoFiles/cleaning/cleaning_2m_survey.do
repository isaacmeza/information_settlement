*Cleaning 2m survey
***************************************OPM**************************************
import excel ".\Raw\base_control_encuestas.xlsx", ///
	sheet("TRANSFERENCIA_EMPRESA_ENCUESTAS") cellrange(A3:U987) firstrow clear
	
	
*Homologation FOLIODELTRABAJADORENCUESTAEM
rename FOLIODELTRABAJADOR id_actor
rename FOLIODELTRABAJADORENCUESTAEM id_opm


keep id_actor id_opm 

tempfile temp_asignaciones
save `temp_asignaciones'

********************************************************************************


program drop _all
do ".\DoFiles\cleaning\rename_opm.do"


forvalues t=1/4 {	

	use ".\Raw\transferencia_`t'.dta", clear
	
	rename_opm


	*Remove special characters
	gen newname = "" 
	gen length = length(id_opm) 
	su length, meanonly 
	replace id_opm=substr(id_opm,1,7)

	forval i = 1/`r(max)' { 
		 local char substr(id_opm, `i', 1) 
		 local OK inrange(`char', "0", "9") 
		 qui replace newname = newname + `char' if `OK' 
	}
	replace id_opm=newname
	drop newname length
		
	destring id_opm, replace 
	drop if missing(status_encuesta)


	*Variable cleaning
	foreach var of varlist  conflicto_arreglado reinstalacion entablo_demanda_1 ///
			se_registro_el_acuerdo_ante_la_ entablo_demanda_2 ///
			asistio_patron_a_la_cita pidio_ser_reinstalado ///
			quiere_cambiar_abogado ha_dejado_de_pagar_servicio_bas ///
			ha_faltado_dinero_para_comida trabaja_actualmente busca_trabajo {
		gen `var'_=(upper(`var')!="NO") if !missing(`var') & length(`var')<=4
		drop `var'
		rename `var'_ `var'
		}

	egen entablo_demanda=rowtotal(entablo_demanda_*)
	replace entablo_demanda=(entablo_demanda>=1) if !missing(entablo_demanda)
	drop entablo_demanda_*
		
	foreach var of varlist fecha* {
		gen `var'_=date(`var', "DMY")
		drop `var'
		rename `var'_ `var'
		format `var' %td
		}

	gen demando_con_abogado_publico=.
	replace demando_con_abogado_publico=1 if ///
		(lower(demando_con_abogado_publico_1)!="privado" | lower(demando_con_abogado_publico_2)!="privado") 
	replace demando_con_abogado_publico=0 if ///
		(lower(demando_con_abogado_publico_1)=="privado" | lower(demando_con_abogado_publico_2)=="privado") 

	gen demando_con_abogado_privado=.
	replace demando_con_abogado_privado=0 if ///
		(lower(demando_con_abogado_publico_1)!="privado" | lower(demando_con_abogado_publico_2)!="privado") 
	replace demando_con_abogado_privado=1 if ///
		(lower(demando_con_abogado_publico_1)=="privado" | lower(demando_con_abogado_publico_2)=="privado") 
			
	replace donde_lo_contacto_="" if strpos(donde_lo_contacto_, "No")!=0
	gen donde_lo_contacto=1 if strpos(donde_lo_contacto_, "Junta")!=0
	replace donde_lo_contacto=2 if missing(donde_lo_contacto) & !missing(donde_lo_contacto_)
	drop donde_lo_contacto_	

	gen tramito_citatorio_=.
	replace tramito_citatorio_=1 if strpos(upper(tramito_citatorio), "S")!=0
	drop tramito_citatorio
	rename tramito_citatorio_ tramito_citatorio

	gen como_lo_consiguio_=.
	replace como_lo_consiguio_=1 if strpos(lower(como_lo_consiguio), "recomendaron")!=0 & ///
			strpos(lower(como_lo_consiguio), "entrada")!=0 & ///
			strpos(lower(como_lo_consiguio), "junta")!=0 
	replace como_lo_consiguio_=2 if strpos(lower(como_lo_consiguio), "encont")!=0 & ///
			strpos(lower(como_lo_consiguio), "entrada")!=0 & ///
			strpos(lower(como_lo_consiguio), "junta")!=0 
	replace como_lo_consiguio_=3 if strpos(lower(como_lo_consiguio), "recomendad")!=0 & ///
			strpos(lower(como_lo_consiguio), "familiar")!=0 & ///
			strpos(lower(como_lo_consiguio), "amigo")!=0 
	replace como_lo_consiguio_=4 if strpos(lower(como_lo_consiguio), "familiar")!=0 & ///
			strpos(lower(como_lo_consiguio), "amigo")!=0 
	replace como_lo_consiguio_=5 if strpos(lower(como_lo_consiguio), "internet")!=0 
	replace como_lo_consiguio_=6 if strpos(lower(como_lo_consiguio), "otro")!=0 
	drop como_lo_consiguio
	rename como_lo_consiguio_ como_lo_consiguio

	gen esquema_de_cobro_otro_=0 if lower(esquema_de_cobro_otro)=="no"
	drop esquema_de_cobro_otro
	rename esquema_de_cobro_otro_ esquema_de_cobro_otro


	destring nivel_de_satisfaccion_abogado, replace force

	gen enojo_con_la_empresa_=.
	replace enojo_con_la_empresa_=1 if strpos(lower(enojo_con_la_empresa),"mucho")!=0
	replace enojo_con_la_empresa_=2 if strpos(lower(enojo_con_la_empresa),"medianamente")!=0
	replace enojo_con_la_empresa_=3 if strpos(lower(enojo_con_la_empresa),"poco")!=0
	replace enojo_con_la_empresa_=4 if strpos(lower(enojo_con_la_empresa),"nada")!=0
	drop enojo_con_la_empresa
	rename enojo_con_la_empresa_ enojo_con_la_empresa

	gen  mas_o_menos_de_75=strpos(mas_o_menos_de_75_, "Mas")!=0 if !missing(mas_o_menos_de_75_)
	gen  mas_o_menos_de_6_meses_de_sueldo=strpos(mas_o_menos_de_6_meses_de_sueld_, "Mas")!=0 if !missing(mas_o_menos_de_6_meses_de_sueld_)
	drop mas_o_menos_de_75_  mas_o_menos_de_6_meses_de_sueld_


	gen que_elemento_es_el_mas_important=.
	replace que_elemento_es_el_mas_important=1 if strpos(lower(elemento_elaborar_expectativas), "dicho")!=0 & ///
			strpos(lower(elemento_elaborar_expectativas), "abogado")!=0 
	replace que_elemento_es_el_mas_important=2 if strpos(lower(elemento_elaborar_expectativas), "dijeron")!=0 & ///
			strpos(lower(elemento_elaborar_expectativas), "entrada")!=0 & ///
			strpos(lower(elemento_elaborar_expectativas), "junta")!=0 
	replace que_elemento_es_el_mas_important=3 if strpos(lower(elemento_elaborar_expectativas), "dijeron")!=0 & ///
			strpos(lower(elemento_elaborar_expectativas), "otra")!=0 & ///
			strpos(lower(elemento_elaborar_expectativas), "parte")!=0 
	replace que_elemento_es_el_mas_important=4 if strpos(lower(elemento_elaborar_expectativas), "dicho")!=0 & ///
			strpos(lower(elemento_elaborar_expectativas), "familiar")!=0 & ///
			strpos(lower(elemento_elaborar_expectativas), "amigo")!=0	
	replace que_elemento_es_el_mas_important=5 if strpos(lower(elemento_elaborar_expectativas), "yo mismo")!=0 
	drop elemento_elaborar_expectativas

	
	foreach var of varlist ultimo_mes_*{
		cap tostring `var', replace force
		}
	gen ultimo_mes_base=ultimo_mes_1+ultimo_mes_2+ultimo_mes_3+ultimo_mes_4
	gen comprado_casa_o_terreno=strpos(ultimo_mes_base, "casa")!=0 if !missing(ultimo_mes_base)
	gen comprado_electrodomestico=strpos(ultimo_mes_base, "electr")!=0 if !missing(ultimo_mes_base)
	drop ultimo_mes_*

	gen comparacion_con_el_trabajo_anter=.
	replace comparacion_con_el_trabajo_anter=1 if upper(comparacion_con_el_trabajo_an)=="MEJOR" 
	replace comparacion_con_el_trabajo_anter=2 if upper(comparacion_con_el_trabajo_an)=="PEOR" 
	replace comparacion_con_el_trabajo_anter=3 if upper(comparacion_con_el_trabajo_an)=="IGUAL" 
	drop comparacion_con_el_trabajo_an

	gen tiempo_arreglar_asunto=.
	replace tiempo_arreglar_asunto=1 if strpos(tiempo_arreglar_asunto_,"0-2 horas")!=0
	replace tiempo_arreglar_asunto=2 if strpos(tiempo_arreglar_asunto_,"2-5 horas")!=0
	replace tiempo_arreglar_asunto=3 if strpos(tiempo_arreglar_asunto_,"5-10 horas")!=0
	replace tiempo_arreglar_asunto=4 if strpos(tiempo_arreglar_asunto_,"10-15 horas")!=0
	replace tiempo_arreglar_asunto=5 if strpos(tiempo_arreglar_asunto_,"15-20 horas")!=0
	replace tiempo_arreglar_asunto=6 if strpos(tiempo_arreglar_asunto_,"20-30 horas")!=0
	replace tiempo_arreglar_asunto=7 if strpos(tiempo_arreglar_asunto_,"mas de 30 horas")!=0

	gen tiempo_arreglar_asunto_imputed=.
	replace tiempo_arreglar_asunto_imputed=1 if strpos(tiempo_arreglar_asunto_,"0-2 horas")!=0
	replace tiempo_arreglar_asunto_imputed=2.5 if strpos(tiempo_arreglar_asunto_,"2-5 horas")!=0
	replace tiempo_arreglar_asunto_imputed=7.5 if strpos(tiempo_arreglar_asunto_,"5-10 horas")!=0
	replace tiempo_arreglar_asunto_imputed=12.5 if strpos(tiempo_arreglar_asunto_,"10-15 horas")!=0
	replace tiempo_arreglar_asunto_imputed=17.5 if strpos(tiempo_arreglar_asunto_,"15-20 horas")!=0
	replace tiempo_arreglar_asunto_imputed=25 if strpos(tiempo_arreglar_asunto_,"20-30 horas")!=0
	replace tiempo_arreglar_asunto_imputed=30 if strpos(tiempo_arreglar_asunto_,"mas de 30 horas")!=0
	
	drop tiempo_arreglar_asunto_
	gen promedio_de_horas_en_traslado= tiempo_trayecto_h+ tiempo_trayecto_m/60
	drop tiempo_trayecto*

	replace probabilidad_de_ganar=round(probabilidad_de_ganar/100) if inrange(probabilidad_de_ganar, 101,10000)

	gen cantidad_num_survey=!missing(monto_que_espera_recibir)
	gen prob_num_survey=!missing(probabilidad_de_ganar)
	
	gen origen="OPM"
	
	*Homologation
	drop status_encuesta
	gen status_encuesta=1
	drop demando_con_abogado_publico_1 demando_con_abogado_publico_2 especifique_cobro 
	foreach var in q_d1 x1 x2 signa {
		cap drop `var'
		}
	rename  se_registro_el_acuerdo_ante_la_ se_registro_el_acuerdo_ante_la_j
	rename  ha_dejado_de_pagar_servicio_bas ultimos_3_meses_ha_dejado_de_pag
	rename  ha_faltado_dinero_para_comida ultimos_3_meses_le_ha_faltado_di
	save  ".\_aux\transferencia_`t'.dta", replace
	
	}
	
	
use ".\_aux\transferencia_1.dta", clear
forvalues t=2/4 {	
	append using ".\_aux\transferencia_`t'.dta"
	}	
	
merge 1:1 id_opm using `temp_asignaciones', keep(3) nogen
save ".\_aux\opm.dta", replace
 


**************************************GFORMS************************************
insheet using ".\Raw\gf2m.csv", clear


*Remove label vars
foreach var of varlist _all {
	label var `var' ""
}

*Rename 
local oldnames = ""
foreach var of varlist _all  {
local oldnames `oldnames' `var'
}
di "`oldnames'"

#delimit ;
 
rename (`oldnames') (timestamp
                  nivel_de_felicidad
                  conflicto_arreglado
                  reinstalacion
                  entablo_demanda_1
                  demando_con_abogado_privado_1
                  monto_del_convenio
                  fecha_del_arreglo
                  se_registro_el_acuerdo_ante_la_
                  entablo_demanda_2
                  demando_con_abogado_privado_2
                  entablo_demanda_3
                  fecha_de_demanda
                  demando_con_abogado_privado_3
                  como_lo_consiguio
                  cuota_por_iniciar_juicio
                  porcentaje
                  especifique_cobro_2
                  donde_lo_contacto_
                  tramito_citatorio
                  pidio_ser_reinstalado
                  cuantos_dias_de_salario_correspo
                  nivel_de_satisfaccion_abogado
                  quiere_cambiar_abogado
                  enojo_con_la_empresa
                  prob_num_survey_
                  cantidad_num_survey_
                  elemento_elaborar_expectativas_1
                  minimo_que_aceptaria_1
				  ha_dejado_de_pagar_servicio_bas
                  ha_faltado_dinero_para_comida
                  ultimo_mes_base
                  trabaja_actualmente
                  comparacion_con_el_trabajo_an
                  busca_trabajo
                  probabilidad_de_que_encuentre_tr
                  tiempo_arreglar_asunto_
                  especifique_cobro_1
                  asistio_patron_a_la_cita
                  v40
                  mas_o_menos_de_75_
                  mas_o_menos_de_6_meses_de_sueld_
                  promedio_de_horas_en_traslado
                  elemento_elaborar_expectativas_2
                  minimo_que_aceptaria_2
                  id_actor
                  fecha_ultimo_intento_encuesta
                  nombre_encuestador
                  status_encuesta
                  probabilidad_de_ganar
                  monto_que_espera_recibir
                  actitud_encuestado
				  num_exp
				  fecha_prox_audiencia_enc
				  como_se_contacto
				  razon_no_localizado
				  contrafactual_sabe_prob
				  contrafactual_prob
				  contrafactual_mas_o_menos_de_75
				  contrafactual_sabe_monto
				  contrafactual_monto
				  contrafactual_mas_o_menos_de_6_m
				  sabe_prob_cobro
				  categorica_cobro
				  prob_cobro) ;
				  
#delimit cr

*Status="Exitosa"
drop if _n<=9
bysort id_actor: gen num_intentos=_N
keep if status_encuesta=="Exitosa"
drop status_encuesta
gen status_encuesta=1

*Join variables in different columns
egen entablo_demanda=concat(entablo_demanda*)
drop entablo_demanda_*

egen demando_con_abogado_priv=concat(demando_con_abogado_privado*)
drop demando_con_abogado_privado_*

egen elemento_elaborar_expectativas=concat(elemento_elaborar_expectativas*)
drop elemento_elaborar_expectativas_*

destring minimo_que_aceptaria_*, replace force
egen minimo_que_aceptaria_para_soluci=rowtotal(minimo_que_aceptaria*)
drop minimo_que_aceptaria_*

egen especifique_cobro=concat(especifique_cobro*)
drop especifique_cobro_*


*Mutates para que se parezca al excel
gen prob_num_survey=(prob_num_survey_=="Sabe" | missing(prob_num_survey_))
gen cantidad_num_survey=(cantidad_num_survey_=="Sabe" | missing(cantidad_num_survey_))
drop prob_num_survey_ cantidad_num_survey_

*Dias de salario ("No sabe")
replace cuantos_dias_de_salario_correspo= "0" if (strpos(cuantos_dias_de_salario_correspo, "No")!=0) ///
	& !missing(cuantos_dias_de_salario_correspo)

destring nivel_de_felicidad monto_del_convenio cuota_por_iniciar_juicio ///
	porcentaje nivel_de_satisfaccion_abogado probabilidad_de_que_encuentre_tr ///
	promedio_de_horas_en_traslado monto_que_espera_recibir cuantos_dias_de_salario_correspo, replace force


*Dummy vars

foreach var of varlist  conflicto_arreglado reinstalacion se_registro_el_acuerdo_ante_la_ ///
	tramito_citatorio pidio_ser_reinstalado quiere_cambiar_abogado ///
	ha_dejado_de_pagar_servicio_bas ha_faltado_dinero_para_comida ///
	trabaja_actualmente busca_trabajo asistio_patron_a_la_cita entablo_demanda {
	
	gen `var'_=(strpos(`var', "Sí")!=0) if !missing(`var') & length(`var')<=4
	drop `var'
	rename `var'_ `var'
	}
	
	
*Recodes
gen demando_con_abogado_privado=strpos(demando_con_abogado_priv, "Privado")!=0 ///
 if (demando_con_abogado_priv!="." | demando_con_abogado_priv!="")  & entablo_demanda==1
drop demando_con_abogado_priv 

gen esquema_de_cobro_pago_para_inici=!missing(cuota_por_iniciar_juicio) if demando_con_abogado_privado==1
gen esquema_de_cobro_porcentaje=!missing(porcentaje) if demando_con_abogado_privado==1
gen esquema_de_cobro_otro=1 if demando_con_abogado_privado==1 & esquema_de_cobro_pago==0 & esquema_de_cobro_porc==0
replace esquema_de_cobro_otro=. if strpos(especifique_cobro, "No")!=0
drop especifique_cobro

gen demando_con_abogado_publico=1 if entablo_demanda==1 & demando_con_abogado_privado==0 
replace demando_con_abogado_publico=0 if missing(demando_con_abogado_publico) & entablo_demanda==1

gen comprado_casa_o_terreno=strpos(ultimo_mes_base, "casa")!=0 if !missing(ultimo_mes_base)
gen comprado_electrodomestico=strpos(ultimo_mes_base, "electro")!=0 if !missing(ultimo_mes_base)

replace donde_lo_contacto_="" if strpos(donde_lo_contacto_, "No")!=0
gen donde_lo_contacto=1 if strpos(donde_lo_contacto_, "Junta")!=0
replace donde_lo_contacto=2 if missing(donde_lo_contacto) & !missing(donde_lo_contacto_)
drop donde_lo_contacto_

gen comparacion_con_el_trabajo_anter=.
replace comparacion_con_el_trabajo_anter=1 if upper(comparacion_con_el_trabajo_an)=="MEJOR" 
replace comparacion_con_el_trabajo_anter=2 if upper(comparacion_con_el_trabajo_an)=="PEOR" 
replace comparacion_con_el_trabajo_anter=3 if upper(comparacion_con_el_trabajo_an)=="IGUAL" 
drop comparacion_con_el_trabajo_an

gen tiempo_arreglar_asunto=.
replace tiempo_arreglar_asunto=1 if tiempo_arreglar_asunto_=="0-2 horas"
replace tiempo_arreglar_asunto=2 if tiempo_arreglar_asunto_=="2.01 - 5 horas"
replace tiempo_arreglar_asunto=3 if tiempo_arreglar_asunto_=="5.01 - 10 horas"
replace tiempo_arreglar_asunto=4 if tiempo_arreglar_asunto_=="10.01 - 15 horas"
replace tiempo_arreglar_asunto=5 if tiempo_arreglar_asunto_=="15.01 - 20 horas"
replace tiempo_arreglar_asunto=6 if tiempo_arreglar_asunto_=="20.01 - 30 horas"
replace tiempo_arreglar_asunto=7 if tiempo_arreglar_asunto_=="Más de 30 horas"

gen tiempo_arreglar_asunto_imputed=.
replace tiempo_arreglar_asunto_imputed=1 if tiempo_arreglar_asunto_=="0-2 horas"
replace tiempo_arreglar_asunto_imputed=2.5 if tiempo_arreglar_asunto_=="2.01 - 5 horas"
replace tiempo_arreglar_asunto_imputed=7.5 if tiempo_arreglar_asunto_=="5.01 - 10 horas"
replace tiempo_arreglar_asunto_imputed=12.5 if tiempo_arreglar_asunto_=="10.01 - 15 horas"
replace tiempo_arreglar_asunto_imputed=17.5 if tiempo_arreglar_asunto_=="15.01 - 20 horas"
replace tiempo_arreglar_asunto_imputed=25 if tiempo_arreglar_asunto_=="20.01 - 30 horas"
replace tiempo_arreglar_asunto_imputed=30 if tiempo_arreglar_asunto_=="Más de 30 horas"

drop tiempo_arreglar_asunto_

gen  mas_o_menos_de_75=strpos(mas_o_menos_de_75_, "Más")!=0 if !missing(mas_o_menos_de_75_)
gen  mas_o_menos_de_6_meses_de_sueldo=strpos(mas_o_menos_de_6_meses_de_sueld_, "Más")!=0 if !missing(mas_o_menos_de_6_meses_de_sueld_)
drop mas_o_menos_de_75_  mas_o_menos_de_6_meses_de_sueld_

foreach var of varlist enojo_con_la_empresa como_lo_consiguio  elemento_elaborar_expectativas {
	
	replace `var'="" if strpos(upper(`var'), "NO SABE")!=0
	gen `var'_=.
	
	forvalues i=1/12 {
		replace `var'_=`i' if strpos(upper(`var'), substr(c(ALPHA),2*`i'-1,1)+")" )!=0 | strpos(upper(`var'), substr(c(ALPHA),2*`i'-1,1)+"." )!=0
		}
	drop `var'
	rename `var'_ `var'
	}

gen origen="gforms"	

*Clean dates
foreach var of varlist fecha* {
	gen `var'_=date(`var', "DMY")
	drop `var'
	rename `var'_ `var'
	}
	
format fecha* %td	


*Homologation 
drop ultimo_mes_base v40 
rename  se_registro_el_acuerdo_ante_la_ se_registro_el_acuerdo_ante_la_j
rename  ha_dejado_de_pagar_servicio_bas ultimos_3_meses_ha_dejado_de_pag
rename  ha_faltado_dinero_para_comida ultimos_3_meses_le_ha_faltado_di
rename  elemento_elaborar_expectativas que_elemento_es_el_mas_important

save ".\_aux\survey_gf_2m.dta", replace




**************************************EXCEL*************************************

import delimited ".\Raw\survey_data_2m.csv", clear

*Clean dates
foreach var of varlist fecha* {
	local vn=substr("`var'",1,length("`var'")-1)
	gen `vn'=date(`var', "YMD")
	drop `var'
	rename `vn' `var'
	}
	
format fecha* %td	


************************************Cleaning************************************

*Combine datasets
append using ".\_aux\survey_gf_2m.dta"
append using ".\_aux\opm.dta"

*Survey date	 
split timestamp, gen(date_timestamp)
gen survey_date=date(date_timestamp1, "DMY")
replace survey_date=fecha_ultimo_intento_encuesta if missing(survey_date)
cap replace date_timestamp2="1" if strpos(date_timestamp2,"Jan")!=0
cap replace date_timestamp2="2" if strpos(date_timestamp2,"Feb")!=0
cap replace date_timestamp2="3" if strpos(date_timestamp2,"Mar")!=0
cap replace date_timestamp2="4" if strpos(date_timestamp2,"Apr")!=0
cap replace date_timestamp2="5" if strpos(date_timestamp2,"May")!=0
cap replace date_timestamp2="6" if strpos(date_timestamp2,"Jun")!=0
cap replace date_timestamp2="7" if strpos(date_timestamp2,"Jul")!=0
cap replace date_timestamp2="8" if strpos(date_timestamp2,"Aug")!=0
cap replace date_timestamp2="9" if strpos(date_timestamp2,"Sep")!=0
cap replace date_timestamp2="10" if strpos(date_timestamp2,"Oct")!=0
cap replace date_timestamp2="11" if strpos(date_timestamp2,"Nov")!=0
cap replace date_timestamp2="12" if strpos(date_timestamp2,"Dec")!=0
cap replace date_timestamp1=date_timestamp1+"/"+date_timestamp2+"/"+"20"+date_timestamp3 if missing(survey_date)
replace survey_date=date(date_timestamp1, "DMY") if missing(survey_date)

format survey_date %td

codebook survey_date

drop if inlist(id_actor,"196_1","145")
duplicates tag id_actor, gen (tag)
*Drop duplicates in excel
drop if tag==1 & origen=="excel"
drop tag
duplicates drop id_actor, force

merge 1:1 id_actor using ".\_aux\treatment_data.dta",  nogen keep(1 3) ///
 keepusing(id_actor date prob_ganar prob_mayor cantidad_ganar cant_mayor salario_diario)


*Mutate all data

gen sabemos_cantidad = !missing(monto_del_convenio)
gen sabemos_fecha_arreglo = !missing(fecha_del_arreglo)
replace probabilidad_de_ganar = probabilidad_de_ganar/100 if probabilidad_de_ganar>1
gen dias_sal = monto_que_espera_recibir/salario_diario
gen mas_6m_aux = (dias_sal>=180) if !missing(dias_sal)
replace mas_6m_aux= mas_o_menos_de_6_meses_de_sueld if missing(mas_6m_aux)
gen mas_75_aux = (probabilidad_de_ganar >=.75) if !missing(probabilidad_de_ganar)
replace mas_75_aux=mas_o_menos_de_75 if missing(mas_75_aux)
gen prob_coarse_survey = !missing(mas_75_aux)
gen cantidad_coarse_survey = !missing(mas_6m_aux)

*Updating variables

gen prob_ganar_fixed_survey = probabilidad_de_ganar
qui su probabilidad_de_ganar if probabilidad_de_ganar>.75
replace prob_ganar_fixed_survey=`r(mean)' if missing(prob_ganar_fixed_survey) & mas_75_aux==1
qui su probabilidad_de_ganar if probabilidad_de_ganar<=.75
replace prob_ganar_fixed_survey=`r(mean)' if missing(prob_ganar_fixed_survey) & mas_75_aux==0

gen cantidad_ganar_fixed_survey = monto_que_espera_recibir
qui su dias_sal if dias_sal>180, d
replace cantidad_ganar_fixed_survey=`r(p50)'*salario_diario if missing(cantidad_ganar_fixed_survey) & mas_6m_aux==1
qui su dias_sal if dias_sal<=180
replace cantidad_ganar_fixed_survey=`r(mean)'*salario_diario if missing(cantidad_ganar_fixed_survey) & mas_6m_aux==0

gen prob_ganar_fixed = prob_ganar
qui su prob_ganar if prob_ganar>.75
replace prob_ganar_fixed=`r(mean)' if missing(prob_ganar_fixed) & prob_mayor==1
qui su prob_ganar if prob_ganar<=.75
replace prob_ganar_fixed_survey=`r(mean)' if missing(prob_ganar_fixed) & prob_mayor==0

gen cantidad_ganar_fixed = cantidad_ganar
qui su dias_sal if dias_sal>180, d
replace cantidad_ganar_fixed=`r(p50)'*salario_diario if missing(cantidad_ganar_fixed) & cant_mayor==1
qui su dias_sal if dias_sal<=180
replace cantidad_ganar_fixed=`r(mean)'*salario_diario if missing(cantidad_ganar_fixed) & cant_mayor==0

gen update_prob_survey = (probabilidad_de_ganar - prob_ganar)/prob_ganar
gen update_comp_survey = (monto_que_espera_recibir - cantidad_ganar)/cantidad_ganar
gen update_prob_fixed_survey = (prob_ganar_fixed_survey - prob_ganar_fixed)/prob_ganar_fixed
gen update_comp_fixed_survey = (cantidad_ganar_fixed_survey - cantidad_ganar_fixed)/cantidad_ganar_fixed
gen switched_prob_survey = prob_mayor > mas_75_aux
gen switched_comp_survey = cant_mayor > mas_6m_aux
gen tiempo_arreglo = fecha_del_arreglo - date
gen tiempo_encuesta = survey_date - date
  
*Drop earthquake
drop if date==date("19-09-2017","DMY") 

drop prob_ganar cantidad_ganar prob_mayor cant_mayor mas_o_menos_de_6_meses_de_sueldo ///
		mas_o_menos_de_75 dias_sal date salario_diario	
	
rename probabilidad_de_ganar prob_ganar_survey
rename monto_que_espera_recibir cantidad_ganar_survey
rename mas_75_aux prob_mayor_survey
rename mas_6m_aux cant_mayor_survey

tempfile temp_2m
save `temp_2m'


use ".\DB\survey_data_2w.dta", clear
keep id_actor conflicto_arreglado entablo_demanda reinstalacion monto_del_convenio fecha_del_arreglo tiempo_arreglo
keep if conflicto_arreglado==1
foreach var of varlist conflicto_arreglado entablo_demanda reinstalacion monto_del_convenio fecha_del_arreglo tiempo_arreglo {
	rename `var' `var'_2ws
	}
tempfile temp_ended2w
save `temp_ended2w'



use `temp_2m', clear
merge 1:1 id_actor using `temp_ended2w', keep(1 2 3)

*Imputation (Para missings de dos meses con informacion de dos semanas)
*Hacer un sanity check
*Si arreglo en dos semanas no entablo demanda en dos meses
replace entablo_demanda = 0 if conflicto_arreglado_2ws==1 & missing(entablo_demanda)

foreach var of varlist conflicto_arreglado entablo_demanda reinstalacion monto_del_convenio fecha_del_arreglo tiempo_arreglo {
	replace `var'=`var'_2ws if _merge==3 & !missing(`var'_2ws)
	replace `var'=`var'_2ws if _merge==2 	
	}


replace origen="2w" if _merge==2
replace entablo_demanda=0 if missing(entablo_demanda) & conflicto_arreglado==1 & status_encuesta==1
drop _merge *_2ws	


foreach var of varlist *_survey {
	replace `var'=. if conflicto_arreglado==1 
	}

replace demando_con_abogado_publico=. if missing(entablo_demanda)
replace demando_con_abogado_publico=. if entablo_demanda==0

*Gen variables
gen coyote=inlist(como_lo_consiguio, 1,2) if !missing(como_lo_consiguio)
gen mejor_trabajo=(comparacion_con_el_trabajo_anter==1) if !missing(comparacion_con_el_trabajo_anter)
gen sabe_dias_salario=(cuantos_dias_de_salario_correspo==90) if !missing(cuantos_dias_de_salario_correspo)


*Drop variables
drop telefono*

*Variable validation
replace probabilidad_de_que_encuentre_tr=0 if probabilidad_de_que_encuentre_tr<0 & !missing(probabilidad_de_que_encuentre_tr)
replace comprado_casa_o_terreno=. if inlist(comprado_casa_o_terreno, 0, 1)!=1 & !missing(comprado_casa_o_terreno)
replace nivel_de_satisfaccion_abogado=. if nivel_de_satisfaccion_abogado==-1

save ".\DB\survey_data_2m.dta", replace
	
