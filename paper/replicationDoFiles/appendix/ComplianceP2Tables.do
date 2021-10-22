
/*
Compliance table for P2
*/


use ".\DB\scaleup_operation.dta", clear //phase2
rename año anio
rename expediente exp

*Notified casefiles
keep if notificado==1

*Homologation - TREATMENT
gen treatment=.
replace treatment=2 if dia_tratamiento==1
replace treatment=1 if dia_tratamiento==0


bysort junta exp anio: gen DuplicatesPredrop=_N
forvalues i=1/3{
	gen T`i'_aux=[treatment==`i'] 
	bysort junta exp anio: egen T`i'=max(T`i'_aux)
}

gen T1T2=[T1==1 & T2==1]
gen T1T3=[T1==1 & T3==1]
gen T2T3=[T2==1 & T3==1]
gen TAll=[T1==1 & T2==1 & T3==1]

replace T1T2=0 if TAll==1
replace T1T3=0 if TAll==1
replace T2T3=0 if TAll==1

*32 drops
drop if T1T2==1 & treatment == 1
*46 drops
drop if T1T3==1
*31 drops
drop if T2T3==1
*8 drops
drop if TAll==1

bysort junta exp anio: gen DuplicatesPostdrop=_N

*44 drops
sort junta exp anio fecha_treat
bysort junta exp anio: keep if _n==1


gen calcu_both = calcu_p_actora*calcu_p_dem
gen calcu_any = calcu_p_actora + calcu_p_dem > 0
gen registro_both = registro_p_actora*registro_p_dem2
gen registro_any = registro_p_actora + registro_p_dem2 > 0
***************************************

putexcel set  "./Tables/ComplianceP2.xlsx", modify sheet("complianceP2")


count if tratamiento == 0
putexcel P3 = (r(N))

count if tratamiento == 1
putexcel P4 = (r(N))

sum calcu_p_actora if tratamiento == 1 
putexcel Q4 = (r(mean))
sum calcu_p_dem if tratamiento == 1 
putexcel R4 = (r(mean))
sum calcu_both if tratamiento == 1 
putexcel S4 = (r(mean))
sum calcu_any  if tratamiento == 1 
putexcel T4 = (r(mean))

sum registro_p_actora if tratamiento == 1 
putexcel U4 = (r(mean))
sum registro_p_dem2 if tratamiento == 1 
putexcel V4 = (r(mean))
sum calcu_both if tratamiento == 1 
putexcel W4 = (r(mean))
sum calcu_any  if tratamiento == 1 
putexcel X4 = (r(mean))
