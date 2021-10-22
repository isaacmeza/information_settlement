*Cleaning HD Data

*********************************HD DATA****************************************
import delimited "$sharelatex\DB\scaleup_hd.csv", clear 


*No negative values
for var c_antiguedad c_indem-c_desc_ob c_recsueldo liq_total: ///
	capture replace X=0 if X<0 & X~=.
	
*Wizorise all at 99th percentile
for var c_* liq_total liq_total_tope: capture egen X99 = pctile(X) , p(99)
for var c_* liq_total liq_total_tope: ///
	capture replace X=X99 if X>X99 & X~=.
drop *99

destring salario_diario, force replace


*Dates in format YMD
foreach dte of varlist fecha* {
	cap drop auxiliar_f*
	cap split `dte', gen(auxiliar_f) p("/" "-") 
	cap gen d_`dte'=auxiliar_f3+"-"+auxiliar_f2+"-"+auxiliar_f1 if !missing(`dte')
	drop  `dte'
	cap rename d_`dte' `dte'
	}


********************************************************************************
*Lawyers name cleaning
do "$sharelatex\DoFiles\cleaning\name_cleaning_hd.do"

*Save dataset
save "$sharelatex\DB\scaleup_hd.dta", replace


