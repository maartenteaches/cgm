{smcl}
{* *! version 1.2 30 August 2021}{...}
{vieweralsosee "char" "help char"}{...}
{vieweralsosee "rename" "help rename"}{...}
{vieweralsosee "rename group" "help rename_group"}{...}
{vieweralsosee "NEPStools" "help nepstools"}{...}
{viewerjumpto "Syntax" "charren##syntax"}{...}
{viewerjumpto "Description" "charren##description"}{...}
{viewerjumpto "Options" "charren##options"}{...}
{viewerjumpto "Remarks" "charren##remarks"}{...}
{viewerjumpto "Examples" "charren##examples"}{...}
{viewerjumpto "Author" "charren##author"}{...}
{viewerjumpto "Saved results" "charren##results"}{...}
{viewerjumpto "Also see" "charren##alsosee"}{...}
help for {cmd:charren}{right:version 1.2  (30 August 2021)}
{hline}


{title:Title}

{phang}
{bf:charren} {hline 2} rename variables via characteristics saved in the dataset


{title:Table of contents}

	{help charren##syntax:Syntax}
	{help charren##description:Description}
	{help charren##options:Options}
	{help charren##remarks:Remarks}
	{help charren##examples:Examples}
	{help charren##author:Author}
	{help charren##results:Saved results}
	{help charren##alsosee:Also see}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:charren} {help namelist:{it:namelist}}, {opt to(charname)} [{it:options}]
{p_end}

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Other options}
{synopt:{opt search:space(charlist)}}search for variables to rename in all saved characteristics of {it:charlist}{p_end}
{synopt:{opt verbose}}give verbose output{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:charren} renames all variables specified in {it:namelist} to pre-defined alternative names. These names have to be defined as {help char:characteristics} and saved to the Stata dataset. 
{p_end}

{pmore}
In many datasets originating from surveys, most variables are renamed from its original name to another before dissemination, i.e. in order to fit a general variable naming convention.
{p_end}

{pmore}
However, dataset users being familiar with the original variable names might want to work with these names. {cmd:charren} provides a mechanism
to easily handle this problem. It is based on Stata's ability to save any extra information to a variable using so-called {help char:characteristics}.
For instance, when renaming variables to its final name, it is possible to save a variable's original name as characteristic {it:NEPS_alias} and attach it to the variable.
A second characteristic {it:NEPS_varname} may hold the new variable name. The {cmd: charren} command enables a data user to easily switch between both alternative names, parsing these characteristics.
{p_end}

{pmore}
In the {browse "https://www.neps-data.de/":NEPS} datasets, saved alternative names are {it:NEPS_alias} and {it:NEPS_varname}.
The first is reflecting the variable name as defined in the survey instrument, the latter the variable name shipped in the Scientific Use Files.
{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Other options}

{phang}
{opt searchspace(charlist)} specifies all characteristics to be parsed when searching for variables to rename. 
If one or more variables designated for renaming is not found in the dataset, it is checked if the name is defined as characteristic out of {it:charlist} attached to any variable in the dataset.
{break}This enables {cmd:charren} to also accept alternative names in {it:namelist}, not only currently active names.
{p_end}

{phang}
{opt verbose} drops verbose output during the process. Eventually needed for debugging.
{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
As mentioned before, the optional parameter {opt searchspace(charlist)} enables {cmd:charren} to accept alternative variable names as input.
This tool is reportedly not only used with {browse "https://www.neps-data.de/":NEPS} Scientific Use Files,
but also with datasets from the {browse "http://www.scip-info.org/":SCIP} survey. Thus, the option does not only default to the array {it:NEPS_instname NEPS_sufname}
(as used in the NEPS SUFs), but to the array {it:oldname tempname NEPS_instname NEPS_sufname}. This reflects the union of both search spaces.
In case the characteristic {input:_dta[EMD_prefix]} is set, as should be for all datasets using the more modern EMD approach for extended
metadata (as are NEPS SUFs since 2021), the default array is {it:<EMD_prefix>varname <EMD_prefix>alias}.
{break}If you want to use a similar mechanism in your Stata datasets, feel free to contact the author for more information on how to do so.
{p_end}

{pstd}
This command is part of the NEPStools bundle, written to assist with the {browse "https://www.neps-data.de/":NEPS} dataset files.
{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}


{marker examples}{...}
{title:Examples}

{phang}Rename variables {it:t73114c} and {it:t73114d} to their pre-defined {it:NEPS_instname}:{p_end}
{phang}{cmd:. charren t73114c t73114d, to(NEPS_instname)}{p_end}


{marker author}{...}
{title:Author}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}), Leibniz Institute for Educational Trajectories e.V. (LIfBi), Germany.
{p_end}


{marker results}{...}
{title:Saved results}

{pstd}
{cmd:charren} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(renamed)}}number of variables renamed{p_end}
{p2colreset}{...}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Locals}{p_end}
{synopt:{cmd:r(from{it:#})}}source variable name of renamed variable {it:#}{p_end}
{synopt:{cmd:r(to{it:#})}}target variable name of renamed variable {it:#}{p_end}
{p2colreset}{...}

{pstd}
(With {it:#} denoting a running number between 0 and the scalar {cmd:r(renamed)})
{p_end}


{marker alsosee}{...}
{title:Also see}

{psee}
{help NEPStools}, {help char}, {help rename}, {help rename_group:rename group} (Stata 12 or newer only)
{p_end}
