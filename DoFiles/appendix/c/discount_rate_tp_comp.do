
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	discount_rate_tp_comp
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification:
* Modifications:		
* Files used:     
		- iiib_pr.dta
		- hh09w_b3b.dta 
		- Append Encuesta Inicial Actor.dta
		- Append Encuesta Inicial Representante Actor.dta
		- Append Encuesta Inicial Representante Demandado.dta
		- phase_1.dta

* Files created:  
		-

* Purpose: Comparison of discount rates for Phase 1 data and survey data from the MxFLS 
(Mexican Family Life Survey- a longitudinal survey in Mexico that follows 
individuals across rounds).

*******************************************************************************/
*/

*MxFLS
********************************************************************************
use "$directorio/DB/iiib_pr.dta", clear
*Expansion factor
merge 1:m folio ls using "$directorio/DB/hh09w_b3b.dta", nogen

*Time preference
gen beta_monthly=.
replace beta_monthly=1 if pr03a==2
replace beta_monthly=10/12 if pr03a==1 & pr03b==2 & pr03c==2
replace beta_monthly=10/15 if pr03a==1 & pr03b==2 & pr03c==1
replace beta_monthly=10/20 if pr03a==1 & pr03b==1 & pr03d==2 & pr03e==2
replace beta_monthly=10/30 if pr03a==1 & pr03b==1 & pr03d==2 & pr03e==1

keep  fac_3b beta_monthly
tempfile temp_mxfls
save `temp_mxfls'

*Plaintiff's Lawyer
********************************************************************************
use "$directorio/DB/Append Encuesta Inicial Representante Actor.dta" , clear
merge m:1 folio using "./DB/phase_1.dta", keepusing(folio) keep(3) 

*Time Preferences
gen beta_monthly=.
replace beta_monthly=1 if RA_6_2_1==2 & RA_6_2_2==. 
replace beta_monthly=10/12 if RA_6_2_1==1 & RA_6_2_2==2 & RA_6_2_3==.
replace beta_monthly=10/15 if RA_6_2_1==1 & RA_6_2_2==1 & RA_6_2_3==2 & RA_6_2_4==.
replace beta_monthly=10/20 if RA_6_2_1==1 & RA_6_2_2==1 & RA_6_2_3==1 & RA_6_2_4==2 & RA_6_2_5==.
replace beta_monthly=10/30 if RA_6_2_1==1 & RA_6_2_2==1 & RA_6_2_3==1 & RA_6_2_4==1 & !missing(RA_6_2_5)

*Categorical party: Party=2 - employee lawyer
gen party=2

keep folio beta_monthly party 
tempfile temp_2
save `temp_2'

*Defendant's Lawyer
********************************************************************************
use "$directorio/DB/Append Encuesta Inicial Representante Demandado.dta" , clear
merge m:1 folio using "./DB/phase_1.dta", keepusing(folio) keep(3) 

*Time Preferences
gen beta_monthly=.
replace beta_monthly=1 if RD6_2_1==2 & RD6_2_2==. 
replace beta_monthly=10/12 if RD6_2_1==1 & RD6_2_2==2 & RD6_2_3==.
replace beta_monthly=10/15 if RD6_2_1==1 & RD6_2_2==1 & RD6_2_3==2 & RD6_2_4==.
replace beta_monthly=10/20 if RD6_2_1==1 & RD6_2_2==1 & RD6_2_3==1 & RD6_2_4==2 & RD6_2_5==.
replace beta_monthly=10/30 if RD6_2_1==1 & RD6_2_2==1 & RD6_2_3==1 & RD6_2_4==1 & !missing(RD6_2_5)

*Categorical party: Party=3 - firm lawyer
gen party=3

keep folio beta_monthly party 
tempfile temp_3
save `temp_3'

*Plaintiff
********************************************************************************
use "$directorio/DB/Append Encuesta Inicial Actor.dta" , clear
merge m:1 folio using "./DB/phase_1.dta", keepusing(folio) keep(3) 

*Time Preferences
gen beta_monthly=.
replace beta_monthly=1 if A_10_2_1==2 & A_10_2_2==. 
replace beta_monthly=10/12 if A_10_2_1==1 & A_10_2_2==2 & A_10_2_3==.
replace beta_monthly=10/15 if A_10_2_1==1 & A_10_2_2==1 & A_10_2_3==2 & A_10_2_4==.
replace beta_monthly=10/20 if A_10_2_1==1 & A_10_2_2==1 & A_10_2_3==1 & A_10_2_4==2 & A_10_2_5==.
replace beta_monthly=10/30 if A_10_2_1==1 & A_10_2_2==1 & A_10_2_3==1 & A_10_2_4==1 & !missing(A_10_2_5)

*Categorical party: Party=1 - employee
gen party=1

keep folio beta_monthly party 
*Appending
append using `temp_2'
append using `temp_3'

*Identify Datasets
gen experiment=1
	
append using `temp_mxfls'
replace experiment=0 if missing(experiment)
replace fac_3b=1 if missing(fac_3b)
replace party=0 if missing(party)

