capture log close
log using cgm_ana02.txt, replace text

// Estimate how much of effect of gender and parental ed is through direct track
// MLB

version 18
clear all
macro drop _all

use cgm06.dta
datasignature confirm, strict
codebook, compact

**# prepare variables and matrices for prediction
**## create indicator and interaction variables
// by not using factor variables we can use an old version of -mlogit-, which was implemented in C and thus a lot faster. 
tab coh, gen(coh)
drop coh1
foreach var1 of varlist coh? {
	foreach var2 of varlist puni mig female {
		gen byte `var1'X`var2' = `var1'*`var2'
	}
}

**## matrices for the values of the explanatory variable at which we want the predictions
matrix atpuni   = J(11,8, 0)\J(1,8,1)
matrix atfem    = J(11,8,0)\J(1,8,1)

// rownumbers
local coh2        = 1
local coh3        = 2
local coh4        = 3
local puni        = 4
local female      = 4
local coh2Xpuni   = 6
local coh2Xfemale = 6
local coh3Xpuni   = 7
local coh3Xfemale = 7
local coh4Xpuni   = 8
local coh4Xfemale = 8

// coh1 male (all 0)

// coh1_female
matrix atfem[`female'      ,2] = 1

// coh2 male
matrix atfem[`coh2'       , 3] = 1

// coh2 female
matrix atfem[`female'      ,4] = 1
matrix atfem[`coh2'       , 4] = 1
matrix atfem[`coh2Xfemale', 4] = 1

// coh3 male
matrix atfem[`coh3'       , 5] = 1

// coh3 female
matrix atfem[`female'     , 6] = 1
matrix atfem[`coh3'       , 6] = 1
matrix atfem[`coh3Xfemale', 6] = 1

// coh4 male
matrix atfem[`coh4'       , 7] = 1

// coh4 female
matrix atfem[`female'     , 8] = 1
matrix atfem[`coh4'       , 8] = 1
matrix atfem[`coh4Xfemale', 8] = 1


// coh1 no parental uni (all 0)

// coh1 parental uni
matrix atpuni[`puni'      , 2] = 1

// coh2 no parental uni
matrix atpuni[`coh2'      , 3] = 1

// coh2 parental uni
matrix atpuni[`puni'      , 4] = 1
matrix atpuni[`coh2'      , 4] = 1
matrix atpuni[`coh2Xpuni' , 4] = 1

// coh3 no parental uni
matrix atpuni[`coh3'      , 5] = 1

// coh3 parental uni
matrix atpuni[`puni'     , 6] = 1
matrix atpuni[`coh3'     , 6] = 1
matrix atpuni[`coh3Xpuni', 6] = 1

// coh4 no parental uni
matrix atpuni[`coh4'       , 7] = 1

// coh4 parental uni
matrix atpuni[`puni'     , 8] = 1
matrix atpuni[`coh4'     , 8] = 1
matrix atpuni[`coh4Xpuni', 8] = 1

**# create predicted transition matrices
**## prepare matices
local na "EHa ERe EGy EVsecH EVsecR FGr FHa FRe FA FVH FVR FVA FU" 
local a  "DGr DHa DRe DA DVH DVR DVA DU"

forvalues coh = 1/4 {
	forvalues puni = 0/1 {
		matrix Q_coh`coh'_puni`puni' = J(13,13,0)
		matrix R_coh`coh'_puni`puni' = J(13, 8,0)

		matrix rownames Q_coh`coh'_puni`puni' = `na'
		matrix colnames Q_coh`coh'_puni`puni' = `na'
		matrix rownames R_coh`coh'_puni`puni' = `na'
		matrix colnames R_coh`coh'_puni`puni' = `a'	
		
	}
}
forvalues coh = 1/4 {
	forvalues fem = 0/1 {
		matrix Q_coh`coh'_fem`fem' = J(13,13,0)
		matrix R_coh`coh'_fem`fem' = J(13, 8,0)

		matrix rownames Q_coh`coh'_fem`fem' = `na'
		matrix colnames Q_coh`coh'_fem`fem' = `na'
		matrix rownames R_coh`coh'_fem`fem' = `na'
		matrix colnames R_coh`coh'_fem`fem' = `a'	
		
	}
}

**## predictions
// Given enter Hauptschule
*fre dest if orig == 2
est_probs , orig(2 "EHa") dest(3 "ERe"; 13 "FHa") 

// Given enter Realschule
*fre dest if orig == 3
est_probs , orig(3 "ERe") dest(2 "EHa"; 4 "EGy"; 14 "FRe") 

// Given enter Gymnasium
*fre dest if orig == 4
est_probs , orig(4 "EGy") dest(3 "ERe"; 15 "FA") 

// Given enter Vocational, general secondary
one_probs, oname("EVsecH") dname("FRe")
one_probs, oname("EVsecR") dname("FA")

// Given finish Grundschule
*fre dest if orig == 12
est_probs , orig(12 "FGr") dest(0 "DGr"; 2 "EHa"; 3 "ERe"; 4 "EGy")

// Given finish Hauptschule
*fre dest if orig == 13
est_probs, orig(13 "FHa") dest(0 "DHa"; 3 "ERe"; 5 "EVsecH"; 7 "FVH")

// Given finish Realschule
*fre dest if orig == 14
est_probs, orig(14 "FRe") dest(0 "DRe"; 4 "EGy"; 6 "EVsecR"; 8 "FVR"; 11 "FU" )

// Given finish Abitur
*fre des if orig == 15
est_probs , orig(15 "FA") dest(0 "DA"; 9 "FVA"; 11 "FU" )

// Given Finish Vocational Hauptschule
one_probs, oname("FVH") dname("DVH")

// Given Finish vocational Realschule
*fre des if orig == 17
est_probs , orig(17 "FVR") dest(0 "DVR"; 11 "FU" )

// Given Finish vocational Abitur
*fre des if orig == 18
est_probs, orig(18 "FVA") dest(0 "DVA"; 11 "FU")

// Given Finish University
one_probs, oname("FU") dname("DU")

// ==========================================================
**# pr finish directly
exit
forvalues coh = 1/3 {
	forvalues puni = 0/1 {
		local dir DIR_coh`coh'_puni`puni'
		local R R_coh`coh'_puni`puni'
		local Q Q_coh`coh'_puni`puni'
		matrix `dir' = J(1,8,0)
		local a  "DGr DHa DRe DA DVH DVR DVA DU"
		matrix colnames `dir' = `a'
		
		matrix `dir'[1,colnumb(`dir',"DGr")] =                 ///
			el(`R', rownumb(`R', "FGr"), colnumb(`R', "DGr"))
			
		matrix `dir'[1,colnumb(`dir',"DHa")] =                  ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "EHa"))*  ///
			el(`Q', rownumb(`Q', "EHa"), colnumb(`Q', "FHa"))*  ///
			el(`R', rownumb(`R', "FHa"), colnumb(`R', "DHa")) 

		matrix `dir'[1,colnumb(`dir',"DRe")] =                 ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "ERe"))* ///
			el(`Q', rownumb(`Q', "ERe"), colnumb(`Q', "FRe"))* ///
			el(`R', rownumb(`R', "FRe"), colnumb(`R', "DRe"))

		matrix `dir'[1,colnumb(`dir',"DA")] =                  ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "EGy"))* ///
			el(`Q', rownumb(`Q', "EGy"), colnumb(`Q', "FA"))*  ///
			el(`R', rownumb(`R', "FA"), colnumb(`R', "DA"))

		matrix `dir'[1,colnumb(`dir',"DVH")] =                 ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "EHa"))* ///
			el(`Q', rownumb(`Q', "EHa"), colnumb(`Q', "FHa"))* ///
			el(`Q', rownumb(`Q', "FHa"), colnumb(`Q', "FVH"))* ///
			el(`R', rownumb(`R', "FVH"), colnumb(`R', "DVH"))
			
		matrix `dir'[1,colnumb(`dir',"DVR")] =                 ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "ERe"))* ///
			el(`Q', rownumb(`Q', "ERe"), colnumb(`Q', "FRe"))* ///
			el(`Q', rownumb(`Q', "FRe"), colnumb(`Q', "FVR"))* ///
			el(`R', rownumb(`R', "FVR"), colnumb(`R', "DVR"))

		matrix `dir'[1,colnumb(`dir',"DVA")] =                 ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "EGy"))* ///
			el(`Q', rownumb(`Q', "EGy"), colnumb(`Q', "FA"))*  ///
			el(`Q', rownumb(`Q', "FA"), colnumb(`Q', "FVA"))*  ///
			el(`R', rownumb(`R', "FVA"), colnumb(`R', "DVA"))
			
		matrix `dir'[1,colnumb(`dir',"DU")] =                 ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "EGy"))* ///
			el(`Q', rownumb(`Q', "EGy"), colnumb(`Q', "FA"))*  ///
			el(`Q', rownumb(`Q', "FA"), colnumb(`Q', "FU"))*  ///
			el(`R', rownumb(`R', "FU"), colnumb(`R', "DU")) + ///					
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "ERe"))* ///
			el(`Q', rownumb(`Q', "ERe"), colnumb(`Q', "FRe"))* ///
			el(`Q', rownumb(`Q', "FRe"), colnumb(`Q', "FU"))* ///
			el(`R', rownumb(`R', "FU"), colnumb(`R', "DU"))
	}
}

