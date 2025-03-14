program define diag
	syntax, wmax(  numlist max=1         >0     ) ///
		    scale( numlist max=1         >0     ) ///
			coh(   integer                      ) ///
		    [                                     ///
			puni(  numlist max=1 integer >=0 <2 ) ///
			fem(   numlist max=1 integer >=0 <2 ) *]

	if "`puni'" == "" {
		local what `"_coh`coh'_fem`fem'"'	
	}		
	else {
		local what `"_coh`coh'_puni`puni'"'	
	}
	
	
	tempname probs
	matrix `probs' = Q`what', R`what'
	
	
	local FGr_DGr "3.9  0    3.1  0"
	local FGr_EGy "4.1  0.2  5.9  1.7"
	local FGr_ERe "4    0.2  4    1.7"
	local FGr_EHa "3.9  0.2  2.1  1.7"
	local ERe_EHa "3.9  2.05 2.1  2.05"
	local EHa_ERe "2.1  1.9  3.9  1.9"
	local EGy_ERe "5.9  2.05 4.1  2.05"
	local ERe_EGy "4.1  1.9  5.9  1.9"
	local EHa_FHa "2    2.3  2    3.7"
	local FHa_DHa "2.1  4.2  2.4  5"
	local FHa_ERe "2.1  3.9  3.9  2.2"
	local FRe_EGy "4.1  3.9  5.9  2.2"
	local ERe_FRe "4    2.3  4    3.7"
	local EGy_FA  "6    2.3  6    3.7"
	local FRe_DRe "3.9  4.2  3.6  4.9 "
	local FA_DA   "5.9  4.15 5.1  4.4"
	local FHa_DVH "2    4.3  2    6.8"
	local FRe_FVR "4    4.3  4    6.2"
	local FA_FVA  "5.9  4.3  5.1  5.4"
	local FA_DU   "6    4.3  6    7.7"
	local FVA_DVA "5    5.8  5    7.7"
	local FVA_DU  "5.1  5.6  5.9  7.8"
	local FHa_FRe "2.1  4    3.9  4"
	local FRe_FA  "4.1  4    5.9  4"
	local FHa_Evsec "2.1 4   2.9  4" 
	local Evsec_FRe "3.1 4   3.9  4"
	local FRe_Evsec "4.1 4   4.9  4"
	local Evsec_FA  "5.1 4   5.9  4"
	local FVR_DVR   "4 6.7   4  7.7"
	local FVR_DU    "4.1 6.6 5.9 7.9" 
	local FRe_DU    "4.1 4.3 5.9 7.9"
	
	
	local lab_FGr_DGr "3.5  0    (9)"
	local lab_FGr_EGy "5.1  0.9  (12)"
	local lab_FGr_ERe "4    0.95 (12)"
	local lab_FGr_EHa "2.9  0.9  (6)"
	local lab_ERe_EHa "3    2.05 (3)"
	local lab_EHa_ERe "3    1.9  (9)"
	local lab_EGy_ERe "5    2.05 (3)"
	local lab_ERe_EGy "5    1.9  (9)"
	local lab_EHa_FHa "2    3    (6)"
	local lab_FHa_DHa "2.35 4.8  (6)"
	local lab_FHa_ERe "3    3.05 (9)"
	local lab_FRe_EGy "5    3.05 (9)"
	local lab_ERe_FRe "4    3    (6)"
	local lab_EGy_FA  "6    3    (12)"
	local lab_FRe_DRe "3.75 4.5  (7)"
	local lab_FA_DA   "5.5  4.6  (7)"
	local lab_FHa_FRe "3    4    (9)"
	local lab_FRe_FA  "5    4    (9)"
	local lab_FHa_DVH "2    6    (6) "
	local lab_FRe_FVR "4    5.2    (12)"
	local lab_FA_FVA  "5.5  5    (3)"
	local lab_FA_DU   "6    6    (12)"
	local lab_FVA_DVA "5    6.9  (12)"
	local lab_FVA_DU  "5.5  6.5  (12)"
	local lab_FHa_Evsec "3 3.8 (9)"
	local lab_Evsec_FRe "3 3.8 (9)"
	local lab_FRe_Evsec "5 3.8 (9)"
	local lab_Evsec_FA  "5 3.8 (9)"
	local lab_FVR_DVR   "4 7.25 (6)"
	local lab_FVR_DU    "4.5 7 (0)"
	local lab_FRe_DU    "4.5 4.6 (7)"
	
	local EHa    =  1
	local ERe    =  2
	local EGy    =  3
	local EVsecH =  4
	local EVsecR =  5
	local FGr    =  6
	local FHa    =  7
	local FRe    =  8
	local FA     =  9
	local DVH    = 10
	local FVR    = 11
	local FVA    = 12
	local DU     = 13
	local DGr    = 14
	local DHa    = 15
	local DRe    = 16
	local DA     = 17
	local DVR    = 19
	local DVA    = 20
	
	local od_FGr_DGr = "o(`FGr') d(`DGr')"
	local od_FGr_EGy = "o(`FGr') d(`EGy')"
	local od_FGr_ERe = "o(`FGr') d(`ERe')"
	local od_FGr_EHa = "o(`FGr') d(`EHa')"
	local od_ERe_EHa = "o(`ERe') d(`EHa')"
	local od_EHa_ERe = "o(`EHa') d(`ERe')"
	local od_EGy_ERe = "o(`EGy') d(`ERe')"
	local od_ERe_EGy = "o(`ERe') d(`EGy')"
	local od_EHa_FHa = "o(`EHa') d(`FHa')"
	local od_FHa_DHa = "o(`FHa') d(`DHa')"
	local od_FHa_ERe = "o(`FHa') d(`ERe')"
	local od_FRe_EGy = "o(`FRe') d(`EGy')"
	local od_ERe_FRe = "o(`ERe') d(`FRe')"
	local od_EGy_FA  = "o(`EGy') d(`FA')"
	local od_FRe_DRe = "o(`FRe') d(`DRe')"
	local od_FA_DA   = "o(`FA') d(`DA')"
	local od_FHa_FRe = "o(`FHa') d(`FRe')"
	local od_FRe_FA  = "o(`FRe') d(`FA')"
	local od_FHa_DVH = "o(`FHa') d(`DVH')"
	local od_FRe_FVR = "o(`FRe') d(`FVR')"
	local od_FA_FVA  = "o(`FA') d(`FVA')"
	local od_FA_DU   = "o(`FA') d(`DU')"
	local od_FVA_DVA = "o(`FVA') d(`DVA')"
	local od_FVA_DU  = "o(`FVA') d(`DU')"
	local od_FHa_Evsec = "o(`FHa') d(`EVsecH')"
	local od_Evsec_FRe = "o(`FHa') d(`EVsecH')"
	local od_FRe_Evsec = "o(`FRe') d(`EVsecR')"
	local od_Evsec_FA  = "o(`FRe') d(`EVsecR')"
	local od_FVR_DVR   = "o(`FVR') d(`DVR')"
	local od_FVR_DU    = "o(`FVR') d(`DU')"
	local od_FRe_DU    = "o(`FRe') d(`DU')"
 
