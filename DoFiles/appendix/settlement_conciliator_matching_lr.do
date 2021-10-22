/*Table C9:  Comparison of aettlement amounts*/
/*
This table is a robustness check considering all cases settled up to December 2018,
contrary to cases settled on the same day as Table 5.
*/

******** Global variables 
global int=3.43			/* Interest rate */
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */
global pago_pri=2000	/* Payment to private lawyer */


*******************************PILOT 1 DATA*************************************
use "$sharelatex/DB/pilot_operation.dta" , clear	
merge m:1 folio using "$sharelatex\DB\pilot_casefiles_wod.dta" , nogen  keep(1 3)

*Not in experiment
drop if tratamientoquelestoco==0

*Follow-up (more than 5 months)
rename expediente exp
merge m:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", nogen

*Settlement
replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1

replace cant_convenio=c1_cantidad_total_pagada_conveni if missing(cant_convenio)

*********
*Settlement amount for 'treated' files
keep if (convenio_m5m==1 & (calculator==1 | conciliator==1))


*Date imputation
*Settlement date
replace fecha_con=fechadem if missing(fecha_con)
*Sue date
replace fechadem=fecha_con if missing(fechadem)

*NPV
gen months=(fecha_con-fechadem)/30
gen npv=.
	*Net present value discounted to the time of filing date and substracting payment to lawyer
