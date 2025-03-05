{smcl}
{* *! version 1.2 18 June 2019}{...}
{vieweralsosee "NEPSstools" "help nepstools"}{...}
{vieweralsosee "neps :" "help neps"}{...}
{viewerjumpto "Syntax" "neps_query##syntax"}{...}
{viewerjumpto "Description" "neps_query##description"}{...}
{viewerjumpto "Options" "neps_query##options"}{...}
{viewerjumpto "Remarks" "neps_query##remarks"}{...}
{viewerjumpto "Examples" "neps_query##examples"}{...}
{viewerjumpto "Authors" "neps_query##author"}{...}
{viewerjumpto "Saved results" "neps_query##results"}{...}
{viewerjumpto "Also see" "neps_query##alsosee"}{...}
help for {cmd:neps query}{right:version 1.2 (18 June 2019)}
{hline}


{title:Title}

{phang}
{bf:neps query} {hline 2} Helper command to display all recorded preferences that the {cmd:neps :} prefix command might use.


{title:Table of contents}

	{help neps_query##syntax:Syntax}
	{help neps_query##options:Options}
	{help neps_query##description:Description}
	{help neps_query##remarks:Remarks}
	{help neps_query##examples:Examples}
	{help neps_query##author:Authors}
	{help neps_query##results:Saved results}
	{help neps_query##alsosee:Also see}


{marker syntax}
{title:Syntax}

{phang}
Display previously set NEPS Scientific Use File parameters

{p 8 12 2}
{cmd:neps query} [* | _all | {it:parameter} [ {it:parameter} ... ] ] [{it:, returnlocals}]


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt returnlocals}}instead of returning results in {it:r()}, return as local macros{p_end}

{synoptline}
{p2colreset}{...}


{marker description}
{title:Description}

{pstd}
The {cmd:neps query} command is a helper command to the {help neps:neps :} prefix command.
It displays previously recorded parameter preferences (e.g. using {cmd:neps set}) for the Stata session.
{p_end}
{phang}
The basic syntax is{break}
{input:. neps set {it:<parameter>}}{break}
where {it:<parameter>} is the name of a parameter (e.g. "{it:version}").{p_end}

{pstd}Several {it:<parameter>} names can be placed in one invocation of {cmd:neps query}.
If no {it:<parameter>} is specified, or "{it:*}" or "{it:_all}" is specified, all previously recorded parameters will be displayed.
{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt returnlocals} is seldomly used.
If specified, query results will be returned as Stata local macros instead of values in {it:r()}.
{break}Only use this option with caution, as it will overwrite existent local macros, if any, without warning.{p_end}


{marker remarks}
{title:Remarks}

{pstd}
Technically, {cmd:neps query} is no more than a wrapper for displaying {help global:global macros} and their contents.
The name of a global that is queried is concatenated from the prefix "{it:NEPS_}" and the parameter name.{p_end}

{pstd}
This means that invoking{break}
{input:. neps query version study}{break}
is equivalent to executing{break}
{input:. display {c 'g}"{c S|}{c -(}NEPS_version{c )-}"'}{break}
{input:. display {c 'g}"{c S|}{c -(}NEPS_study{c )-}"'}{p_end}

{pstd}
However, {cmd:neps query} displays results in a nicely formatted table, and returns appropriate results in {it:r()}.
{p_end}

{pstd}
This command is part of the NEPStools bundle, written to assist with the {browse "https://www.neps-data.de/":NEPS} dataset files.
{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}


{marker examples}
{title:Examples}

{phang}Display the NEPS sub-study preference recorded in the Stata session:{break}
{input:. neps query study}{p_end}

{phang}Display the NEPS dataset version preference recorded in the Stata session:{break}
{input:. neps query version}{p_end}

{phang}Display the NEPS dataset file directory preference recorded in the Stata session:{break}
{input:. neps query directory}{p_end}

{phang}Do all of the above in one step:{break}
{input:. neps query study version directory}{p_end}

{phang}Display all recorded NEPS preferences at once:{break}
{input:. neps query}{p_end}

{marker author}
{title:Authors}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}), Leibniz Institute for Educational Trajectories (LIfBi), Germany.{break}
{p_end}


{marker results}
{title:Saved results}

{pstd}
{cmd:neps query} saves the following in {cmd:r()}, unless option {opt returnlocals} is specified:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Local macros}{p_end}
{synopt:{cmd:r(<preference>)}}content of global macro {it:{c S|}{c -(}NEPS_<preference>{c )-}}{p_end}
{p2colreset}{...}


{marker alsosee}
{title:Also see}

{psee}
{help neps:neps :}, {help nepstools:NEPStools}
{p_end}