forvalues coh = 1/3 {
	forvalues fem = 0/1 {
		local dir DIR_coh`coh'_fem`fem'
		local R R_coh`coh'_fem`fem'
		local Q Q_coh`coh'_fem`fem'
		matrix `dir' = J(1,8,0)
		local a  "DGr DHa DRe DA DVH DVR DVA DU"
		matrix colnames `dir' = `a'
		
		matrix `dir'[1,colnumb(`dir',"DGr")] =                 ///
			el(`R', rownumb(`R', "FGr"), colnumb(`R', "DGr"))
			
		matrix `dir'[1,colnumb(`dir',"DHa")] =                  ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "EHa"))*  ///
			el(`Q', rownumb(`Q', "EHa"), colnumb(`Q', "FHa"))*  ///
			el(`R', rownumb(`R', "FHa"), colnumb(`R', "DHa")) 

		matrix `dir'[1,colnumb(`dir',"DRe")] =                 ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "ERe"))* ///
			el(`Q', rownumb(`Q', "ERe"), colnumb(`Q', "FRe"))* ///
			el(`R', rownumb(`R', "FRe"), colnumb(`R', "DRe"))

		matrix `dir'[1,colnumb(`dir',"DA")] =                  ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "EGy"))* ///
			el(`Q', rownumb(`Q', "EGy"), colnumb(`Q', "FA"))*  ///
			el(`R', rownumb(`R', "FA"), colnumb(`R', "DA"))

		matrix `dir'[1,colnumb(`dir',"DVH")] =                 ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "EHa"))* ///
			el(`Q', rownumb(`Q', "EHa"), colnumb(`Q', "FHa"))* ///
			el(`Q', rownumb(`Q', "FHa"), colnumb(`Q', "FVH"))* ///
			el(`R', rownumb(`R', "FVH"), colnumb(`R', "DVH"))
			
		matrix `dir'[1,colnumb(`dir',"DVR")] =                 ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "ERe"))* ///
			el(`Q', rownumb(`Q', "ERe"), colnumb(`Q', "FRe"))* ///
			el(`Q', rownumb(`Q', "FRe"), colnumb(`Q', "FVR"))* ///
			el(`R', rownumb(`R', "FVR"), colnumb(`R', "DVR"))

		matrix `dir'[1,colnumb(`dir',"DVA")] =                 ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "EGy"))* ///
			el(`Q', rownumb(`Q', "EGy"), colnumb(`Q', "FA"))*  ///
			el(`Q', rownumb(`Q', "FA"), colnumb(`Q', "FVA"))*  ///
			el(`R', rownumb(`R', "FVA"), colnumb(`R', "DVA"))
			
		matrix `dir'[1,colnumb(`dir',"DU")] =                 ///
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "EGy"))* ///
			el(`Q', rownumb(`Q', "EGy"), colnumb(`Q', "FA"))*  ///
			el(`Q', rownumb(`Q', "FA"), colnumb(`Q', "FU"))*  ///
			el(`R', rownumb(`R', "FU"), colnumb(`R', "DU")) + ///					
			el(`Q', rownumb(`Q', "FGr"), colnumb(`Q', "ERe"))* ///
			el(`Q', rownumb(`Q', "ERe"), colnumb(`Q', "FRe"))* ///
			el(`Q', rownumb(`Q', "FRe"), colnumb(`Q', "FU"))* ///
			el(`R', rownumb(`R', "FU"), colnumb(`R', "DU"))
	}
}

