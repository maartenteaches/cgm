capture log close
log using cgm_dta05.txt, replace text

// turn spells into transitions
// clean those transitions
// MLB

version 18
clear all
macro drop _all

use cgm04
datasignature confirm, strict

// expand
expand 2, gen(f)
gen orig = start if f == 1
gen dest = cond(f==1, finish, start) 
replace sort = sort + .5 if f==1
bys ID_t (sort) : replace sort = _n
bys ID_t ( sort ) : replace orig = finish[_n-1] if f==0    
label value orig dest edlevs
label variable orig "origin"
label variable dest "destination"
notes orig : origin of transition / cgm_dta05.do MLB TS 
notes dest : destination of transition / cgm_dta05.do MLB TS 

tab orig dest

// drop the first enter Grundschule transition
drop if orig == . & dest == 1 & sort == 1

// drop intermediate drop-out
bys ID_t (sort) : gen tobedropped = 1 if orig == 0 & dest[_n -1 ] == 0
bys ID_t (sort) : replace dest = dest[_n +1] if dest == 0 & orig[_n + 1] == 0
drop if tobedropped == 1
drop tobedropped

//enter grundschule --> finish hauptschule (Volksschule)
//enter grundschule --> finish groundschule --> enter hauptschule --> finish Hauptschule
bys ID_t (sort) : gen n = cond(orig==1 & dest == 13, 3, 1)
expand n, gen(added)
bys ID_t added : replace sort = sort + .3*_n if added
bys ID_t (sort) : replace sort = _n
replace dest = 12 if orig == 1 & dest == 13
replace orig = 12 if added & sort == 2
replace dest = 2 if added & sort == 2
replace orig = 2 if added & sort == 3
replace dest = 13 if added & sort == 3
drop n added

// end in exit
bys ID_t (sort) : gen exp = (_n==_N) + 1
expand exp , gen(added)
replace orig = dest if added
replace dest = 0 if added
replace sort = sort + 1 if added
drop added
bys ID_t (sort) : replace sort = _n

// remove first transition as that now contains no information
assert orig == 1 & dest == 12 if sort == 1
drop if sort == 1
bys ID_t (sort) : replace sort = _n

bys orig : tab dest

// remove orig == done & dest == done
drop if orig == 0 & dest == 0

// drop Egy --> Evocreal 
bys ID_t (sort): replace dest = 8 if orig[_n+1] == 4 & dest[_n+1] == 8
bys ID_t (sort): drop if orig == 4 & dest == 8

// drop Evocreal --> Evocreal
drop if  orig == 8 & dest == 8 

// FVocR --> Evocreal --> EHoch 
// FvocR --> Ehoch
bys ID_t (sort) : replace dest = 11 if dest == 8 & orig == 17 & dest[_n+1] == 11
drop if orig == 8 & dest == 11

//FvocR or FRe --> Egy --> Euni
//FvocR --> Euni
bys ID_t (sort) : replace dest = 11 if dest == 4 & inlist(orig,14,17) & orig[_n+1] == 4 & dest[_n+1] == 11
drop if orig == 4 & dest == 11

// drop EvocAbi --> EvocAbi
drop if orig == 9 & dest == 9

// Abi --> EvocAbi --> drop out --> EHoch
// Abi --> Ehoc
bys ID_t (sort) : replace dest = 11 if orig[_n+1] == 9 & dest[_n+1] == 11 
drop if orig == 9 & dest == 11

// drop EvocAbi --> done
replace dest = 0 if dest[_n+1] == 0 & orig[_n+1] == 9
drop if dest == 0 & orig == 9


tab dest if orig == 16
//EvocH --> FvocHau --> Euni
// EVgensecH --> FRe --> Euni
sort ID_t sort
replace dest =  5 if orig[_n+2] == 16 & dest[_n+2] == 11
replace orig =  5 if orig[_n+1] == 16 & dest[_n+1] == 11
replace dest = 14 if orig[_n+1] == 16 & dest[_n+1] == 11
replace orig = 14 if orig       == 16 & dest       == 11

bys orig : tab dest
drop f exp
label var sort "sort order"

compress
note: cgm05.dta \ clean transitions \ cgm_dta05.do \ MLB TS 
label data "cleaned transitions"
datasignature set, reset
save cgm05.dta, replace

log close
exit
