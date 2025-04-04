capture log close
log using cgm_dta04.txt, replace text

// make consistent spells
// MLB

version 18
clear all
macro drop _all

use cgm03
datasignature confirm

**# first transition begins with entering Grundschule
tab start finish if sort == 1
bys ID_t (sort) : gen byte add = ( start != 1 & _n == 1 ) + 1
expand add, gen(added)

replace sort   = 0  if added 
replace start  = 1  if added
replace finish = 10 if added
bys ID_t (sort) : replace sort = _n
drop add added

// drop spells entering grundschule after first spell
drop if start == 1 & sort > 1

// no drop-outs from Grundschule
replace finish = 10 if start == 1 & finish == 0

// clean sort
bys ID_t (sort) : replace sort = _n

tab start finish if sort == 1

// -------------------------------------------------------------- 
**# Second spell

// before cleaning
tsset ID_t sort
gen lstart = L.start
gen lfinish = L.finish
label val lstart lfinish edlevs

tab lfinish start if sort == 2 

// probably wrong sort
// reverse sort if 2nd trans voc & 3rd trans general secondary
bys ID_t (sort) : gen byte toberecoded = start==7  & ///
                                         inlist(start[_n+1], 2, 3, 4) & ///
										 _n == 2
replace sort = 3 if toberecoded == 1
bys ID_t (sort): replace sort = 2 if toberecoded[_n-1]==1

//2nd spell: voc --> finish real
// enter haupt --> finish haupt --> enter voc --> finsh real
gen add = (sort == 2 & start == 7 & finish == 12)+1
expand add, gen(added)
replace sort = sort - 0.5 if added
replace start = 2 if added
replace finish = 11 if added
bys ID_t (sort): replace sort = _n
drop add added

//2nd spell: voc --> finish Abi
// enter real --> finish real --> enter voc --> finsh abi
gen add = (sort == 2 & start == 7 & finish == 14)+1
expand add, gen(added)
replace sort = sort - 0.5 if added
replace start = 3 if added
replace finish = 12 if added
bys ID_t (sort): replace sort = _n
drop add added

// if just two spells and 2nd spell is enter voc 
// the Volksschule (+/- Realschulabschluss) in first spell
bys ID_t (sort): gen add = (sort == 1 & start[_n+1]==7 & _N == 2) +1
expand add, gen(added)
replace sort = sort +0.5 if added
replace start = 2 if added
replace finish = 11 if added
bys ID_t (sort): replace sort = _n
drop add added

// enter voc --> finish voc --> enter hoch
// enter gym --> finish abi --> enter voc --> finish voc --enter hoch
bys ID_t (sort) : gen add = (sort == 2 & start == 7 & finish == 16 & start[_n+1]==9)+1
expand add, gen(added)
replace sort = sort - 0.5 if added
replace start = 4 if added
replace finish = 14 if added
bys ID_t (sort): replace sort = _n
drop add added

// if 2nd spell is enter voc & 3rd spell is enter voc
// the Volksschule (+/- Realschulabschluss) in first spell
bys ID_t (sort): gen add = (sort == 2 & start == 7 & start[_n+1]==7 ) +1
expand add, gen(added)
replace sort = sort -0.5 if added
replace start = 2 if added
replace finish = 11 if added
bys ID_t (sort): replace sort = _n
drop add added

// enter a spell start Gymnasium, finish Abi if second transition 
// started with enter hochschule	
bys ID_t (sort) : gen byte add = (start == 9 & sort == 2) + 1
expand add, gen(added)

replace sort   = 1.5 if added
replace start  = 4   if added
replace finish = 14  if added
bys ID_t (sort) : replace sort = _n
drop add added

// return table of lfinish start for research log
// after cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 2 

// -------------------------------------------------------------- 
**# Third spell

// return table of lfinish start for research log
// before cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 3 

// drop finish Real --> enter Haupt --> drop-out
bys ID_t (sort) : drop if sort > 2 & finish[_n-1] == 12 & start == 2 & finish == 0
bys ID_t (sort) : replace sort = _n