//========================================= 
**# finishing directly and indirectly

mata 
for(coh=1; coh <= 3; coh++) {
	for(puni=0; puni<=1; puni++) {
		name = "R_coh" + strofreal(coh) + "_puni" + strofreal(puni)
		R = st_matrix(name)
		name = "Q_coh" + strofreal(coh) + "_puni" + strofreal(puni)
		Q = st_matrix(name)
		name = "DIR_coh" + strofreal(coh) + "_puni" + strofreal(puni)
		
		DIR = st_matrix(name)
		N = luinv(I(13) - Q)
		E =  N*R
		E = E[6,.] \ DIR \ E[6,.]:-DIR \ (E[6,.]:-DIR) :/ E[6,.] 
		D = (N[6,.]*100)':*Q , (N[6,.]*100)':*R
		
		name = "E_coh"+strofreal(coh) + "_puni" + strofreal(puni)
		st_matrix(name,E)
		name = "N_coh" + strofreal(coh) + "_puni"+ strofreal(puni)
		st_matrix(name, N)
		name = "D_coh" + strofreal(coh) + "_puni" + strofreal(puni)
		st_matrix(name,D)
	}
	
}

for(coh=1; coh <= 3; coh++) {
	for(fem=0; fem<=1; fem++) {
		name = "R_coh" + strofreal(coh) + "_fem" + strofreal(fem)
		R = st_matrix(name)
		name = "Q_coh" + strofreal(coh) + "_fem" + strofreal(fem)
		Q = st_matrix(name)
		name = "DIR_coh" + strofreal(coh) + "_fem" + strofreal(fem)
		
		DIR = st_matrix(name)
		N = luinv(I(13) - Q)
		E =  N*R
		E = E[6,.] \ DIR \ E[6,.]:-DIR \ (E[6,.]:-DIR) :/ E[6,.] 
		D = (N[6,.]*100)':*Q , (N[6,.]*100)':*R
		
		name = "E_coh"+strofreal(coh) + "_fem" + strofreal(fem)
		st_matrix(name,E)
		name = "N_coh" + strofreal(coh) + "_fem"+ strofreal(fem)
		st_matrix(name, N)
		name = "D_coh" + strofreal(coh) + "_fem" + strofreal(fem)
		st_matrix(name,D)
	}
	
}