label define party  0 "MxFLS" 1 "E" 2 "EL" 3 "FL"
label values party party
	
********************************************************************************
********************************************************************************

levelsof beta_monthly, local(levels) 
local i=1
foreach l of local levels {
	gen tp_`i'=(beta_monthly==`l') if !missing(beta_monthly)
	gen a_`i'=`l'
	local i=`i'+1
	}
	
	
*Aux graphing variables
gen n=_n if _n<=3
gen m=.
forvalues j=1/30 {
	replace m=100*`j' in `j'
	}

*Results
local beta1=0.33
local beta2=0.5
local beta3=0.66
local beta4=0.83
local beta5=1


*********************************	   
*Probability Linear Model
*********************************
collapse (mean) a_* ///
			(mean) mean_tp_1 =tp_1  (sd) sd_tp_1=tp_1 (count) n_tp_1=tp_1 ///
			(mean) mean_tp_2 =tp_2  (sd) sd_tp_2=tp_2 (count) n_tp_2=tp_2 ///
			(mean) mean_tp_3 =tp_3  (sd) sd_tp_3=tp_3 (count) n_tp_3=tp_3 ///
			(mean) mean_tp_4 =tp_4  (sd) sd_tp_4=tp_4 (count) n_tp_4=tp_4 ///
			(mean) mean_tp_5 =tp_5  (sd) sd_tp_5=tp_5 (count) n_tp_5=tp_5 ///
		[fw=fac_3b], by(party)

*CI (truncated)
forvalues i=1/5 {			
	generate hi_tp_`i' = max( min (mean_tp_`i' + invttail(n_tp_`i'-1,0.05)*(sd_tp_`i' / sqrt(n_tp_`i')),1),0) if n_tp_`i'!=0
	generate low_tp_`i' = max( min (mean_tp_`i' - invttail(n_tp_`i'-1,0.05)*(sd_tp_`i' / sqrt(n_tp_`i')),1),0) if n_tp_`i'!=0
	}	
		
*Aux variables to graph in x pos
forvalues i=1/24 {
		gen v`i'=`i'
		}
		
twoway (bar mean_tp_1 v1 if party==0, color(black)  ) ///
		   (bar mean_tp_1 v2 if party==1, color(gs4) lcolor(black)) ///
		   (bar mean_tp_2 v6 if party==0,color(black)) ///
		   (bar mean_tp_2 v7 if party==1, color(gs4) lcolor(black)) ///
		   (bar mean_tp_3 v11 if party==0,color(black)) ///
		   (bar mean_tp_3 v12 if party==1, color(gs4) lcolor(black)) ///
		   (bar mean_tp_4 v16 if party==0,color(black)) ///
		   (bar mean_tp_4 v17 if party==1, color(gs4) lcolor(black)) ///
		   (bar mean_tp_5 v21 if party==0,color(black)) ///
		   (bar mean_tp_5 v22 if party==1, color(gs4) lcolor(black)) ///
		   (rcap hi_tp_1 low_tp_1 v1 if party==0, color(white) lpattern(solid)  ) ///
		   (rcap hi_tp_1 low_tp_1 v2 if party==1, color(black) lpattern(solid)) ///	   
		   (rcap hi_tp_2 low_tp_2 v6 if party==0,color(white) lpattern(solid)) ///
		   (rcap hi_tp_2 low_tp_2 v7 if party==1, color(black) lpattern(solid)) ///
		   (rcap hi_tp_3 low_tp_3 v11 if party==0,color(white) lpattern(solid)) ///
		   (rcap hi_tp_3 low_tp_3 v12 if party==1, color(black) lpattern(solid)) ///
		   (rcap hi_tp_4 low_tp_4 v16 if party==0,color(white) lpattern(solid)) ///
		   (rcap hi_tp_4 low_tp_4 v17 if party==1, color(black) lpattern(solid)) ///
		   (rcap hi_tp_5 low_tp_5 v21 if party==0,color(white) lpattern(solid)) ///
		   (rcap hi_tp_5 low_tp_5 v22 if party==1, color(black) lpattern(solid)) , ///
		   legend(order( 1 "MxFLS" 2 "J7-employee") rows(1) pos(6)) ///
		   xlabel( 2.5 "0.33" 7.5 "0.5" 12.5 "0.66" 17.5 "0.83" 22.5 "1", noticks) ///
		   ytitle("Percentage") title("Time preference") ///
		    graphregion(color(white)) 
graph export "./Figures/appendix/c/discount_rate_tp_comp.tif", replace 
 
	