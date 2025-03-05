capture log close
log using cgm_dta01.txt, replace text

// What this .do file does
// Who wrote it

version 18
clear all
macro drop _all

*use ../data/[original_data_file.dta]

*rename *, lower
*keep

// prepare data

*gen some_var = ...
*note some_var: based on [original vars] \ cgm_dta01.do \ [author] TS

*compress
*note: cgm##.dta \ [description] \ cgm_dta01.do \ [author] TS 
*label data [description]
*datasignature set, reset
*save cgm##.dta, replace

log close
exit