// drop finish Abi --> enter Real --> drop-out
bys ID_t (sort) : drop if sort > 2 & finish[_n-1] == 14 & start == 3 & finish == 0
bys ID_t (sort) : replace sort = _n

// drop finish real --> enter real --> finish realschule, drop-out
bys ID_t (sort) : drop if sort > 2 & start == 3 & finish[_n-1] == 12 & inlist(finish,0, 12)
bys ID_t (sort) : replace sort = _n

// drop finish haupt --> enter haupt --> finish haupt or drop-out
bys ID_t (sort) : drop if sort > 2 & start == 2 & finish[_n-1] == 11 & inlist(finish, 0, 11)
bys ID_t (sort) : replace sort = _n

// drop finish Abi --> enter Gym --> finish abi or drop-out
bys ID_t (sort) : drop if sort > 2 & start == 4 & finish[_n-1] == 14 & inlist(finish, 0, 14)
bys ID_t (sort) : replace sort = _n

// enter .. --> finish Real --> enter Haupt --> finish Haupt
// enter Haupt --> finish Haupt --> enter .. --> finish Real
bys ID_t (sort) : gen tochange = finish[_n-1]==12 & start==2 & finish == 11 & sort > 2
bys ID_t (sort) : replace sort = sort - 1 if tochange==1
bys ID_t (sort) : replace sort = sort + 1 if tochange[_n+1]==1
drop tochange

// enter Real --> finish Real --> enter Real --> finish Haupt
// enter Real --> finish Haupt --> enter Real --> finish Real
bys ID_t (sort) : gen tochange = finish[_n-1]==12 & start==3 & finish == 11 & sort > 2
bys ID_t (sort) : replace sort = sort - 1 if tochange==1
bys ID_t (sort) : replace sort = sort + 1 if tochange[_n+1]==1
drop tochange

// enter .. --> finish Abi --> enter Real/Gym --> finish Real
// enter Real --> finish Real --> enter .. --> finish Abi
bys ID_t (sort) : gen tochange = finish[_n-1]==14 & inlist(start,3,4) & finish == 12 & sort > 2
bys ID_t (sort) : replace sort = sort - 1 if tochange==1
bys ID_t (sort) : replace sort = sort + 1 if tochange[_n+1]==1
drop tochange

// enter Gym --> finish Abi --> enter Haupt --> finish Haupt
// enter Real --> finish Real --> enter Gym --> finish Abi
bys ID_t (sort) : gen tochange = finish[_n-1]==14 & start==2 & finish == 11 & sort > 2
bys ID_t (sort) : replace sort = sort - 1 if tochange==1
bys ID_t (sort) : replace sort = sort + 1 if tochange[_n+1]==1
replace start = 3 if tochange == 1
replace finish = 12 if tochange == 1
drop tochange

// finish hauptschule --> enter Hauptschule --> finish Real  
// finish hauptschule --> enter realschule --> finish Realschule
bys ID_t (sort) : replace start = 3 if sort > 2 & start == 2 & finish[_n-1] == 11 & finish == 12

// finish realschule --> enter realschule --> finish Abi 
// finish realschule --> enter gym --> finish Abi
bys ID_t (sort) : replace start = 4 if sort > 2 & start == 3 & finish[_n-1] == 12 & finish == 14

// again:
// drop finish Real --> enter Haupt --> drop-out
bys ID_t (sort) : drop if sort > 2 & finish[_n-1] == 12 & start == 2 & finish == 0
bys ID_t (sort) : replace sort = _n

// drop finish Abi --> enter Real --> drop-out
bys ID_t (sort) : drop if sort > 2 & finish[_n-1] == 14 & start == 3 & finish == 0
bys ID_t (sort) : replace sort = _n

// drop finish real --> enter real --> finish realschule, drop-out
bys ID_t (sort) : drop if sort > 2 & start == 3 & finish[_n-1] == 12 & inlist(finish,0, 12)
bys ID_t (sort) : replace sort = _n

// drop finish haupt --> enter haupt --> finish haupt or drop-out
bys ID_t (sort) : drop if sort > 2 & start == 2 & finish[_n-1] == 11 & inlist(finish, 0, 11)
bys ID_t (sort) : replace sort = _n

