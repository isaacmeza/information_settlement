*Generation of MxFLS dataset for use of the preference and risk rates
********************************************************************************

*Gender
use ".\Raw\mxfls\c_ls.dta", clear	
duplicates drop folio ls, force

*Education level
merge 1:1 folio ls using ".\Raw\mxfls\iiia_ed.dta", nogen

*Employment
merge 1:1 folio ls using ".\Raw\mxfls\iiia_tb.dta", nogen

*Age
merge 1:1 folio ls using ".\Raw\mxfls\iiib_portad.dta", nogen

*Time preference
merge 1:1 folio ls using ".\Raw\mxfls\iiib_pr.dta", nogen

*Expansion factor
merge 1:m folio ls using ".\Raw\mxfls\hh09w_b3b.dta", nogen



*Cleaning
rename ls04 gen
recode gen (3=1) (1=0)

rename ed06 education
recode education (1/3=1) (4/5=2) (6/7=3) (8/10=4) (98=.)

gen salario_diario=tb35aa_2/20


gen numempleados=.
replace numempleados=1 if inrange(tb30p_2,1,10)
replace numempleados=2 if inrange(tb30p_2,11,50)
replace numempleados=3 if inrange(tb30p_2,51,100)
replace numempleados=4 if tb30p_2>100 & !missing(tb30p_2)

rename tb28s horas_sem

gen trabajador_base=(tb33p_a==1)
replace trabajador_base=. if missing(tb33p_a) & ///
							missing(tb33p_b) & ///
							missing(tb33p_c) & ///
							missing(tb33p_d) & ///
							missing(tb33p_e) & ///
							missing(tb33p_f) & ///
							missing(tb33p_g) & ///
							missing(tb33p_h) & ///
							missing(tb33p_i)		
							
gen social_security=( tb33p_d==4 | tb33p_e==5 | tb33p_g==7 )	
replace social_security=. if missing(tb33p_a) & ///
							missing(tb33p_b) & ///
							missing(tb33p_c) & ///
							missing(tb33p_d) & ///
							missing(tb33p_e) & ///
							missing(tb33p_f) & ///
							missing(tb33p_g) & ///
							missing(tb33p_h) & ///
							missing(tb33p_i)				

rename edad age

rename tb41_43p_cmo giro

*Annual cuantifications

rename tb36ae_2 c_aguinaldo

rename tb36ah_2 c_utilidades

rename tb36ag_2 c_vacaciones

rename tb35ad_2 c_horasextras			

rename tb36af_2 annual_bonus



*Time preference
gen beta_monthly=.
replace beta_monthly=1 if pr03a==2
replace beta_monthly=10/12 if pr03a==1 & pr03b==2 & pr03c==2
replace beta_monthly=10/15 if pr03a==1 & pr03b==2 & pr03c==1
replace beta_monthly=10/20 if pr03a==1 & pr03b==1 & pr03d==2 & pr03e==2
replace beta_monthly=10/30 if pr03a==1 & pr03b==1 & pr03d==2 & pr03e==1

gen beta_annual=.
replace beta_annual=1 if pr04a==2
replace beta_annual=10/12 if pr04a==1 & pr04b==2 & pr04c==2
replace beta_annual=10/15 if pr04a==1 & pr04b==2 & pr04c==1
replace beta_annual=10/20 if pr04a==1 & pr04b==1 & pr04d==2 & pr04e==2
replace beta_annual=10/30 if pr04a==1 & pr04b==1 & pr04d==2 & pr04e==1

gen beta_monthly_a=(beta_annual)^(1/12)


keep  fac_3b gen education  salario_diario numempleados horas_sem ///
	trabajador_base social_security age c_aguinaldo c_utilidades c_vacaciones ///
	c_horasextra annual_bonus giro beta_*
	
	
save ".\DB\mxfls.dta", replace	