end

local na "EHa ERe EGy EVsecH EVsecR FGr FHa FRe FA FVH FVR FVA FU" 
local a  "DGr DHa DRe DA DVH DVR DVA DU"
forvalues coh = 1/3 {
	forvalues puni = 0/1 {
		matrix rownames E_coh`coh'_puni`puni' = "total" "direct" "indirect" "proportion"
		matrix colnames E_coh`coh'_puni`puni' = `a'
		matlist E_coh`coh'_puni`puni'
		matrix rownames N_coh`coh'_puni`puni' = `na'
		matrix colnames N_coh`coh'_puni`puni' = `na'
		matlist N_coh`coh'_puni`puni'
		matrix rownames D_coh`coh'_puni`puni' = `na' 
		matrix colnames D_coh`coh'_puni`puni' = `na' `a'
		matlist D_coh`coh'_puni`puni'
	}
}
forvalues coh = 1/3 {
	forvalues fem = 0/1 {
		matrix rownames E_coh`coh'_fem`fem' = "total" "direct" "indirect" "proportion"
		matrix colnames E_coh`coh'_fem`fem' = `a'
		matlist E_coh`coh'_fem`fem'
		matrix rownames N_coh`coh'_fem`fem' = `na'
		matrix colnames N_coh`coh'_fem`fem' = `na'
		matlist N_coh`coh'_fem`fem'
		matrix rownames D_coh`coh'_fem`fem' = `na' 
		matrix colnames D_coh`coh'_fem`fem' = `na' `a'
		matlist D_coh`coh'_fem`fem'
	}
}

label define school 1 "Grundschule"                   ///
                    2 "Hauptschule"                   ///
                    3 "Realschule"                    ///
                    4 "Abitur"                        ///
                    5 `""vocational-" "Hauptschule""' ///
                    6 `""vocational-" "Realschule""'  ///
                    7 `""vocational-" "Abitur""'      ///
					8 "tertiary", replace

label define schoolr 8 "Grundschule"                   ///
                     7 "Hauptschule"                   ///
                     6 "Realschule"                    ///
                     5 "Abitur"                        ///
                     4 `""vocational-" "Hauptschule""' ///
                     3 `""vocational-" "Realschule""'  ///
                     2 `""vocational-" "Abitur""'      ///
					 1 "tertiary", replace					

drop _all
tempfile tofill
foreach var in total direct indirect proportion{
	gen `var' = .
}
foreach var in school coh puni fem {
	gen byte `var' = .
}

save `tofill'
forvalues coh = 1/3 {
	forvalues puni = 0/1 {
		drop _all
		matrix E_coh`coh'_puni`puni' = E_coh`coh'_puni`puni''
		svmat E_coh`coh'_puni`puni', names(col)
		gen byte school:school = _n
		gen byte coh:coh = `coh'
		gen byte puni:puni_lb=`puni'
		append using `tofill'
		save `tofill', replace
	}
}
forvalues coh = 1/3 {
	forvalues fem = 0/1 {
		drop _all
		matrix E_coh`coh'_fem`fem' = E_coh`coh'_fem`fem''
		svmat E_coh`coh'_fem`fem', names(col)
		gen byte school:school = _n
		gen byte coh:coh = `coh'
		gen byte fem:fem_lb=`fem'
		append using `tofill'
		save `tofill', replace
	}
}


