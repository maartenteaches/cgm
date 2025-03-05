/*----------------------------------------------------------------------------------
  comp2long.ado: reshape NEPS competency data from wide to long
    Copyright (C) 2021  Dietmar Angerer (dietmar.angerer@lifbi.de)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    For a copy of the GNU General Public License see <http://www.gnu.org/licenses/>.

-----------------------------------------------------------------------------------*/
*! comp2long.ado: reshape NEPS competency data from wide to long
*! Dietmar Angerer (dietmar.angerer@lifbi.de), Leibniz Institute for Educational Trajectories (LIfBi), Germany
*! version 1.3 January, 16th 2024 - harmonization of scores, dropped option "dropsingle"; only scored variables can be harmonized or kept 
*! version 1.2 January, 25th 2023 - harmonization of scores, added options "clear" "onlyharmonized" "dropsingle"
*! version 1.1 December, 9th 2022 - TK: small adaptions to make it work in syntax
*! version 1.0 June, 1st 2021 - initial release
program comp2long , rclass
	version 14
	set more off		

	// parse syntax
	syntax anything(everything equalok id="NEPS competency file name")  ///
	, [SAVE(string) REPLACE HARMonize IGNORE VERBOSE ONLYHARMonized DROPSINGLE CLEAR]

	local replaceit 0
	if (`"`replace'"' != "") local replaceit 1
	
	local harmonizeit 0
	if (`"`harmonize'"' != "") local harmonizeit 1

	local ignoreit 0
	if (`"`ignore'"' != "") local ignoreit 1

	local verboseit 0
	if (`"`verbose'"' != "") local verboseit 1

	local onlyharmonizedit 0
	if (`"`onlyharmonized'"' != "") local onlyharmonizedit 1

	local clearit 0
	if (`"`clear'"' != "") local clearit 1

	local dropsingleit 0
	if (`"`dropsingle'"' != "") {
		noisily: display as error "option dropsingle is obsolete; to drop single items simply choose option {it: onlyharmonized} to keep only scored items; harmonization of single items is no longer supported; single items will be sorted to the right wave using option {it:harmonize}"
		local dropsingleit 1
		exit 459
	}

	local idvars ID_t wave  // defining id-variables
	local loudtext noisily: display as text
	local loudres noisily: display as result

	local anything `anything'
	capture: confirm file `"`anything'"'
	if _rc != 0 {
		noisily: display as error "Could not find competency file {input:`anything'}."
		if ("`noninteractive'"=="") {
			noisily: display as text "Enter the {bf:source path and file name of competency data desired to reshape} (e.g. C:/NEPS/SC4/10-0-0/SC4_xTargetCompetencies_D_10-0-0.dta), then press {bf:return}", _request(_compfilename)
			local compfilename `compfilename'
			capture: confirm file `"`compfilename'"'
			if _rc == 0 local anything : copy local compfilename
			else error _rc
		}
		else {
			error _rc
		}
	}
	else {
		local anything: subinstr local anything "\" "`c(dirsep)'", all	    
	}
	local saveit 0
	if (`"`save'"' != "") {
	    local saveit 1
		local save: subinstr local save "\" "`c(dirsep)'", all
		local save `save'
	}
	
	if `replaceit' == 1 & `saveit' == 0 {
	    noisily: display as error "option {bf:replace} requires option {bf:save}"
		exit 459
	}	
	if `replaceit' == 0 & `saveit' == 1 {
	    capture: confirm file "`save'"
		if _rc == 0 {
		    noisily: display as error "file `save' already exists"
			exit 602
		} 
	}
	
	if `replaceit' == 1 {
		capture: assert `"`anything'"' != `"`save'"'
		if _rc == 9 {
		    noisily: display as error "you are trying to overwrite the sourcefile `anything' - action canceled!!!"
			exit 459
		}
	}
	
	if `onlyharmonizedit' == 1 & `harmonizeit' == 0 {
	    local harmonizeit 1
		noisily: display as error "option onlyharmonized overrides option harmonize - harmonization initialized..."
	}
	
	
	if `verboseit' == 0 local loudtext quietly: display as text
	// replace any backward slashes, double quotes and double quotes in string
	local compfilename: subinstr local anything "\" "`c(dirsep)'", all
	local compfilename= subinstr("`compfilename'",`"""',"",.)
	if (regexm(`"`compfilename'"',`"^[\`]?["](.*)["][']?$"')) local compfilename=regexs(1)
	`loudres' "found file: `compfilename'"
	`loudtext' "{hline 120}"
	`loudtext' _newline
	`loudres' "{bf:This ado-file {bf:reshapes} {bf:x}TargetCompetencies-datasets} from {bf:wide} to {bf:long} format"
	`loudtext' _newline
	`loudres'  "Structure of reshaped data is similar to long-shaped files (e.g. pTarget, pTargetCATI, pTargetCAWI)"
	`loudres' _col(5) "- wave indicators modified: wave_wX becomes wave==X  (e.g wave_w7==1 >> wave==7)"
	`loudres' _col(5) "- ID variables are: ID_t & wave"
	`loudtext' _newline
	`loudres' "{bf:Step 1: opening desired xTargetCompetencies-Data}" 

************************************************************************	
	
	use `"`compfilename'"', `clear'
	
	// create local with different variable lists
	
	//list: all variables
	unab allvars: _all

	unab wavevars: wave_w* // list: wave_wX-variables
	
	foreach wave of local wavevars { // extract numbers of waves
		assert regexm("`wave'","^wave_w([0-9]+)$")
		local wave=regexs(1)
		capture: assert wave_w`wave' == 0
		if _rc == 0 {
			drop wave_w`wave'
		}
		else {
			local waves : list waves | wave
			local waves_rev : list wave | waves_rev 
		}
	}
	
