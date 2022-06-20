import delimited "$directorio\_aux\df_pre_imp.csv", clear


replace feature =  "Recruitment" if feature=="reclutamiento"
replace feature =  "Industry dummy 2" if feature=="giro_empresa_d2"
replace feature =  "Industry dummy 3" if feature=="giro_empresa_d3"
replace feature =  "Industry dummy 4" if feature=="giro_empresa_d4"
replace feature =  "Industry dummy 5" if feature=="giro_empresa_d5"
replace feature =  "Industry dummy 6" if feature=="giro_empresa_d6"
replace feature =  "Industry dummy 7" if feature=="giro_empresa_d7"
replace feature =  "Industry dummy 8" if feature=="giro_empresa_d8"
replace feature =  "Industry dummy 9" if feature=="giro_empresa_d9"
replace feature =  "Industry dummy 10" if feature=="giro_empresa_d10"
replace feature =  "Industry dummy 11" if feature=="giro_empresa_d11"
replace feature =  "Industry dummy 12" if feature=="giro_empresa_d12"
replace feature =  "Industry dummy 13" if feature=="giro_empresa_d13"
replace feature =  "Industry dummy 14" if feature=="giro_empresa_d14"
replace feature =  "Industry dummy 15" if feature=="giro_empresa_d15"
replace feature =  "Industry dummy 16" if feature=="giro_empresa_d16"
replace feature =  "Industry dummy 17" if feature=="giro_empresa_d17"
replace feature =  "Industry dummy 18" if feature=="giro_empresa_d18"
replace feature =  "Industry dummy 19" if feature=="giro_empresa_d19"
replace feature =  "Industry dummy 20" if feature=="giro_empresa_d20"
replace feature =  "Industry dummy 21" if feature=="giro_empresa_d21"
replace feature =  "Industry dummy 22" if feature=="giro_empresa_d22"
replace feature =  "Industry dummy 23" if feature=="giro_empresa_d23"
replace feature =  "Industry dummy 24" if feature=="giro_empresa_d24"
replace feature =  "At will worker" if feature=="trabajador_base"
replace feature =  "Gender" if feature=="gen"
replace feature =  "Type of working day 2" if feature=="tipo_jornada_d2"
replace feature =  "Type of working day 3" if feature=="tipo_jornada_d3"
replace feature =  "Type of working day 4" if feature=="tipo_jornada_d4"
replace feature =  "Reinstatement" if feature=="reinst"
replace feature =  "Severance" if feature=="indem"
replace feature =  "Lost wages" if feature=="sal_caidos"
replace feature =  "Tenure bonus" if feature=="prima_antig"
replace feature =  "Holiday bonus" if feature=="prima_vac"
replace feature =  "Overtime 2" if feature=="hextra"
replace feature =  "Rec 20" if feature=="rec20"
replace feature =  "Sunday bonus" if feature=="prima_dom"
replace feature =  "Weekly rest" if feature=="desc_sem"
replace feature =  "Rest" if feature=="desc_ob"
replace feature =  "Insurance" if feature=="sarimssinf"
replace feature =  "Utility" if feature=="utilidades"
replace feature =  "Amount Rec Salary" if feature=="monto_recsueldo"
replace feature =  "Nulity" if feature=="nulidad"
replace feature =  "Holiday" if feature=="vac"
replace feature =  "Ag" if feature=="ag"
replace feature =  "Co-sue" if feature=="codem"
replace feature =  "Overtime " if feature=="horas_extra"
replace feature =  "Tenure" if feature=="antiguedad"
replace feature =  "Daily wage" if feature=="salario_diario"
replace feature =  "Weekly hours" if feature=="horas_sem"
replace feature =  "Compensation (tenure)" if feature=="c_antiguedad"
replace feature =  "Compensation (severance)" if feature=="c_indem"
replace feature =  "Compensation (tenure bonus)" if feature=="c_prima_antig"
replace feature =  "Compensation (rec20)" if feature=="c_rec20"
replace feature =  "Compensation (ag)" if feature=="c_ag"
replace feature =  "Compensation (holiday)" if feature=="c_vac"
replace feature =  "Compensation (overtime)" if feature=="c_hextra"
replace feature =  "Compensation (holiday bonus)" if feature=="c_prima_vac"
replace feature =  "Compensation (sunday bonus)" if feature=="c_prima_dom"
replace feature =  "Compensation (weekly rest)" if feature=="c_desc_sem"
replace feature =  "Compensation (rest)" if feature=="c_desc_ob"
replace feature =  "Compensation (utility)" if feature=="c_utilidades"
replace feature =  "Compensation (rec salary)" if feature=="c_recsueldo"
replace feature =  "Compensation (total)" if feature=="c_total"
replace feature =  "Min entitlement" if feature=="min_indem"
replace feature =  "Min entitlement (tenure)" if feature=="min_prima_antig"
replace feature =  "Min entitlement (ag)" if feature=="min_ag"
replace feature =  "Min entitlement (holiday)" if feature=="min_vac"
replace feature =  "Min entitlement (holiday bonus)" if feature=="min_prima_vac"
replace feature =  "Legal Entitlement" if feature=="min_ley"
replace feature =  "Compensation (lost wages)" if feature=="c_sal_caidos"
replace feature =  "Prop overtime" if feature=="prop_hextra"




