*use "D:\Dropbox\Dropbox\Documentos_\Joyce_Seira\p1_w_p3\out\dulce_1911.dta", clear
use ".\DB\P3Outcomes.dta", clear
*/
merge m:1 id_actor using ".\DB\treatment_data.dta", keep(2 3) nogen
merge m:1 id_actor using ".\DB\survey_data_2m.dta", nogen keep(1 3)

gen calculadora = main_treatment
replace calculadora = . if main_treatment==3
gen convenio = MODODETERMINO == "CONVENIO"
gen doble_convenio = convenio ==1 | conflicto_arreglado == 1
*replace doble_convenio = . if missing(conflicto_arreglado)
gen convenio_mamon = [conflicto_arreglado==1]

local depvar conflicto_arreglado convenio doble_convenio
local controls mujer antiguedad salario_diario

qui gen esample=1	
qui gen nvals=.

gen altT = calculadora-1
bysort fecha_alta: egen minT = min(altT)
bysort fecha_alta: egen maxT = max(altT)
gen indicadora = minT != maxT

drop if indicadora == 1


foreach var in `depvar'	{
	ritest altT _b[altT], reps(10000) cluster(fecha_alta) seed(125): reg `var' altT `controls', robust cluster(fecha_alta)
	matrix pvalues=r(p) 
	local pvalNoInteract = pvalues[1,1]

	reg `var' i.calculadora `controls', robust cluster(fecha_alta)
	qui sum `var' if main_treatment==1
	local DepVarMean=`r(mean)'
	outreg2 using  "./Tables/reg_results/te123_calculator_p1.xls", append ctitle("`var'")  ///
	addstat(Dependent Variable Mean, `DepVarMean', pvalueRI, `pvalNoInteract')dec(3)
	}

	/*
foreach var in `depvar'	{	
	eststo: reg `var' i.calculadora `controls', robust cluster(fecha_alta)
	estadd scalar Erre=e(r2)
	estadd local BVC="YES"
	estadd local Source=""
	qui sum `var' if main_treatment==1
	estadd local control_mean=`r(mean)'
	forvalues i=1/2 {
		qui count if main_treatment==`i' & e(sample)
		local obs_`i'=r(N)
		}	
	estadd local obs_per_gr="`obs_1'/`obs_2'"
	
	qui replace esample=(e(sample)==1)
	bysort esample main_treatment fecha_alta : replace nvals = _n == 1  
	forvalues i=1/2 {
		qui count if nvals==1 & main_treatment==`i' & esample==1
		local obs_`i'=r(N)
		}
	estadd local days_per_gr="`obs_1'/`obs_2'"
	
	}
	
	
	*************************
	esttab using "./Tables/reg_results/te123_calculator_p1.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "BVC BVC" "Source Source" "obs_per_gr Obs per group" "days_per_gr Days per group" "test_23 T2=T3" "control_mean Control group mean") replace 
