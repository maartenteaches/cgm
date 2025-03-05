/*-------------------------------------------------------------------------------
  nepsuse.ado: conveniently open a NEPS Scientific Use File (SUF) dataset
  
    Copyright (C) 2016-2018  	Daniel Bela (daniel.bela@lifbi.de)

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
*! nepsuse.ado: conveniently open a NEPS Scientific Use File (SUF) dataset
*! Daniel Bela (daniel.bela@lifbi.de) Leibniz Institute for Educational Trajectories (LIfBi), Germany
*! version 1.2.1 04 May 2018: fixed a bug where nepsuse died when using the language option in combination with quoted file names (thanks for bug report by A. Bela, LIfBi)
*! version 1.2 11 April 2018: several bugs fixed, added option 'setup' to auto-save global macros (thanks for bug hunting an helpful suggestions for improvement by D. Klein, Univ. Kassel)
*! version 1.1 04 March 2017: bugfix when opening a dataset without "use ... using" syntax, and using the option "language()"
*! version 1.0 27 July 2016: inital release
program define nepsuse , nclass
	if (`c(stata_version)'<14) {
		local fcn_strupper strupper
		local fcn_substr substr
		local fcn_regex regex
		local fcn_regexr regexr
		local fcn_length strlen
		local fcn_subinstr subinstr
		version 12
	}
	else {
		local fcn_strupper ustrupper
		local fcn_substr usubstr
		local fcn_regex ustrregex
		local fcn_regexr ustrregexrf
		local fcn_length udstrlen
		local fcn_subinstr usubinstr
		version 14
	}
	noisily : display as error in smcl `"{bf:Warning: nepsuse} is deprecated; please consider migrating your syntax to use its successor, {bf:neps}."' _newline `"{tab}See {help neps:help neps} for details on this more powerful command."'
	* program metadata
	local nepsuse_version "1.2"
	local nepsuse_date "11 April 2018"
	local nepsuse_shortdesc `"conveniently open a NEPS Scientific Use File (SUF) dataset"'
	local nepsuse_options cohort version level language directory
	* parse allowed syntax; use case 1: no arguments at all, or only ", setup"; display version and a pretty table of pre-recorded option preferences and exit
	if (missing(`"`0'"') | `fcn_regex'm(`fcn_subinstr'(`fcn_strupper'(`"`0'"')," ","",.),`"^,(SET((U)|(UP))?)?$"')) {
		noisily: display as result in smcl `"{text}This is {cmd:nepsuse} version {result}`nepsuse_version'{text} ({result}`nepsuse_date'{text}),"' , ///
			`"{text}a program to `nepsuse_shortdesc'"' , _newline `"{text}see {help nepsuse:help nepsuse} for more information"'
		local col1width 6
		local col2width 7
		local nepsuse_prefs 0
		foreach macro of local nepsuse_options {
			local preference : copy global NEPSuse_`macro'
			if (!missing(`"`preference'"')) {
				local col1width=max(`fcn_length'(`"`macro'"'),`col1width')
				local col2width=max(`fcn_length'(`"`preference'"'),`col2width')
				local nepsuse_pref`++nepsuse_prefs'name `macro'
				local nepsuse_pref`nepsuse_prefs'content `macval(preference)'
			}
		}
		if (`nepsuse_prefs'>0) {
			noisily : display as result in smcl _newline `"{text}previously recorded preferences for {cmd:nepsuse}:"'
			noisily : display as result in smcl _newline `"{p2colset 4 `=`col1width'+8' `=`col1width'+10' `=c(linesize)-(`col2width'+`col1width'+7)'}{p2col :option}content{p_end}"'
			noisily : display as result in smcl `"{p2line}"'
			forvalues num=1/`nepsuse_prefs' {
				noisily : display as result in smcl `"{text}{p2col :`macval(nepsuse_pref`num'name)'()}{result}`macval(nepsuse_pref`num'content)'{p_end}"'
			}
		}
		exit 0
	}
	* parse allowed syntax; use case 2: only -setup- and options are specified, but no file name etc; note: no additional options for -use- are allowed then
	if (replay()==1) {
		syntax [ , DIRectory(string asis) Cohort(string asis) VERsion(string asis) LEVel(string asis) LANGuage(string asis) SETup ]
	}
	* parse allowed syntax; use case 3: file name etc. is specified
	else {
		syntax anything(id="NEPS dataset name" name=allparams everything) [ , DIRectory(string) Cohort(string) VERsion(string) LEVel(string) LANGuage(string) SETup *]
	}
	* if not specified as option, copy dirname, cohort, etc from global macros (if present)
	foreach macro of local nepsuse_options {
		if missing(`"`macval(`macro')'"') {
			local `macro' : copy global NEPSuse_`macro'
			if missing(`"``macro''"') {
				if (`"`macro'"'=="directory") {
					local directory .
					continue
				}
				else if (`"`macro'"'=="language") continue
				noisily : display as error in smcl `"option {opt `macro'()} or global macro {it:{c S|}{c -(}NEPSuse_`macro'{c )-}} required"'
				exit 198
			}
		}
		else if (`"`setup'"'==`"setup"' | replay()==1) {
			* record setup preferences
			global NEPSuse_`macro' ``macro''
			noisily : display as result in smcl `"{text}({result}NEPSuse_`macro'{text} preference recorded: {result}``macro'')
		}
	}
	* use case 2 scenario ends here
	if (replay()==1) exit 0
	* insert trailing space character after "using", and before file name, if missing
	if (`fcn_regex'm(`"`macval(allparams)'"',`"((.*) )?using(["\`].*)"')) local allparams=`fcn_regex's(1)+" using "+`fcn_regex's(3)
	local usingpos: list posof "using" in allparams
	if (`usingpos'>0) {
		local usingname : word `=`usingpos'+1' of `macval(allparams)'
	}
	else local usingname : word 1 of `macval(allparams)'
	* strip off manually specified double quotes around directory path, if any
	local directory `macval(directory)'
	* replace Windows-like backslash path delimiters with forward slashes
	local directory : subinstr local directory "\" "/" , all
	* tolerate specifying "download", "remote" or "onsite" instead of "D", "R" or "O" as level
	local level=`fcn_strupper'(`fcn_substr'(`"`level'"',1,1))
	* tolerate specifying lower case cohort names
	local cohort=`fcn_strupper'(`"`cohort'"')
	// concatenate full file path
	local dashedversion : subinstr local version "." "-" , all
	local fullpath `"`"`directory'/`cohort'_`usingname'_`level'_`dashedversion'.dta"'"'
	local namelist=`fcn_regexr'(`"`macval(allparams)'"',`"((\`)?")?`macval(usingname)'("(')?)?"',`"`macval(fullpath)'"')
	local anything=`fcn_regexr'(`"`macval(allparams)'"',`"((\`)?")?`macval(usingname)'("(')?)?"',`"`macval(fullpath)'"')
	// the following if/else-block is a dirty workaround, because Stata currently
	// does not read multi-language labels when using -use ... using ...-;
	// if it does in the future, this block is obsolete and can be safely
	// replaced by lines 182 and 183
	if (!missing(`"`language'"')) {
		use `fullpath' , `options'
		quietly {
			* extract -if- from -namelist-
			local ifpos: list posof "if" in namelist
			if (`ifpos'>0) {
				local if
				forvalues wordnum=`ifpos'/`: word count `namelist'' {
					local nextword : word `wordnum' of `namelist'
					if (inlist(`"`nextword'"',`"in"',`"using"')) continue , break
					local if `"`if' `nextword'"'
				}
				local if=`fcn_substr'(`"`if'"',2,.)
				local namelist : subinstr local namelist `"`if'"' ""
			}
			* extract -in- from -namelist-
			local inpos: list posof "in" in namelist
			if (`inpos'>0) {
				local in
				forvalues wordnum=`inpos'/`: word count `namelist'' {
					local nextword : word `wordnum' of `namelist'
					if (inlist(`"`nextword'"',`"using"')) continue , break
					local in `"`in' `nextword'"'
				}
				local in=`fcn_substr'(`"`in'"',2,.)
				local namelist : subinstr local namelist `"`in'"' ""
			}
			* extract -using- from -namelist-
			local usingpos: list posof "using" in namelist
			if (`usingpos'>0) {
				local usingfile : word `=`usingpos'+1' of `namelist'
				local namelist : subinstr local namelist `"using `"`usingfile'"'"' ""
				local namelist : subinstr local namelist `"using "`usingfile'""' ""
				local namelist : subinstr local namelist `"using `usingfile'"' ""
			}
			else {
				local namelist : subinstr local namelist `"`: word 1 of `namelist''"' ""
			}
			local namelist `namelist' // get rid of empty string quotes in `namelist' that prevent from checking for missing content
			if (!missing(`"`namelist'"')) keep `namelist'
			if (!missing(`"`in'"')) keep `in'
			if (!missing(`"`if'"')) keep `if'
			capture : label language `language'
			if (_rc!=0) {
				local activelang : char _dta[_lang_c]
				if missing(`"`activelang'"') local activelang "default"
				noisily : display as error in smcl `"{bf:Warning:} language {it:`language'} is undefined in {it:`fullpath'};"' ///
				_newline `"{tab}file has been loaded anyways, with active language {it:`activelang'}"'
			}
		}
	}
	else use `anything' , `options'
	// the desired way  for the above workaround would be this, regardless which options are specified:
	*use `anything' , `options'
	*if (!missing(`"`language'"')) label language `language'
	exit 0
end
// EOF
