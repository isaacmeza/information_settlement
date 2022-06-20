import delimited "$directorio\_aux\hd_data.csv", clear
gen id = _n

*Directory for .\boost64.dll 
cd "$directorio"
*cd D:\WKDir-Stata
capture program drop boost_plugin
program boost_plugin, plugin using("$directorio\boost64.dll")


global ind_var  reclutamiento giro_empresa_d2 giro_empresa_d3 giro_empresa_d4 giro_empresa_d5 giro_empresa_d6 giro_empresa_d7 giro_empresa_d8 giro_empresa_d9 giro_empresa_d10 giro_empresa_d11 giro_empresa_d12 giro_empresa_d13 giro_empresa_d14 giro_empresa_d15 giro_empresa_d16 giro_empresa_d17 giro_empresa_d18 giro_empresa_d19 giro_empresa_d20 giro_empresa_d21 giro_empresa_d22 giro_empresa_d23 giro_empresa_d24 trabajador_base gen tipo_jornada_d2 tipo_jornada_d3 tipo_jornada_d4 reinst indem sal_caidos prima_antig prima_vac hextra rec20 prima_dom desc_sem desc_ob sarimssinf utilidades monto_recsueldo nulidad vac ag codem horas_extra antiguedad salario_diario horas_sem c_antiguedad c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total min_indem min_prima_antig min_ag min_vac min_prima_vac min_ley c_sal_caidos prop_hextra


