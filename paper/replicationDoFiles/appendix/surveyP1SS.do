/* Survey SS
*/

use "./DB/pilot_operation.dta" , clear	
drop renglon
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment
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

keep folio abogado_pub

tempfile selectedCasefiles
save `selectedCasefiles'
/* Actores */

putexcel set ".\Tables\surveySS_dummies.xlsx", sheet("Actor") modify
use "./DB/Append Encuesta Inicial Actor.dta", clear
merge 1:1 folio using `selectedCasefiles', nogen keep(3) 

//1) Age
putexcel A5 = ("Age")
qui sum Age
putexcel B5 = (r(mean))
putexcel B6 = (r(sd))
putexcel B7 = (r(N))

// 5) Number of employees
gen empleados50 = numempleados <=2
replace empleados50 = . if missing(numempleados)

putexcel A8 = ("Less than 50 employees") 
qui sum empleados50
putexcel B8 = (r(mean))
putexcel B9 = (r(sd))
putexcel B10= (r(N))

// 6) Percentage of what is obtained
putexcel A11 = ("Percentage of what is obtained")
qui sum porc_pago
putexcel B11 = (r(mean))
putexcel B12 = (r(sd))
putexcel B13 = (r(N))

// 7) Probability of other part of winning
putexcel A14 = ("Probability of winning")
qui sum probotro
putexcel B14 = (r(mean))
putexcel B15 = (r(sd))
putexcel B16 = (r(N))

// 8) Education
gen masQuePrepa = A_1_2<4
qui sum masQuePrepa
putexcel A17 = ("More than secondary education")
putexcel B17 = (r(mean))
putexcel B18 = (r(sd))
putexcel B19 = (r(N))

// 10) Changed lawyer
putexcel a20 =("Have you changed lawyer during trial?")
qui sum A_4_6
putexcel B20 = (r(mean))
putexcel B21 = (r(sd))
putexcel B22 = (r(N))

//11) Probability of winning trial
putexcel a23 = ("Probability of winning trial")
qui sum A_5_1
putexcel B23 = (r(mean))
putexcel B24 = (r(sd))
putexcel B25 = (r(N))

// 12) Most probable amount
putexcel a26 = ("Most probable amount")
qui sum A_5_5
putexcel B26 = (r(mean))
putexcel B27 = (r(sd))
putexcel B28 = (r(N))

// 13) Most probable time
putexcel a29 = ("Most probable time")
qui sum A_5_8
putexcel B29 = (r(mean))
putexcel B30 = (r(sd))
putexcel B31 = (r(N))

// 14) How well were you treated?
gen treatedWell = A_6_1<3
replace treatedWell = . if missing(A_6_1)

putexcel a32 = ("How well were you treated?")
qui sum treatedWell
putexcel B32 = (r(mean))
putexcel B33 = (r(sd))
putexcel B34 = (r(N))

// 15) How common is the company mistreat its employees?
gen firmMistreats = A_6_2<3
replace firmMistreats = . if missing(A_6_2)

putexcel a35 = ("The company mistreats its employees")
qui sum firmMistreats
putexcel B36 = (r(mean))
putexcel B37 = (r(sd))
putexcel B38 = (r(N))

// 16) Level of anger with company
gen veryAngry = A_6_3 < 2
replace veryAngry = . if missing(A_6_3)

putexcel A39 = ("Is very angry with company")
qui sum veryAngry
putexcel B39 = (r(mean))
putexcel B40 = (r(sd))
putexcel B41 = (r(N))

// 17) Repeated player
putexcel A42 = ("Repeated player")
sum A_7_3
putexcel B42 = (r(mean))
putexcel B43 = (r(sd))
putexcel B44 = (r(N))

// Currently employed
putexcel A45 = ("Currently employed")
sum A_9_1 
putexcel B45 = (r(mean))
putexcel B46 = (r(sd))
putexcel B47 = (r(N))

// Looking for a job
putexcel A48 = ("Looking for a job")
sum A_9_2
putexcel B48 = (r(mean))
putexcel B49 = (r(sd))
putexcel B50 = (r(N))
 
// Probability of finding a job in next 3 months
putexcel A51 = ("Probability of finding a job in next 3 months")
sum A_9_3
putexcel B51 = (r(mean))
putexcel B52 = (r(sd))
putexcel B53 = (r(N))