// drop finish Abi --> enter Gym --> finish abi or drop-out
bys ID_t (sort) : drop if sort > 2 & start == 4 & finish[_n-1] == 14 & inlist(finish, 0, 14)
bys ID_t (sort) : replace sort = _n

// enter .. --> finish Abi --> enter Real --> finish Real
// enter Real --> finish Real --> enter .. --> finish Abi
bys ID_t (sort) : gen tochange = finish[_n-1]==14 & start==3 & inlist(finish, 11, 12) & sort > 2
bys ID_t (sort) : replace sort = sort - 1 if tochange==1
bys ID_t (sort) : replace sort = sort + 1 if tochange[_n+1]==1
drop tochange

// drop-out --> enter voc --> finish voc in 3rd spell
// finish gensec --> enter voc --> finish voc
bys ID_t (sort) : replace finish = 11 if start == 2 & finish == 0 & ///
                                         start[_n+1] == 7 & finish[_n+1] == 16 ///
										 & sort == 2
bys ID_t (sort) : replace finish = 12 if start == 3 & finish == 0 & ///
                                         start[_n+1] == 7 & finish[_n+1] == 16  ///
										 & sort == 2
bys ID_t (sort) : replace finish = 14 if start == 4 & finish == 0 & ///
                                         start[_n+1] == 7 & finish[_n+1] == 16 ///
                                         & sort == 2
										 
// enter Haupt/Real --> drop-out --> enter voc --> finish real in 3rd spell
// enter Haupt/real --> finish Haupt --> enter voc --> finish real
bys ID_t (sort) : replace finish = 11 if sort == 2 & inlist(start, 2,3) & ///
                                         finish == 0 & ///
                                         start[_n+1] == 7 & finish[_n+1] == 12

// enter Gym --> drop-out --> enter voc --> finish real in 3rd spell
// enter real --> finish Haupt --> enter voc --> finish real
bys ID_t (sort) : gen tochange = sort == 2 & start == 4 & finish == 0 & ///
                                 start[_n+1] == 7 & finish[_n+1] == 12
replace finish = 11 if tochange == 1									 
replace start = 3 if tochange == 1
drop tochange	

// enter haupt --> drop-out --> enter voc --> finish gymnasium
// enter real --> finish real --> enter voc --> finish gymnasium
bys ID_t (sort) : gen tochange = sort == 2 & start == 2 & finish == 0 & ///
                                 start[_n+1] == 7 & finish[_n+1] == 14
replace finish = 12 if tochange == 1									 
replace start = 3 if tochange == 1
drop tochange	

// enter real/gym --> drop-out --> enter voc --> finish Abi
// enter real/gym --> finish real --> enter voc --> finish abi
bys ID_t (sort) : replace finish = 12 if sort == 2 & inlist(start, 3,4) & ///
                                         finish == 0 & ///
                                         start[_n+1] == 7 & finish[_n+1] == 14

// enter haupt --> drop-out --> enter voc --> drop-out
// enter haupt --> finish haupt --> enter voc --> drop-out
bys ID_t (sort): replace finish = 11 if start == 2 & finish == 0 & ///
                                        start[_n+1] == 7 & finish[_n+1] == 0 ///
										& sort == 2

// enter haupt --> finish Haupt --> enter uni	
// enter Real --> finish Real --> enter (fach)uni	
gen tochange = sort == 2 & start == 2 & finish == 11 & ///
               start[_n+1] == 9
replace start = 3 if tochange == 1
replace finish = 12 if tochange == 1
drop tochange

// enter Real --> finish Haupt --> enter Gym 
// enter Real --> finish Real --> enter gym
bys ID_t (sort): replace finish = 12 if ///
    sort == 2 & start == 3 & finish == 11 & start[_n+1] == 4

// enter haupt --> finish haupt --> enter gym	
// enter haupt --> finish haupt --> enter real --> finish real --> enter gym
bys ID_t (sort): gen byte toadd = (start == 2 & finish == 11 & start[_n+1]==4) + 1
expand toadd, gen(added)
replace sort = sort + 0.5 if added == 1
replace start = 3 if added == 1
replace finish = 12 if added == 1
bys ID_t (sort): replace sort = _n
drop add added

