*Cleaning 2w survey
**************************************GFORMS************************************
insheet using ".\Raw\gf2w.csv", clear


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
					id_actor
					fecha_ultimo_intento_encuesta
					nombre_encuestador
					status_encuesta
					conflicto_arreglado
					reinstalacion
					dice_cantidad
					monto_del_convenio
					fecha_del_arreglo
					se_registro_el_acuerdo_ante_j
					ha_hablado_con_abogado_publico
					tramito_citatorio
					fecha_de_la_cita_procu
					entablo_demanda
					ha_hablado_con_abogado_privado
					como_lo_encontro
					firmo_carta_poder
					esquema_de_pago
					esquema_de_cobro_porcentaje
					porcentaje
					esquema_de_cobro_pago_para_inic
					cuota_por_iniciar_juicio
					sigue_buscando_alternativas_pri
					tramito_alguna_cita_de_conc
					fecha_de_la_cita_junta
					dummy_encuestador
					piensa_hacer_algo_respecto_al_d
					sabe_prob
					probabilidad_de_ganar
					mas_o_menos_de_75
					sabe_monto
					monto_que_espera_recibir
					mas_o_menos_de_6_meses_de_sueld
					ha_iniciado_una_demanda_laboral_
					hace_cuanto_anios
					gano_el_juicio_
					grado_de_estudios_
					contacto_abogado_pub_1
					vtelefono
					vrazon_noloc
					contrafactual_sabe_prob
					contrafactual_prob
					contrafactual_mas_o_menos_de_75
					contrafactual_sabe_monto
					contrafactual_monto
					contrafactual_mas_o_menos_de_6_m			
					contacto_abogado_pub_2
					v49) ;

#delimit cr


*Status="Exitosa"
bysort id_actor: gen num_intentos=_N
keep if status_encuesta=="Exitosa"
drop status_encuesta
gen status_encuesta=1



*Dummy vars
foreach var of varlist  conflicto_arreglado reinstalacion dice_cantidad ///
		ha_hablado_con_abogado_publico tramito_citatorio entablo_demanda ///
		ha_hablado_con_abogado_privado firmo_carta_poder sigue_buscando_alternativas_pri ///
		tramito_alguna_cita_de_conc {
	
	gen `var'_=(strpos(`var', "SÃ­")!=0) if !missing(`var') & length(`var')<=4
	drop `var'
	rename `var'_ `var'
	}
	
*Mutates	

replace sigue_buscando_alternativas_pri=. if conflicto_arreglado==1

gen se_registro_el_acuerdo_ante_la_j=(strpos(se_registro_el_acuerdo_ante_j, "Junta")!=0) if !missing(se_registro_el_acuerdo_ante_j)
drop se_registro_el_acuerdo_ante_j


gen como_lo_encontro_=.
replace como_lo_encontro_=1 if strpos(upper(como_lo_encontro), "ENTRADA")!=0 ///
					& strpos(upper(como_lo_encontro), "JUNTA")!=0 ///
					& strpos(upper(como_lo_encontro), "RECOMENDARON")!=0
replace como_lo_encontro_=2 if strpos(upper(como_lo_encontro), "JUNTA")!=0 ///
					& como_lo_encontro_!=1
replace como_lo_encontro_=3 if strpos(upper(como_lo_encontro), "REPRESENTADO")!=0 
replace como_lo_encontro_=4 if strpos(upper(como_lo_encontro), "RECOMENDADO")!=0 
replace como_lo_encontro_=5 if strpos(upper(como_lo_encontro), "CONOCIDO")!=0 ///
					& strpos(upper(como_lo_encontro), "RECOMENDADO")==0
replace como_lo_encontro_=6 if strpos(upper(como_lo_encontro), "INTERNET")!=0 
replace como_lo_encontro_=8 if !missing(como_lo_encontro) & missing(como_lo_encontro_)
drop como_lo_encontro
rename como_lo_encontro_ como_lo_encontro
					

foreach var of varlist  esquema_de_cobro_porcentaje esquema_de_cobro_pago_para_inic {
	gen `var'_=(!missing(`var')) if !missing(esquema_de_pago)
	drop `var'
	rename `var'_ `var'
	}
	
	
gen  esquema_de_cobro_otro=0 if !missing(esquema_de_pago)
replace esquema_de_cobro_otro=1 if esquema_de_cobro_porcentaje==0 & esquema_de_cobro_pago_para_inic==0
drop esquema_de_pago


gen piensa_hacer_algo_respecto_al_de=(strpos(upper(piensa_hacer_algo_respecto_al_d), "NADA")==0  ///
		& !missing(piensa_hacer_algo_respecto_al_d))
drop piensa_hacer_algo_respecto_al_d		
		
