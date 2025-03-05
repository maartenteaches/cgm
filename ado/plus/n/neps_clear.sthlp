{smcl}
{* *! version 1.2 18 June 2019}{...}
{vieweralsosee "NEPSstools" "help nepstools"}{...}
{vieweralsosee "neps :" "help neps"}{...}
{viewerjumpto "Syntax" "neps_clear##syntax"}{...}
{viewerjumpto "Description" "neps_clear##description"}{...}
{viewerjumpto "Remarks" "neps_clear##remarks"}{...}
{viewerjumpto "Examples" "neps_clear##examples"}{...}
{viewerjumpto "Authors" "neps_clear##author"}{...}
{viewerjumpto "Also see" "neps_clear##alsosee"}{...}
help for {cmd:neps clear}{right:version 1.2 (18 June 2019)}
{hline}


{title:Title}

{phang}
{bf:neps clear} {hline 2} Helper command to clear all previously set up parameters for the {cmd:neps :} prefix command.


{title:Table of contents}

	{help neps_clear##syntax:Syntax}
	{help neps_clear##description:Description}
	{help neps_clear##remarks:Remarks}
	{help neps_clear##examples:Examples}
	{help neps_clear##author:Authors}
	{help neps_clear##alsosee:Also see}


{marker syntax}
{title:Syntax}

{phang}
Clear previously set NEPS Scientific Use File parameters

{p 8 12 2}
{cmd:neps clear} [* | _all | {it:parameter} [ {it:parameter} ... ] ]


{marker description}
{title:Description}

{pstd}
The {cmd:neps clear} command is a helper command to the {help neps:neps :} prefix command.
It removes previously recorded parameter preferences (e.g. using {cmd:neps set}) from the Stata session.
{p_end}
{phang}
The basic syntax is{break}
{input:. neps clear {it:<parameter>}}{break}
where {it:<parameter>} is the name of a parameter (e.g. "{it:version}").{p_end}

{pstd}Several {it:<parameter>} names can be placed in one invocation of {cmd:neps clear}.
If no {it:<parameter>} is specified, or "{it:*}" or "{it:_all}" is specified, all previously recorded parameters will be cleared.
{p_end}


{marker remarks}
{title:Remarks}

{pstd}
Technically, {cmd: neps clear} is no more than a wrapper for {cmd:neps set} with empty double quotes for each parameter's value.{p_end}

{pstd}
This means that invoking{break}
{input:. neps clear version}{break}
has the same effect as executing{break}
{input:. neps set version ""}{p_end}

{pstd}
This command is part of the NEPStools bundle, written to assist with the {browse "https://www.neps-data.de/":NEPS} dataset files.
{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}


{marker examples}
{title:Examples}

{phang}Clear the previously recorded NEPS sub-study to use:{break}
{input:. neps clear study}{p_end}

{phang}Clear the previously recorded NEPS version to use:{break}
{input:. neps clear version}{p_end}

{phang}Clear the previously recorded directory path to read NEPS files from :{break}
{input:. neps clear directory}{p_end}

{phang}Do all of the above in one step:{break}
{input:. neps clear study version directory}{p_end}

{phang}Clear any previously recorded NEPS parameters:{break}
{input:. neps clear}{p_end}

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
