use "$directorio\DB\varimppr.dta", clear

	
	
foreach var of varlist antiguedad salario_diario horas_sem c_antiguedad c_indem c_prima_antig c_rec20 c_ag c_vac c_hextra c_prima_vac c_prima_dom c_desc_sem c_desc_ob c_utilidades c_recsueldo c_total min_indem min_prima_antig min_ag min_vac min_prima_vac min_ley c_sal_caidos prop_hextra {
	replace `var' = log(`var'+1)
}

	local i = 1
foreach depvar in  sett  cr_los cr_win drp cr_win_ph2 tot_comp_1l tot_comp_3l tot_comp_1l_r tot_comp_3 dur_1  dur_30 dur_31 dur_4 dur_2l    {

preserve
	local model = "m`i'"
	gen logs`depvar' = log(pr_`depvar')

local alpha = .05 // for 95% confidence intervals 

*
	
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
replace feature =  "Overtime 2" if _n==35
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
replace feature =  "Overtime " if _n==47
replace feature =  "Tenure" if _n==48
replace feature =  "Daily wage" if _n==49
replace feature =  "Weekly hours" if _n==50
replace feature =  "Compensation (tenure)" if _n==51
replace feature =  "Compensation (severance)" if _n==52
replace feature =  "Compensation (tenure bonus)" if _n==53
replace feature =  "Compensation (rec20)" if _n==54
replace feature =  "Compensation (ag)" if _n==55
replace feature =  "Compensation (holiday)" if _n==56
replace feature =  "Compensation (overtime)" if _n==57
replace feature =  "Compensation (holiday bonus)" if _n==58
replace feature =  "Compensation (sunday bonus)" if _n==59
replace feature =  "Compensation (weekly rest)" if _n==60
replace feature =  "Compensation (rest)" if _n==61
replace feature =  "Compensation (utility)" if _n==62
replace feature =  "Compensation (rec salary)" if _n==63
replace feature =  "Compensation (total)" if _n==64
replace feature =  "Min entitlement" if _n==65
replace feature =  "Min entitlement (tenure)" if _n==66
replace feature =  "Min entitlement (ag)" if _n==67
replace feature =  "Min entitlement (holiday)" if _n==68
replace feature =  "Min entitlement (holiday bonus)" if _n==69
replace feature =  "Legal Entitlement" if _n==70
replace feature =  "Compensation (lost wages)" if _n==71
replace feature =  "Prop overtime" if _n==72

gen abs = abs(beta)
gsort -abs
gen ord = _n
keep if ord<=20

encode feature, gen(ft)

graph dot beta, over(ft, sort(1) descending)  horizontal   graphregion(color(white)) legend(off)  ytitle("Linear Projection") 
graph export ".\paper\Figures\coef1_`model'.pdf", replace

restore
local i = `i'+1
}