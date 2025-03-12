capture log close
log using cgm_dta06.txt, replace text

// merge explanatory variables into transitions
// MLB

version 18
clear all
macro drop _all

// check files
use cgm02
datasignature confirm, strict
use cgm05
datasignature confirm, strict

// merge files
merge m:1 ID_t using cgm02.dta

// remove first generation migrants
drop if todrop
drop todrop

compress
note: cgm06.dta \ merge explanatory vars & transitions \ cgm_dta06.do \ MLB TS 
label data "analysis dataset"
datasignature set, reset
save cgm06.dta, replace

log close
exit