replace npv=(cant_convenio/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(cant_convenio/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1
drop if npv==.

keep npv fecha_con ///
/*Entitlement by law*/       min_ley ///
/*Basic variable contrlols*/ abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///

*Homologation
rename fecha_con fecha
gen mes=month(fecha)
gen anio=year(fecha)

merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

*Pesos amounts at constant prices (June 2016)
replace npv=(npv/inpc)*118.901
replace min_ley=(min_ley/inpc)*118.901
replace salario_diario=(salario_diario/inpc)*118.901


*Treated dummy
gen treat=1

*Save file to append it with HD data
tempfile temp_conc_p1
save `temp_conc_p1'

*******************************PILOT 2 DATA*************************************
use "$scaleup/DB/scaleup_operation.dta" , clear	
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$scaleup\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

*Homologation
rename convenio seconcilio
rename convenio_seg_2m convenio_2m 
rename convenio_seg_5m convenio_5m

	
*Follow-up (more than 5 months)
merge m:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", nogen

*Settlement
replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1

replace cant_convenio=cantidad_convenio if missing(cant_convenio)	
	
*********
*Settlement amount for 'treated' files
keep if (convenio_m5m==1 & (dia_tratamiento==1))


*Date 
*Settlement date
gen fecha_con=date(fecha_lista, "YMD")
*Sue date
gen fechadem=date(fecha_demanda, "YMD")

*NPV
gen months=(fecha_con-fechadem)/30
gen npv=.
	*Net present value discounted to the time of filing date and substracting payment to lawyer
replace npv=(cant_convenio/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(cant_convenio/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1
drop if npv==.


keep npv fecha_con ///
/*Entitlement by law*/       min_ley ///
/*Basic variable contrlols*/ abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///

*Homologation
rename fecha_con fecha
gen mes=month(fecha)
gen anio=year(fecha)

merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

*Pesos amounts at constant prices (June 2016)
replace npv=(npv/inpc)*118.901
replace min_ley=(min_ley/inpc)*118.901
replace salario_diario=(salario_diario/inpc)*118.901


*Treated dummy
gen treat=1

*Save file to append it with HD data
tempfile temp_conc_p2
save `temp_conc_p2'

*********************************HD DATA****************************************
use  "$sharelatex\DB\scaleup_hd.dta", clear

*Compare with ONLY those who end case by COURT RULING
keep if modo_termino==3


*Dates
*Sue date
gen fechadem=date(fecha_demanda,"YMD")
*End date
gen fechater=date(fecha_termino,"YMD")

*NPV
gen months=(fechater-fechadem)/30
gen npv=.
	*Net present value discounted to the time of filing date and substracting payment to lawyer
replace npv=(liq_total_tope/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(liq_total_tope/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1
drop if npv==.


keep npv fechadem ///
/*Entitlement by law*/       min_ley ///
/*Basic variable contrlols*/ abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///


*Homologation
rename fechadem fecha
gen mes=month(fecha)
gen anio=year(fecha)

merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

*Pesos amounts at constant prices (June 2016)
replace npv=(npv/inpc)*118.901
replace min_ley=(min_ley/inpc)*118.901
replace salario_diario=(salario_diario/inpc)*118.901


*Append datasets
append using `temp_conc_p1'
append using `temp_conc_p2'
replace treat=0 if missing(treat)



********************************************************************************
*************************************NN Match***********************************
********************************************************************************

*For the matching procedure we follow the procedure as described in Imbens 2015
* 
*
*
*

********************************************************************************
********************************************************************************

/*
A. Stage I: Design
	The full sample will be trimmed by discarding some units to improve overlap
in covariate distributions.
*/

* Dropping observations with extreme values of the propensity score - CHIM

*Get pscore
	*Using a logit model
pscore treat min_ley abogado_pub gen  c_antiguedad salario_diario horas_sem, pscore(ps_l) logit

*Generate g function
	*Logit
gen g_func_l=1/(ps_l*(1-ps_l))
	
*One finds the smallest value of \alpha\in [0,0.5] s.t.
* \lambda:=\frac{1}{\alpha(1-\alpha)}
* 2\frac{\sum 1(g(X)\leq\lambda)*g(X)}{\sum 1(g(X)\leq\lambda)}-\lambda\geq 0

*Equivalently the first value of alpha (in increasing order) such that the constraint is achieved by equality (as the constraint is a monotone increasing function in alpha)

local alpha_l=0.01
local const_l=-1

while `const_l'<0  {

	qui {
	cap drop ind* den* num* h_func*
	
	*LOGIT
	local alpha_l=`alpha_l' + 0.00001
	local lambda_l=1/(`alpha_l'*(1-`alpha_l'))
		
	*Evaluate constraint
	gen ind_l=(g_func_l<=`lambda_l')
	egen den_l=sum(ind_l)
	gen num_l=g_func_l*ind_l
	egen h_func_l=sum(num_l)
	replace h_func_l=2*h_func_l/den_l
	local const_l=h_func_l[1]-`lambda_l' 
	
	}
	}

di `alpha_l'
gen covariate_space=inrange(ps_l,`alpha_l',1-`alpha_l')

*IMPORTANT: The results were checked to be robust to logit-probit specification in 
*the PS. We therefore use logit specification.
*

*Overlap
cap drop psm_1*
teffects psmatch (npv) ///
	(treat min_ley abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
		, logit) ///
		if covariate_space==1 , nneighbor(1) gen(psm_1)
teffects overlap,  graphregion(color(white)) xtitle("Propensity Score") ///
	ytitle("Density") legend(order(1 "Control" 2 "Treatment"))


orth_out  ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
   if covariate_space==1, by(treat) se pcompare vce(robust) bdec(3) count



********************************************************************************
********************************************************************************

/*
B. Stage II: Supplementary Analysis: Assessing Unconfoundedness
	The unconfoundedness assumption is assessed.
*/

******************************************



teffects nnmatch (min_ley  ///
  abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ) ///
  (treat) if covariate_space==1, nneighbor(3) ///
  ematch(abogado_pub) biasadj(c_antiguedad salario_diario horas_sem) ///


******************************************			
		

  
teffects nnmatch (salario_diario  ///
  min_ley abogado_pub gen trabajador_base c_antiguedad horas_sem ) ///
  (treat) if covariate_space==1, nneighbor(3) ///
  ematch(abogado_pub) biasadj( min_ley c_antiguedad  horas_sem) ///



******************************************

  
teffects nnmatch (c_antiguedad  ///
  min_ley abogado_pub gen trabajador_base salario_diario  horas_sem ) ///
  (treat) if covariate_space==1, nneighbor(3) ///
  ematch(abogado_pub) biasadj( min_ley  salario_diario horas_sem)
  

******************************************  
  
  
teffects nnmatch (npv ///
	min_ley abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem) ///
	(treat) if covariate_space==1 , nneighbor(3) generate(match)
egen cou = rownonmiss(match*)

reg salario_diario treat  min_ley   abogado_pub gen  c_antiguedad  horas_sem [w=cou] if cou>0
reg min_ley treat  salario_diario   abogado_pub gen  c_antiguedad  horas_sem [w=cou] if cou>0  
reg c_antiguedad treat  salario_diario   abogado_pub gen  min_ley  horas_sem [w=cou] if cou>0  


********************************************************************************
********************************************************************************

/*
C. Stage III: Analysis
	The estimator for the average effect will be applied to the trimmed data set
*/


local i=2
local Col=substr(c(ALPHA),2*`i'-1,1)

teffects nnmatch (npv  ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
					) (treat) if covariate_space==1

*Baseline
	qui su npv if treat==0 & e(sample) &  covariate_space==1
	qui putexcel B27=("`r(mean)'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
*ATE
	mat def ate=e(b)
	local ate=round(ate[1,1])
	qui putexcel `Col'29=("`ate'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Std Dev
	mat def var=e(V)
	local std=round(sqrt(var[1,1]))
	local sd="(`std')"
	qui putexcel `Col'32=("`sd'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Obs
	qui putexcel `Col'33=(e(n1))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
	qui putexcel `Col'34=(e(n0))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify		
*Matches
	local mtch="[`e(k_nnmin)', `e(k_nnmax)']"
	qui putexcel `Col'35=("`mtch'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify

******************************************

local i=`i'+1
local Col=substr(c(ALPHA),2*`i'-1,1)

teffects nnmatch (npv  ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
					) (treat) if covariate_space==1, ///
	nneighbor(3)
	
*ATE
	mat def ate=e(b)
	local ate=round(ate[1,1])
	qui putexcel `Col'29=("`ate'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Std Dev
	mat def var=e(V)
	local std=round(sqrt(var[1,1]))
	local sd="(`std')"
	qui putexcel `Col'32=("`sd'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Obs
	qui putexcel `Col'33=(e(n1))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
	qui putexcel `Col'34=(e(n0))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify		
*Matches
	local mtch="[`e(k_nnmin)', `e(k_nnmax)']"
	qui putexcel `Col'35=("`mtch'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
		
******************************************


local i=`i'+1
local Col=substr(c(ALPHA),2*`i'-1,1)
		
teffects nnmatch (npv  ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  gen trabajador_base c_antiguedad salario_diario horas_sem ///
					) (treat) if covariate_space==1 , ///
	ematch(abogado_pub) biasadj( min_ley c_antiguedad salario_diario horas_sem)
	
*ATE
	mat def ate=e(b)
	local ate=round(ate[1,1])
	qui putexcel `Col'29=("`ate'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Std Dev
	mat def var=e(V)
	local std=round(sqrt(var[1,1]))
	local sd="(`std')"
	qui putexcel `Col'32=("`sd'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Obs
	qui putexcel `Col'33=(e(n1))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
	qui putexcel `Col'34=(e(n0))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify		
*Matches
	local mtch="[`e(k_nnmin)', `e(k_nnmax)']"
	qui putexcel `Col'35=("`mtch'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
		
******************************************
	
	
local i=`i'+1
local Col=substr(c(ALPHA),2*`i'-1,1)
		
teffects nnmatch (npv  ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  gen trabajador_base c_antiguedad salario_diario horas_sem ///
					) (treat) if covariate_space==1 , ///
	ematch(abogado_pub) biasadj( min_ley c_antiguedad salario_diario horas_sem) ///
	nneighbor(3)


*ATE
	mat def ate=e(b)
	local ate=round(ate[1,1])
	qui putexcel `Col'29=("`ate'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Std Dev
	mat def var=e(V)
	local std=round(sqrt(var[1,1]))
	local sd="(`std')"
	qui putexcel `Col'32=("`sd'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Obs
	qui putexcel `Col'33=(e(n1))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
	qui putexcel `Col'34=(e(n0))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify		
*Matches
	local mtch="[`e(k_nnmin)', `e(k_nnmax)']"
	qui putexcel `Col'35=("`mtch'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
		
******************************************


local i=`i'+1
local Col=substr(c(ALPHA),2*`i'-1,1)

teffects psmatch (npv) ///
	(treat min_ley abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
		, logit) ///
		if covariate_space==1 , nneighbor(1)
	
*ATE
	mat def ate=e(b)
	local ate=round(ate[1,1])
	qui putexcel `Col'29=("`ate'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Std Dev
	mat def var=e(V)
	local std=round(sqrt(var[1,1]))
	local sd="(`std')"
	qui putexcel `Col'32=("`sd'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Obs
	qui putexcel `Col'33=(e(n1))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
	qui putexcel `Col'34=(e(n0))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify		
*Matches
	local mtch="[`e(k_nnmin)', `e(k_nnmax)']"
	qui putexcel `Col'35=("`mtch'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
		
******************************************


local i=`i'+1
local Col=substr(c(ALPHA),2*`i'-1,1)

teffects psmatch (npv) ///
	(treat min_ley abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
		, logit) ///
		if covariate_space==1 , nneighbor(3)
	
*ATE
	mat def ate=e(b)
	local ate=round(ate[1,1])
	qui putexcel `Col'29=("`ate'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Std Dev
	mat def var=e(V)
	local std=round(sqrt(var[1,1]))
	local sd="(`std')"
	qui putexcel `Col'32=("`sd'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify	
*Obs
	qui putexcel `Col'33=(e(n1))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
	qui putexcel `Col'34=(e(n0))  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify		
*Matches
	local mtch="[`e(k_nnmin)', `e(k_nnmax)']"
	qui putexcel `Col'35=("`mtch'")  using "$sharelatex/Tables/NN_match_lr.xlsx", ///
		sheet("NN_match_lr") modify
		
******************************************
