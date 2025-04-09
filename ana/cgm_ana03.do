capture log close
log using cgm_ana03.txt, replace text

// describe what trajectories are most common
// MLB

version 18
clear all
macro drop _all

use cgm06.dta
datasignature confirm
codebook, compact

keep ID_t sort orig
reshape wide orig, i(ID_t) j(sort)

label define brief ///
           0 "D" ///
           1 "EGr" ///
           2 "EHa" ///
           3 "ERe" ///
           4 "EGy" ///
           5 "EVgensecH" ///
           6 "EVgensecR" ///
           7 "EVH" ///
           8 "EVR" ///
           9 "EVA" ///
          11 "ET" ///
          12 "FGr" ///
          13 "FHa" ///
          14 "FRe" ///
          15 "FA" ///
          16 "FVH" ///
          17 "FVR" ///
          18 "FVA" ///
          20 "FT"

label values orig* brief

gen k = 0
gen high:edlevs = 0

forvalues i = 1/14 {
	replace k = `i' if !missing(orig`i')
	replace high = orig`i' if !missing(orig`i')
	decode orig`i', gen(s`i')
	if `i' == 1 {
		gen traj = s`i'
	}
	else {
		replace traj = traj + ", " + s`i' if !missing(orig`i')
	}
	
}
keep if high == 20
drop high

fre traj, all desc
log close
exit
