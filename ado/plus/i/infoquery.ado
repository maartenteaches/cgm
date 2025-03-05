/*-------------------------------------------------------------------------------
 infoquery.ado: query information attached to variables

    Copyright (C) 2023 Benno Schönberger (benno.schoenberger@lifbi.de)
				  2011-2021  Daniel Bela (daniel.bela@lifbi.de)

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
*! infoquery.ado: query information attached to variables
*! Daniel Bela (daniel.bela@lifbi.de), Leibniz Institute for Educational Trajectories (LIfBi), Germany
*! version 1.12 01 March 2023 - added new charcteristic to default list: 'NEPS_harmonization_rule'; they are filled for all NEPS SUFs distributed in March 2023 or later
*! version 1.11 31 May 2021 - wrap infoquery around the EMD framework, which will be published in a SSC package; this way, infoquery doesn't have to applied to new metadata attributes, once included in the data
*! version 1.10 08 October 2020 - added new characteristic to default list: 'NEPS_confidentiality'; it is filled for all NEPS SUFs distributed in October 2020 or later
*! version 1.9 06 December 2019 - added new characteristics to default list: 'NEPS_relations_', 'NEPS_procedures_', and 'NEPS_limitations_'; they are filled for all NEPS SUFs distributed in December 2019 or later
*! version 1.8 01 August 2016 - added new characteristic to default list: 'NEPS_varlabel_', which is filled for all NEPS SUFs from August 2016 or younger, circumventing variable label truncation in Stata
*! version 1.7 27 February 2015 - added several new characteristics to default list, including IDs, added option -ids- to display the latter; changed display mode
*! version 1.6 08 May 2014 - bug fix in handling long characteristics' names; removed returning locals
*! version 1.5 14 October 2013 - report additional characteristic -unit-, if present; characteristics now prefixed with "NEPS_"
*! version 1.4 04 June 2013 - report additional characteristics -instname- and -sufname-, if present; added option -charlist-
*! version 1.3 18 September 2012 - only report information in current language; implemented option -alllanguages-
*! version 1.2 26 January 2012 - corrected handling of characteristics not to be interpreted
*! version 1.1 05 October 2011 - program renamed, various bugfixes, correct handling of empty queries (when no characteristic is set)
*! version 1.0 22 September 2011 - inital release (as showquestion.ado)
program define infoquery, nclass
	syntax varlist, [ALLLANGuages charlist(string) IDs]
	quietly: label language
	if (`"`alllanguages'"'=="alllanguages") local langs `r(languages)'
	else local langs `r(language)'
	if (missing(`"`charlist'"')) {
		/*
			-infoquery- bases upon the EMD ('extended metadata') framework,
			which is provided and documented by the SSC packege 'EMD'.
			We simply wrap around that package's features.
		*/
		local EMD_prefix : char _dta[EMD_prefix]
		local add_attribute NEPS_harmonization_rule
		if (!missing(`"`EMD_prefix'"')) {
			local EMD_attributes : char _dta[EMD_attributes]
			local EMD_langattributes : char _dta[EMD_langattributes]
			assert (!missing(`"`EMD_attributes'"'))
			foreach attribute of local EMD_attributes {
				local newchar `"`EMD_prefix'`attribute'"'
				local charlist : list charlist | newchar
			}
			foreach attribute of local EMD_langattributes {
				foreach lang of local langs {
					local newchar `"`EMD_prefix'`attribute'`lang'"'
					local charlist : list charlist | newchar
				}
			}
			local charlist : list charlist | add_attribute
		}
		/*
			this part is legacy code necessary to work on NEPS SUFs prior to June 2021;
			if legacy functionality is not needed anymore, remove the following "else{}" block
		*/
		else {
			local charlist ///
				instname sufname NEPS_instname NEPS_sufname NEPS_instID ///
				NEPS_institemID NEPS_sufitemID NEPS_questionnumber ///
				NEPS_vartype NEPS_decimals NEPS_schemeID NEPS_harmonization_rule
			foreach langitem in ///
				questiontext_ variablequestion_ unit_ NEPS_unit_ NEPS_varlabel_ ///
				NEPS_itemsinstruction_ NEPS_inputfilter_ NEPS_outputfilter_ ///
				NEPS_autofillinstruction_ NEPS_valuefilter_ NEPS_questiontext_ ///
				NEPS_variablequestion_ NEPS_interviewerinstruction_ ///
				NEPS_relations_ NEPS_procedures_ NEPS_limitations_ ///
				NEPS_confidentiality ///
				{
				foreach lang of local langs {
					local newitem `langitem'`lang'
					local charlist: list charlist | newitem
				}
			}
		}
	}
	foreach var of varlist `varlist' {
		local chars: char `var'[]
		local processchars ""
		foreach item of local charlist {
			if (missing(`"`ids'"') & strmatch(`"`item'"',"*ID")) continue
			if (`: list item in chars'==1) local processchars: list processchars | item
		}
		noisily : display as result in smcl _newline `"{p2col:variable {it:`var'}:}{p_end}"' _newline `"{p2line}"'
		if (`"`processchars'"'!= "") {
			foreach item of local processchars {
				if (!missing(`"`: char `var'[`item']'"')) {
					noisily: display as result in smcl `"{p2col:`item'}{text}`: char `var'[`item']'{p_end}"'
				}
			}
		}
		else noisily: display as result in smcl `"{it:no characteristics found for `var'}"'
	}
	exit 0
end
// EOF
