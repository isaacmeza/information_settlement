
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	variable_importance
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: June. 26, 2023
* Modifications:		
* Files used:     
		- scaleup_hd.dta
* Files created:  
		- var_imp_pr.dta
		
* Purpose: Variable importance plots for final models

*******************************************************************************/
*/


use "./DB/scaleup_hd.dta", clear
gen id = _n

*Directory for ./boost64.dll 
cd "$directorio"
*cd D:/WKDir-Stata
capture program drop boost_plugin
program boost_plugin, plugin using("$directorio/boost64.dll")

tab giro_empresa, gen(giro_empresa_d)
tab tipo_jornada, gen(tipo_jornada_d)

*Covariates
global ind_var reclutamiento giro_empresa_d2 giro_empresa_d3 giro_empresa_d4 giro_empresa_d5 giro_empresa_d6 giro_empresa_d7 giro_empresa_d8 giro_empresa_d9 giro_empresa_d10 giro_empresa_d11 giro_empresa_d12 giro_empresa_d13 giro_empresa_d14 giro_empresa_d15 giro_empresa_d16 giro_empresa_d17 giro_empresa_d18 giro_empresa_d19 giro_empresa_d20 giro_empresa_d21 giro_empresa_d22 giro_empresa_d23 giro_empresa_d24 trabajador_base gen tipo_jornada_d2 tipo_jornada_d3 tipo_jornada_d4 reinst indem sal_caidos prima_antig prima_vac hextra rec20 prima_dom desc_sem desc_ob sarimssinf utilidades monto_recsueldo nulidad vac ag codem salario_diario horas_sem c_antiguedad c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total min_indem min_prima_antig min_ag min_vac min_prima_vac min_ley c_sal_caidos prop_hextra