forvalues model = 1/15 {
	
	gen lo_c_m`model' = coef_m`model' - 1.96*std_m`model'
	gen hi_c_m`model' = coef_m`model' + 1.96*std_m`model'

	su imp_mean_m`model'
	local mx2 = `r(max)'
	local mi2 = `r(min)'
	replace imp_mean_m`model' = (imp_mean_m`model'-`mi2')/(`mx2'-`mi2')
	
	gen lo_i_m`model' = imp_mean_m`model' - 1.96*imp_std_m`model'/(`mx2'-`mi2')
	gen hi_i_m`model' = imp_mean_m`model' + 1.96*imp_std_m`model'/(`mx2'-`mi2')
	
	preserve
	*Order 
	cap drop indice
	gen abscoef_m`model' = abs(coef_m`model')
	su abscoef_m`model'
	local mx1 = `r(max)'
	local mi1 = `r(min)'
	gen absimp_mean_m`model' = abs(imp_mean_m`model')	
	su absimp_mean_m`model'
	local mx2 = `r(max)'
	local mi2 = `r(min)'
	gen indice = (absimp_mean_m`model'-`mi2')/(`mx2'-`mi2')
	gsort -abscoef_m`model' -indice
	gen ord = _n
	keep if inrange(ord,1,10)
	
	cap drop ft
	encode feature, gen(ft)

	twoway (rcap  lo_c_m`model' hi_c_m`model' ft ,  xaxis(1) horizontal color(navy%90) lw( medthick )) ///
		(scatter  ft coef_m`model' , xaxis(1) ylabel(1(1)10, valuelabel angle(0)) msymbol(O) color(navy%90)) ///
		(rcap  lo_i_m`model' hi_i_m`model' ft ,  xaxis(2) horizontal color(red*0.8%80) lw( medthick )) ///
		(scatter  ft imp_mean_m`model' , xaxis(2)  msymbol(O) color(red*0.8%80) ), graphregion(color(white)) legend(off) xtitle("Variable importance", axis(2)) xtitle("Linear projection", axis(1)) ytitle("") xline(0, axis(2)) xline(0, axis(1)) 
		
	graph export ".\paper\Figures\varimp_m`model'.pdf", replace
	
	twoway (rcap  lo_c_m`model' hi_c_m`model' ft ,   horizontal color(navy%90) lw( medthick )) ///
			(scatter  ft coef_m`model' ,  ylabel(1(1)10, valuelabel angle(0)) msymbol(O) color(navy%90)) ///
			, graphregion(color(white)) legend(off)  xtitle("Linear projection") ytitle("") xline(0) xline(0) 

	graph export ".\paper\Figures\coef_m`model'.pdf", replace
			
	twoway 	(rcap  lo_i_m`model' hi_i_m`model' ft ,   horizontal color(red*0.8%80) lw( medthick )) ///
			(scatter  ft imp_mean_m`model' , ylabel(1(1)10, valuelabel angle(0)) msymbol(O) color(red*0.8%80) ), graphregion(color(white)) legend(off) xtitle("Variable importance")  ytitle("") xline(0) xline(0)
				
			
	graph export ".\paper\Figures\imp_m`model'.pdf", replace	
	restore
}
