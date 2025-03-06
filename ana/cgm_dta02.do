capture log close
log using cgm_dta02.txt, replace text

// explanatory variables
// MLB

version 18
clear all
macro drop _all
include cgm_neps.do


neps: use pTarget
datasignature confirm
bys ID_t (wave): keep if _n == 1
keep ID_t t700001 t70000m t70000y t751001_g1  t731351_g3 t731301_g3 t731301 t731301_ha t731301_v1 t731303 t731303_ha t731303_v1 t731351_ha t731353_ha t731353 t731353_v1 t400500_g1

// drop 1st generation migrants
drop if inlist(t400500_g1,1,2) 

// migration status
gen byte mig:mig_lb = inlist(t400500_g1, 3,4,5,6) 
label variable mig "migration status"
label define mig_lb 1 "2nd generation" 0 "no migration background"
note mig : based on t400500_g1 in pTarget \ cgm_dta02 \ MLB TS

// sex
gen byte female:fem_lb = t700001 == 2 if t700001 < .
label var female "sex"
label define fem_lb 0 "male" 1 "female"
note female : based on t700001 in pTarget \ cgm_dta02.do \ MLB TS

nepsmiss t751001_g1
rename t751001_g1 region
note region: based on t751001_g1 in pTarget \ cgm_dta02.do \ MLB TS

rename t70000y byr
note byr: based on t70000y in pTarget \ cgm_dta02.do \ MLB TS

// parent's education
gen muni = t731303_ha == 4  if t731303_ha >= -20 & !missing(t731303_ha)
gen funi = t731353_ha == 4 if t731353_ha >= -20 & !missing(t731353_ha) 
egen byte puni = rowmax(muni funi)
label define puni_lb 0 "no university" 1 "university"
label values puni puni_lb
label variable puni "parental education"
note puni : based on t731303_ha t731353_ha in pT

// prepare to save
keep ID_t female byr puni mig
notes : cgm02.dta \ explanatory vars \ trieo-dta02.do \ MLB TS

compress
label data "explanatory variables"
datasignature set, reset
save cgm02.dta, replace

log close
exit