// enter Haupt --> drop-out --> enter gym
// enter real --> drop-out --> enter gym
bys ID_t (sort): replace start = 3 if sort == 2 & start == 2 & ///
                                      finish == 0 & start[_n+1] == 4


// return table of lfinish start for research log
// after cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 3 

// --------------------------------------------------------------- 
**# Fourth spell
bys ID_t (sort) : replace sort = _n

// return table of lfinish start for research log
// before cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 4 

// drop finish abi --> enter haupt
bys ID_t (sort) : drop if finish[_n-1] == 14 & start == 2

// drop finish abi --> enter gym
bys ID_t (sort) : drop if finish[_n-1] == 14 & start == 4

// drop finish real --> enter real
bys ID_t (sort) : drop if finish[_n-1] == 12 & start == 3

bys ID_t (sort) : replace sort = _n


tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 4 

exit
// finish haupt --> enter haupt --> finish real to
// finish haupt --> enter real --> finish real
bys ID_t (sort) : replace start = 3 if finish[_n-1] == 11 & start == 2 & sort == 4


// spell start real then drop-out adds nothing if previous spell finished real
bys ID_t (sort) : drop if finish[_n-1] == 12 & start == 3 & finish == 0 & sort == 4
	
// after vocational no need to enter hauptschule	
bys ID_t (sort) : drop if finish[_n-1] == 16 & start == 2 & sort == 4
	
// after fachhochschule no need to enter pre-voc, voc, or fachhochschule
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : drop if finish[_n-1] == 17 & inlist(start, 7,8) & sort == 4
// repeat
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : drop if finish[_n-1] == 17 & inlist(start, 7,8) & sort == 4

// after hochschule you are done
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : gen byte hoch = finish[_n-1] == 18
bys ID_t (sort) : replace hoch = sum(hoch)
fre hoch
drop if hoch
drop hoch

// after abi no need to enter Haupt, real, or gym
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : drop if finish[_n-1] == 14 & start < 6 

// drop duplicate spell
bys ID_t (sort) : drop if start == start[_n-1] & finish == finish[_n-1]


// after cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 4 


// --------------------------------------------------------------- 
**# Fifth spell
bys ID_t (sort) : replace sort = _n

// before cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 5 

// no need to enter realschule or gesamtschule after abi
bys ID_t (sort) : drop if finish[_n-1] == 14 & inlist(start, 3, 5)

// no need to enter realschule after realschule
bys ID_t (sort) : drop if finish[_n-1] == 12 & start == 3

// no need to enter hauptschule after finish voc
bys ID_t (sort) : drop if finish[_n-1]==16 & start == 2

// no need to enter pre-voc, voc, real or fachhochschule after finish fachhochschule
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : drop if finish[_n-1]==17 & inlist(start, 3,7,8) & sort == 5
//repeat
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : drop if finish[_n-1]==17 & inlist(start, 3,7,8) & sort == 5

// drop duplicate spell
bys ID_t (sort) : drop if start == start[_n-1] & finish == finish[_n-1]

// after cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 5 

// --------------------------------------------------------------- 
**# Sixth spell
bys ID_t (sort) : replace sort = _n

// before cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 6 

// no need to enter real pre-voc, voc or fachhochschule after finish fachhochschule
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : drop if finish[_n-1]==17 & inlist(start, 3,7,8) & sort == 6
//repeat
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : drop if finish[_n-1]==17 & inlist(start, 3,7,8) & sort == 6

// drop duplicate spell
bys ID_t (sort) : drop if start == start[_n-1] & finish == finish[_n-1]

// after cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 6 

// --------------------------------------------------------------- 
**# Seventh spell

// before cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 7 
	
// no need to enter pre-voc, voc or fachhochschule after finish fachhochschule
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : drop if finish[_n-1]==17 & inlist(start, 7,8) & sort == 7
//repeat
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : drop if finish[_n-1]==17 & inlist(start, 7,8) & sort == 7