*Drop NA
foreach var of varlist reclutamiento giro_empresa_d2 giro_empresa_d3 giro_empresa_d4 giro_empresa_d5 giro_empresa_d6 giro_empresa_d7 giro_empresa_d8 giro_empresa_d9 giro_empresa_d10 giro_empresa_d11 giro_empresa_d12 giro_empresa_d13 giro_empresa_d14 giro_empresa_d15 giro_empresa_d16 giro_empresa_d17 giro_empresa_d18 giro_empresa_d19 giro_empresa_d20 giro_empresa_d21 giro_empresa_d22 giro_empresa_d23 giro_empresa_d24 trabajador_base gen tipo_jornada_d2 tipo_jornada_d3 tipo_jornada_d4 reinst indem sal_caidos prima_antig prima_vac hextra rec20 prima_dom desc_sem desc_ob sarimssinf utilidades monto_recsueldo nulidad vac ag codem salario_diario horas_sem c_antiguedad c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total min_indem min_prima_antig min_ag min_vac min_prima_vac min_ley c_sal_caidos prop_hextra {
	drop if missing(`var')
}

*Define outcomes
gen liq_total_pos = liq_total>0

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

********************************************************************************
********************************************************************************
********************************************************************************
*Logit model for classification
foreach var of varlist sett  drp cr_win {
	logit `var' ${ind_var},  iterate(1000)
	predict pr_`var' 
	cap drop perc
	xtile perc = pr_`var' , nq(100)
	qui su $depvar 
	gen bin_pr_`var' = (perc>=(100*(1-`r(mean)')))
}


********************************************************************************
********************************************************************************
********************************************************************************
*Boosting model for classification
foreach var of varlist  cr_los cr_win_ph2 {

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


********************************************************************************
********************************************************************************
********************************************************************************
*Boosting model for regression
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


********************************************************************************
********************************************************************************
********************************************************************************
*Lasso model 
foreach var of varlist dur_31 {
	cvlasso `var' ${ind_var}
	cvlasso, lopt
	predict pr_`var' , xb lopt
}


********************************************************************************
********************************************************************************
********************************************************************************
*Linear regression model
foreach var of varlist tot_comp_3l tot_comp_3 dur_30  {
	reg `var' ${ind_var}
	predict pr_`var' 
}

reg tot_comp_1l ${ind_var}
predict pr_tot_comp_1l_r

********************************************************************************
*Correlations
foreach var of varlist sett  drp cr_win  cr_los  cr_win_ph2 tot_comp_1l dur_2l dur_1 dur_4 dur_31 tot_comp_3l tot_comp_3 dur_30 tot_comp_1l {
	cor `var' pr_`var'
}

save "$directorio/_aux/var_imp_pr.dta", replace


*****************************************************************************************
*****************************************************************************************
*****************************************************************************************
*****************************************************************************************
*****************************************************************************************
*****************************************************************************************
*****************************************************************************************


use "$directorio/_aux/var_imp_pr.dta", clear

foreach var of varlist  salario_diario horas_sem c_antiguedad c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total min_indem min_prima_antig min_ag min_vac min_prima_vac min_ley c_sal_caidos prop_hextra {
	replace `var' = log(`var'+1)
}

********************************************************************************
********************************************************************************
********************************************************************************
*Plot variable importance for every model
local i = 1
foreach depvar in  sett  cr_los cr_win drp cr_win_ph2 tot_comp_1l tot_comp_3l tot_comp_1l_r tot_comp_3 dur_1  dur_30 dur_31 dur_4 dur_2l   {

	preserve
	local model = "m`i'"
	gen logs`depvar' = log(pr_`depvar')

	local alpha = .05 // for 95% confidence intervals 
		
	matrix lp = J(72, 6, .)
	local row = 1
	foreach var of varlist $ind_var  {

		qui reg logs`depvar' `var', r
		local df = e(df_r)	
		
		matrix lp[`row',1] = `row'
		// Beta 
		matrix lp[`row',2] = _b[`var']
		// Standard error
		matrix lp[`row',3] = _se[`var']
		// P-value
		matrix lp[`row',4] = 2*ttail(`df', abs(_b[`var']/_se[`var']))
		// Confidence Intervals
		matrix lp[`row',5] =  _b[`var'] - invttail(`df',`=`alpha'/2')*_se[`var']
		matrix lp[`row',6] =  _b[`var'] + invttail(`df',`=`alpha'/2')*_se[`var']
		
		local row = `row' + 1
	}
	matrix colnames lp = "k" "beta" "se" "p" "lo" "hi"

	clear 
	svmat lp, names(col)

	gen feature = ""
	replace feature =  "Recruitment" if _n==1
	replace feature =  "NAICS-Agriculture" if _n==2
	replace feature =  "NAICS-Utilities" if _n==3
	replace feature =  "NAICS-Construction" if _n==4
	replace feature =  "NAICS-Manufacturing" if _n==5
	replace feature =  "NAICS-Manufacturing" if _n==6
	replace feature =  "NAICS-Manufacturing" if _n==7
	replace feature =  "NAICS-Retail Trade" if _n==8
	replace feature =  "NAICS-Retail trade " if _n==9
	replace feature =  "NAICS-Transportation and Warehousing" if _n==10
	replace feature =  "NAICS-Transportation and Warehousing" if _n==11
	replace feature =  "NAICS-Information" if _n==12
	replace feature =  "NAICS-Finance and Insurance" if _n==13
	replace feature =  "NAICS-Real Estate and Rental and Leasing" if _n==14
	replace feature =  "NAICS-Professional, Scientific Services" if _n==15
	replace feature =  "NAICS-Management of Companies and Enterprises" if _n==16
	replace feature =  "NAICS-Waste Management, Remediation Services" if _n==17
	replace feature =  "NAICS-Educational Services" if _n==18
	replace feature =  "NAICS-Health Care and Social Assistance" if _n==19
	replace feature =  "NAICS-64" if _n==20
	replace feature =  "NAICS-Arts, Entertainment, and Recreation" if _n==21
	replace feature =  "NAICS-Accommodation and Food Services" if _n==22
	replace feature =  "NAICS-Other Services (except Public Administration)" if _n==23
	replace feature =  "NAICS-Public Administration" if _n==24

	replace feature =  "At will worker" if _n==25
	replace feature =  "Gender" if _n==26
	replace feature =  "Shift : Nocturnal" if _n==27
	replace feature =  "Shift : Mixed" if _n==28
	replace feature =  "Shift : 24x24" if _n==29
	replace feature =  "Reinstatement" if _n==30
	replace feature =  "Severance" if _n==31
	replace feature =  "Lost wages" if _n==32
	replace feature =  "Tenure bonus" if _n==33
	replace feature =  "Holiday bonus" if _n==34
	replace feature =  "Overtime" if _n==35
	replace feature =  "Rec 20" if _n==36
	replace feature =  "Sunday bonus" if _n==37
	replace feature =  "Weekly rest" if _n==38
	replace feature =  "Rest" if _n==39
	replace feature =  "Insurance" if _n==40
	replace feature =  "Utility" if _n==41
	replace feature =  "Amount Rec Salary" if _n==42
	replace feature =  "Nulity" if _n==43
	replace feature =  "Holiday" if _n==44
	replace feature =  "Ag" if _n==45
	replace feature =  "Co-sue" if _n==46
	replace feature =  "Daily wage" if _n==47
	replace feature =  "Weekly hours" if _n==48
	replace feature =  "Tenure" if _n==49
	replace feature =  "Compensation (severance)" if _n==50
	replace feature =  "Compensation (tenure bonus)" if _n==51
	replace feature =  "Compensation (rec20)" if _n==52
	replace feature =  "Compensation (ag)" if _n==53
	replace feature =  "Compensation (holiday)" if _n==54
	replace feature =  "Compensation (overtime)" if _n==55
	replace feature =  "Compensation (holiday bonus)" if _n==56
	replace feature =  "Compensation (sunday bonus)" if _n==57
	replace feature =  "Compensation (weekly rest)" if _n==58
	replace feature =  "Compensation (rest)" if _n==59
	replace feature =  "Compensation (utility)" if _n==60
	replace feature =  "Compensation (rec salary)" if _n==61
	replace feature =  "Compensation (total)" if _n==62
	replace feature =  "Min entitlement" if _n==63
	replace feature =  "Min entitlement (tenure)" if _n==64
	replace feature =  "Min entitlement (ag)" if _n==65
	replace feature =  "Min entitlement (holiday)" if _n==66
	replace feature =  "Min entitlement (holiday bonus)" if _n==67
	replace feature =  "Legal Entitlement" if _n==68
	replace feature =  "Compensation (lost wages)" if _n==69
	replace feature =  "Prop overtime" if _n==70

	gen abs = abs(beta)
	gsort -abs
	gen ord = _n
	keep if ord<=20

	encode feature, gen(ft)

	graph dot beta, over(ft, sort(1) descending)  horizontal   graphregion(color(white)) legend(off)  ytitle("Linear Projection") 
	graph export "./Figures/appendix/a/coef1_`model'.tif", replace

	restore
	local i = `i'+1
}