local paths FGr_DGr FGr_EGy FGr_ERe FGr_EHa ERe_EHa EHa_ERe ///
            EGy_ERe ERe_EGy EHa_FHa FHa_DHa FHa_ERe FRe_EGy ///
			ERe_FRe EGy_FA  FRe_DRe FA_DA   FVR_DVR FVR_DU  ///
			FHa_DVH FRe_FVR FA_FVA  FA_DU   FVA_DVA FVA_DU  ///
			FHa_Evsec Evsec_FRe FRe_Evsec Evsec_FA FRe_DU

foreach path of local paths {
	make_arrows, `od_`path'' labcoords(`lab_`path'') acoords(``path'') ///
	              wmax(`wmax') scale(`scale') probs(`probs')
	local gr `"`gr' `s(gr)'"'
}

if "`fem'" != "" {
	local femtitle = cond(`fem' == 1, "{bf:female}", "{bf:male}")	
	local title = `"        6   0 (3) "`femtitle'""'
}
if "`puni'" != "" {
	local punititle = cond(`puni' == 1, "{bf:parents tertiary}", ///
	                                    "{bf:parents no tertiary}")	
	local title = `"        6   0 (3) "`punititle'""'
}
local cohtitle = cond(`coh' == 1, "{bf:1944-1955}", ///
                 cond(`coh' == 2, "{bf:1956-1975}", ///
			                       "{bf:1976-1989}"))
local title = `"`title' 5.8 0 (3) "`cohtitle'""'

twoway scatteri     4 0 (0) "FGr" ///
					3 0 (0) "DGr" ///
					2 2 (0) "EHa" ///
					4 2 (0) "ERe" ///
					6 2 (0) "EGy" ///
					2 4 (0) "FHa" ///
					4 4 (0) "FRe" ///
					6 4 (0) "FGy" ///
					5 4 (0) "Vsec" ///
					3 4 (0) "Vsec" ///
					2.5 5 (0) "DHa"   ///
					3.5 5 (0) "DRe"   ///
					5 4.5 (0) "DGy"   ///
					5 5.5 (0) "FVA" ///
					2 7 (0) "DVH" ///
					4 6.5 (0) "FVR" ///
					4 8 (0) "DVR" ///
					5 8 (0) "DVA" ///
					6 8 (0) "DT" ///
					`title'      ///
					,  ///
		   msymbol(i) yscale(off)    ///
		   mlabcolor(black) ///
		   ylab(,nolabels noticks nogrid)   ///
		   xscale(range(1 8) off)              ///
		   xlab(1/8, nolabels noticks nogrid) ///
		   ytitle("") xtitle("")     ///
		   plotregion(lstyle(none))  ///
		   legend(off) `options'  ///
		   `gr' 
end

program define make_arrows, sclass
	syntax, o(integer) d(integer)               ///
	        acoords(string) labcoords(string)   ///
			wmax(real) scale(real) probs(name) ///
			
			
	local c     = el(`probs'    , `o', `d') 

	local bluell  "204 238 249"
	local bluel   "166 225 244"
	local blued   " 89 199 235"
	local bluedd  "  0 169 224"
	local blueddd "  0 142 206"
	local peachll "254 207 199"
	local peachl  "255 184 172"
	local peachd  "255 142 123"
	
	local gr `" || pcarrowi `acoords'"'
	

	local w = `c' * `wmax'
	local gr `"`gr' , lwidth(`w'cm) lcolor("`blueddd'")"'
	local gr `"`gr'   mlwidth(`w'cm) mlcolor("`blueddd'")"'
	local v : disp %3.0f `c'*`scale'
	local gr `"`gr' || scatteri `labcoords' "`v'", msymbol(i) mlabcolor(black)"'
	

	sreturn local gr = `"`gr'"'
end