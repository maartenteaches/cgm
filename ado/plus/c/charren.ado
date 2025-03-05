/*-------------------------------------------------------------------------------
  charren.ado: rename variables via characteristics saved in the dataset
  
    Copyright (C) 2012-2021  Daniel Bela (daniel.bela@lifbi.de)

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
*! charren.ado: rename variables via characteristics saved in the dataset
*! Daniel Bela (daniel.bela@lifbi.de), Leibniz Institute for Educational Trajectories (LIfBi), Germany
*! version 1.2 30 August 2021 - wrap charren around the EMD framework, so that is does not default to NEPS-only characteristics' names
*! version 1.1 04 May 2015 - do no abort when meta data erroneously contains the same target name for multiple variables [bug report N. Kracke, IAB Nuremberg (thanks!)]
*! version 1.0.1 27 February 2015 - fixed typo in help file [bug report N. Stawarz, Univ. of Siegen (thanks!)]
*! version 1.0 14 October 2013 - support for -charren _all-; correctly search in characteristics prefixed by "NEPS_"
*! version 0.9.1 15 January 2013 - fixed issue in checking current Stata version (for compatibility to versions <12) [bug report D. Klein, Univ. of Bamberg (thanks!)]
*! version 0.9 28 November 2012 - initial release
program define charren, rclass
	version 9
	local EMD_prefix : char _dta[EMD_prefix]
	if (!missing(`"`EMD_prefix'"')) {
		local defsearchspace `EMD_prefix'varname `EMD_prefix'alias
	}
	else {
		local defsearchspace oldname tempname instname sufname NEPS_instname NEPS_sufname
	}
	// check for correct syntax, and drop usage-message if incorrect (or requested)
	if inlist(trim(lower(`"`0'"')),"help","--help","-h","h","/?","/help","/h","") {
		noisily: display _newline as result in smcl `"{phang}{bf:Usage:}"' _newline `"{break}{text}{cmd:charren} {help namelist:namelist}, {opt to(charname)} [{opt search:space(charlist)} {opt verbose}]{p_end}"' _newline(2) ///
		`"{pmore}{text}Rename each variable in {help namelist:namelist} to its alternative name, as defined in the characteristic {help char:var[{it:charname}]}."' _newline ///
		`"{text}In the NEPS datasets, alternative names available are {it:instname} and {it:sufname}."' _newline ///
		`"{text}Note that even if you specify one of the alternative names in {help namelist:namelist}, everything will work out properly as long as an appropriate search space is specified with the option {opt searchspace(charlist)}. "' ///
		`"{text}If omitted, the latter defaults to the array {it:`defsearchspace'}.{p_end}"'
		exit 0
	}
	else {
		capture: syntax namelist(min=1), to(name) [SEARCHspace(string) VERBOSE]
		if c(rc)!=0 {
			noisily: display as error in smcl "{pstd}{bf:Error:} invalid syntax. See {stata charren --help} for quick help or {help charren:help charren} for details.{p_end}" _newline(2) ///
			as result in smcl `"{phang}{bf:Usage:}"' _newline `"{break}{text}{cmd:charren} {help namelist:namelist}, {opt to(charname)} [{opt search:space(charlist)} {opt verbose}]{p_end}"'
			exit `c(rc)'
		}
	}
	// initialize macros
	local count 0
	local fromgroup ""
	local togroup ""
	if missing(`"`searchspace'"') local searchspace `defsearchspace'
	if (inlist(`"`namelist'"',"_all","*")) unab namelist : _all
	// check for source variable names
	foreach var of local namelist {
		local fromname ""
		local toname ""
		capture: confirm variable `var'
		if c(rc)!=0 {
			// search in given searchspace
			if "`verbose'"=="verbose" noisily: display as result in smcl "{text}{bf:Info:} {it:`var'} is not a variable name in current dataset; searching for {it:`var'} in specified search space"
			local returncode `c(rc)'
			foreach testvar of varlist _all {
				foreach testname of local searchspace {
					if "`: char `testvar'[`testname']'"=="`var'" {
						local fromname `testvar'
						continue, break
					}
					if !missing("`fromname'") continue, break
				}
			}
			if missing("`fromname'") {
				noisily: display as error in smcl "{bf:Error:} cannot find variable {it:`var'}, did you specify the correct {stata charren --help:searchspace()}?"
				continue
			}
		}
		else local fromname `var'
		local toname: char `fromname'[`to']
		if "`toname'"=="`fromname'" {
			if "`verbose'"=="verbose" noisily: display as result in smcl "{text}{bf:Info:} variable {it:`fromname'} already named in accordance with {it:`to'}, skipped"
			continue
		}
		else if missing("`toname'") {
			if "`verbose'"=="verbose" noisily: display as result in smcl "{text}{bf:Info:} cannot find {it:`to'} for variable {it:`fromname'}, skipped"
			continue
		}
		else if (`: list toname in togroup'==1) {
			if "`verbose'"=="verbose" noisily: display as error in smcl "{bf:Warning:}{text} target name {it:`toname'} multiply defined in meta data; will not rename {it:`fromname'} to {it:`to'}"
			continue
		}
		else {
			foreach type in from to {
				assert `: list `type'name in `type'group'==0
				local `type'group: list `type'group | `type'name
			}
			if "`verbose'"=="verbose" noisily: display as result "{bf:Info:} will rename {it:`fromname'} to {it:`toname'}"
			if c(stata_version)<12 rename `fromname' `toname'
			return local from`++count' `fromname'
			return local to`count' `toname'
			continue
		}
	}
	// execute -rename group-, if this is Stata 12 or higher
	if c(stata_version)>=12 {
		version 12.1
		capture: assert !missing(`"`fromgroup'"') & !missing(`"`togroup'"')
		if c(rc)==0 rename (`fromgroup') (`togroup')
		else assert `count'==0
	}
	return scalar renamed=`count'
	exit 0
end
// EOF
