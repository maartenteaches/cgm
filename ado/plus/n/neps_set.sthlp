{smcl}
{* *! version 1.2 18 June 2019}{...}
{vieweralsosee "NEPSstools" "help nepstools"}{...}
{vieweralsosee "neps :" "help neps"}{...}
{viewerjumpto "Syntax" "neps_set##syntax"}{...}
{viewerjumpto "Description" "neps_set##description"}{...}
{viewerjumpto "Options" "neps_set##options"}{...}
{viewerjumpto "Remarks" "neps_set##remarks"}{...}
{viewerjumpto "Examples" "neps_set##examples"}{...}
{viewerjumpto "Authors" "neps_set##author"}{...}
{viewerjumpto "Also see" "neps_set##alsosee"}{...}
help for {cmd:neps set}{right:version 1.2 (18 June 2019)}
{hline}


{title:Title}

{phang}
{bf:neps set} {hline 2} Helper command to record preferences that the {cmd:neps :} prefix command might use in the Stata session.


{title:Table of contents}

	{help neps_set##syntax:Syntax}
	{help neps_set##options:Options}
	{help neps_set##description:Description}
	{help neps_set##remarks:Remarks}
	{help neps_set##examples:Examples}
	{help neps_set##author:Authors}
	{help neps_set##alsosee:Also see}


{marker syntax}
{title:Syntax}

{phang}
Set NEPS Scientific Use File parameters for the current Stata session

{p 8 12 2}
{cmd:neps set} {it:parameter} {it:"value"} [ {it:parameter} {it:"value"} ... ] [{it:, replace}]


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt replace}}replace already set parameters, if any{p_end}

{synoptline}
{p2colreset}{...}


{marker description}
{title:Description}

{pstd}
The {cmd:neps set} command is a helper command to the {help neps:neps :} prefix command.
It enables users to set any parameter that {cmd:neps :} may use permanently in the Stata session.
{p_end}
{phang}
The basic syntax is{break}
{input:. neps set {it:<parameter>} {it:<value>}}{break}
where {it:<parameter>} is the name of a parameter (e.g. "{it:version}"),{break}
and {it:<value>} is the value to store (e.g. "{it:9.1.1}").{break}
Be sure to specify {it:<value>} in double quotes if it contains spaces.{p_end}

{pstd}Several {it:<parameter>} / {it:<value>} settings can be placed in one invocation of {cmd:neps set}.
{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt replace} if specified, parameters to be set will overwrite previously set parameters.
{break}If not specified, a warning message will be displayed if already set, conflicting parameters are detected.{p_end}



{marker remarks}
{title:Remarks}

{pstd}
Technically, {cmd:neps set} is no more than a wrapper for creating and filling {help global:global macros}.
The name of a global that is saved is concatenated from the prefix "{it:NEPS_}" and the parameter name.{p_end}

{pstd}
This means that invoking{break}
{input:. neps set version "9.1.1" study "SC4"}{break}
has the same effect as executing{break}
{input:. global NEPS_version "9.1.1"}{break}
{input:. global NEPS_study "SC4"}{p_end}

{pstd}
However, {cmd:neps set} additionally checks if the corresponding global macros have been previously defined, and warns the user if so.
{p_end}

{pstd}
Note that {cmd: neps set} does not check the saved parameters for validity or consistency.
It is the user's task to make sure only valid parameters are {cmd:neps set}.
{p_end}

{pstd}
Further note that manually specifying parameters as option to the {cmd:neps :} prefix command always takes precedence over recorded parameters from {cmd:neps set}.
{p_end}

{pstd}
This command is part of the NEPStools bundle, written to assist with the {browse "https://www.neps-data.de/":NEPS} dataset files.
{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}


{marker examples}
{title:Examples}

{phang}Set the NEPS sub-study to use to "{it:SC4}":{break}
{input:. neps set study "SC4"}{p_end}

{phang}Set the NEPS version to use to "{it:9.1.1}":{break}
{input:. neps set version "9.1.1"}{p_end}

{phang}Set the directory path to read NEPS files from to "{it:C:\my path}":{break}
{input:. neps set directory "C:\my path"}{p_end}

{phang}Do all of the above in one step:{break}
{input:. neps set study "SC4" version "9.1.1" directory "C:\my path"}{p_end}

{marker author}
{title:Authors}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}), Leibniz Institute for Educational Trajectories (LIfBi), Germany.{break}
{p_end}


{marker alsosee}
{title:Also see}

{psee}
{help neps:neps :}, {help nepstools:NEPStools}
{p_end}
