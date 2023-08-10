
********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	survey_var_ss
* Author: Isaac Meza
* Machine:	 											
* Date of creation:	
* Last date of modification: 
* Modifications:		
* Files used:     
		- Append Encuesta Inicial Actor.dta
		- Append Encuesta Inicial Representante Actor.dta
		- Append Encuesta Inicial Representante Demandado.dta
* Files created:  
		- survey_var_ss.xlsx

* Purpose: Summary statistics of survey variables 
*******************************************************************************/
*/

*Plaintiff
********************************************************************************
use "./DB/Append Encuesta Inicial Actor.dta", clear
merge m:1 folio using "./DB/phase_1.dta", keepusing(folio) keep(3) 
putexcel set "./Tables/appendix/a/survey_var_ss.xlsx", sheet("Plaintiff") modify

// Age
putexcel A5 = ("Age")
gen age = (fecha - A_1_1)/365
sum age
putexcel B5 = (r(mean))
putexcel B6 = (r(sd))
putexcel B7 = (r(N))

// Number of employees
putexcel A8 = ("Firm had less than 50 employees") 
gen empleados50 = inlist(A_3_1,1,2) if !missing(A_3_1)
sum empleados50
putexcel B8 = (r(mean))
putexcel B9 = (r(sd))
putexcel B10= (r(N))

// Probability of winning trial
putexcel A11 = ("Expected probability of winning trial")
sum A_5_1
putexcel B11 = (r(mean))
putexcel B12 = (r(sd))
putexcel B13 = (r(N))

// Probability of other part of winning
putexcel A14 = ("Expected probability winning the trial by the other party")
sum A_5_2
putexcel B14 = (r(mean))
putexcel B15 = (r(sd))
putexcel B16 = (r(N))

// Percentage of what is obtained
putexcel A17 = ("Percentage paid to lawyer")
sum A_4_2_2 
putexcel B17 = (r(mean))
putexcel B18 = (r(sd))
putexcel B19 = (r(N))

// Education
putexcel A20 = ("More than secondary education")
gen masprepa = A_1_2==4
sum masprepa
putexcel B20 = (r(mean))
putexcel B21 = (r(sd))
putexcel B22 = (r(N))

// How well were you treated?
putexcel A23 = ("Was treated poorly/very poorly by former employer")
gen treatedBad = A_6_1>2 if !missing(A_6_1)
sum treatedBad
putexcel B23 = (r(mean))
putexcel B24 = (r(sd))
putexcel B25 = (r(N))

// Most probable amount
putexcel A26 = ("Mean / Median expected recovery amount (Pesos)")
sum A_5_5, d
putexcel B26 = (r(mean))
putexcel C26 = (r(p50))
putexcel B27 = (r(sd))
putexcel B28 = (r(N))

// Most probable time
putexcel A29 = ("Expected duration (years)")
sum A_5_8
putexcel B29 = (r(mean))
putexcel B30 = (r(sd))
putexcel B31 = (r(N))

// Changed lawyer
putexcel A32 =("Has changed lawyer during trial")
sum A_4_6
putexcel B32 = (r(mean))
putexcel B33 = (r(sd))
putexcel B34 = (r(N))


*Plaintiff's Lawyer
********************************************************************************
use "./DB/Append Encuesta Inicial Representante Actor.dta", clear
merge m:1 folio using "./DB/phase_1.dta", keepusing(folio) keep(3) 
putexcel set "./Tables/appendix/a/survey_var_ss.xlsx", sheet("Lawyers") modify

// Age
putexcel A5 = ("Age") 
gen age = (fecha - RA_1_1)/365
sum age
putexcel B5 = (r(mean))
putexcel B6 = (r(sd))
putexcel B7 = (r(N))

// Tenure
putexcel A8 = ("Tenure") 
replace RA_1_5 = abs(RA_1_5) if RA_1_5<0
replace RA_1_5 = 1990 if RA_1_5==90
gen tenure = 2022-RA_1_5
sum tenure
putexcel B8 = (r(mean))
putexcel B9 = (r(sd))
putexcel B10 = (r(N))

