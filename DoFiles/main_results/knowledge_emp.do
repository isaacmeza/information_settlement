/*Figure 4. :  Knowledge about Law and their Own Claims in Lawsuit*/
/* 
knowledge of the law --panel (a) and (b)--
*/

use "$sharelatex\DB\pilot_casefiles_wod.dta", clear	
merge m:1 folio using  "$sharelatex/Raw/Append Encuesta Inicial Actor.dta" , keep( 2 3)




*Histogram what the law says
	*A_7_1=knows
gen correct_sabe=( A_7_1_O==90) 
	
preserve	
collapse (mean) mean_1=A_7_1 (sd) sd_1=A_7_1  (count) n_1=A_7_1 ///
		(mean) mean_2=correct_sabe (sd) sd_2=correct_sabe  (count) n_2=correct_sabe 
		
		
gen id=1
reshape long mean_ sd_ n_, i(id) j(sabe)

label define sabe 1 "Knows" 2 "Correctly knows" , replace
label values sabe sabe

rename mean_ mean_total
rename sd_ sd_total
rename n_ n_total

tempfile total
save `total'
restore

preserve
collapse (mean) mean_1=A_7_1 (sd) sd_1=A_7_1  (count) n_1=A_7_1 ///
		(mean) mean_2=correct_sabe (sd) sd_2=correct_sabe  (count) n_2=correct_sabe ///
		, by(A_1_2)
		
reshape long mean_ sd_ n_, i(A_1_2) j(sabe)

label define sabe 1 "Knows" 2 "Correctly knows" , replace
label values sabe sabe	

tempfile education
save `education'
restore


preserve
collapse (mean) mean_1=A_7_1 (sd) sd_1=A_7_1  (count) n_1=A_7_1 ///
		(mean) mean_2=correct_sabe (sd) sd_2=correct_sabe  (count) n_2=correct_sabe ///
		, by(A_7_3)
	
reshape long mean_ sd_ n_, i(A_7_3) j(sabe)

label define sabe 1 "Knows" 2 "Correctly knows" , replace
label values sabe sabe	
	
	
tempfile repeated_p
save `repeated_p'
restore


use `education', clear

preserve
keep if A_1_2==1
rename mean_ mean_prim
rename sd_ sd_prim
rename n_ n_prim

tempfile prim
save `prim'
restore

preserve
keep if A_1_2==2
rename mean_ mean_sec
rename sd_ sd_sec
rename n_ n_sec

tempfile sec
save `sec'
restore

preserve
keep if A_1_2==3
rename mean_ mean_prepa
rename sd_ sd_prepa
rename n_ n_prepa

tempfile prepa
save `prepa'
restore

keep if A_1_2==4
rename mean_ mean_masprep
rename sd_ sd_masprep
rename n_ n_masprep

tempfile masprep
save `masprep'



use `repeated_p', clear

preserve
keep if A_7_3==0
rename mean_ mean_no
rename sd_ sd_no
rename n_ n_no

tempfile no
save `no'
restore


keep if A_7_3==1
rename mean_ mean_yes
rename sd_ sd_yes
rename n_ n_yes

tempfile yes
save `yes'



use `total', clear
merge 1:1 sabe using `prim', nogen
merge 1:1 sabe using `sec', nogen
merge 1:1 sabe using `prepa', nogen
merge 1:1 sabe using `masprep', nogen

merge 1:1 sabe using `no', nogen
merge 1:1 sabe using `yes', nogen

drop id A_*	
	
	
	
*CI (truncated)
	*Total
generate hi_total = max( min (mean_total + invttail(n_total-1,0.05)*(sd_total / sqrt(n_total)),1),0) if n_total!=0
generate low_total = max( min (mean_total - invttail(n_total-1,0.05)*(sd_total / sqrt(n_total)),1),0) if n_total!=0

	*Primaria
generate hi_prim = max( min (mean_prim + invttail(n_prim-1,0.05)*(sd_prim / sqrt(n_prim)),1),0) if n_prim!=0
generate low_prim = max( min (mean_prim - invttail(n_prim-1,0.05)*(sd_prim / sqrt(n_prim)),1),0) if n_prim!=0
	*Secundaria
generate hi_sec = max( min (mean_sec + invttail(n_sec-1,0.05)*(sd_sec / sqrt(n_sec)),1),0) if n_sec!=0
generate low_sec = max( min (mean_sec - invttail(n_sec-1,0.05)*(sd_sec / sqrt(n_sec)),1),0) if n_sec!=0
	*Preparatoria