gen byte schoolr:schoolr = abs(school-9) 
replace direct = direct*100
replace total = total*100
gen zero = 0
gen dirlab = strofreal(direct, "%3.0f")
gen totlab = strofreal(total, "%3.0f")

keep if schoolr == 1

gen var:var = fem if !missing(fem)
replace var = puni+2 if !missing(puni)
label defin var 0 "male" 1 "female" 2 "parents no tertiary" ///
                3 "parents tertiary", replace
				
gsort -coh var

seqvar yaxis = 1/4 7/10 13/16
labmask yaxis , values(var) decode

set obs `=_N+1'
replace yaxis = 0 in l
set obs `=_N+1'
replace yaxis = 6 in l
set obs `=_N+1'
replace yaxis =  12 in l

label define yaxis 12 "{bf:1944-1955}" ///
                   6  "{bf:1956-1975}" ///
				   0 "{bf:1976-1989}", modify
twoway scatter total yaxis, ///
    recast(dropline) horizontal  ///
	ylab(0/4 6/10 12/16, val noticks nogrid) yscale(reverse) ///
	lcolor("0 154 209") mcolor("0 154 209") || ///
	scatter direct yaxis, ///
	recast(dropline) horizontal ///
	lcolor("255 142 123") mcolor("255 142 123") || ///
	scatter yaxis direct, msymbol(i) mlab(dirlab) mlabpos(12) ///
	mlabcolor("255 142 123") || ///
	scatter yaxis total, msymbol(i) mlab(totlab) mlabpos(12) ///
	mlabcolor("0 154 209") ///
	xtitle("% attaining tertiary education") ///
	xlab(none) xscale(range(0 65))
graph export ../txt/gr03.emf, replace

drop if var == .
keep coh var total direct
reshape wide total direct , i(coh) j(var)
gen efft1 = total0 - total1
gen efft2 = total3 - total2
gen effd1 = direct0 - direct1
gen effd2 = direct3 - direct2
keep coh eff*
reshape long efft effd, i(coh) j(var)
label define var 1 "male" 2 `""parents" "tertiary""', replace
label var var

gsort -coh var

seqvar yaxis = 1/2 5/6 9/10
labmask yaxis , values(var) decode

set obs `=_N+1'
replace yaxis = 0 in l
set obs `=_N+1'
replace yaxis = 4 in l
set obs `=_N+1'
replace yaxis =  8 in l

label define yaxis 8 "{bf:1944-1955}" ///
                   4 "{bf:1956-1975}" ///
				   0 "{bf:1976-1989}", modify 	

gen max = max(efft, effd)
gen min = min(efft, effd)
gen mid = min + .5*(max-min)
gen indir = efft-effd				   
				   
twoway scatter efft yaxis, ///
    recast(dropline) horizontal  ///
	ylab(0/2 4/6 8/10, val noticks nogrid) yscale(reverse) ///
	lcolor("0 154 209") mcolor("0 154 209") || ///
	scatter effd yaxis, ///
	recast(dropline) horizontal ///
	lcolor("255 142 123") mcolor("255 142 123") || ///
	scatter yaxis effd, msymbol(i) mlab(effd) mlabpos(12) ///
	mlabcolor("255 142 123") mlabformat(%5.1f) || ///
	scatter yaxis efft, msymbol(i) mlab(efft) mlabpos(12) ///
	mlabcolor("0 154 209") mlabformat(%5.1f) || ///
	scatter yaxis mid, msymbol(i) mlab(indir) mlabpos(6) ///
	mlabcolor(black) mlabformat(%5.1f) ///
	xtitle("effect on attaining tertiary education (%-point difference)") ///
	xlab(none) xscale(range(-4 37))	///
	legend( order(1 "total" 2 "direct")) yscale(range(0 10.3))
graph export ../txt/gr04.emf, replace	
	
diag, wmax(0.5) scale(100) coh(3) puni(0) name(coh3_puni0, replace)
diag, wmax(0.5) scale(100) coh(3) puni(1) name(coh3_puni1, replace)
graph combine coh3_puni0 coh3_puni1, rows(1) xsize(12)	
graph export ../txt/gr05.emf, replace

diag, wmax(0.5) scale(100) coh(3) fem(0) name(coh3_fem0, replace)
diag, wmax(0.5) scale(100) coh(3) fem(1) name(coh3_fem1, replace)
graph combine coh3_fem0 coh3_fem1, rows(1) xsize(12)
graph export ../txt/gr06.emf, replace
log close
exit
