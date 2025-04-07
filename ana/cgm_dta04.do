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

// enter real --> finish haupt --> enter gym --> finish abi
// enter real --> finish real --> enter gym --> finish abi
bys ID_t (sort) : replace finish = 12 if finish == 11 & start == 3 & ///
                                         start[_n+1] == 4 & finish[_n+1] == 14

// enter hochschule when allowed
gen allowed = inlist(finish, 12,14)		
bys ID_t (sort) : replace allowed = sum(allowed) >= 1
fre allowed if start == 9		

// gain allowance through vocational, only if finished vocational
gen vocfinish = finish == 16
bys ID_t (sort) : replace vocfinish = sum(vocfinish) >= 1
gen add = (start == 9 & allowed == 0 & vocfinish == 1) +1
expand add, gen(added)
replace sort = sort - 0.5 if added == 1
replace start = 7 if added == 1
replace finish = 14 if added == 1
bys ID_t (sort): replace sort = _n

// drop enter hoch if not allowed and not finish voc			
drop if start == 9 & allowed == 0 & vocfinish == 0				
drop allowed vocfinish add added

// stop after finish hochschule
bys ID_t (sort) : gen done = finish[_n-1] == 18
bys ID_t (sort) : replace done = sum(done) >= 1
drop if done == 1
drop done

// finish voc --> finish gensec
// finish gensec --> finish voc
gen vocfinish = finish == 16
bys ID_t (sort) : replace vocfinish = sum(vocfinish) >= 1
bys ID_t (sort) : gen where = vocfinish == 0 & vocfinish[_n+1] == 1
bys ID_t (sort) : replace where = sum(where * sort)
replace sort = where + 0.3 if finish == 12 & vocfinish == 1
replace sort = where + 0.6 if finish == 14 & vocfinish == 1
bys ID_t (sort) : replace sort = _n
drop where vocfinish

// drop finish voc --> enter voc --> finish voc / drop-out
bys ID_t (sort) : drop if finish[_n-1]== 16 & start == 7 & inlist(finish,0,16)

// no haupt after finish haupt
bys ID_t (sort) : gen haupt = finish[_n-1] == 11
bys ID_t (sort) : replace haupt = sum(haupt) >= 1
fre finish if haupt
fre start if haupt
drop if haupt == 1 & (start == 2 | finish == 11)
drop haupt
bys ID_t (sort) : replace sort = _n

// no haupt or real after finish real
bys ID_t (sort) : gen real = finish[_n-1] == 12
bys ID_t (sort) : replace real = sum(real) >= 1
fre finish if real
fre start if real
drop if inlist(finish,11,12) & real == 1
drop if start == 2 & real == 1
drop real
bys ID_t (sort) : replace sort = _n

// no haupt or real or abi after finish abi
bys ID_t (sort) : gen abi = finish[_n-1] == 14
bys ID_t (sort) : replace abi = sum(abi) >= 1
fre start finish if abi == 1
drop if inlist(finish,11,12, 14) & abi == 1
drop if inlist(start, 2, 3,4) & abi == 1
bys ID_t (sort) : replace sort = _n
drop abi

// voc after finish voc
bys ID_t (sort) : gen voc = finish[_n-1] == 16
bys ID_t (sort) : replace voc = sum(voc) >= 1
fre start finish if voc == 1
drop if start == 7 & finish == 16 & voc == 1
bys ID_t (sort) : replace sort = _n
drop voc

// drop duplicate spells
bys ID_t (sort) : drop if start == start[_n+1] & finish == finish[_n+1]

// drop start something --> drop-out --> start samething
drop if start == start[_n+1] & finish == 0
bys ID_t (sort) : replace sort = _n

tsset ID_t sort
replace lstart = L.start
replace lfinish = L.finish
tab lfinish start 								 


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
bys ID_t (sort) : drop if start == 7 & finish == 0 & start[_n+1] == 9

//-------------------------------------------------------------------------
// hochschule --> drop out --> voc/fach/gym to
// voc/fach/gym
bys ID_t (sort) : drop if start == 9 & finish == 0 & inlist(start[_n+1],7,4)

bys ID_t (sort) : replace sort = _n	



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
bys ID_t (sort) : replace sort = _n
drop add added

//------------------------------------------------
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

// drop enter Real, Gym --> drop-out --> enter voc
bys ID_t (sort) : drop if inlist(start, 3,4) & finish == 0 & start[_n+1] == 7

// -------------------------------------------------------------------------
// last spell ends in a diploma
gen rsort = -sort
gen tobedropped = (finish == 0)

bys ID_t (rsort) : replace tobedropped = sum(tobedropped)
bys ID_t (rsort) : replace tobedropped = tobedropped == _n
drop if tobedropped

**# vocational separate by gensec
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
note: cgm04.dta \ cleaned spells \ cgm_dta04.do \ MLB TS 
label data "cleaned spells"
datasignature set, reset
save cgm04.dta, replace

log close
exit
