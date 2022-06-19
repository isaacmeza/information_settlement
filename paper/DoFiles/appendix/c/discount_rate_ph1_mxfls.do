/*Figure C5: Discount rate for Phase 1 and MxFLS*/
/*
Comparison of discount rates for Phase 1 data and survey data from the MxFLS 
(Mexican Family Life Survey- a longitudinal survey in Mexico that follows 
individuals across rounds).
*/

use "$sharelatex\DB\time_pref.dta", replace


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
		   legend(order( 1 "MxFLS" 2 "J7-employee")) ///
		   xlabel( 2.5 "0.33" 7.5 "0.5" 12.5 "0.66" 17.5 "0.83" 22.5 "1", noticks) ///
		   ytitle("Percentage") title("Time preference") ///
		   scheme(s2mono) graphregion(color(white)) 
graph export "$sharelatex\Figuras\discount_rate_tp_comp.pdf", replace 
 