// drop duplicate spell
bys ID_t (sort) : drop if start == start[_n-1] & finish == finish[_n-1]

// after cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 7 

// --------------------------------------------------------------- 
**# Eigth spell

// before cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 8 
	
// no need to enter pre-voc, voc, real or fachhochschule after finish fachhochschule
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : drop if finish[_n-1]==17 & inlist(start, 3,7,8) & sort == 8
//repeat
bys ID_t (sort) : replace sort = _n
bys ID_t (sort) : drop if finish[_n-1]==17 & inlist(start, 3,7,8) & sort == 8

// drop duplicate spell
bys ID_t (sort) : drop if start == start[_n-1] & finish == finish[_n-1]

// after cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 8 

// --------------------------------------------------------------- 
**# Ninth spell

// before cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 9 

// drop duplicate spell
bys ID_t (sort) : drop if start == start[_n-1] & finish == finish[_n-1]

// after cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 9 


// --------------------------------------------------------------- 
**# Tenth spell

// before cleaning
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 10 
	
// no need to enter Fachhochschule if finished Fachhochschule
bys ID_t (sort) : drop if finish[_n-1]==17 & start== 8 & sort == 10

// drop duplicate spell
bys ID_t (sort) : drop if start == start[_n-1] & finish == finish[_n-1]

// after cleaning
bys ID_t (sort) : replace sort = _n
tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start if sort == 10

// --------------------------------------------------------------------------
**# drop spells that are lower or equal than what was already achieved

// nothing after finishing hochschule
bys ID_t (sort) : gen byte tobedropped = finish[_n-1] == 18
bys ID_t (sort) : replace  tobedropped = sum(tobedropped)
drop if tobedropped

// only hochschule after fachhochschule
bys ID_t (sort) : replace tobedropped = finish[_n-1]== 17
bys ID_t (sort) : replace  tobedropped = sum(tobedropped)
replace tobedropped = 0 if start == 9
drop if tobedropped

// no hauptschule after vocational
// no vocational diploma after vocational
bys ID_t (sort) : replace tobedropped = finish[_n-1]== 16
bys ID_t (sort) : replace  tobedropped = sum(tobedropped)
replace tobedropped = 0 if !(inlist(start,2) | finish == 16)
drop if tobedropped

// no general secondary education after finishing Abi
bys ID_t (sort) : replace tobedropped = finish[_n-1] == 14
bys ID_t (sort) : replace tobedropped = sum(tobedropped)
replace tobedropped = ( tobedropped >= 1 & tobedropped < .) & ( inlist(finish,11,12,14) | inrange(start,1,5) )
drop if tobedropped

// no diploma realschule after realschule
// no enter hauptschule after realschule
bys ID_t (sort) : replace tobedropped = finish[_n-1] == 12
bys ID_t (sort) : replace tobedropped = sum(tobedropped)
replace tobedropped = 0 if !(finish == 12 | start == 2 | finish == 11)
drop if tobedropped

// no finish hauptschule after hauptschule
bys ID_t (sort) : replace tobedropped = finish[_n-1] == 11
bys ID_t (sort) : replace tobedropped = sum(tobedropped)
replace tobedropped = 0 if finish != 11 
drop if tobedropped

bys ID_t (sort) : replace sort = _n
fre sort

//--------------------------------------------------------------------------
// voc --> drop out --> gen sec to
// enter gen sec --> finish gen sec

// hauptschule
bys ID_t (sort) : drop if start == 7 & finish == 0 & ///
                          start[_n+1] == 2 & finish[_n+1] == 11

// realschule
bys ID_t (sort) : drop if start == 7 & finish == 0 & ///
                          start[_n+1] == 3 & finish[_n+1] == 12
// gymnasium
bys ID_t (sort) : drop if start == 7 & finish == 0 & ///
                          start[_n+1] == 4 & finish[_n+1] == 14

//-------------------------------------------------------------------------
// voc --> drop out --> (fach)hochschule to
// --> (fach)hochschule
bys ID_t (sort) : drop if start == 7 & finish == 0 & inlist(start[_n+1], 8, 9)