generate hi_prepa = max( min (mean_prepa + invttail(n_prepa-1,0.05)*(sd_prepa / sqrt(n_prepa)),1),0) if n_prepa!=0
generate low_prepa = max( min (mean_prepa - invttail(n_prepa-1,0.05)*(sd_prepa / sqrt(n_prepa)),1),0) if n_prepa!=0
	*Más preparatoria
generate hi_masprep = max( min (mean_masprep + invttail(n_masprep-1,0.05)*(sd_masprep / sqrt(n_masprep)),1),0) if n_masprep!=0
generate low_masprep = max( min (mean_masprep - invttail(n_masprep-1,0.05)*(sd_masprep / sqrt(n_masprep)),1),0) if n_masprep!=0

	*RP: No
generate hi_no = max( min (mean_no + invttail(n_no-1,0.05)*(sd_no / sqrt(n_no)),1),0) if n_no!=0
generate low_no = max( min (mean_no - invttail(n_no-1,0.05)*(sd_no / sqrt(n_no)),1),0) if n_no!=0
	*RP: Yes
generate hi_yes = max( min (mean_yes + invttail(n_yes-1,0.05)*(sd_yes / sqrt(n_yes)),1),0) if n_yes!=0
generate low_yes = max( min (mean_yes - invttail(n_yes-1,0.05)*(sd_yes / sqrt(n_yes)),1),0) if n_yes!=0
	
	
	

*Aux variables to graph in x pos
gen v1=1

gen v3=3
gen v4=4
gen v5=5
gen v6=6

gen v8=8
gen v9=9



*


forvalues i=1/2 {

	local n_tot=n_total[`i']

	local n_prim=n_prim[`i']
	local n_sec=n_sec[`i']
	local n_prepa=n_prepa[`i']
	local n_masprep=n_masprep[`i']

	local n_no=n_no[`i']
	local n_yes=n_yes[`i']

	local sabe : label sabe `i'


	twoway (bar mean_total v1 if sabe==`i', color(black) ) ///
		   (bar mean_prim v3 if sabe==`i', color(gs1)) ///
		   (bar mean_sec v4 if sabe==`i', color(gs6)) ///
		   (bar mean_prepa v5 if sabe==`i', color(gs11)) ///
		   (bar mean_masprep v6 if sabe==`i', color(gs16) lcolor(black)) ///
		   (bar mean_no v8 if sabe==`i', color(gs6)) ///
		   (bar mean_yes v9 if sabe==`i', color(white) lcolor(black)) ///
		   (rcap hi_total low_total v1 if sabe==`i', color(black) lpattern(solid)) ///
		   (rcap hi_prim low_prim v3 if sabe==`i', color(black) lpattern(solid)) ///
		   (rcap hi_sec low_sec v4 if sabe==`i', color(black) lpattern(solid)) ///
		   (rcap hi_prepa low_prepa v5 if sabe==`i', color(black) lpattern(solid)) ///
		   (rcap hi_masprep low_masprep v6 if sabe==`i', color(black) lpattern(solid)) ///
		   (rcap hi_no low_no v8 if sabe==`i', color(black) lpattern(solid)) ///
		   (rcap hi_yes low_yes v9 if sabe==`i', color(black) lpattern(solid) ///
				text(0.1 1 "`n_tot'", place(n) color(white)) ///
				text(0.1 3 "`n_prim'", place(n) color(white)) ///
				text(0.1 4 "`n_sec'", place(n) color(black)) ///
				text(0.1 5 "`n_prepa'", place(n) color(black)) ///
				text(0.1 6 "`n_masprep'", place(n) color(black)) ///
				text(0.1 8 "`n_no'", place(n) color(black)) ///
				text(0.1 9 "`n_yes'", place(n) color(black)) ///
			) ///
			, ///
		   legend(row(2) order( 2 "Primary" 3 "Secondary" 4 "High-school" 5 "+ High-school" 6 "No" 7 "Yes") ) ///
		   xlabel( 1 "Total" 5 "Education" 8.5 "Repeated P.", noticks) ///
		   ytitle("Percentage Correct") ///
		   ylabel (0(0.2)0.6) ///
		   scheme(s2mono) graphregion(color(none)) 

		   
	if `i'==2 {
		graph export "$sharelatex\Figuras\Correctly_knows.pdf", replace 
	}
	else {
		graph export "$sharelatex\Figuras\\`sabe'.pdf", replace 
	}
	
}


********************************************************************************



