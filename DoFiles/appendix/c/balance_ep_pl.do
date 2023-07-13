/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	balance_ep_pl
* Author:	Isaac M 
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: November. 9, 2021  
* Modifications: 	
* Files used:     
		- phase_1.dta
		- phase_2.dta
* Files created:  
		- Balance_EP.xlsx
* Purpose: Balance table on basic and strategic variables.

*******************************************************************************/
*/

local balance_var trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley gen p_actor p_ractor p_dem p_rdem

* Phase 2
********************************************************************************
use ".\DB\phase_2.dta", clear
keep junta exp anio fecha treatment phase `balance_var' 
tempfile p2
save `p2', replace

* Phase 1
********************************************************************************
use ".\DB\phase_1.dta" , clear	
keep junta exp anio fecha treatment phase `balance_var'
append using `p2'

********************************************************************************
*Drop duplicates
sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if (renglon==1 & inlist(phase,1,2)) | phase==3

********************************************************************************
				
*define clusters
egen gp=group(exp anio)
egen fechaJunta=group(junta fecha)
replace fechaJunta=fechaJunta+1481 
gen cluster_v=.
replace cluster_v=gp if phase==1
replace cluster_v=fechaJunta if phase==2 
	
************************************EP******************************************
********************************************************************************

putexcel set ".\Tables\appendix\c\Balance_EP.xlsx", sheet("Balance_EP") modify

***************************** Balance by EP=1 **********************************
orth_out `balance_var' if p_actor==1,  ///
				by(treatment) vce(cluster cluster_v)   bdec(3)  count pcompare  covariates(phase)
	
qui putexcel N6=matrix(r(matrix)) 
		
reg treatment trabajador_base c_antiguedad abogado_pub indem salario_diario prima_antig min_ley  p_ractor p_dem p_rdem  if p_actor==1, vce(cluster cluster_v)
local pval = Ftail(e(df_m), e(df_r), e(F))
qui putexcel P18 = `pval' 
	
***************************** Balance by EP=0 **********************************
orth_out `balance_var' if p_actor==0,  ///
				by(treatment)  vce(cluster cluster_v)   bdec(3)  count  pcompare covariates(phase)
				
qui putexcel R6=matrix(r(matrix)) 

reg treatment trabajador_base c_antiguedad  indem salario_diario prima_antig min_ley abogado_pub p_ractor p_dem p_rdem  if p_actor==0, vce(cluster cluster_v)
local pval = Ftail(e(df_m), e(df_r), e(F))
qui putexcel T18 = `pval' 

*****************************  Balance by EP  **********************************
orth_out `balance_var' ,  ///
				by(p_actor)  bdec(3)  count  pcompare covariates(phase)
				
qui putexcel V6=matrix(r(matrix)) 

reg p_actor trabajador_base c_antiguedad  indem salario_diario prima_antig min_ley abogado_pub p_ractor p_dem p_rdem , 
local pval = Ftail(e(df_m), e(df_r), e(F))
qui putexcel Y18 = `pval' 

************************************PL******************************************
********************************************************************************

putexcel set ".\Tables\appendix\c\Balance_EP.xlsx", sheet("Balance_PL") modify

***************************** Balance by PL=1 **********************************
orth_out `balance_var' if abogado_pub==1,  ///
				by(treatment)  vce(cluster cluster_v)   bdec(3)  count pcompare covariates(phase)
				
qui putexcel N6=matrix(r(matrix)) 
 
reg treatment trabajador_base c_antiguedad p_actor indem salario_diario prima_antig min_ley  p_ractor p_dem p_rdem  if abogado_pub==1, vce(cluster cluster_v)
local pval = Ftail(e(df_m), e(df_r), e(F))
qui putexcel P18 = `pval' 
	
***************************** Balance by PL=0 **********************************
orth_out `balance_var' if abogado_pub==0,  ///
				by(treatment)  vce(cluster cluster_v)   bdec(3)  count pcompare covariates(phase)
				
qui putexcel R6=matrix(r(matrix)) 
		
reg treatment trabajador_base c_antiguedad  indem salario_diario prima_antig min_ley p_actor p_ractor p_dem p_rdem  if abogado_pub==0, vce(cluster cluster_v)
local pval = Ftail(e(df_m), e(df_r), e(F))
qui putexcel T18 = `pval' 

*****************************  Balance by PL  **********************************
orth_out `balance_var' ,  ///
				by(abogado_pub)  bdec(3)  count  pcompare covariates(phase)
				
qui putexcel V6=matrix(r(matrix)) 

reg abogado_pub trabajador_base c_antiguedad  indem salario_diario prima_antig min_ley p_actor p_ractor p_dem p_rdem , 
local pval = Ftail(e(df_m), e(df_r), e(F))
qui putexcel Y18 = `pval' 
