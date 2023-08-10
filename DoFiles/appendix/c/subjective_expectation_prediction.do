
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	subjective_expectation_prediction
* Author:	Isaac M 
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- Append Encuesta Inicial Actor.dta
		- Append Encuesta Inicial Representante Actor.dta
		- Append Encuesta Inicial Representante Demandado.dta
* Files created:  


* Purpose: Subjective expectation minus prediction - Overconfidence plots 

*******************************************************************************/
*/

*Plaintiff
********************************************************************************
use "./DB/Append Encuesta Inicial Actor.dta", clear
merge m:1 folio using "./DB/phase_1.dta", keepusing(folio comp_esp prob_esp) keep(3) 

*Outliers
xtile perc=A_5_5, nq(100)
drop if perc>=99
*Money
gen diff_amount=(A_5_5-comp_esp)/1000
*Probability
rename A_5_1 Prob_win
gen diff_prob=Prob_win-prob_esp*100


qui su diff_amount
twoway (hist diff_amount if diff_amount<160 & diff_amount>=-50 , w(3) percent xline(`r(mean)', lcolor(gs6) lpattern(solid) lwidth(thick))) ///
		,  graphregion(color(white)) ///
	title("Amount") xtitle("Survey - Calculator in thousand pesos") ///
	legend(off) name(amount, replace)
graph export "./Figures/appendix/c/diff_amt_e.tif", replace 

qui su diff_prob
twoway (hist diff_prob, w(5) percent xline(`r(mean)', lcolor(gs6) lpattern(solid) lwidth(thick))) ///
		,  graphregion(color(white)) ///
	title("Probability") xtitle("Survey -  Calculator in % points") ///
	legend(off) name(prob, replace)
graph export "./Figures/appendix/c/diff_prob_e.tif", replace 
	

*Plaintiff's Lawyer
********************************************************************************
use "./DB/Append Encuesta Inicial Representante Actor.dta", clear
merge m:1 folio using "./DB/phase_1.dta", keepusing(folio comp_esp prob_esp) keep(3) 

*Outliers
xtile perc=RA_5_5, nq(100)
drop if perc>=99
*Money
gen diff_amount=(RA_5_5-comp_esp)/1000
*Probability
rename RA_5_1 Prob_win
gen diff_prob=Prob_win-prob_esp*100


qui su diff_amount
twoway (hist diff_amount if diff_amount<160 & diff_amount>=-50 , w(3) percent xline(`r(mean)', lcolor(gs6) lpattern(solid) lwidth(thick))) ///
		,  graphregion(color(white)) ///
	title("Amount") xtitle("Survey - Calculator in thousand pesos") ///
	legend(off) name(amount, replace)
graph export "./Figures/appendix/c/diff_amt_el.tif", replace 


qui su diff_prob
twoway (hist diff_prob, w(5) percent xline(`r(mean)', lcolor(gs6) lpattern(solid) lwidth(thick))) ///
		,  graphregion(color(white)) ///
	title("Probability") xtitle("Survey -  Calculator in % points") ///
	legend(off) name(prob, replace)
graph export "./Figures/appendix/c/diff_prob_el.tif", replace 
	

*Defendant's Lawyer
********************************************************************************
use "./DB/Append Encuesta Inicial Representante Demandado.dta", clear
merge m:1 folio using "./DB/phase_1.dta", keepusing(folio comp_esp prob_esp) keep(3) 

*Outliers
xtile perc=RD5_5, nq(100)
drop if perc>=99
*Money
gen diff_amount=(RD5_5-comp_esp)/1000
*Probability
rename RD5_1_1 Prob_win
gen diff_prob=Prob_win-prob_esp*100


qui su diff_amount
twoway (hist diff_amount if diff_amount<160 & diff_amount>=-50 , w(3) percent xline(`r(mean)', lcolor(gs6) lpattern(solid) lwidth(thick))) ///
		,  graphregion(color(white)) ///
	title("Amount") xtitle("Survey - Calculator in thousand pesos") ///
	legend(off) name(amount, replace)
graph export "./Figures/appendix/c/diff_amt_fl.tif", replace 

qui su diff_prob
twoway (hist diff_prob, w(5) percent xline(`r(mean)', lcolor(gs6) lpattern(solid) lwidth(thick))) ///
		,  graphregion(color(white)) ///
	title("Probability") xtitle("Survey -  Calculator in % points") ///
	legend(off) name(prob, replace)
graph export "./Figures/appendix/c/diff_prob_fl.tif", replace 

	
