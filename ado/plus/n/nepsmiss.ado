/*-------------------------------------------------------------------------------
  nepsmiss.ado:  create Stata extended missing codes from NEPS missing codes
  
    Copyright (C) 2011-2015  	Daniel Bela (daniel.bela@lifbi.de)
				Jan Skopek

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

-------------------------------------------------------------------------------*/
*! nepsmiss.ado: create Stata extended missing codes from NEPS missing codes
*! Daniel Bela (daniel.bela@lifbi.de) Leibniz Institute for Educational Trajectories (LIfBi), Germany and Jan Skopek
*! version 2.6 18 July 2016: added option -legacydefailt- to use the legacy NEPS default missings; use "NEPSMISS_*" as char names
*! version 2.5.2 09 June 2015: corrected typo in nepsmiss help file
*! version 2.5.1 16 May 2013: corrected default misslist including -91, matching missing list in doi:10.5157/NEPS:SC5:3.0.0
*! version 2.5 18 September 2012: corrected default misslist including -99 and -56, matching missing list in doi:10.5157/NEPS:SC2:1.0.0
*! version 2.4.1 04 June 2012: bugfix in recoding values without labels
*! version 2.4 25 April 2012: recoding values without labels correctly; corrected default -misslist- values (now including -9-); bugreport by D. Gaterman, WZB (thanks!)
*! version 2.3 17 January 2012: fixed recoding of values without labels; speedup by using replace instead of recode; made `varlist' optional
*! version 2.2 12 January 2012: fixed handling of value labels with multiple variable associations
*! version 2.1 09 November 2011: added option 'misslist' for generalization
*! version 2.0 02 November 2011: major rewrite; added option 'reverse', added functionality for multilingual labels
*! version 1.0 02 August 2011: inital release

program define nepsmiss, rclass
	syntax [varlist(min=1)] [, Reverse Verbose Keeplabels Misslist(numlist min=1 max=26) LEGACYdefault]
	quietly: label language
	local languages `r(languages)'
	local mainlang `r(language)'
	local changed=0
	local nepsmissings "-99/-91 -90 -56/-52 -29/-20"
	local legacy_nepsmissings "-99/-91 -90 -56/-52 -25/-20 -9/-5"
	// check if -misslist- and/or -legacydefault- are specified, if not: set default NEPS list
	if `"`legacydefault'"'=="" local defaultlist : copy local nepsmissings
	else local defaultlist : copy local legacy_nepsmissings
	if `"`misslist'"'=="" local misslist : copy local defaultlist
	else if (!missing(`"`legacydefault'"')) noisily : display as error in smcl `"Option {it:`legacydefault'} will not have an effect, as you invoked {cmd:nepsmiss} with a user-defined {opt misslist()}!"'
	// query values to process for all variables
	if "`reverse'"!="reverse" {
		labquery `varlist' , languages(`languages')	mainlang(`mainlang') misslist(`misslist') `verbose'	// subroutine defined below
		local labqueryresult `r(labqueryresult)'
	}	
	// change values if applicable
	foreach var of varlist `varlist' {
		// ignore string variables
		capture: confirm string variable `var'
		if !_rc {
			if `"`verbose'"'=="verbose" noisily: display as text in smcl `"Variable {it:`var'} is string and will be ignored."'
			continue
		}
		// process numeric variables
		else {
			// run reverse mode if requested
			if "`reverse'"=="reverse" {
				if `"`verbose'"'=="verbose" noisily: display _newline as text in smcl `"Begin decoding extended missing values for variable {it:`var'}."'
				frommiss `var' , languages(`languages') mainlanguage(`mainlang') `keeplabels' `verbose'				// subroutine defined below
				if `"`verbose'"'=="verbose" noisily: display as result in smcl `"Applied changes to `r(frommissresult)' values (and maybe labels) in {it:`var'}."'
				local changed=`changed'+`r(frommissresult)'
			}
			// regular mode
			else {
				if `"`verbose'"'=="verbose" noisily: display _newline as text in smcl `"Begin encoding missing values for variable {it:`var'}."'
				tomiss `var' , languages(`languages') mainlanguage(`mainlang') `keeplabels' `verbose'				// subroutine defined below
				local tomissresult `r(tomissresult)'
				if `"`verbose'"'=="verbose" noisily: display as result in smcl `"Applied changes to `tomissresult' values (and maybe labels) in {it:`var'}."'
				local changed=`changed'+`tomissresult'
			}
		}
	}
	if `"`languages'"'!=`"`mainlang'"' quietly: label language `mainlang'
	return scalar changed=`changed'
	noisily: display as result in smcl `"Recoded {it:`changed'} values in total"'
	exit 0
