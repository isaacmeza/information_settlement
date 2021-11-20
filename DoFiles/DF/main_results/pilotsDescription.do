*****************************************************************
*																*
*		Get basic statistics for pilot description table		*
*																*
*****************************************************************

* 1) Create databas
********************************************************************************
use  ".\DB\ITTSample.dta", clear

*2) Calculate things and write table
putexcel set ".\Tables\tablePilots.xlsx", modify sheet("pilotsDescription")

preserve
keep if phase == 1
count
local num = `r(N)'
putexcel D2 = (`num')
count if treatment == 2
putexcel E2 = (`r(N)')
sum fecha, f
local fechaMin: disp %tdDD/NN/CCYY r(min)
local fechaMax: disp %tdDD/NN/CCYY r(max)
putexcel K2 = ("`fechaMin'")
putexcel L2 = ("`fechaMax'")
restore


preserve
keep if phase == 2
count
putexcel D3 = (`r(N)')
count if treatment == 2
putexcel E3 = (`r(N)')
sum fecha, f
local fechaMin: disp %tdDD/NN/CCYY r(min)
local fechaMax: disp %tdDD/NN/CCYY r(max)
putexcel K3 = ("`fechaMin'")
putexcel L3 = ("`fechaMax'")
restore

*P3 data

use ".\DB\P3Outcomes.dta", clear
merge m:1 id_actor using ".\DB\treatment_data.dta", keep(2 3) nogen
merge m:1 id_actor using ".\DB\survey_data_2m.dta", nogen keep(1 3)

gen calculadora = main_treatment
replace calculadora = . if main_treatment==3
drop if missing(calculadora)

count
local num = `r(N)'
putexcel D4 = (`num')
count if calculadora == 2
putexcel E4 = (`r(N)')
sum fecha_alta, f
local fechaMin: disp %tdDD/NN/CCYY r(min)
local fechaMax: disp %tdDD/NN/CCYY r(max)
putexcel K4 = ("`fechaMin'")
putexcel L4 = ("`fechaMax'")


