/*Table 4׺  Treatment Effects*/
/*
We add a control for potential endogeneity of the presence of the employee
Column (9)
*/
********************************************************************************
clear all 
set maxvar 30000
*Set controls.
local controls i.anioControl i.junta i.phase i.numActores
//local balance_var gen trabajador_base horas_sem c_antiguedad abogado_pub reinst indem salario_diario sal_caidos prima_antig hextra rec20  prima_dom  desc_sem desc_ob sarimssinf utilidades nulidad min_ley 
local balance_var trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley 
//p_actor p_ractor p_dem p_rdem

use "./DB/scaleup_operation.dta", clear
rename año anio
rename expediente exp
merge m:1 junta exp anio using "./DB/scaleup_casefiles_wod.dta" , nogen  keep(1 3)

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


*Time hearing (Instrument)
gen time_hearing=substr(horario_aud,strpos(horario_aud," "),length(horario_aud))
egen time_hr=group(time_hearing)

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub time_hearing time_hr numActores `balance_var'
gen phase=2
tempfile p2
save `p2'

use "./DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)

*Presence employee
replace p_actor=(p_actor==1)
*Not in experiment
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment
rename expediente exp

*Time hearing (Instrument)
gen time_hearing=substr(horarioaudiencia,strpos(horarioaudiencia," "),length(horarioaudiencia))
egen time_hr=group(time_hearing)

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub time_hearing time_hr numActores `balance_var'
append using `p2'
replace phase=1 if missing(phase)

merge m:1 junta exp anio using ".\DB\seguimiento_m5m.dta", nogen
merge m:1 junta exp anio using ".\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)
replace seconcilio = 0 if modoTermino != 3 & !missing(modoTermino)
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

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

*Drop conciliator observations
drop if treatment==3

gen anioControl = anio
replace anioControl = 2010 if anio < 2010
replace numActores = 3 if numActores>3

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


*Instrument
gen time_instrument=inlist(time_hr,1,2,7,8) if !missing(time_hr) 
gen time_actor=time_instrument*p_actor

gen treat_inst=treatment*time_instrument
gen treat_p_actor=treatment*p_actor

********************************************************************************
********************************************************************************
*Balance Tables
/*
*Balance Tables

putexcel set ".\Tables\balanceTime2.xlsx", sheet("Balance") modify

orth_out `balance_var' if phase==1, by(time_instrument)  vce(robust)   bdec(3)  count
				
qui putexcel L5=matrix(r(matrix)) 
		
local i=5
foreach var in `balance_var' {
		
	*1 vs 2
	preserve
	local stars = ""
	qui ttest `var' if phase==1, by(time_instrument) unequal		
	local vp=round(r(p),.01)
	qui putexcel N`i'=(`vp') 
	if `vp' < .1 {
		local stars = "*"
	}
	if `vp' < .05 {
		local stars = "**"
	}
	if `vp' < .01 {
		local stars = "***"
	}
	qui putexcel O`i'=("`stars'") 
	local i=`i'+1
	restore
}

reg time_instrument `balance_var' if phase==1
local pval = Ftail(e(df_m), e(df_r), e(F))
	if `pval' < .1 {
		local stars = "*"
	}
	if `pval' < .05 {
		local stars = "**"
	}
	if `pval' < .01 {
		local stars = "***"
	} 
qui putexcel N12 = `pval' 
qui putexcel O12 = ("`stars'") 

************************************PHASE 2*************************************
********************************************************************************
orth_out `balance_var' ///
			if phase==2, ///
				by(time_instrument)  vce(robust)   bdec(3)  count
				
qui putexcel P5=matrix(r(matrix)) 
		
local i=5
foreach var in `balance_var' {
		
	*1 vs 2
	preserve	
	local stars = ""
	qui ttest `var' if phase==2, by(time_instrument) unequal	
	local vp=round(r(p),.01)
	qui putexcel R`i'=(`vp') 
	if `vp' < .1 {
		local stars = "*"
	}
	if `vp' < .05 {
		local stars = "**"
	}
	if `vp' < .01 {
		local stars = "***"
	}
	qui putexcel S`i'=("`stars'") 
	local i=`i'+1
	restore
	}	

reg time_instrument `balance_var' if phase==2
local pval = Ftail(e(df_m), e(df_r), e(F))
	if `pval' < .1 {
		local stars = "*"
	}
	if `pval' < .05 {
		local stars = "**"
	}
	if `pval' < .01 {
		local stars = "***"
	} 
qui putexcel R12 = `pval' 
qui putexcel S12 = ("`stars'") 
	
************************************PHASE 1/2***********************************
********************************************************************************


orth_out `balance_var' if treatment!=3,  ///
				by(time_instrument)  vce(robust)   bdec(3)  count
				
qui putexcel T5=matrix(r(matrix)) 
		
local i=5
foreach var in `balance_var' {
		
	*1 vs 2
	preserve	
	local stars = ""
	qui ttest `var', by(time_instrument) unequal		
	local vp=round(r(p),.01)
	qui putexcel V`i'=(`vp') 
	if `vp' < .1 {
		local stars = "*"
	}
	if `vp' < .05 {
		local stars = "**"
	}
	if `vp' < .01 {
		local stars = "***"
	}
	qui putexcel W`i'=("`stars'") 
	local i=`i'+1
	restore
	
	}	

reg time_instrument `balance_var'
local pval = Ftail(e(df_m), e(df_r), e(F))
	if `pval' < .1 {
		local stars = "*"
	}
	if `pval' < .05 {
		local stars = "**"
	}
	if `pval' < .01 {
		local stars = "***"
	} 
qui putexcel V12 = `pval' 
qui putexcel W12 = ("`stars'") 
*/
********************************************************************************
*REGRESSIONS
*