// Number of lawsuits
putexcel A11 = ("More than 100 historical cases")
gen more100ls = RA_1_6==4 if !missing(RA_1_6)
sum more100ls
putexcel B11 = (r(mean))
putexcel B12 = (r(sd))
putexcel B13 = (r(N))

// Current number of lawsuits
putexcel A14 = ("More than 30 current lawsuits")
gen more30cls = RA_1_7==4 if !missing(RA_1_7)
sum more30cls
putexcel B14 = (r(mean))
putexcel B15 = (r(sd))
putexcel B16 = (r(N))

// Number of employees
putexcel A17 = ("Less than 50 employees") 
gen empleados50 = inlist(RA_3_1,1,2) if !missing(RA_3_1)
sum empleados50
putexcel B17 = (r(mean))
putexcel B18 = (r(sd))
putexcel B19= (r(N))

// Percentage of what is obtained
putexcel A20 = ("Percentage paid to lawyer")
sum RA_4_1_2
putexcel B20 = (r(mean))
putexcel B21 = (r(sd))
putexcel B22 = (r(N))

// Probability of winning trial
putexcel A23 = ("Expected probability of winning trial")
sum RA_5_1
putexcel B23 = (r(mean))
putexcel B24 = (r(sd))
putexcel B25 = (r(N))

// Most probable amount
putexcel A26 = ("Mean / Median expected recovery amount (Pesos)")
sum RA_5_5, d
putexcel B26 = (r(mean))
putexcel C26 = (r(p50))
putexcel B27  = (r(sd))
putexcel B28 = (r(N))

// Most probable time
putexcel A29 = ("Expected duration (years)")
sum RA_5_8
putexcel B29 = (r(mean))
putexcel B30 = (r(sd))
putexcel B31 = (r(N))

*Defendant's Lawyer
********************************************************************************
use "./DB/Append Encuesta Inicial Representante Demandado.dta", clear
merge m:1 folio using "./DB/phase_1.dta", keepusing(folio) keep(3) 

// Age
putexcel A5 = ("Age") 
gen age = (fecha - RD1_1)/365
sum age
putexcel D5 = (r(mean))
putexcel D6 = (r(sd))
putexcel D7 = (r(N))

// Tenure
putexcel A8 = ("Tenure") 
replace RD1_5 = . if RD1_5<=20
gen tenure = 2022-RD1_5
sum tenure
putexcel D8 = (r(mean))
putexcel D9 = (r(sd))
putexcel D10 = (r(N))

// Number of lawsuits
putexcel A11 = ("More than 100 historical cases")
gen more100ls = RD1_6==4 if !missing(RD1_6)
sum more100ls
putexcel D11 = (r(mean))
putexcel D12 = (r(sd))
putexcel D13 = (r(N))

// Current number of lawsuits
putexcel A14 = ("More than 30 current lawsuits")
gen more30cls = RD1_7==4 if !missing(RD1_7)
sum more30cls
putexcel D14 = (r(mean))
putexcel D15 = (r(sd))
putexcel D16 = (r(N))

// Number of employees
putexcel A17 = ("Less than 50 employees") 
gen empleados50 = inlist(RD3_1,1,2) if !missing(RD3_1)
sum empleados50
putexcel D17 = (r(mean))
putexcel D18 = (r(sd))
putexcel D19= (r(N))

// Probability of winning trial
putexcel A23 = ("Expected probability of winning trial")
sum RD5_1_1
putexcel D23 = (r(mean))
putexcel D24 = (r(sd))
putexcel D25 = (r(N))

// Most probable amount
putexcel A26 = ("Mean / Median expected recovery amount (Pesos)")
sum RD5_5, d
putexcel D26 = (r(mean))
putexcel E26 = (r(p50))
putexcel D27  = (r(sd))
putexcel D28 = (r(N))

// Most probable time
putexcel A29 = ("Expected duration (years)")
sum RD5_8
putexcel D29 = (r(mean))
putexcel D30 = (r(sd))
putexcel D31 = (r(N))