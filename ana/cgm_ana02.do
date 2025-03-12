capture log close
log using cgm_ana02.txt, replace text

// What this .do file does
// Who wrote it

version 18
clear all
macro drop _all

*use cgm##.dta
*datasignature confirm
*codebook, compact

// do your analysis

log close
exit