foreach var of varlist reclutamiento giro_empresa_d2 giro_empresa_d3 giro_empresa_d4 giro_empresa_d5 giro_empresa_d6 giro_empresa_d7 giro_empresa_d8 giro_empresa_d9 giro_empresa_d10 giro_empresa_d11 giro_empresa_d12 giro_empresa_d13 giro_empresa_d14 giro_empresa_d15 giro_empresa_d16 giro_empresa_d17 giro_empresa_d18 giro_empresa_d19 giro_empresa_d20 giro_empresa_d21 giro_empresa_d22 giro_empresa_d23 giro_empresa_d24 trabajador_base gen tipo_jornada_d2 tipo_jornada_d3 tipo_jornada_d4 reinst indem sal_caidos prima_antig prima_vac hextra rec20 prima_dom desc_sem desc_ob sarimssinf utilidades monto_recsueldo nulidad vac ag codem horas_extra antiguedad salario_diario horas_sem c_antiguedad c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total min_indem min_prima_antig min_ag min_vac min_prima_vac min_ley c_sal_caidos prop_hextra {
	drop if missing(`var')
}

gen sett = modo_termino==1

gen drp = modo_termino==2




gen cr_win = modo_termino==3 & liq_total_pos==1
gen cr_los = modo_termino==3 & liq_total_pos==0
gen cr_win_ph2 = liq_total_pos if modo_termino==3 

gen tot_comp_3 = liq_total_tope if modo_termino==3
gen tot_comp_3l = log(liq_total_tope+1) if modo_termino==3

gen dur_31 = duracion if modo_termino==3 & liq_total_pos==1
gen dur_30 = duracion if modo_termino==3 & liq_total_pos==0

gen dur_1 = duracion if  modo_termino==1
gen tot_comp_1l = log(liq_total_tope+1) if  modo_termino==1

gen dur_2l = log(duracion+1) if modo_termino==2
gen dur_4 = duracion if modo_termino==4


foreach var of varlist sett  drp cr_win {
	logit `var' ${ind_var},  iterate(1000)
	predict pr_`var' 
	cap drop perc
	xtile perc = pr_`var' , nq(100)
	qui su $depvar 
	gen bin_pr_`var'  = (perc>=(100*(1-`r(mean)')))
}


foreach var of varlist   cr_los  cr_win_ph2 {

preserve
drop if missing(`var')
gen Rsquared=.
gen bestiter=.
gen maxiter=.
gen myinter=.
local i=0
local maxiter=750
capture profiler clear 
profiler on
local tempiter=`maxiter'
foreach inter of numlist 1 2 4 7 10 {
	local i=`i'+1
    replace myinter= `inter' in `i'
	boost `var' $ind_var , dist(logistic) train(0.8) maxiter(`tempiter') ///
		bag(0.5) interaction(`inter') shrink(0.1) 
	local maxiter=e(bestiter) 
	replace maxiter=`tempiter' in `i'
	replace bestiter=e(bestiter) in `i' 
	replace Rsquared=e(test_R2) in `i'
	* as the number of interactions increase the best number of iterations will decrease
	* to be safe I am allowing an extra 20% of iterations and in case maxiter equals bestiter we double the number of iter
	* when the number of interactions is large this can save a lot of time
	if ( maxiter[`i']-bestiter[`i']<60) {
		local tempiter= round(maxiter[`i']*2)+10
		}
	else {
		local tempiter=round( e(bestiter) * 1.2 )+10
		}
	}



********************************************************************************


********************************************************************************
*Boosting 

qui egen maxrsq=max(Rsquared)
qui gen iden=_n if Rsquared==maxrsq
qui su iden

local opt_int=`r(min)'		/*Optimum interaction according to previous process*/

if ( maxiter[`r(mean)']-bestiter[`r(mean)']<60) {
	local miter= round(maxiter[`r(mean)']*2.2+10)
	}
else {
	local miter=bestiter[`r(mean)']+120
	}
							/*Maximum number of iterations-if bestiter is closed to maxiter, 
							increase the number of max iter as the maximum likelihood 
							iteration may be larger*/
							
local shrink=0.05       	/*Lower shrinkage values usually improve the test R2 but 
							they increase the running time dramatically. 
							Shrinkage can be thought of as a step size*/						
						
capture drop boost_pred boost_pred2
capture profiler clear
profiler on
boost `var' $ind_var , dist(logistic) train(0.8) maxiter(`miter') bag(0.5) ///
	interaction(`opt_int') shrink(`shrink') pred("pr_`var'") influence 

	
cap drop perc
xtile perc = pr_`var', nq(100)
qui su `var' 
gen bin_pr_`var' = (perc>=(100*(1-`r(mean)')))
keep id bin_pr_`var' pr_`var' 
tempfile temp_`var'
save `temp_`var''
restore 

merge 1:1 id using `temp_`var'', nogen
}


foreach var of varlist tot_comp_1l dur_2l dur_1 dur_4 {


preserve
drop if missing(`var')
gen Rsquared=.
gen bestiter=.
gen maxiter=.
gen myinter=.
local i=0
local maxiter=750
capture profiler clear 
profiler on
local tempiter=`maxiter'
foreach inter of numlist 1 2 4 7 10 {
	local i=`i'+1
    replace myinter= `inter' in `i'
	boost `var' $ind_var , dist(normal) train(0.8) maxiter(`tempiter') ///
		bag(0.5) interaction(`inter') shrink(0.1) 
	local maxiter=e(bestiter) 
	replace maxiter=`tempiter' in `i'
	replace bestiter=e(bestiter) in `i' 
	replace Rsquared=e(test_R2) in `i'
	* as the number of interactions increase the best number of iterations will decrease
	* to be safe I am allowing an extra 20% of iterations and in case maxiter equals bestiter we double the number of iter
	* when the number of interactions is large this can save a lot of time
	if ( maxiter[`i']-bestiter[`i']<60) {
		local tempiter= round(maxiter[`i']*2)+10
		}
	else {
		local tempiter=round( e(bestiter) * 1.2 )+10
		}
	}



********************************************************************************


********************************************************************************
*Boosting 

qui egen maxrsq=max(Rsquared)
qui gen iden=_n if Rsquared==maxrsq
qui su iden

local opt_int=`r(min)'		/*Optimum interaction according to previous process*/

if ( maxiter[`r(mean)']-bestiter[`r(mean)']<60) {
	local miter= round(maxiter[`r(mean)']*2.2+10)
	}
else {
	local miter=bestiter[`r(mean)']+120
	}
							/*Maximum number of iterations-if bestiter is closed to maxiter, 
							increase the number of max iter as the maximum likelihood 
							iteration may be larger*/
							
local shrink=0.05       	/*Lower shrinkage values usually improve the test R2 but 
							they increase the running time dramatically. 
							Shrinkage can be thought of as a step size*/						
						
capture drop boost_pred boost_pred2
capture profiler clear
profiler on
boost `var' $ind_var , dist(normal) train(0.8) maxiter(`miter') bag(0.5) ///
	interaction(`opt_int') shrink(`shrink') pred("pr_`var'") influence 

	

keep id  pr_`var' 
tempfile temp_`var'
save `temp_`var''
restore 

merge 1:1 id using `temp_`var'', nogen
}


foreach var of varlist dur_31 {
	cvlasso `var' ${ind_var}
	 cvlasso, lopt
	predict pr_`var' , xb lopt
}

foreach var of varlist tot_comp_3l tot_comp_3 dur_30  {
	reg `var' ${ind_var}
	predict pr_`var' 
}

reg tot_comp_1l ${ind_var}
predict pr_tot_comp_1l_r

*****************************************************************************************

foreach var of varlist sett  drp cr_win  cr_los  cr_win_ph2 tot_comp_1l dur_2l dur_1 dur_4 dur_31 tot_comp_3l tot_comp_3 dur_30 tot_comp_1l {
	cor `var' pr_`var'
}


save "$directorio\DB\varimppr.dta", replace


