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

drop start finish

tab orig dest

// drop the first enter Grundschule transition
drop if orig == . & dest == 1 & sort == 1

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

// drop intermediate drop-out
bys ID_t (sort) : gen todrop = dest[_n-1] == 0 & orig == 0
bys ID_t (sort) : replace dest = dest[_n+1] ///
    if dest == 0 & orig[_n+1] == 0
drop if todrop

// finish Real --> enter Voc R --> enter Real --> enter gym
// finish Real --> enter Gym
bys ID_t (sort) : gen tochange = orig == 14 & dest == 8 & ///
                                 orig[_n+1]== 8 & dest[_n+1]==3 & ///
								 orig[_n+2]==3 & dest[_n+2]==4
replace dest = 4 if tochange
bys ID_t (sort) : drop if tochange[_n-1] == 1
bys ID_t (sort) : drop if tochange[_n-1] == 1
bys ID_t (sort) : replace sort = _n

// drop voc-R --> voc-R
drop if orig == 8 & dest == 8
bys ID_t (sort) : replace sort = _n

exit
bys orig : tab dest
label var sort "sort order"

compress
note: cgm05.dta \ clean transitions \ cgm_dta05.do \ MLB TS 
label data "cleaned transitions"
datasignature set, reset
save cgm05.dta, replace

log close
exit