end 

// subroutine querying missings and labels, and saving them in characteristics
program define labquery, rclass
	syntax varlist(min=1) , LANGuages(string asis) MAINlang(string asis) Misslist(numlist min=1) [VERBOSE]
	local skipvars ""
	foreach var of local varlist {
		local i=0
		if `"`verbose'"'=="verbose" noisily: display _newline as text in smcl `"Begin querying information for variable {it:`var'}."'
		local alreadydone: list var in skipvars
		if `alreadydone'==1 {
			if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...value for variable {it:`var'} already queried; skipped variable {it:`var'}"'
			continue
		}
		local oldmisscount: char `var'[NEPSMISS_misscount]
		if `"`oldmisscount'"'!="" {
			 if `"`verbose'"'=="verbose" noisily: display as error in smcl `"{bf:Warning:} variable {it:`var'} seems to have been encoded with nepsmiss already; label query skipped"'
			continue
		}
		local vallab: value label `var'
		if missing(`"`vallab'"') {
			if strmatch("`:type `var''","str*") {
				noisily: display as text in smcl `"Variable {it:`var'} is string; skipped"'
				continue
			}
			if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...no value label for variable {it:`var'}"'
			foreach val of numlist `misslist' {
				quietly: count if `var'==`val'
				if `r(N)'>0 {
					if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...detected value {it:`val'} in variable {it:`var'}"'
					// pre-save valid and missing value
					local mis ".`: word `++i' of `c(alpha)''"
					char define `var'[NEPSMISS_val`i'] "`val'"
					char define `var'[NEPSMISS_mis`i'] "`mis'"
				}
			}
			char define `var'[NEPSMISS_misscount] "`i'"
			continue
		}
		quietly: ds `varlist', has(vallabel `vallab')
		local varstoprocess `r(varlist)'
		quietly: ds , has(vallabel `vallab')
		local allvallabvars `r(varlist)'
		local surplusvars: list allvallabvars - varstoprocess
		if `"`surplusvars'"'!="" noisily display as error in smcl `"{bf:Warning:} value label {it:`vallab'} is also attached to variables {it:`surplusvars'};"' _newline as error in smcl `"these surplus variables will not be recoded!"' _newline as error in smcl `"Consider running {it:nepsmiss} on those variables as well to correctly recode them!"'
		foreach val of numlist `misslist' {
			local lab: label `vallab' `val', strict
			if missing(`"`lab'"') {
				// intercept missing values without value label, but empirically in the data
				foreach subvar of local allvallabvars {
					quietly: count if `subvar'==`val'
					if `r(N)'>0 noisily: display as error in smcl `"...detected value {it:`val'} in variable {it:`subvar'}, but it has no entry in value label {it:`vallab'}; this might be a metadata or data error!"'
				}
			}
			if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...detected value {it:`val'} in value label {it:`vallab'}"'
			// pre-save valid and missing value
			local mis ".`: word `++i' of `c(alpha)''"
			foreach subvar of local allvallabvars {
				char define `subvar'[NEPSMISS_val`i'] "`val'"
				char define `subvar'[NEPSMISS_mis`i'] "`mis'"
			}
			// pre-save labels (for each language)
			foreach lang of local languages {
				quietly: label language `lang'
				foreach subvar of local allvallabvars {
					local langvallab: value label `subvar'
					if !missing("`langvallab'") {
						local lab: label `langvallab' `val', strict
						char define `subvar'[NEPSMISS_lab`i'`lang'] "`lab'"
						char define `subvar'[NEPSMISS_vallab`lang'] "`langvallab'"
					}
					if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...assigned missing {it:`mis'} to variable {it:`subvar'} (language: {it:`lang'})"'
				}
				quietly: label language `mainlang'
			}
		}
		foreach subvar of local allvallabvars {
			char define `subvar'[NEPSMISS_misscount] "`i'"
		}
		local skipvars: list skipvars | varstoprocess
	}
	if `"`verbose'"'=="verbose" noisily: display _newline as text in smcl `"...pre-saved total of {it:`i'} numeric missing values for variables {it:`varlist'}"'
	return local labqueryresult `i'
	exit 0
end

// subroutine converting NEPS-missings to extended missings
program define tomiss, rclass
	syntax varname , LANGuages(string asis) MAINlanguage(string asis) [Keeplabels VERBOSE]
	local misscount: char `varlist'[NEPSMISS_misscount]
	capture: assert `"`misscount'"'!=""
	if _rc!=0 {
		local misscount 0
	}
	// only encode if NEPS missings detected
	local recoded 0
	if `misscount'>0 {
		if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...found {it:`misscount'} numeric missing values for variable {it:`varlist'}"'
		forvalues i=1/`misscount' {
			// recode variable
			local val: char `varlist'[NEPSMISS_val`i']
			local mis: char `varlist'[NEPSMISS_mis`i']
			quietly: count if `varlist'==`val'
			local recoded=`recoded'+`r(N)'
			quietly: replace `varlist'=`mis' if `varlist'==`val'
			if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...recoded {it:`val'} to {it:`mis'} variable {it:`varlist'}"'
			// modify label for each language
			foreach lang of local languages {
				local vallab: char `varlist'[NEPSMISS_vallab`lang']
				if "`vallab'" != "" {
					local lab: char `varlist'[NEPSMISS_lab`i'`lang']
					quietly: label language `lang'
					local oldmislab: label `vallab' `mis', strict
					local oldvallab: label `vallab' `val', strict
					if !missing(`"`oldmislab'"') {
						assert missing(`"`oldvallab'"')
						if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...value label {it:`vallab'} already modified, skipping for variable {it:`varlist'} (language: {it:`lang'})"'
					}
					else {
						if `"`keeplabels'"'!="keeplabels" {
							label define `vallab' `mis' `"`lab'"' `val' "", modify
							if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...modified value label {it:`vallab'} for variable {it:`varlist'} (language: {it:`lang'})"'
						}
					}
					quietly: label language `mainlanguage'
				}
				else {
					if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...no value label for variable {it:`varlist'} (language: {it:`lang'})"'
				}
			}
		}
	}
	else {
		if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...no numeric missing values for variable {it:`varlist'}, skipped"'
	}
	return local tomissresult `recoded'
	exit 0
end

// subroutine converting extended missings to NEPS-missings
program define frommiss, rclass
	syntax varname , LANGuages(string asis) MAINlanguage(string asis) [Keeplabels VERBOSE]
	local misscount: char `varlist'[NEPSMISS_misscount]
	capture: assert `"`misscount'"'!=""
	if _rc!=0 {
		local misscount 0
	}
	// only encode if NEPS missings detected
	local recoded 0
	if `misscount'>0 {
		if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...found {it:`misscount'} pre-saved numeric missing values for variable {it:`varlist'}"'
		forvalues i=1/`misscount' {
			// recode variable
			local val: char `varlist'[NEPSMISS_val`i']
			local mis: char `varlist'[NEPSMISS_mis`i']
			quietly: count if `varlist'==`mis'
			local recoded=`recoded'+`r(N)'
			quietly: replace `varlist'=`val' if `varlist'==`mis'
			if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...recoded {it:`mis'} to {it:`val'} variable {it:`varlist'}"'
			// modify label for each language
			foreach lang of local languages {
				local vallab: char `varlist'[NEPSMISS_vallab`lang']
				if "`vallab'" != "" {
					local lab: char `varlist'[NEPSMISS_lab`i'`lang']
					quietly: label language `lang'
					local oldmislab: label `vallab' `mis', strict
					local oldvallab: label `vallab' `val', strict
					if !missing(`"`oldvallab'"') {
						assert missing(`"`oldmislab'"')
						if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...value label {it:`vallab'} already modified, skipping for variable {it:`varlist'} (language: {it:`lang'})"'
					}
					else {
						if `"`keeplabels'"'!="keeplabels" {
							label define `vallab' `val' `"`lab'"' `mis' "", modify
							if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...modified value label {it:`vallab'} for variable {it:`varlist'} (language: {it:`lang'})"'
						}
					}
					quietly: label language `mainlanguage'
				}
				else {
					if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...no value label for variable {it:`varlist'} (language: {it:`lang'})"'
				}
			}
		}
	}
	else {
		if `"`verbose'"'=="verbose" noisily: display as text in smcl `"...no numeric missing values for variable {it:`varlist'}, skipped"'
	}
	return local frommissresult `recoded'
	exit 0
end
// EOF
