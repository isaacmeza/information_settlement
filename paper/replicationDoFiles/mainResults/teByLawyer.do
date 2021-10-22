/*Table C14: Treatment Effects conditional on type of lawyer*/
/*
This dofile reproduces the main treatment effects but by type of lawyer
*/

********************************************************************************
clear all
set maxvar 32767
local controls i.anioControl i.junta i.phase i.numActores

use ".\DB\scaleup_operation.dta", clear
rename año anio
rename expediente exp
merge m:1 junta exp anio using ".\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

*Notified casefiles
keep if notificado==1

*Homologation
gen treatment=.
replace treatment=2 if dia_tratamiento==1
replace treatment=1 if dia_tratamiento==0
rename convenio seconcilio
rename convenio_seg_2m convenio_2m 
rename convenio_seg_5m convenio_5m
gen fecha=date(fecha_lista,"YMD")
format fecha %td

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub numActores
gen phase=2
tempfile temp_p2
save "`temp_p2'"

use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub numActores
append using "`temp_p2'"
replace phase=1 if missing(phase)
********************************************************************************

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
*drop if T1T2==1 & treatment == 1
*46 drops
drop if T1T3==1
*31 drops
drop if T2T3==1
*8 drops
drop if TAll==1

*bysort junta exp anio: gen DuplicatesPostdrop=_N

*44 drops
*sort junta exp anio fecha
*bysort junta exp anio: keep if _n==1
********************************************************************************
*Drop conciliator observations
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1
********************************************************************************

merge 1:1 junta exp anio using ".\p1_w_p3\out\inicialesP1Faltantes_wod.dta", keep(1 3) keepusing(abogado_pubN tipodeabogado_M fechadecaptura2 numActoresN ) gen(_mNuevasIniciales) 

*Follow-up (more than 5 months)
merge 1:1 junta exp anio using ".\DB\seguimiento_m5m.dta", nogen keep(1 3)
merge 1:1 junta exp anio using ".\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)

*Settlement
//replace convenio_2m=seconcilio if missing(convenio_2m) & seconcilio==1
replace convenio_2m=seconcilio if seconcilio==1

//replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace modo_termino_expediente=3 if missing(modo_termino_expediente) & convenio_m5m==1
//replace modo_termino_expediente = modoTermino if missing(modo_termino_expediente) | [modo_termino_expediente == 3 & !missing(modoTermino)]
replace modo_termino_expediente=2 if missing(modo_termino_expediente)

//replace modo_termino_expediente = modoTermino  if missing(modo_termino_expediente)

replace modoTermino = modo_termino_expediente if missing(modoTermino)


//replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1
replace convenio_m5m = 1 if modoTermino == 3
replace convenio_m5m = 0 if modoTermino != 3 & !missing(modoTermino)
replace seconcilio = 0 if modoTermino != 3 & !missing(modoTermino)

replace convenio_m5m = . if modoTermino == 5
replace seconcilio = . if modoTermino == 5

gen anioControl = anio
replace anioControl = 2010 if anio < 2010
replace numActores = 3 if numActores>3
gen altT = treatment-1
gen interactT = altT*p_actor

foreach var in numActores abogado_pub{
replace `var' = `var'N if missing(`var') & !missing(`var'N)
}

replace numActores = 3 if numActores>3

//replace abogado_pub = 0 if missing(abogado_pub)
********************************************************************************
	preserve
	keep if abogado_pub==0
	
	
	
	*********************************
	*			POOLED				*
	*********************************
	ritest altT _b[altT] _b[c.altT#c.p_actor], samplingsourcefile("./_aux/samplePooled.dta") samplingmatchvar(junta exp anio) reps(10000): reg seconcilio c.altT##c.p_actor  `controls', robust  cluster(fecha)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]
	local pvalInteract = pvalues[1,2]

	*Same day
	reg seconcilio i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su seconcilio if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su seconcilio if e(sample) & treatment == 1
	local DepVarMean=r(mean)
	outreg2 using  "./Tables/reg_results/by_lawyerITT.xls", replace ctitle("Same day. Pooled") addtext(Court Dummies, Yes) ///
	addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean', test interaction, `testInteraction', pvalueRI, `pvalNoInteract', pvalueRIInteraction,  `pvalInteract') dec(3) keep(2.treatment 1.p_actor 2.treatment#1.p_actor )

	ritest altT _b[altT] _b[c.altT#c.p_actor], samplingsourcefile("./_aux/samplePooled.dta") samplingmatchvar(junta exp anio) reps(10000): reg convenio_m5m c.altT##c.p_actor  `controls', robust  cluster(fecha)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]
	local pvalInteract = pvalues[1,2]

	reg convenio_m5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su convenio_m5m if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su convenio_m5m if e(sample) & treatment == 1
	local DepVarMean=r(mean)
	outreg2 using  "./Tables/reg_results/by_lawyerITT.xls", append ctitle("LR. Pooled") addtext(Court Dummies, Yes) ///
	addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction', pvalueRI, `pvalNoInteract', pvalueRIInteraction,  `pvalInteract')	dec(3) keep(2.treatment 1.p_actor 2.treatment#1.p_actor )
	
********************************************************************************	

	restore
	
********************************************************************************	
	preserve
	keep if abogado_pub==1

	*********************************
	*			POOLED				*
	*********************************
	ritest altT _b[altT] _b[c.altT#c.p_actor], samplingsourcefile("./_aux/samplePooled.dta") samplingmatchvar(junta exp anio) reps(10000): reg seconcilio c.altT##c.p_actor  `controls', robust  cluster(fecha)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]
	local pvalInteract = pvalues[1,2]

*Same day
	reg seconcilio i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su seconcilio if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su seconcilio if e(sample) & treatment == 1
	local DepVarMean=r(mean)
	outreg2 using  "./Tables/reg_results/by_lawyerITT.xls", append ctitle("Same day. Pooled") addtext(Court Dummies, Yes) ///
	addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction', pvalueRI, `pvalNoInteract', pvalueRIInteraction,  `pvalInteract') dec(3) keep(2.treatment 1.p_actor 2.treatment#1.p_actor )

	ritest altT _b[altT] _b[c.altT#c.p_actor], samplingsourcefile("./_aux/samplePooled.dta") samplingmatchvar(junta exp anio) reps(10000): reg convenio_m5m c.altT##c.p_actor  `controls', robust  cluster(fecha)
	matrix pvalues=r(p)
	local pvalNoInteract = pvalues[1,1]
	local pvalInteract = pvalues[1,2]
	
	*5+ months
	reg convenio_m5m i.treatment##i.p_actor i.junta if treatment!=0, robust  cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su convenio_m5m if e(sample) & treatment == 1 & p_actor == 1
	local IntMean=r(mean) 
	qui su convenio_m5m if e(sample) & treatment == 1
	local DepVarMean=r(mean)
	outreg2 using  "./Tables/reg_results/by_lawyerITT.xls", append ctitle("LR. Pooled") addtext(Court Dummies, Yes) ///
	addstat(Dependant Variable Mean,`DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction', pvalueRI, `pvalNoInteract', pvalueRIInteraction,  `pvalInteract') ///
	dec(3) keep(2.treatment 1.p_actor 2.treatment#1.p_actor )
	
	restore
		

	