// set up a list off variables to check if it is a single item or a scored item
	local messedup_scorevarnames dgci110s_sc4a10_c dgci120s_sc4a10_c dgci130s_sc4a10_c dgci110s_sc4g9_c dgci120s_sc4g9_c dgci130s_sc4g9_c dgci110s_sc3g5_c dgci120s_sc3g5_c dgci130s_sc3g5_c dgci110s_sc3g9_c dgci120s_sc3g9_c dgci130s_sc3g9_c dgci110s_sc2k2_c dgci120s_sc2k2_c dgci110s_sc2g2_c dgci120s_sc2g2_c dgcj110s_c dgcj120s_c dgci110s_sc1n11_c dgci120s_sc1n11_c
		
	unab txvars: tx80211_w*	// list: instrument ids
	local donttouch `wavevars' `txvars' `idvars'  // these variables should not be checked for being scored items or single items (wave-indicators, instrument-variables, ID_t)
	
	local checkitems: list allvars - donttouch
	foreach checkitem of local checkitems {
		local singleitem ""
		if regexm("`checkitem'","^[a-z0-9]+_c$") local singleitem `checkitem'
		if regexm("`checkitem'","^[a-z0-9]+_sc[1-8][a-z0-9]+_c$") local singleitem `checkitem'
		if regexm("`checkitem'","^[a-z0-9]+$") local singleitem `checkitem'		
		foreach messedupvar of local messedup_scorevarnames {
			if "`checkitem'" == "`messedupvar'" local singleitem ""
		}
		local singleitems : list singleitems | singleitem
	}
	
	// list scoreditems: everything with is neither a singleitem or variable in list donttouch is a scored item
	local scoreditems : list checkitems - singleitems
		
	
	`loudres' _col(7) _dup(3) "." "found data for waves `waves'" _newline
