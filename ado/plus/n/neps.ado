/*-------------------------------------------------------------------------------
  neps.ado: prefix command to conveniently handle NEPS Scientific Use File data
  
    Copyright (C) 2018-2019  	Daniel Bela (daniel.bela@lifbi.de)
								Daniel Klein

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
*! neps.ado: prefix command to conveniently handle NEPS Scientific Use File data
*! Daniel Bela (daniel.bela@lifbi.de), Leibniz Institute for Educational Trajectories (LIfBi), Germany
*! Daniel Klein, INCHER-Kassel
*! version 1.2 18 June 2019: bugfix in syntax parsing with non-default language -neps set-
*! version 1.1 08 May 2019: bugfix in parsing file names followed by comma from syntax (bug report by U. Liebeskind, Univ. of Siegen; thanks!)
*! version 1.0 20 September 2018: first public release
*! version 0.9.1 29 May 2018: (bugfixes after feedback by D. Klein, INCHER-Kassel)
*! version 0.9 02 May 2018: initial (internal) release
// neps main command itself
program define neps , nclass
	* version compatibility: unicode functions for 14 or younger
	if (_caller()<14) {
		version 11
		local strpos strpos
		local strupper strupper
		local regexm regexm
		local regexs regexs
		local substr substr
		local strtrim strtrim
		local regexr regexr
	}
	else {
		version 14
		local strpos ustrpos
		local strupper ustrupper
		local regexm ustrregexm
		local regexs ustrregexs
		local substr usubstr
		local strtrim ustrtrim
		local regexr ustrregexrf
	}
	* set prefix, if supported (Stata 13 or younger)
	if (_caller()>=13) set prefix neps
	* prepare macros
	// list of Stata commands featuring file name spec without "using" (like "use"; list is quoted, comma-separated)
	local masterloadcmds `""use","useold""'
	local neps_subcmds `""set","clear","query","fileparse""' // valid neps subcommands (list is quoted, comma-separated))
	local mandatory_prefs study level version // mandatory parameters for file name concatenation 
	local optional_prefs directory language // optional parameters for file name concatenation
	local deprecated_prefs cohort // deprecated parameters that are implemented for legacy reasons
	local all_prefs : list mandatory_prefs | optional_prefs
	local all_prefs : list all_prefs | deprecated_prefs
	local query_prefs
	local set_prefs
	local filelist
	local fulllist
	local replacelist
	local use_with_tempfile 0
	local post_load_langswitch 0
	local post_load_vallabdef 0
	* check if we are in colon mode or not
	capture : _on_colon_parse `0'
	if (_rc!=0 | inlist(`"`: word 1 of `0''"',`neps_subcmds')) {
		* escape to _neps_set, _neps_clear, _neps_query, or _neps_fileparse where appropriate, abort otherwise
		if (missing(`"`macval(0)'"')) local 1 query // no subcmd should be treated as 'neps query'
		local subcmd `macval(1)'
		if (inlist(`"`macval(subcmd)'"',`neps_subcmds')) {
			local 0 : subinstr local 0 `"`macval(subcmd)'"' `""'
			capture : noisily : _neps_`subcmd' `macval(0)'
			if (_rc!=0) exit _rc
			if (`"`subcmd'"'=="query" & (`: list posof "returnlocals" in 0'!=0 | `: list posof ",returnlocals" in 0'!=0)) {
				foreach macro of local all_prefs {
					c_local `macro' `macval(`macro')'
				}
			}
			exit 0
		}
		else {
			display as error in smcl `"illegal {cmd:neps} subcommand: {it:`subcmd'}"'
			exit 198
		}
	}
	* save split-up syntaxes of prefix and called command
	local cmd `"`s(after)'"'
	local 0 `"`s(before)'"'
	* parse prefix syntax
	syntax [, Study(string) Level(string) Version(string) DIRectory(string) LANGuage(string) Cohort(string) SETup replace]
	* identify called command, parse its syntax
	local cmdname : word 1 of `macval(cmd)'
	capture : unabcmd `macval(cmdname)'
	if (_rc!=0) {
		display as error in smcl `"command {bf:`macval(cmdname)'} is unrecognized"'
		exit 199
	}
	local cmdname `r(cmd)'
	* make list of recorded preferences to read
	foreach pref of local all_prefs {
		if (missing(`"``pref''"')) {
			local query_prefs : list query_prefs | pref
		}
		else {
			* make list of preferences to record (if requested)
			if (`"`setup'"'=="setup") {
				local `pref' `macval(`pref')' // get rid of surrounding quotes, if any
				local set_prefs `set_prefs' `pref' `"`macval(`pref')'"'
			}
		}
	}
	* record preferences (if requested)
	if (!missing(`"`set_prefs'"')) _neps_set `set_prefs' , `replace'
	* read recorded preferences
	if (!missing(`"`query_prefs'"')) quietly : _neps_query `query_prefs' , returnlocals
	* if legacy option `cohort' is specified, replace `study' with its content
	if (!missing(`"`cohort'"')) {
		if (!missing(`"`study'"')) {
			display as error in smcl `"parameters {it:cohort} and {it:study} may not be combined"'
			exit 184
		}
		local study `macval(cohort)'
		display as error in smcl `"{bf:Warning:} {text}you are using deprecated syntax; please replace option {it:cohort(`macval(cohort)')} with {it:study(`macval(cohort)')}"'
	}
	* canonical dashed and dotted version number
	local dottedversion : subinstr local version "-" "." , all
	local dashedversion : subinstr local version "." "-" , all
	* directory names with forward slashes
	local directory : subinstr local directory "\" "/" , all
	* auto-replace @-Strings (@VERSION, @LEVEL, @STUDY) into directory, if appropriate
	local searchstrings : copy local mandatory_prefs
	local searchstrings `"`searchstrings' dashedversion dottedversion"'
	foreach atstring of local searchstrings {
		local searchstring="@"+`strupper'(`"`atstring'"')
		local replacestring=char(92)+char(96)+cond(`"`atstring'"'=="version","dashedversion","`atstring'")+char(39)
		local directory : subinstr local directory `"`macval(searchstring)'"' `"`macval(replacestring)'"' , all
	}
	* check if all mandatory preferences have been specified
	foreach pref of local mandatory_prefs {
		if (missing(`"`macval(pref)'"')) {
			display as error in smcl `"option {opt `pref'()} required"'
			exit 198
		}
	}
	// insert space character in case file specification is something like 'using"<file>"'
	if (`regexm'(`"`macval(cmd)'"',`"((.*) )?using([\`]?["].*)"')) local cmd=`regexs'(1)+" using "+`regexs'(3)
	* parse called command syntax and read filename(s) into list
	_get_filelist `macval(cmd)'
	if (!inlist(`"`cmdname'"',`masterloadcmds') & missing(`"`using'"')) {
		// nothing to do -- there is no "using", and this is not a non-"using" command; just execute `cmd'
		display as result in smcl `"{text}(neps prefix command has no effect on invocation of {cmd:`cmdname'})"'
		capture : noisily `cmd'
		exit _rc
	}
	* create full file name(s)
	local directory `directory' // resolve unescaped macros in `directory', if any
	foreach filename of local filelist {
		_neps_concatenate `filename' , study(`"`study'"') level(`"`level'"') dashedversion(`"`dashedversion'"') directory(`"`directory'"')
		local fulllist `"`fulllist' "`fullname'""'
	}
	local filecount : list sizeof fulllist
	* prepare file names for injection into command invocation, prepare dataset files if necessary
	// check if language option has been specified
	if (!missing(`"`macval(language)'"')) {
		// preserve original data
		preserve
		// language scenario 1: "use" or alike master-data loading command --> open from temporary file, switch language after loading
		if (inlist(`"`cmdname'"',`masterloadcmds')) {
			// such commands only allow for a single file specification
			if (`filecount'!=1) {
				display as error in smcl `"invalid file specification"'
				exit 198
			}
			// both scenarios: copy to temporary file
			local num `filecount'
			local file : word `num' of `filelist'
			local fullfile: word `num' of `fulllist'
			tempfile tmpfile`num'
			local fulllist : subinstr local fulllist `""`fullfile'""' `""\`tmpfile`num''""'
			capture : noisily confirm file `"`fullfile'"'
			if (_rc!=0) exit _rc
			quietly : copy `"`fullfile'"' `"`tmpfile`num''"'
			local use_with_tempfile 1
			local post_load_langswitch 1
			if (`"`using'"'==`"using"') {
				// language scenario 1a: "use" or alike master-data loading command, "using" found --> pre-save value labels with -label save-, re-insert value labels after loading from copied temp file and switching language
				capture : use `"`fullfile'"' in 1 , clear
				if (_rc!=0) use `"`fullfile'"' in 1 , clear
				_neps_switchlang `language'
				if (`s(langok)'==0) {
					tempfile labels
					quietly : label save using `"`labels'"'
					local post_load_langswitch 1
					local post_load_vallabdef 1
				}
			}
		}
		else {
			// language scenario 2: any other command: use file, change label language, save as temporary copy
			forvalues num=1/`filecount' {
				local file : word `num' of `filelist'
				local fullfile: word `num' of `fulllist'
				tempfile tmpfile`num'
				local fulllist : subinstr local fulllist `""`fullfile'""' `""\`tmpfile`num''""'
				capture : use `"`fullfile'"' , clear
				if (_rc!=0) use `"`fullfile'"' , clear
				_neps_switchlang `language'
				quietly : save `"`tmpfile`num''"'
			}
		}
		// restore original data
		restore
	}
	else {
		if (inlist(`"`cmdname'"',`masterloadcmds')) {
			// non-language scenario 1: "use" or alike master-data loading command --> load from copied temp file to prevent "save , replace" ovewriting original data
			forvalues num=1/`filecount' {
				local file: word `num' of `filelist'
				local fullfile: word `num' of `fulllist'
				tempfile tmpfile`num'
				local fulllist : subinstr local fulllist `""`fullfile'""' `""\`tmpfile`num''""'
				local use_with_tempfile 1
				quietly : copy `"`fullfile'"' `"`tmpfile`num''"'
			}
		}
		else {
			// non-language scenario 2: any other command: insert file name and done
			* nothing more to do
		}
	}
	* inject full file names or temporary file names into command invocation
	forvalues num=1/`filecount' {
		local file : word `num' of `filelist'
		local fullfile : word `num' of `fulllist'
		local fullfile : subinstr local fullfile "\" "/" , all
		local cmd=`regexr'(`"`cmd'"',`"((\`")|("))?`file'(("')|("))?"',`""`macval(fullfile)'""')
	}
	* drop warning message in case a temporary file has been read with -use- or similar
	if (`use_with_tempfile'==1) {
		noisily : display as error in smcl `"{p 0 4 2}{bf:Warning:}{text} will read file from temporary copy.{break}Do {bf:not} use {cmd:save , replace} without a file name afterwards, nor use {it:{c 'g}c(filename)'}!{p_end}"'
	}
	* run `cmd'
	`cmd'
	* re-define non-default value labels in case of use...using syntax
	if (`post_load_vallabdef'==1) run `labels'
	* switch label language after file load, if indicated
	if (`post_load_langswitch'==1) _neps_switchlang `language'
	* done
	exit 0
end
// record preferences (as global NEPS_<preference>)
program define _neps_set , nclass
	syntax anything(everything equalok) [ , replace ]
	local anything : subinstr local anything "=" " " , all // for jokesters specifying <preference>=<content>
	while (!missing(`"`anything'"')) {
		gettoken macro anything : anything
		gettoken preference anything : anything
		* set global
		local oldval : copy global NEPS_`macro'
		if (!missing(`"`oldval'"') & `"`oldval'"'!=`"`macval(preference)'"') {
			if (missing(`"`replace'"')) {
				display as error in smcl `"(preference {bf:`macro'(`oldval')} already recorded; won't overwrite, unless option {bf:replace} is used"'
				continue
			}
			local procedure=cond(missing(`"`macval(preference)'"'),"cleared","replaced former preference {bf:`macro'(`oldval')}")
		}
		else if (`"`oldval'"'==`"`macval(preference)'"') local procedure "unchanged"
		else local procedure=cond(missing(`"`macval(preference)'"'),"cleared","recorded")
		global NEPS_`macro' `macval(preference)'
		display as result in smcl `"{text}(preference {result}`macro'(`macval(preference)'){text} `procedure')"'
	}
	* exit
	exit 0
end
// wrapper for 'neps set <preference> ""'
program define _neps_clear , nclass
	* default list of all recorded neps preferences
	if (inlist(`"`macval(1)'"',"_all","*","",",")) {
		local presentprefs : all globals "NEPS_*"
		local 0 : subinstr local presentprefs "NEPS_" "" , all
	}
	syntax [namelist]
	* nothing recorded? nothing to clear
	if (missing(`"`namelist'"')) {
		display as result in smcl `"{text}(nothing to clear)"'
		exit 0
	}
	* read and clear globals
	local neps_set_args ""
	foreach macro of local namelist {
		local neps_set_args `macval(neps_set_args)' `macval(macro)' `""'
	}
	_neps_set `macval(neps_set_args)' , replace
	* exit
	exit 0
end
// query and display recorded preferences
program define _neps_query , rclass
	return add
	* version compatibility: unicode functions for 14 or younger
	if (_caller()<14) {
		local length strlen
	}
	else {
		local length ustrlen
	}
	* default list of all recorded neps preferences
	if (inlist(`"`macval(1)'"',"_all","*","",",",",returnlocals")) {
		local presentprefs : all globals "NEPS_*"
		local replaceprefs : subinstr local presentprefs "NEPS_" "" , all
		if (inlist(`"`macval(1)'"',"_all","*")) {
			local 0 : subinstr local 0 `"`macval(1)'"' `"`macval(replaceprefs)'"'
		}
		else local 0 `"`macval(replaceprefs)' `macval(0)'"'
	}
	syntax [namelist] [ , returnlocals ] // option 'returnlocals' to overwrite caller's locals instead of returning stuff in r()
	if (missing(`"`namelist'"')) {
		display as result in smcl `"{text}(no previously recorded preferences for {cmd:neps :} found)"'
		exit 0
	}
	local neps_prefs 0
	* read globals, return results, set table width
	foreach macro of local namelist {
		local preference : copy global NEPS_`macro'
		if (!missing(`"`preference'"')) {
			local neps_pref`++neps_prefs'name `macro'
			local neps_pref`neps_prefs'content `macval(preference)'
			if (`"`returnlocals'"'=="returnlocals") c_local `macro' `macval(preference)'
			else return local NEPS_`macro' `macval(preference)'
			local neps_pref_names `"`neps_pref_names' "`macro'""'
			local neps_pref_contents `"`neps_pref_contents' "`macval(preference)'""'
		}
	}
	if (missing(`"`neps_pref_names'"')) {
		display as result in smcl `"{text}(none of {it:`namelist'} found as previously recorded preferences for {cmd:neps :})"'
		exit 0
	}
	* present table
	_neps_resultstable "previously recorded preferences for {cmd:neps}:" , col1title("parameter") col2title("content") col1contents(`neps_pref_names') col2contents(`neps_pref_contents')
	* exit
	exit 0
end
// file name splitter
program define _neps_fileparse , rclass
	return add
	* parse syntax
	syntax anything(name=filepath) [ , SETup replace ]
	* strip surrounding quotes from filepath, if any
	local filepath `filepath'
	* split filename
	capture : mata : filepathsplitter(`"`filepath'"', "study", "basename", "level", "version", "directory", "suffix")
	if _rc!=0 {
		display as error in smcl `"invalid NEPS file path"'
		exit _rc
	}
	* canonical dashed and dotted version number
	local dottedversion : subinstr local version "-" "." , all
	local dashedversion : subinstr local version "." "-" , all
	* return results
	local neps_parts 0
	local returnitems basename study level version directory
	foreach macro of local returnitems {
		local preference : copy local `macro'
		if (!missing(`"`preference'"')) {
			local neps_pref`++neps_parts'name `macro'
			local neps_pref`neps_parts'content `macval(preference)'
			return local `macro' `macval(preference)'
			local neps_pref_names `"`neps_pref_names' "`macro'""'
			local neps_pref_contents `"`neps_pref_contents' "`macval(preference)'""'
		}
	}
	* present results table
	if (`neps_parts'>0) {
		_neps_resultstable "identified chunks from file path:" , col1title("parameter") col2title("content") col1contents(`neps_pref_names') col2contents(`neps_pref_contents')
	}
	* setup, if specified
	if (`"`setup'"'=="setup") {
		_neps_set study `study' level `level' version `dottedversion' , `replace'
	}
	exit 0
end
// file name concatenator
program define _neps_concatenate , nclass
	* version compatibility: unicode functions for 14 or younger
	if (_caller()<14) {
		local strreverse strreverse
		local substr substr
	}
	else {
		local strreverse ustrreverse
		local substr usubstr
	}
	syntax anything(name=basename) , study(string) level(string) dashedversion(string) directory(string)
	local directory=cond(missing(`"`directory'"'),"",`"`directory'"'+cond(`substr'(`"`directory'"',-1,1)=="/",`""',`"/"'))
	local fullname `"`directory'`study'_`basename'_`level'_`dashedversion'.dta"'
	c_local fullname `"`fullname'"'
	exit 0
end
// switch language, report default language if undefined language specified
program define _neps_switchlang , sclass
	args language
	capture : label language `language'
	sreturn local langok `"`c(rc)'"'
	if (_rc!=0) {
		quietly : label language
		display as error in smcl `"language {bf:`language'} undefined in dataset {bf:`fullfile'};"' _newline `"{tab}will load default language {bf:`r(language)'} instead"'
	}
	exit 0
end
// helper program to present results tables
program define _neps_resultstable , nclass
	* version compatibility: unicode functions for 14 or younger
	if (_caller()<14) {
		local length strlen
	}
	else {
		local length ustrlen
	}
	syntax anything(name=title) , col1title(string) col2title(string) col1contents(string asis) col2contents(string asis) [ col1offset(integer 4) ] [ col2offset(integer 4) ] [ tableoffset(integer 4) ]
	* remove surrounding quotes from title, if any
	local title `title'
	* prepare widht parameters
	local col1width=`length'(`"`col1title'"')
	local col2width=`length'(`"`col2title'"')
	local col1_rows 0
	local col2_rows 0
	* read contents to calculate widths
	forvalues num=1/2 {
		foreach contentrow of local col`num'contents {
			local col`num'_row`++col`num'_rows' `contentrow'
			local col`num'width=max(`length'(`"`contentrow'"'),`col`num'width')
		}
	}
	local totalrows=max(`col1_rows',`col2_rows')
	* present table
	display as result in smcl _newline `"{text}`title'"'
	display as result in smcl _newline `"{p2colset `tableoffset' `=`col1width'+`col1offset'+`tableoffset'' `=`col1width'+`col1offset'+`col2offset'' `=c(linesize)-(`col1width'+`col2width'+`col1offset'+`col2offset')'}{p2col :`col1title'}`col2title'{p_end}"'
	display as result in smcl `"{p2line}"'
	forvalues num=1/`totalrows' {
		display as result in smcl `"{text}{p2col :`col1_row`num''}{result}`col2_row`num''{p_end}"'
	}
	display as result in smcl _newline _continue
	exit 0
end
// helper program to extract list of file names from a specified syntax
program define _get_filelist , nclass
	syntax anything(name=allargs everything equalok) , *
	local wordcount 0
	local cleanlist
	local usingpos : list posof "using" in allargs
	foreach entry of local allargs {
		local ++ wordcount
		if (`wordcount'==1 | `wordcount'<=`usingpos') continue
		if (missing(`"`macval(cleanlist)'"')) local cleanlist `""`macval(entry)'""'
		else local cleanlist `"`macval(cleanlist)' "`macval(entry)'""'
	}
	if (`usingpos'>0) c_local using `"using"'
	c_local filelist `"`macval(cleanlist)'"'
	exit 0
end
// Mata function for splitting a file path to (a) directory, (b) cohort, (c) file base name, (d) level, (e) version, and (f) suffix
set matastrict on
mata :
	void filepathsplitter(string scalar filepath, string scalar studylcl, string scalar basenamelcl, string scalar levellcl, string scalar versionlcl, string scalar directorylcl, string scalar suffixlcl) {
		string scalar filestudy, filebasename, filelevel, fileversion, filedirectory, filefilename, filesuffix
		transmorphic rowvector tokentmp
		real scalar partcount
		if ((filename = pathbasename(filepath)) == "") {
			directory = filepath
		}
		else {
			pragma unset directory
			pathsplit(filepath, filedirectory, filename)
		}
		filesuffix=pathsuffix(filename)
		filename=pathrmsuffix(filename)
		tokentmp=tokeninit("_")
		tokenset(tokentmp, filename)
		partcount=cols(tokengetall(tokentmp))
		tokenset(tokentmp, filename)
		if (partcount==3) {
			filestudy=tokenget(tokentmp)
			filelevel=tokenget(tokentmp)
			fileversion=tokenget(tokentmp)
			filedirectory=pathjoin(filedirectory,filename)
		}
		else if (partcount==4) {
			filestudy=tokenget(tokentmp)
			filebasename=tokenget(tokentmp)
			filelevel=tokenget(tokentmp)
			fileversion=tokenget(tokentmp)
		}
		else {
			exit(error(198))
		}
		st_local(studylcl,filestudy)
		st_local(basenamelcl,filebasename)
		st_local(levellcl,filelevel)
		st_local(versionlcl,fileversion)
		st_local(directorylcl,filedirectory)
		st_local(suffixlcl,filesuffix)
		exit(0)
	}
end
// EOF
