capture log close
log using cgm_dta01.txt, replace text

// merge educational spells 
// MLB

version 18
clear all
macro drop _all
include cgm_neps.do

**# base list of spells

neps : use "Biography"
datasignature confirm, strict


// keep only educational spells 
// i.e. exclude employment, military, etc. spells
keep if sptype < 25
drop if sptype == 23 // vocprep
tempfile tofill
save `tofill', replace

**# merge in the generated educational spells
neps : use Education
// mising splink = spell outside regular German education
drop if missing(splink) 
merge 1:1 ID_t splink using `tofill'

// number = sort in time
// splink first sorts by general sec and voc/tertiary and sorts by time
// the last is what we want
bys ID_t (splink) : replace number = _n
drop _merge 


notes : cgm01.dta \ merged in generated educational spells from SC6_Education_D_15-0-0.dta \ cgm-dta01.do \ MLB TS         

save `tofill', replace

**# primary and general secondary
neps: use spSchool
datasignature confirm
keep ID_t splink spell subspell   ///
    ts11204 ts11204_ha ts11204_v1 ///
	ts11209 ts11210 ts11211

	
label define edlevs 0  "drop out"                  ///
                    1  "enter Grund- Volksschule"  /// 
                    2  "enter Hauptschule"         ///
                    3  "enter Realschule"          ///
					4  "enter Gymnasium"           ///
					5  "enter Gesamtschule"        ///
					6  "enter pre-vocational"      ///
					7  "enter vocational"          ///
					8  "enter Fachhochschule"      ///
					9  "enter Hochschule"          ///
					10 "finish Grundschule"        ///
					11 "finish Hauptschule"        ///
                    12 "finish Realschule"         ///
					13 "finish Fachabitur"         ///
					14 "finish Abitur"             ///
					15 "finish pre-vocational"     ///
					16 "finish vocational"         ///
					17 "finish Fachhochschule"     ///
					18 "finish Hochschule"     

recode ts11209 ( -21 -20 6 7    =  0  ) /// andere Abschluss & sonderschulabslus & nich in liste == drop-out
               (  .             = 10  ) /// Grund
               (  1  2          = 11  ) /// Haupt
			   (  3             = 12  ) /// Real
			   (  4  5          = 14  ) /// Abi + Fachabi
			   ( else           = .   ) ///
			   , generate(finish)	
replace finish = . if finish == 10 & ts11204_ha != 1
label value finish edlevs		
label variable finish "end of spell"					
note finish: based on ts11209 ts11204_ha in spSchool \ cgm_dta01.do \ MLB TS	
	
recode ts11204    ( 1 3 2          = 1 ) ///
                  ( 4              = 2 ) ///
				  ( 5 7            = 3 ) ///
				  ( 6 10 11 12 14  = 5 ) /// Waldorf, sonderschule, andere schule = gesamtschule
				  ( 8 9            = 4 ) ///
				  ( 13             = 7 ) ///
				  ( else           = . ) ///
				  , generate(start)
replace start = 1 if start == . & ts11204_v1 == 1	
replace start = 2 if start == . & ts11204_v1 == 2
replace start = 3 if start == . & ts11204_v1 == 3
replace start = 4 if start == . & ts11204_v1 == 6
replace start = 5 if start == . & inlist(ts11204_v1, 4, 5, 8, 9)
replace start = 7 if start == . & ts11204_v1 == 7 
replace start = 4 if start == . & ts11204_ha == 5				  
label value start edlevs
label variable start "begin of spell"
note start: based on ts11204_v1 ts11204_ha ts11204 in spSchool \ cgm_dta01.do \ MLB TS	

// missing values in start correspond to missing values on all school variables
assert (ts11204    < 0 | missing(ts11204   ) ) & /// 
	   (ts11204_v1 < 0 | missing(ts11204_v1) ) & ///
	   (ts11204_ha < 0 | missing(ts11204_ha) ) if start == .
	   
keep if subspell == 0
 
keep ID_t splink spell finish start ts11209 

merge 1:1 ID_t splink using `tofill', update

bys ID_t (splink) : replace number = _n

replace finish =  0 if tx28101 == 0 & missing(finish) & !missing(start)
replace finish = 11 if inlist(tx28101, 1,2) & finish == . & inlist(start,1,2,5,7)
replace finish = 12 if inlist(tx28101, 3,4) & finish == . & inlist(start,2,3,4,5,7)
replace finish = 14 if inlist(tx28101, 5,6) & finish == . & inlist(start,3,4,5,7)
replace finish = 10 if start == 1 & finish == .

drop _merge ts11209

notes : cgm01.dta \ meged in primary and general secondary from spSchool \ cgm-dta01.do \ MLB TS 
save `tofill', replace


tab start finish, miss
	   
**# voc and tertiary
neps : use spVocTrain
datasignature confirm
keep ID_t splink subspell /// 
	 ts15201 ts15201_v1 ts15202_O ///
	 ts15216 ts15217 ts15218 ts15218_v1 ///
	 ts15219 ts15219_v1 ts15219_ha ts15220_O
	 
recode  ts15201_v1 ( 1 2 3 4 = 7 ) ///
                   ( 5 6     = 8 ) ///
				   ( 7       = 9 ) /// 
				   ( else    = . ) ///
				  , generate(start)
replace start = 7 if inlist(ts15201, 1, 2, 3, 4, 5)
replace start = 8 if inlist(ts15201, 6, 7, 8, 9)
replace start = 9 if ts15201 == 10
label value start edlevs	
label variable start "begin of spell"
note start : based on ts15201 ts15201_v1 in spVocTrain \ cgm_dta01.do \MLB TS

// not relevant education (medical specialist, civil service examination, phd, etc)
gen byte tobedropped = start == . & ts15201 > 0

recode ts15219_ha ( -20        =  0 ) ///
                  (  1 2 3 4 5 = 16 ) ///
				  (  6 7 8     = 18 ) ///
				  ( else       = .  ) ///
                  , generate(finish)				  
replace finish = 0 if  ts15218  == 2
replace finish = 18 if inlist(ts15219_ha, 9,10) & tobedropped == 0
label value finish 	edlevs
label variable finish "end of spell"

// copy finish from subspell if mainspell finish is missing
bys ID_t splink : egen maxfinish = max(finish)
fre maxfinish if finish == . & subspell ==0
replace finish = maxfinish if finish == . & subspell == 0
drop maxfinish
			
keep if subspell == 0
			
keep ID_t splink finish start ts15219_ha ts15218 tobedropped
merge 1:1 ID_t splink using `tofill', update

replace finish = 16 if ts15219_ha == 17 & inlist(tx28101, 2, 4, 6) & missing(finish)
replace finish = 17 if ts15219_ha == 17 & tx28101 == 7 & missing(finish)
replace finish = 18 if ts15219_ha == 17 & tx28101 == 8 & missing(finish)
replace start = 7 if finish == 16 & start == .
replace start = 9 if finish == 18 & start == .
replace finish = 0 if inlist(ts15219, 16) // other abschluss and IHK is drop-out

drop if tobedropped == 1
drop tobedropped

tab start finish, miss

drop _merge ts15219_ha ts15218 

notes : cgm01.dta \ merged in vocational and tertiary from spVocTrain \ cgm_dta01.do \ MLB TS 

compress
datasignature set, reset
label data "raw educational spells from NEPS"
save cgm01.dta, replace

log close 
exit