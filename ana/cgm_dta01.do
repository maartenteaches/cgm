capture log close
log using cgm_dta01.txt, replace text

// What this .do file does
// Who wrote it

version 18
clear all
macro drop _all

neps set study SC6
neps set level D
neps set version 15.0.0
neps set directory ../data
neps : use "pTarget"

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
