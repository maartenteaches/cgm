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

keep ID_t wave t700001 t70000m t70000y t751001_g1  t731351_g3 t731301_g3 t731301 t731301_ha t731301_v1 t731303 t731303_ha t731303_v1 t731351_ha t731353_ha t731353 t731353_v1 t400500_g1 t405100_g2 t405070_g2 t731453_g8 t731403_g8

// these are asked multiple times ---------------------------
// sex
gen byte female2 = t700001 == 2 if t700001 < .
// the most commonly named gender is the gender
bys ID_t : egen female = mode(female2)
// but when there are ties, then the first mentioned gender applies
bys ID_t (wave) : replace female = female2[1] if female == .
label var female "sex"
label define fem_lb 0 "male" 1 "female"
label values female fem_lb
note female : based on t700001 in pTarget \ cgm_dta02.do \ MLB TS


// birth year
rename t70000y byr2
bys ID_t : egen byr = mode(byr2)
bys ID_t (wave) : replace byr = byr2[1] if byr == .
note byr: based on t70000y in pTarget \ cgm_dta02.do \ MLB TS
label var byr "year of birth"

bys ID_t (wave): keep if _n == 1

gen byte coh = cond(byr <= 1955, 1, ///
               cond(byr <= 1965, 2, ///
               cond(byr <= 1975, 3, ///
			   cond(byr < ., 4, 0)))) 
label define coh 1 "1944-1955" ///
                 2 "1956-1965" ///
                 3 "1966-1975" ///
				 4 "1976-1989"
label value coh coh	
label var coh "cohort"
note coh : based on t70000y in pTarget \ cgm_dta02.do \ MLB TS	


// these are asked only in the first interview -------------

// drop 1st generation migrants
// it is uncertain where they got their education
gen byte todrop = inlist(t400500_g1,1,2) 

// migration status
gen byte mig:mig_lb = inlist(t400500_g1, 3,4,5,6) if t400500_g1 >= 0
// northern and western Europe and north America are excluded as immigrants
replace mig = 0 if mig == 1 & (inlist(t405100_g2, 1,9,10) & inlist(t405070_g2,1,9,10))
label variable mig "migration status"
label define mig_lb 1 "2nd generation" 0 "no migration background"
note mig : based on t400500_g1 in pTarget \ cgm_dta02 \ MLB TS

// parent's education
gen muni = t731303_ha == 4  if t731303_ha >= -20 & !missing(t731303_ha)
gen funi = t731353_ha == 4 if t731353_ha >= -20 & !missing(t731353_ha) 
egen byte puni = rowmax(muni funi)
label define puni_lb 0 "no university" 1 "university"
label values puni puni_lb
label variable puni "parental education"
note puni : based on t731303_ha t731353_ha in pTarget \ cgm_dta02.do \ MLB TS

// parental class
recode t731453_g8 (1 2= 1) (3 4 5 6 7 8 = 2) (9 10 11 = 3) (else=.), gen(classf)
recode t731403_g8 (1 2= 1) (3 4 5 6 7 8 = 2) (9 10 11 = 3) (else=.), gen(classm)
egen classp = rowmin(classf classm)
label define class 1 "service" 2 "intermediate" 3 "working"
label values classp class
label var classp "dominant occupational class parents"
note classp : based on t731403_g8 t731453_g8 in pTarget \ cgm_dta02.do \ MLB TS

// prepare to save
keep ID_t female byr coh puni mig classp todrop
notes : cgm02.dta \ explanatory vars \ trieo-dta02.do \ MLB TS

compress
label data "explanatory variables"
datasignature set, reset
save cgm02.dta, replace

log close
exit