gen mas_o_menos_de_75_=.
replace mas_o_menos_de_75_=1 if strpos(upper(mas_o_menos_de_75), "ARRIBA")!=0 
replace mas_o_menos_de_75_=0 if strpos(upper(mas_o_menos_de_75), "ABAJO")!=0 
drop mas_o_menos_de_75
rename mas_o_menos_de_75_ mas_o_menos_de_75

gen mas_o_menos_de_6_meses_de_sueld_=.
replace mas_o_menos_de_6_meses_de_sueld_=1 if strpos(mas_o_menos_de_6_meses_de_sueld, "MÃ¡s")!=0 
replace mas_o_menos_de_6_meses_de_sueld_=0 if strpos(upper(mas_o_menos_de_6_meses_de_sueld), "MENOS")!=0 
drop mas_o_menos_de_6_meses_de_sueld
rename mas_o_menos_de_6_meses_de_sueld_ mas_o_menos_de_6_meses_de_sueld

gen ha_iniciado_una_demanda_laboral=strpos(ha_iniciado_una_demanda_laboral_, "Primera")==0
drop ha_iniciado_una_demanda_laboral_

gen gano_el_juicio=strpos(gano_el_juicio_, "Gan")!=0 if !missing(gano_el_juicio_)
drop gano_el_juicio_

gen grado_de_estudios=.
replace grado_de_estudios=1 if strpos(grado_de_estudios_, "Primaria")!=0 
replace grado_de_estudios=2 if strpos(grado_de_estudios_, "Secundaria")!=0 
replace grado_de_estudios=3 if strpos(grado_de_estudios_, "Preparatoria")!=0 
replace grado_de_estudios=4 if strpos(grado_de_estudios_, "Licenciatura")!=0
drop grado_de_estudios_

gen prob_num_survey = !missing(probabilidad_de_ganar)
gen cantidad_num_survey = !missing(monto_que_espera_recibir) 
 
gen origen="gforms"

*Variable que se omitió (1=Junta; por sismo)
gen donde_lo_contacto=1

*Clean dates
foreach var of varlist fecha* {
	gen `var'_=date(`var', "MDY")
	drop `var'
	rename `var'_ `var'
	}
	
format fecha* %td	

*Homologation
rename esquema_de_cobro_pago_para_inic esquema_de_cobro_pago_para_inici
rename sigue_buscando_alternativas_pri sigue_buscando_alternativas_de_a
rename tramito_alguna_cita_de_conc tramito_alguna_cita_de_conciliac
rename mas_o_menos_de_6_meses_de_sueld mas_o_menos_de_6_meses_de_sueldo
rename ha_iniciado_una_demanda_laboral ha_iniciado_una_demanda_laboral_

save ".\_aux\survey_gf_2w.dta", replace




**************************************EXCEL*************************************

import delimited ".\Raw\survey_data_2w.csv", clear

*Clean dates
foreach var of varlist fecha* {
	gen `var'_=date(`var', "YMD")
	drop `var'
	rename `var'_ `var'
	}
	
format fecha* %td	


************************************Cleaning************************************

*Combine datasets
append using ".\_aux\survey_gf_2w.dta"

*Survey date	 
split timestamp, gen(date_timestamp)
gen survey_date=date(date_timestamp1, "MDY")
replace survey_date=fecha_ultimo_intento_encuesta if missing(survey_date)
format survey_date %td

codebook survey_date

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

gen cond_hablo_con_privado = ha_hablado_con_abogado_privado
gen cond_hablo_con_publico = ha_hablado_con_abogado_publico
gen hablo_con_abogado = (ha_hablado_con_abogado_privado == 1 | ha_hablado_con_abogado_publico == 1)
        
drop prob_ganar cantidad_ganar prob_mayor cant_mayor mas_o_menos_de_6_meses_de_sueldo ///
		mas_o_menos_de_75 dias_sal date salario_diario	
	
rename probabilidad_de_ganar prob_ganar_survey
rename monto_que_espera_recibir cantidad_ganar_survey
rename mas_75_aux prob_mayor_survey
rename mas_6m_aux cant_mayor_survey


foreach var of varlist *_survey {
	replace `var'=. if conflicto_arreglado==1
	}
	

foreach var of varlist cond_hablo_con* {
	replace `var'=. if ha_hablado_con_abogado_publico==0 & ha_hablado_con_abogado_privado==0
	}

*Gen variables
*IMPORTANTE: definicion de coyote (puede refinarse con la pregunta "Donde encontro al abogado publico")
gen coyote=inlist(como_lo_encontro, 1,2) if !missing(como_lo_encontro)
replace coyote=1 if como_lo_encontro==8 & (especifique=="dentro de la junta" | especifique=="afuera de la oficina del mÃ³dulo") ///
					& !missing(coyote)

*Drop variables
drop telefono*
					
save ".\DB\survey_data_2w.dta", replace	

