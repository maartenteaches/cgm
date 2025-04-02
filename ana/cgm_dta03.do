capture log close
log using cgm_dta03.txt, replace text

// clean spells
// Who wrote it

version 18
clear all
macro drop _all

use cgm01

// sort order of spells	
rename number sort

//----------------------------------------------------------------------------
**#missing values

// start == . & finish == gen sec only happens before entering vocaltional
bys ID_t (sort) : gen voc = inlist(start, 7,9)
bys ID_t (sort) : replace voc = sum(voc) >= 1
count if missing(start) & finish == 11 & voc == 1
assert r(N) == 0
count if missing(start) & finish == 12 & voc == 1
assert r(N) == 0
count if missing(start) & finish == 14 & voc == 1
assert r(N) == 0
drop voc

// as a consequence
// first start missing followed by finish gen sec to
// first start enter gen sec 
bys ID_t (sort) : replace start = 2 if start == . & finish== 11 
bys ID_t (sort) : replace start = 3 if start == . & finish== 12 
bys ID_t (sort) : replace start = 4 if start == . & finish== 14 

// drop if we don't know the start and finish 
drop if missing(start) & missing(finish)

// drop if start = . & finish = drop out
drop if missing(start) & finish == 0

// no more spells with start == .
count if missing(start)
assert r(N) == 0

// enter Real --> . --> enter vocaltional
// enter Real --> finish Real --> enter vocaltional
bys ID_t (sort): replace finish = 12 if start == 3 & finish == . & start[_n+1] == 7

// enter real --> . --> enter Gym --> finish Real
// enter real --> drop out --> enter Gym --> finish Real
bys ID_t (sort) : replace finish = 0 if finish == . & start == 3 & start[_n+1] == 4 & finish[_n+1] == 12

// enter gym --> . is only plausible for 8020706
// but we don't know if it was finished or not, so still drop
lany ID_t sort start finish if finish == . & start ==4 , by(ID_t ) sepby(ID_t )
drop if start == 4 & finish == .

// some gensec --> enter gesamt --> .
// drop enter gesamt --> .
gen gensec = inrange(finish,11,14)
bys ID_t (sort) : replace gensec = sum(gensec) >= 1
drop if start == 5 & finish == . & gensec == 1

// just enter gesamt --> .
// enter grund --> finish grund
bys ID_t (sort) :  gen tochange = start == 5 & finish == . & _N == 1
replace start = 1 if tochange
replace finish = 10 if tochange
drop tochange

// drop enter gesamt --> . --> enter grund
bys ID_t (sort) : drop if start == 5 & finish == . & start[_n+1]==1

// no gensec --> enter gesamt --> . --> enter vocaltional
// no gensec --> enter gesamt --> finish haupt --> enter vocaltional
bys ID_t (sort): replace finish = 11 if gensec == 0 & start == 5 & finish == . & start[_n+1] == 7

// drop if enter gesamt --> . is last spell
bys ID_t (sort): drop if start == 5 & finish == . & _n == _N
drop gensec

// drop spells with unknown finish
drop if finish == .

//----------------------------------------------------------------------------
**# merge consecutive spells with the same start and end level 
bys ID_t start finish (sort) : drop if _n > 1 & _N > 1 & sort[_N] - sort[1] == _N -1

// merge consecutive spells with same start and first ends are drop-outs
bys ID_t (sort) : replace sort = _n
gen dropout = finish == 0
bys ID_t start (sort) : replace dropout = sum(dropout)
bys ID_t start (sort) : replace dropout = dropout[_N-1] == _N-1
bys ID_t start (sort) : replace finish = finish[_N] if _N > 1 & sort[_N] - sort[1] == _N - 1 & dropout==1 & finish[_N] < .
bys ID_t start (sort) : drop if _n > 1 & _N > 1 & sort[_N] - sort[1] == _N-1 & dropout == 1
drop dropout					  
	
//-------------------------------------------------------------
**# simplify/ correct some rare transitions					  
// no finishing (Fach)Abitur after entering Hauptschule
// finish Realschule instead
replace finish = 12 if start == 2 & inlist(finish, 13, 14)

// no finishing Hauptschule after entering Gymnasium
// finish Realschule instead
replace finish = 12 if start == 4 & finish == 11

// no finishing Hauptschule after entering vocational
// finish Realschule instead
replace finish = 12 if start == 7 & finish == 11

// no finishing (fach)hochschule after entering vocational
// enter vocational --> finish vocational --> enter ter --> finish ter if eligable
gen elig = inlist(finish, 12,14)
bys ID_t (sort) : replace elig = sum(elig)>=1
gen toadd = (finish == 18 & start == 7 & elig == 1) +1
replace finish = 16 if toadd == 2
expand toadd, gen(added)
replace sort = sort + 0.5 if added
replace start = 9 if added
replace finish = 18 if added
drop added toadd
bys ID_t (sort) : replace sort = _n

// enter vocational --> finish real --> enter ter --> finish ter if not eligable
gen toadd = (finish == 18 & start == 7 & elig == 0) +1
replace finish = 12 if toadd == 2
expand toadd, gen(added)
replace sort = sort + 0.5 if added
replace start = 9 if added
replace finish = 18 if added
drop added toadd
bys ID_t (sort) : replace sort = _n

// no finishing vocational after entering hochschule
// finish hochschule instead
replace finish = 18 if start == 9 & finish == 16

// no enter grund --> finish gensec
// enter grund --> finish grund --> enter gensec --> finish gensec
gen toadd = (start == 1 & finish == 11) + 1 // Hauptschule
replace finish = 10 if toadd == 2
expand toadd, gen(added)
replace sort = sort +0.5 if added
replace start = 2 if added 
replace finish = 11 if added
bys ID_t (sort) : replace sort = _n
drop toadd added

gen toadd = (start == 1 & finish == 12) + 1 // Realschule
replace finish = 10 if toadd == 2
expand toadd, gen(added)
replace sort = sort +0.5 if added
replace start = 3 if added 
replace finish = 12 if added
bys ID_t (sort) : replace sort = _n
drop toadd added

gen toadd = (start == 1 & finish == 14) + 1 // Gymnasium
replace finish = 10 if toadd == 2
expand toadd, gen(added)
replace sort = sort +0.5 if added
replace start = 4 if added 
replace finish = 14 if added
bys ID_t (sort) : replace sort = _n
drop toadd added

// remove gesamtschule
replace start = 2 if start == 5 & finish == 11
replace start = 3 if start == 5 & inlist(finish,0, 12)
replace start = 4 if start == 5 & inlist(finish,13, 14)

// no double degrees
bys ID_t (sort) : drop if finish == finish[_n-1] 

// clean up sort
bys ID_t (sort) : replace sort = _n

compress
note: cgm03.dta \ cleaned spells \ cgm_dta03.do \ MLB TS 
label data "cleaned spells"
datasignature set, reset
save cgm03.dta, replace

log close
exit
