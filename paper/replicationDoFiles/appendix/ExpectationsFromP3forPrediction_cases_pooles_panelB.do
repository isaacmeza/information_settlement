*From Jan 2020 to do list we agreed on adding stats from pilot 3 to the table about baseline expectations/predictions for the lawsuit. This do file adds this to the previos results

*************************  P3 baseline data *************************
use ".\DB\treatment_data.dta", clear


***************************** Calculator prediction  ****************************

gen quadrant="NE"
replace quadrant="NW" if antiguedad>2.61 & salario_diario<207.66
replace quadrant="SE" if antiguedad<2.61 & salario_diario>207.66
replace quadrant="SW" if antiguedad<2.61 & salario_diario<207.66

gen min_prediction=61.03 if quadrant=="NE"
replace min_prediction=69.87 if quadrant=="NW"
replace min_prediction=42.24 if quadrant=="SE"
replace min_prediction=51.22 if quadrant=="SW"

gen max_prediction=90.08 if quadrant=="NE"
replace max_prediction=98.69 if quadrant=="NW"
replace max_prediction=59.22 if quadrant=="SE"
replace max_prediction=67.36 if quadrant=="SW"

gen mid_prediction=(max_prediction+min_prediction)/2


foreach pred in min max mid{
	replace `pred'_prediction=`pred'_prediction*salario_diario

	gen `pred'_overconfidenceAmmount=(cantidad_ganar-`pred'_prediction)/`pred'_prediction
}

*Predicion de cantidad ganar, la R2 es muy baja, no la uso
reg cantidad_ganar mujer salario_diario antiguedad
predict predicted_cantidad_ganar, xb

qui su na_prob
local ignores=r(mean)*100

replace prob_ganar=prob_ganar
replace mid_overconfidenceAmmount=mid_overconfidenceAmmount
replace max_overconfidenceAmmount=max_overconfidenceAmmount

reg prob_ganar
qui su prob_ganar
local sd r(sd)
outreg2 using ".\Tables\reg_results\Pilot3_overconfidence.xls", addstat("Ignores prob. (%)",`ignores', "Standard deviation", `sd') replace
qui su prob_ganar


qui su na_cant
local ignores=r(mean)*100

reg cantidad_ganar
qui su cantidad_ganar
local sd r(sd)
outreg2 using ".\Tables\reg_results\Pilot3_overconfidence.xls", addstat("Ignores amount. (%)",`ignores', "Standard deviation", `sd') append

reg mid_overconfidenceAmmount
qui su mid_overconfidenceAmmount
local sd r(sd)
outreg2 using ".\Tables\reg_results\Pilot3_overconfidence.xls", addstat("Ignores amount. (%)",`ignores', "Standard deviation", `sd') append

reg max_overconfidenceAmmount
qui su max_overconfidenceAmmount
local sd r(sd)
outreg2 using ".\Tables\reg_results\Pilot3_overconfidence.xls", addstat("Ignores amount. (%)",`ignores', "Standard deviation", `sd') append