*Drop conciliator observations
drop if treatment==3
gen altT = treatment-1
gen interactT = altT*p_actor

*1) Probit probability model
reg  seconcilio i.treatment##i.p_actor `controls', r cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
local testInteraction=`r(p)'
qui su seconcilio if e(sample) & treatment == 1
local DepVarMean=r(mean)
qui su seconcilio if e(sample) & treatment == 1 & p_actor == 1
local IntMean=r(mean)
outreg2 using "./Tables/reg_results/CF_ITT.xls", replace ctitle("Probit Prob model") dec(3)  keep(2.treatment 1.p_actor 2.treatment#1.p_actor) addstat(DepVarMean, `DepVarMean', IntMean, `IntMean', calculator p value, `testInteraction')

*2) OLS (FS)
reg p_actor i.treatment time_instrument `controls', r cluster(fecha)
qui su seconcilio if e(sample) & treatment == 1
local DepVarMean=r(mean)
outreg2 using "./Tables/reg_results/CF_ITT.xls", append ctitle("OLS FS") dec(3) keep(2.treatment 1.p_actor 2.treatment#1.p_actor time_instrument) addstat(DepVarMean, `DepVarMean')



cap drop xb
predict xb, xb
*Generalized residuals
gen gen_resid_pr8 = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*3) Probit (FS)
reg  p_actor i.treatment time_instrument `controls', vce(bootstrap, reps(1000)) cluster(fecha)
qui su seconcilio if e(sample) & treatment == 1
local DepVarMean=r(mean)
outreg2 using "./Tables/reg_results/CF_ITT.xls", append ctitle("FS Probit") keep(2.treatment 1.p_actor 2.treatment#1.p_actor time_instrument) addstat(DepVarMean, `DepVarMean')


	

*Now use dummy variables for time groups
tab time_hr, gen(time_hr)
foreach var of varlist time_hr2-time_hr8 {
	gen treat_`var'=treatment*`var'
	}
	
*4 ) Probit (FS)
probit p_actor i.treatment i.junta time_hr2-time_hr8 `controls', r cluster(fecha)
qui su seconcilio if e(sample) & treatment == 1
local DepVarMean=r(mean)
outreg2 using "./Tables/reg_results/CF_ITT.xls", append ctitle("Probit FS") dec(3) sortvar(2.treatment 1.p_actor 2.treatment#1.p_actor gen_resid_pr time_hr2-time_hr8)  keep(2.treatment 1.p_actor 2.treatment#1.p_actor gen_resid_pr time_hr2-time_hr8) addstat(DepVarMean, `DepVarMean')

cap drop xb gen_resid_pr8
predict xb, xb
*Generalized residuals
gen gen_resid_pr8 = cond(p_actor == 1, normalden(xb)/normal(xb), -normalden(xb)/(1-normal(xb)))	

*CF
*5) Probit - CF
ritest altT _b[altT] _b[c.altT#c.p_actor], samplingsourcefile("./_aux/samplePooled.dta") samplingmatchvar(junta exp anio) reps(10000): reg seconcilio c.altT##c.p_actor `controls' gen_resid_pr8 if phase==1, robust  cluster(fecha)
matrix pvalues=r(p)
local pvalNoInteract = pvalues[1,1]
local pvalInteract = pvalues[1,2]

reg seconcilio i.treatment##i.p_actor i.junta  gen_resid_pr8 `controls', vce(bootstrap, reps(10000)) cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
qui su seconcilio if e(sample) & treatment == 1
local DepVarMean=r(mean)
qui su seconcilio if e(sample) & treatment == 1 & p_actor == 1
local IntMean=r(mean)
outreg2 using "./Tables/reg_results/CF_ITT.xls", append ctitle("CF Probit") addstat(DepVarMean, `DepVarMean', IntMean, `IntMean', test_interaction,`testInteraction', pvalueRI, `pvalNoInteract', pvalueRIInteraction,  `pvalInteract') dec(3)  keep(2.treatment 1.p_actor 2.treatment#1.p_actor gen_resid_pr8)
 