// ------------------------------------------------------------------------
// fachhochschule --> drop out --> hochschule/voc to
//  --> hochschule/voc
bys ID_t (sort) : drop if start == 8 & finish == 0 & inlist(start[_n+1],9,7)
	
//-------------------------------------------------------------------------
// hochschule --> drop out --> voc/fach/gym to
// voc/fach/gym
bys ID_t (sort) : drop if start == 9 & finish == 0 & inlist(start[_n+1],7,8,4)

drop if start == 7 & finish == 11

bys ID_t (sort) : replace sort = _n	

//-------------------------------------------------------------------------
// finish voc --> enter gen sec
// finish voc --> enter voc --> finish gen sec
bys ID_t (sort) : replace start = 7 if inlist(start,3, 4, 5) & finish[_n-1] == 16
drop if start == 7 & finish == 11

//------------------------------------------------------------------------
// finish Real enter Hochschule to
// finish Real enter Fachhochschule
bys ID_t (sort) : gen byte tochange = finish[_n-1] == 12 & start== 9
replace start = 8 if tochange
replace finish = 17 if tochange
drop tochange

//-------------------------------------------------------------------------
// repeat enter voc --> drop out --> enter gen sec to
// enter gen sec --> finish gen sec
// gymnasium
bys ID_t (sort) : drop if start == 7 & finish == 0 & ///
                          start[_n+1] == 4 & finish[_n+1] == 14

//--------------------------------------------------------------------------
// voc --> drop out --> enter Fach to
// enter Fac
bys ID_t (sort) : drop if start == 7 & finish == 0 & start[_n+1] == 8

//-------------------------------------------------------------------------
// Egym --> drop-out --> enter fach
// Egym --> FRe --> enter Fach
bys ID_t (sort) : replace finish = 12 if start[_n+1] == 8 & start == 4 & finish==0


// gym --> hoch
// gym --> Abi --> hoch
bys ID_t (sort) : replace finish = 14 if start== 4 & finish == 0 & start[_n+1] == 9

// drop unfinished university
drop if start == 9 & finish == 0

//--------------------------------------------------------------------------
// gym --> haupt to
// gym --> real --> haupt
bys ID_t (sort) : replace sort = _n	
bys ID_t (sort) : gen byte add = (start == 4 & finish == 0 & start[_n+1] == 2) + 1
expand add, gen(added)

replace sort   = sort + .5 if added
replace start  = 3   if added
replace finish = 0  if added
replace startm = .   if added
replace starty = .   if added
replace endm   = .   if added
replace endy   = .   if added
bys ID_t (sort) : replace sort = _n
drop add added

//--------------------------------------------------------------------------
// haupt --> gym to
// haupt --> real --> gym
bys ID_t (sort) : replace sort = _n	
bys ID_t (sort) : gen byte add = (start == 2 & finish == 0 & start[_n+1] == 4) + 1
expand add, gen(added)

replace sort   = sort + .5 if added
replace start  = 3   if added
replace finish = 0  if added
replace startm = .   if added
replace starty = .   if added
replace endm   = .   if added
replace endy   = .   if added
bys ID_t (sort) : replace sort = _n
drop add added

//--------------------------------------------------------------------------
// gen sec --> drop out --> enter voc to 
// gen sec --> finish gen sec --> enter voc
bys ID_t (sort) : replace finish = 11 if start == 2 & finish == 0 & start[_n+1] ==7
bys ID_t (sort) : replace finish = 12 if start == 3 & finish == 0 & start[_n+1] ==7
bys ID_t (sort) : replace finish = 14 if start == 4 & finish == 0 & start[_n+1] ==7

//--------------------------------------------------------------------------
// no enter XX --> drop out --> enter XX again
bys ID_t (sort) : replace tobedropped = start == start[_n+1] & finish == 0
drop if tobedropped
bys ID_t (sort) : replace sort = _n

// enter Gym --> finish Real
// Enter Gym --> enter Real --> finish Real
gen add = (start == 4 & finish == 12) + 1
expand add, gen(added)
replace sort = sort + .5 if added
replace finish = 0 if start == 4 & finish == 12 & added == 0
replace start = 3 if added == 1
bys ID_t (sort) : replace sort = _n
drop add added