//	local panelvarpairs ""
//	local panelvarpair ""
	foreach testitem of local scoreditems {
		local scorepanelvar ""
	*if regexm("`testitem'","([a-z]+[0-9].*)_sc[1-9][a-z][0-9]+_c$") local panelvar=regexs(1)+"_c"
	*if regexm("`testitem'","([a-z][a-z])[nkgsa]?c?i?[0-9][0-9]([0-9][0-9][0-9])_sc[1-9][a-z][0-9]+_c$") local panelvar=regexs(1)+"_"+regexs(2)	
	*if regexm("`testitem'","^mp[nkgsa]?c?i?[0-9][0-9]?([a-z][a-z][0-9][0-9])_(sc[1-9])$") local panelvar="mp_"+regexs(1)+"_"+regexs(2)
	if regexm("`testitem'","([a-z][a-z])[nkgsa]?c?i?[1-9][0-9]?_(sc[1-9][abu]?$)") local scorepanelvar=regexs(1)+"_"+regexs(2)
	if regexm("`testitem'","^mp[nkgsa]?c?i?[0-9]+([a-z][a-z])_(sc[1-9]?$)") local scorepanelvar = "mp_"+regexs(1)+"_"+regexs(2)
	if regexm("`testitem'","^mp[nkgsa]?c?i?[0-9][0-9]?n([rt])0[1-9]_(sc[56]$)") local scorepanelvar = "mp_n"+regexs(1)+"_"+regexs(2)
	if regexm("`testitem'","([a-z][a-z])[nkgsa]?c?i?[1-9][0-9]?_sc[0-9][nkgsa]?c?i?[1-9][0-0]?_(sc[1-9][abu]?$)") local scorepanelvar=regexs(1)+"_"+regexs(2)
	if regexm("`testitem'","^md[nkgsa]?c?i?[1-9][0-9]?([a-z][a-z])_(sc[0-9]$)") local scorepanelvar="md_"+regexs(1)+"_"+regexs(2)

// 		if "`panelvar'" != "" {
// 			// MEMO: BRAUCHT'S DAS? ODER WILL MAN NICHT IMMER PANELVARPAIRS SPEICHERN?
// 			capture: confirm variable `panelvar', exact
// 			if _rc==0 {
// 				`loudtext'  _col(7) _dup(3) "." "identified repeated item: `testitem' will be converted to `panelvar'"
// 				local panelvarpair "`testitem'|`panelvar'"
// 				local panelvarpairs : list panelvarpairs | panelvarpair
// 			}
// 		}
		if "`scorepanelvar'" != "" {
			capture: confirm variable `scorepanelvar', exact
			if _rc != 0 {
				`loudtext'  _col(7) _dup(3) "." "identified score/sum item: `testitem' will be converted to `scorepanelvar'"
				local scorepanelvarpair "`testitem'|`scorepanelvar'"
				local scorepanelvarpairs : list scorepanelvarpairs | scorepanelvarpair
			}
		}
	}

	`loudtext' _newline
	`loudres' "{bf:Step 2: cutting dataset into pieces - each wave a piece}"
	foreach wave of local waves {
		local harmvars_in_wave`wave' ""
		`loudres' _col(9) _dup(3) "." "working on data from wave `wave'"
		preserve   // save complete xTargetCompetencies in a temporary file
		
		capture: confirm variable tx80211_w`wave'
		if !_rc {
			rename tx80211_w`wave'  tx80211  // renaming variables with wave-suffixes
		}
		unab allvars:  _all   // generate a varlist containing all variables currently in the dataset
		local checkvars: list allvars - idvars // substract idvars ID_t and wave  from list of all variables
		quietly : count if inlist(wave_w`wave',1,.) // keep data from target persons 
		local numobs_wave`wave' `r(N)'
		//`loudtext' _col(12) _dup(3) "." "identifying variables in wave `wave'"
		foreach var of local checkvars {
			quietly: count if `var'!=-56  // count the number of cases unequal to -56
			local obs`var' `r(N)'
			// keeping vars if number of cases is equal to wave_wX==1
			 if `obs`var''==`numobs_wave`wave'' local varlist_wave`wave': list varlist_wave`wave' | var
		}
		//`loudtext' _col(12) _dup(3) "." "generating wave-indicator"
		generate wave = `wave' // generate wave indicator
		quietly : keep if wave_w`wave' == 1 // keep data of wave X
		//`loudtext' _col(12) _dup(3) "." "keeping only variables in wave `wave'"		
		keep ID_t wave `varlist_wave`wave''
		if `harmonizeit' == 1 {
			

			//foreach pairs of local scorepanelvarpairs {
			foreach pair of local scorepanelvarpairs {
			//foreach pair of local pairs {
				local found_longvar 0
				local found_testitem 0
				local itemsum ""
				//if regexm("`panelvarpairs'","`pairs'") local itemsum item
				//if regexm("`scorepanelvarpairs'","`pairs'") local itemsum sum
				local itemsum sum	
				gettoken testitem rest: pair, parse("|")
				gettoken rest longvar: rest, parse("|")
				capture: confirm variable `testitem', exact
				if _rc==0 local found_testitem 1
				capture: confirm variable `longvar', exact
				if _rc==0 local found_longvar 1
				if `found_testitem' == 1 & `found_longvar' == 1 {
					noisily: display as error "`testitem' and `longvar' should not be collect within the same wave, panelvars misspecified, please contact fdz@lifbi.de for further help!!!"
					if `ignoreit' == 0 {
						noisily: display as error "process canceled"
						exit 459
					}
					if `ignoreit' == 1  noisily: display as error "ok, you chose to go on but you really should consider to contact those guys"
					}
					
				else {
					if `found_testitem' == 1 {
						local sourcevar `testitem'
						local harmvar `longvar'_ha
						local scorevars : list scorevars | harmvar

				
						if `onlyharmonizedit' == 1 local harmvars : list harmvars | harmvar
						`loudtext' _col(12) "renaming `sourcevar' to `harmvar'"
						capture: assert "`sourcevar'" != "`harmvar'"
						if _rc != 0 noisily display as error "original items has same variable name as harmonized item!!!"
						if "`sourcevar'" != "`harmvar'" rename `sourcevar' `harmvar'
						local harmvarlab `: variable label `harmvar'' (e.g. `sourcevar', harmon.)
						if length("`harmvarlab'") > 80 {
							local harmvarlab = usubinstr("`harmvarlab'","prozedurale","prozed.",.)
							local harmvarlab = usubinstr("`harmvarlab'","deklarative","deklar.",.)
							local harmvarlab = usubinstr("`harmvarlab'","Metakognition","Metakog.",.)
							local harmvarlab = usubinstr("`harmvarlab'","Standardfehler","SE",.)
							if regexm("`harmvarlab'",".*([Ss]tandard [Ee]rror).*") local harmvarlab = usubinstr("`harmvarlab'",regexs(1),"SE",.)
							if regexm("`harmvarlab'",".*([Nn]aturwissenschaf[a-z]+).*") local harmvarlab = usubinstr("`harmvarlab'",regexs(1),"NaWi",.)
							if regexm("`harmvarlab'",".*[Ww][Ll][Ee](-Schätzer[s]?).*") local harmvarlab = usubinstr("`harmvarlab'",regexs(1),"",.)
							local harmvarlab = usubinstr("`harmvarlab'","(A101:32; B108:12 Items)","",.)
							local harmvarlab = usubinstr("`harmvarlab'","Mathematische","Mathem.",.)
							local harmvarlab = usubinstr("`harmvarlab'","Mathematik","Mathe",.)
							local harmvarlab = usubinstr("`harmvarlab'","Kompetenz","Komp.",.)
							local harmvarlab = usubinstr("`harmvarlab'","Längsschnitt","Längsschn.",.)
							local harmvarlab = usubinstr("`harmvarlab'","Querschnitt","Querschn.",.)
							local harmvarlab = usubinstr("`harmvarlab'","Erstsprache","Erstspr.",.)
							local harmvarlab = usubinstr("`harmvarlab'","Wissenschaftsverständnis","Wissenschaftsverst.",.)
							if regexm("`harmvarlab'",".*(korrigiert[e]?[r]?).*") local harmvarlab = usubinstr("`harmvarlab'",regexs(1),"korr.",.)
						}
						quietly: label variable `harmvar' `"`harmvarlab'"'
						local harmvars_in_wave`wave': list harmvars_in_wave`wave' | harmvar			
						
					}
				}
			}
		}
		
		unab allvars: _all
		local varlist_wave`wave' : list allvars - idvars
		local vars_allwaves: list vars_allwaves | varlist_wave`wave' 
		tempfile xComp`wave'  // defining tempfile
		//`loudtext' _col(12) _dup(3) "." "competency data from wave `wave' stored in seperate temporary file (=wide-format)"
		order ID_t wave, first
		quietly : save "`xComp`wave''", replace // save shrinked xTargetCompetencies of wave X to tempfile for late usage
		
		restore // return to complete  xTargetCompetencies in a temperary file (saved using "preserve")
		
	}
	

	`loudtext' _newline
	`loudres' "Step 3: append separated temporary wide-format data to a long-format dataset"
	// generate long-format pTargetCompetencies:
	local append_cntr 0
	foreach wave of local waves_rev {
		local masteronlylist ""
		local usingonlylist ""
		//`loudtext' _col(9) _dup(3) "." "appending data from wave `wave'"		
		if `++append_cntr' == 1 {
			quietly : use "`xComp`wave''", clear
			local allvarlist : copy local varlist_wave`wave'
		}
		else {
			local masterlist : copy local allvarlist
			local usinglist : copy local varlist_wave`wave'
			local masteronlylist : list masterlist - usinglist
			local usingonlylist: list usinglist - masterlist
			local bothlist: list masterlist & usinglist
			tempvar append_indic`append_cntr'
			append using "`xComp`wave''" , nolabel generate(`append_indic`append_cntr'') // appending wave-specific xTargetCompetencies-Files
			if "`masteronlylist'"!="" foreach mastervar of local masteronlylist {
				quietly: replace `mastervar' = -54 if `append_indic`append_cntr'' == 1
			}
			if "`usingonlylist'"!="" foreach usingvar of local usingonlylist {
				quietly: replace `usingvar' = -54 if `append_indic`append_cntr'' == 0
			}
			drop `append_indic`append_cntr''
			local allvarlist : list masterlist | usingonlylist
		}
		erase "`xComp`wave''"	
	}
	`loudtext' _newline
	`loudres' "{bf:Step 4: final checks and cleaning the mess}"
	`loudres' _col(9) _dup(3) "." "checking for uniqueness within ID_t and wave"
	isid ID_t wave
	`loudres' _col(9) _dup(3) "." "ordering variables"
	order ID_t wave `vars_allwaves'
	capture: confirm variable tx80211
	if !_rc {
		order tx80211, after(wave)
	}

	`loudres' _col(9) _dup(3) "." "sorting dataset rows for ID_t and wave"
	sort ID_t wave
	if `onlyharmonizedit' == 1 {
		`loudres' _col(9) _dup(3) "." "chosen option onlyharmonized: keeping only harmonized variables"
	    keep `idvars' `harmvars'
	}
		
	    
	*`loudres' _col(9) _dup(3) "." "keeping only harmonized sum scores WLEs and WLE-standard-errors"

	label variable wave "Welle"
	`loudtext' _newline
	`loudtext' "{hline 80}"
	if `saveit'==1 {
		save `"`save'"', `replace'
	}
	`loudres' "{bf:...done, file is in long format now!!!}"


exit 0
end
// EOF