******************
/* Actor lawyer */
******************
putexcel set ".\Tables\surveySS_dummies.xlsx", sheet("Lawyers") modify
use "./DB/Append Encuesta Inicial Representante Actor.dta", clear
merge m:1 folio using `selectedCasefiles', nogen keep(3) 

//1) Age
putexcel A5 = ("Age") 
qui sum Age
putexcel B5 = (r(mean))
putexcel B6 = (r(sd))
putexcel B7 = (r(N))

// 2) Tenure
putexcel A8 = ("Tenure") 
qui sum Tenure
putexcel B8 = (r(mean))
putexcel B9 = (r(sd))
putexcel B10 = (r(N))

// 3) Number of lawsuits
gen more100ls = litigiosha==4
replace more100ls = . if missing(litigiosha)

putexcel A11 = ("More than 100 historical cases")
qui sum more100ls
putexcel B11 = (r(mean))
putexcel B12 = (r(sd))
putexcel B13 = (r(N))

// 4) Current number of lawsuits
gen more30hls = litigiosesta==4
replace more30hls = . if missing(litigiosesta)

putexcel A14 = ("More than 30 current lawsuits")
qui sum more30hls
putexcel B14 = (r(mean))
putexcel B15 = (r(sd))
putexcel B16 = (r(N))

// 5) Number of employees
gen empleados50 = numempleados <=2
replace empleados50 = . if missing(numempleados)

replace empleados50 = . if missing(numempleados)
putexcel A17 = ("Less than 50 employees") 
qui sum empleados50
putexcel B17 = (r(mean))
putexcel B18 = (r(sd))
putexcel B19= (r(N))

// 6) Percentage of what is obtained
putexcel A20 = ("Percentage of what is obtained")
qui sum porc_pago
putexcel B20 = (r(mean))
putexcel B21 = (r(sd))
putexcel B22 = (r(N))

// 7) Probability of other part of winning
putexcel A23 = ("Probability of the other part winning")
qui sum probotro
putexcel B23 = (r(mean))
putexcel B24 = (r(sd))
putexcel B25 = (r(N))

//10) Probability of winning trial
putexcel A26 = ("Probability of winning trial")
qui sum A_5_1
putexcel B26 = (r(mean))
putexcel B27 = (r(sd))
putexcel B28 = (r(N))

// 11) Most probable amount
putexcel A29 = ("Most probable amount")
qui sum A_5_5
putexcel B29 = (r(mean))
putexcel B30 = (r(sd))
putexcel B31 = (r(N))

// 12) Most probable time
putexcel A32 = ("Most probable time")
qui sum A_5_8
putexcel B32 = (r(mean))
putexcel B33 = (r(sd))
putexcel B34 = (r(N))

**********************
/* Defendant lawyer */
**********************

use "./DB/Append Encuesta Inicial Representante Demandado.dta", clear
merge m:1 folio using `selectedCasefiles', nogen keep(3) 

//1) Age
putexcel A5 = ("Age") 
qui sum Age
putexcel C5 = (r(mean))
putexcel C6 = (r(sd))
putexcel C7 = (r(N))

// 2) Tenure
putexcel A8 = ("Tenure") 
qui sum Tenure
putexcel C8 = (r(mean))
putexcel C9 = (r(sd))
putexcel C10 = (r(N))

// 3) Number of lawsuits
gen more100ls = litigiosha==4
replace more100ls = . if missing(litigiosha)

putexcel A11 = ("More than 100 historical cases")
qui sum more100ls
putexcel C11 = (r(mean))
putexcel C12 = (r(sd))
putexcel C13 = (r(N))

// 4) Current number of lawsuits
gen more30hls = litigiosesta==4
replace more30hls = . if missing(litigiosesta)

putexcel A14 = ("More than 30 current lawsuits")
qui sum more30hls
putexcel C14 = (r(mean))
putexcel C15 = (r(sd))
putexcel C16 = (r(N))

// 5) Number of employees
gen empleados50 = numempleados <=2
replace empleados50 = . if missing(numempleados)

replace empleados50 = . if missing(numempleados)
putexcel A17 = ("Less than 50 employees") 
qui sum empleados50
putexcel C17 = (r(mean))
putexcel C18 = (r(sd))
putexcel C19= (r(N))

// 7) Probability of other part of winning
putexcel A23 = ("Probability of the other part winning")
qui sum probotro
putexcel C23 = (r(mean))
putexcel C24 = (r(sd))
putexcel C25 = (r(N))

//10) Probability of winning trial
putexcel A26 = ("Probability of winning trial")
qui sum A_5_1
putexcel C26 = (r(mean))
putexcel C27 = (r(sd))
putexcel C28 = (r(N))

// 11) Most probable amount
putexcel A29 = ("Most probable amount")
qui sum A_5_5
putexcel C29 = (r(mean))
putexcel C30 = (r(sd))
putexcel C31 = (r(N))

// 12) Most probable time
putexcel A32 = ("Most probable time")
qui sum A_5_8
putexcel C32 = (r(mean))
putexcel C33 = (r(sd))
putexcel C34 = (r(N))
