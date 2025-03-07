capture log close
log using cgm_dta03.txt, replace text

// clean spells
// Who wrote it

version 18
clear all
macro drop _all

use cgm01

// sort order of spells	
sort ID_t starty startm start, stable
by ID_t : gen sort = _n

//----------------------------------------------------------------------------
**#missing values
// all missing start and all drop-out finish = only grundschule
bys ID_t (sort) : replace start = 1 if sum(missing(start)) == _N & sum(finish==0)==_N

// first start missing followed by finish gen sec to
// first start enter gen sec 
bys ID_t (sort) : replace start = 2 if start[1] == . & finish[1]== 11 & _n == 1
bys ID_t (sort) : replace start = 3 if start[1] == . & finish[1]== 12 & _n == 1
bys ID_t (sort) : replace start = 4 if start[1] == . & finish[1]== 14 & _n == 1

// enter haupt --> miss --> enter real
// enter haupt --> drop-out --> enter real
bys ID_t (sort) : replace finish = 0 if start[2]== 2 & finish[2] == . & start[3]==3 & _n == 2
bys ID_t (sort) : replace finish = 0 if start[1]== 2 & finish[1] == . & start[2]==3 & _n == 1

// enter real --> miss --> enter haupt
// enter haupt --> drop-out --> enter haupt
bys ID_t (sort) : replace finish = 0 if start[2]== 3 & finish[2] == . & start[3]==2 & _n == 2
bys ID_t (sort) : replace finish = 0 if start[1]== 3 & finish[1] == . & start[2]==2 & _n == 1

// enter real --> miss --> enter gym
// enter haupt --> drop-out --> enter gym
bys ID_t (sort) : replace finish = 0 if start[2]== 3 & finish[2] == . & start[3]==4 & _n == 2
bys ID_t (sort) : replace finish = 0 if start[1]== 3 & finish[1] == . & start[2]==4 & _n == 1

// enter gym --> miss --> enter real
// enter gym --> drop-out --> enter real
bys ID_t (sort) : replace finish = 0 if start[2]== 4 & finish[2] == . & start[3]==3 & _n == 2
bys ID_t (sort) : replace finish = 0 if start[1]== 4 & finish[1] == . & start[2]==3 & _n == 1

// drop spells where start and/or finish and/or starty is unknown
drop if missing(start,finish, starty)

//----------------------------------------------------------------------------
**# merge consecutive spells with the same start and end level 
bys ID_t start finish (sort) : replace endm = endm[_N] if _N > 1 & sort[_N] - sort[1] == _N -1
bys ID_t start finish (sort) : replace endy = endy[_N] if _N > 1 & sort[_N] - sort[1] == _N -1
bys ID_t start finish (sort) : drop if _n > 1 & _N > 1 & sort[_N] - sort[1] == _N -1

// missing start but previous spell started with the level that finished in current spell
bys ID_t (sort ) : replace sort = _n
bys ID_t (sort) : replace start = start[_n -1] ///
      if start == . & ( start[_n-1] == 1 & finish == 10 ) | ///
                      ( start[_n-1] == 2 & finish == 11 ) | ///
                      ( start[_n-1] == 3 & finish == 12 ) | ///
                      ( start[_n-1] == 4 & finish == 14 ) 

// merge consecutive spells with same start and first ends are drop-outs
bys ID_t (sort) : replace sort = _n
gen dropout = finish == 0
bys ID_t start (sort) : replace dropout = sum(dropout)
bys ID_t start (sort) : replace dropout = dropout[_N-1] == _N-1
bys ID_t start (sort) : replace endm = endm[_N] if _N > 1 & sort[_N] - sort[1] == _N - 1 & dropout==1
bys ID_t start (sort) : replace endy = endy[_N] if _N > 1 & sort[_N] - sort[1] == _N - 1 & dropout==1
bys ID_t start (sort) : replace finish = finish[_N] if _N > 1 & sort[_N] - sort[1] == _N - 1 & dropout==1 & finish[_N] < .
bys ID_t start (sort) : drop if _n > 1 & _N > 1 & sort[_N] - sort[1] == _N-1 & dropout == 1
drop dropout					  
	
//---------------------------------------------------------------	
**# duplicate spells and big gaps	
// drop duplicate spells
bys ID_t start finish endm endy startm starty : keep if _n == 1

// drop spells with a gap larger or equal to 10 years
bys ID_t (sort) : gen diff = starty - endy[_n-1] 
gen tobedropped = diff >= 10 & diff < .
bys ID_t (sort) : replace tobedropped = sum(tobedropped)
drop if tobedropped
drop tobedropped					  

//-------------------------------------------------------------
**# simplify/ correct some rare transitions					  
// no finishing (Fach)Abitur after entering Hauptschule
// finish Realschule instead
replace finish = 12 if start == 2 & inlist(finish, 13, 14)

// no finishing Hauptschule after entering Gymnasium
// finish Realschule instead
replace finish = 12 if start == 4 & finish == 11

// no finishing Hauptschule after entering vocaltional
// finish Realschule instead
replace finish = 12 if start == 7 & finish == 11

// no finishing fachhochschule after entering vocational
// finish vocational instead
replace finish = 16 if start == 7 & finish == 17

// no finishing vocational after entering fachhochschule
// finish fachhochschule instead
replace finish = 17 if start == 8 & finish == 16

// no finishing fachhochschule after entering hochschule
// finish hochschule instead
replace finish = 18 if start == 9 & finish == 17

// Fachabi = abi
replace finish = 14 if finish == 13					  

// remove gesamtschule
replace start = 2 if start == 5 & finish == 11
replace start = 3 if start == 5 & inlist(finish,0, 12)
replace start = 4 if start == 5 & inlist(finish,13, 14)

// no double Hauptschule
bys ID_t (sort) : drop if finish == 11 & finish[_n-1] == 11

// no double realschule
bys ID_t (sort) : drop if finish == 12 & finish[_n-1] == 12

// no double Abi
bys ID_t (sort) : drop if finish == 14 & finish[_n-1] == 14

// no double pre-voc
bys ID_t (sort) : drop if finish == 15 & finish[_n-1] == 15

// no double voc
bys ID_t (sort) : drop if finish == 16 & finish[_n-1] == 16

// no double Fachhochschule
bys ID_t (sort) : drop if finish == 17 & finish[_n-1] == 17

// no double Hochschule
bys ID_t (sort) : drop if finish == 18 & finish[_n-1] == 18


// clean up sort
bys ID_t (sort) : replace sort = _n

compress
note: cgm03.dta \ cleaned spells \ cgm_dta03.do \ MLB TS 
label data "cleaned spells"
datasignature set, reset
save cgm03.dta, replace

log close
exit