// enter Real --> finish Haupt
// Enter Gym --> enter Haupt --> finish Haupt
gen add = (start == 3 & finish == 11) + 1
expand add, gen(added)
replace sort = sort + .5 if added
replace finish = 0 if start == 3 & finish == 11 & added == 0
replace start = 2 if added == 1
bys ID_t (sort) : replace sort = _n
drop add added

// enter Real --> finish Gym
// Enter Real --> enter Gym --> finish Gym
gen add = (start == 3 & finish == 14) + 1
expand add, gen(added)
replace sort = sort + .5 if added
replace finish = 0 if start == 3 & finish == 14 & added == 0
replace start = 4 if added == 1
bys ID_t (sort) : replace sort = _n
drop add added

// enter Haupt --> finish Real
// Enter Haupt --> enter Real --> finish Real
gen add = (start == 2 & finish == 12) + 1
expand add, gen(added)
replace sort = sort + .5 if added
replace finish = 0 if start == 2 & finish == 12 & added == 0
replace start = 3 if added == 1
bys ID_t (sort) : replace sort = _n
drop add added

// Fachhochschule = hochschule
replace start = 9 if start == 8
replace finish = 18 if finish ==17

//drop  finish real --> enter real 
bys ID_t (sort) : drop if start == 3 & finish[_n-1] == 12
bys ID_t (sort) : replace sort = _n

// enter real --> drop out --> enter uni
// enter real --> finish real --> enter uni
bys ID_t (sort) : replace finish = 12 if start == 3 & finish == 0 & start[_n+1]==9


// EHo --> drop --> Eho --> finish
// Eho -- Finish
bys ID_t (sort) : drop if start == 9 & finish == 0 & start[_n+1] == 9 & finish[_n+1] == 18

// Eho --> Fvo 
// Evo --> Fvo
bys ID_t (sort) : replace start = 7 if start == 9 & finish == 16

// EVo --> Fho 
// EHo --> Fho if Real or Abi
// Evo --> Fvo if not real or abi
bys ID_t (sort) : gen abi = inlist(finish,12,14)
bys ID_t (sort) : replace abi = sum(abi)
bys ID_t (sort) : replace start  =  9 if start == 7 & finish == 18 & abi
bys ID_t (sort) : replace finish = 16 if start == 7 & finish == 18 & abi == 0
drop abi

// -------------------------------------------------------------------------
// last spell ends in a diploma
gen rsort = -sort
replace tobedropped = (finish == 0)

bys ID_t (rsort) : replace tobedropped = sum(tobedropped)
bys ID_t (rsort) : replace tobedropped = tobedropped == _n
drop if tobedropped

// drop duplicate spell
bys ID_t (sort) : drop if start == start[_n-1] & finish == finish[_n-1]


//----------------------------------------------------------------------- 
**# move general secondary before vocational
gen byte voc = start == 7
bys ID_t voc (sort) : gen place2 = sort[1] if voc == 1
bys ID_t (sort) : egen place = min(place2)
drop place2
bys ID_t (sort) : replace voc = sum(voc)
assert voc <=4
gen toberesorted = voc >= 1 & inlist(finish,11, 12, 14)
tab toberesorted

bys ID_t (sort) : replace toberesorted = sum(toberesorted) if toberesorted == 1
replace sort = place - 1 + ( toberesorted / 4) if toberesorted > 0 & toberesorted < 3
bys ID_t (sort) : replace sort = _n

//----------------------------------------------------------------------- 
**# some corrections
// drop duplicate gen sec diplomas after Abi
drop tobedropped
bys ID_t (sort) : gen byte tobedropped = finish[_n-1] == 14
bys ID_t (sort) : replace tobedropped = sum(tobedropped)
replace tobedropped = tobedropped == 1 & inlist(finish,11,12,14)
drop if tobedropped

