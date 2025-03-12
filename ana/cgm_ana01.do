capture log close
log using cgm_ana01.txt, replace text

// descriptives
// MLB

version 18
clear all
macro drop _all

use cgm06.dta
datasignature confirm
codebook, compact

// Who gets to university directly?

gen uni = orig == 20 & dest == 0
bys ID_t (sort) : replace uni = uni[_N]

gen dir = 0 if uni

replace dir = 1 if sort==1 & orig==12 & dest== 4  & uni
replace dir = 1 if sort==2 & orig== 4 & dest==15 & uni
replace dir = 1 if sort==3 & orig==15 & dest==11  & uni
replace dir = 1 if sort==4 & orig==11 & dest==20 & uni
replace dir = 1 if sort==5 & orig==20 & dest==0   & uni

replace dir = 1 if sort==1 & orig==12 & dest== 3  & uni
replace dir = 1 if sort==2 & orig== 3 & dest==14 & uni
replace dir = 1 if sort==3 & orig==14 & dest==11  & uni
replace dir = 1 if sort==4 & orig==11 & dest==20 & uni
replace dir = 1 if sort==5 & orig==20 & dest==0   & uni

bys ID_t (dir): replace dir = dir[1] == dir[_N] & dir[1] == 1 if uni
fre dir if sort == 1

**# percent indirect
// create empty file to append results to
tempfile tofill
preserve
drop _all
gen labels = ""
save `tofill', replace
restore

recode dir (0=1) (1=0) , gen(indir)
// fill file with proportions of pineapple by x
foreach var of varlist mig female puni {
	preserve 
	
	// get the proportions
	collapse (mean) indir if sort == 1 & !missing(`var') & uni==1, by(coh `var' )

	// make a string variable from the variable
	decode `var', gen(labels)
	drop `var'
	gen var = "`var'"
	
	// add those rows to `tofill'
	append using `tofill'
	save `tofill', replace
	restore
}

preserve
use `tofill', clear

sort coh var, stable
l , sepby(coh)
// add some blank space between the variables
seqvar yaxis = 1 2 4 5 7 8 12 13 15 16 18 19 23 24 26 27 29 30
labmask yaxis, values(labels)

set obs `=_N+1'
replace yaxis = 0 in l
set obs `=_N+1'
replace yaxis = 11 in l
set obs `=_N+1'
replace yaxis =  22 in l
label define yaxis  0 "{bf:1944-1955}" ///
                   11 "{bf:1956-1975}" ///
				   22 "{bf:1976-1989}", modify

// turn proportions into percentages
replace indir = indir * 100

// make the graph
twoway scatter indir yaxis ,             ///
    recast(dropline) horizontal              ///
	ylabel(0 1 2 4 5 7 8 11 12 13 15 16 18 19 22 23 24 26 27 29 30, val noticks nogrid) ///
	xlabel(none)                             ///
	yscale(reverse) xscale(range(0 60))      ///
    mlabel(indir) mlabformat(%9.0f)      ///
	mlabcolor("0 154 209") ///
	lcolor("0 154 209") mcolor("0 154 209")  ///
	xtitle("% of people with university degree" "who got there indirectly")
graph export ../txt/gr01.emf, replace
restore 

**# percent university
// create empty file to append results to
tempfile tofill
preserve
drop _all
gen labels = ""
save `tofill', replace
restore

// fill file with proportions of pineapple by x
foreach var of varlist mig female puni {
	preserve 
	
	// get the proportions
	collapse (mean) uni if sort == 1 & !missing(`var'), by(coh `var' )

	// make a string variable from the variable
	decode `var', gen(labels)
	drop `var'
	gen var = "`var'"
	
	// add those rows to `tofill'
	append using `tofill'
	save `tofill', replace
	restore
}

use `tofill', clear

sort coh var, stable
l , sepby(coh)
// add some blank space between the variables
seqvar yaxis = 1 2 4 5 7 8 12 13 15 16 18 19 23 24 26 27 29 30
labmask yaxis, values(labels)

set obs `=_N+1'
replace yaxis = 0 in l
set obs `=_N+1'
replace yaxis = 11 in l
set obs `=_N+1'
replace yaxis =  22 in l
label define yaxis  0 "{bf:1944-1955}" ///
                   11 "{bf:1956-1975}" ///
				   22 "{bf:1976-1989}", modify

// turn proportions into percentages
replace uni = uni * 100

// make the graph
twoway scatter uni yaxis ,             ///
    recast(dropline) horizontal              ///
	ylabel(0 1 2 4 5 7 8 11 12 13 15 16 18 19 22 23 24 26 27 29 30, val noticks nogrid) ///
	xlabel(none)                             ///
	yscale(reverse) xscale(range(0 60))      ///
    mlabel(uni) mlabformat(%9.0f)      ///
	mlabcolor("0 154 209") ///
	lcolor("0 154 209") mcolor("0 154 209")  ///
	xtitle("% with a university degree")
graph export ../txt/gr02.emf, replace
  
log close
exit
