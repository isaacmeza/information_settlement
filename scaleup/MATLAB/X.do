*Creates X matrix for the creation of intervlas using optim2d_conv.m
set more off
global directorio "C:\Users\chasi_000\Dropbox\Statistics\P10\MATLAB"
import delimited "$directorio\convenio_menor_anio1.csv", clear 

*Variables of the model
keep c_antiguedad ///
hextra ///
sueldo ///
rec20 ///
c_indem ///
gen ///
top_dem ///
giro_empresa00 ///
giro_empresa22 ///
giro_3 ///
giro_4 ///
giro_5 ///
giro_6 ///
giro_7

*Cleaning
foreach var of varlist * {
	destring `var', replace force
	drop if `var'==.
}

*Order of specification
order sueldo c_antiguedad ///
hextra ///
rec20 ///
c_indem ///
gen ///
top_dem ///
giro_empresa00 ///
giro_empresa22 ///
giro_3 ///
giro_4 ///
giro_5 ///
giro_6 ///
giro_7 


*Trimming
xtile perc_sueldo=sueldo, nq(100)
xtile perc_ant=c_antiguedad, nq(100)

drop if perc_sueldo>=95
drop if perc_ant>=90

drop perc*

su sueldo c_ant
scatter sueldo c_antiguedad

export excel using "$directorio\X.xlsx", replace