// drop duplicate haupt & real diplomas after real
bys ID_t (sort) : replace tobedropped = finish[_n-1] == 12
bys ID_t (sort) : replace tobedropped = sum(tobedropped)
replace tobedropped = tobedropped == 1 & inlist(finish,11,12)
drop if tobedropped

bys ID_t (sort) : replace sort = _n

//------------------------------------------------------------------------ #3
// store highest general secondary diploma
gen haupt = finish == 11
gen real  = finish == 12
gen abi   = finish == 14
bys ID_t (sort) : replace haupt = sum(haupt)
bys ID_t (sort) : replace real  = sum(real)
bys ID_t (sort) : replace abi   = sum(abi)

// create new education system
clonevar start2 = start
replace start2 = .  if start >  5
bys ID_t (sort) : replace start2 = 5  if start == 7 & finish[_n-1] == 11 & inlist(finish,12,14)
bys ID_t (sort) : replace start2 = 6  if start == 7 & finish[_n-1] == 12 & inlist(finish,12,14)
replace start2 = 7  if start == 7 & real == 0 & abi == 0 & !inlist(finish,12,14)
replace start2 = 8  if start == 7 & real == 1 & abi == 0 & !inlist(finish,12,14)
replace start2 = 9  if start == 7 & abi  == 1 & !inlist(finish,12,14)
replace start2 = 10 if start == 8
replace start2 = 11 if start == 9

clonevar finish2 = finish
replace finish2 = .
replace finish2 = 0  if finish ==  0
replace finish2 = 12 if finish == 10
replace finish2 = 13 if finish == 11
replace finish2 = 14 if finish == 12
replace finish2 = 15 if finish == 14
replace finish2 = 16 if finish == 16 & start2 == 7
replace finish2 = 17 if finish == 16 & start2 == 8
replace finish2 = 18 if finish == 16 & start2 == 9
replace finish2 = 19 if finish == 17
replace finish2 = 20 if finish == 18


// new educational "system"
label define edlevs2 0  "done" ///
                    1  "enter Grundschule" ///
                    2  "enter Hauptschule" ///
                    3  "enter Realschule" ///
                    4  "enter Gymnasium" ///
                    5  "enter vocational, gen. sec., Haupt" ///
                    6  "enter vocational, gen. sec., Real" ///
                    7  "enter vocational, Hauptschule" ///
                    8  "enter vocational, Realschule" ///
                    9  "enter vocational, Abitur" ///
                    10 "enter Fachhochschule" ///
                    11 "enter University" ///
                    12 "finish Grundschule" ///
                    13 "finish Hauptschule" /// 
					14 "finish Realschule" ///
                    15 "finish Abitur" ///
                    16 "finish vocational, Hauptschule" /// 
					17 "finish vocational, Realschule" /// 
					18 "finish vocational, Abitur" /// 
					19 "finish Fachhochschule" /// 
					20 "finish University" /// 
       , replace

label value start2 finish2 edlevs2

// check the new variables

tab start start2
tab finish finish2

// replace the new variables with the old variables
replace start = start2
replace finish = finish2
label copy edlevs2 edlevs, replace

// admire the result
tab start finish

//-----------------------------------------------------------
// some corrections

// haupt --> enter gymnasium
// haupt --> enter Real --> finish real --> enter Gym
bys ID_t (sort) : gen n = (finish == 13 & start[_n+1]==4) + 1
expand n, gen(added)
replace start = 3 if added
replace finish = 14 if added
replace sort = sort + .5 if added
bys ID_t (sort) : replace sort = _n
drop n added


// EVgensecH --> FA
// EVgensecH --> FRe --> EVgensecR --> FA
bys ID_t (sort) : gen n = (finish == 15 & start==5) + 1
expand n, gen(added)
replace finish = 14 if finish == 15 & start==5 & !added
replace start = 6 if added
replace sort = sort + .5 if added
bys ID_t (sort) : replace sort = _n
drop n added

// clean up
keep ID_t sort start finish 
bys ID_t (sort) : replace sort = _n

compress
note: cgm04.dta \ cleaned spelss \ cgm_dta04.do \ MLB TS 
label data "cleaned spells"
datasignature set, reset
save cgm04.dta, replace

log close
exit
