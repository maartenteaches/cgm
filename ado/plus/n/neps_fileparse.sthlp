{smcl}
{* *! version 1.2 18 June 2019}{...}
{vieweralsosee "NEPSstools" "help nepstools"}{...}
{vieweralsosee "neps :" "help neps"}{...}
{viewerjumpto "Syntax" "neps_fileparse##syntax"}{...}
{viewerjumpto "Description" "neps_fileparse##description"}{...}
{viewerjumpto "Options" "neps_fileparse##options"}{...}
{viewerjumpto "Remarks" "neps_fileparse##remarks"}{...}
{viewerjumpto "Examples" "neps_fileparse##examples"}{...}
{viewerjumpto "Authors" "neps_fileparse##author"}{...}
{viewerjumpto "Also see" "neps_fileparse##alsosee"}{...}
help for {cmd:neps fileparse}{right:version 1.2 (18 June 2019)}
{hline}


{title:Title}

{phang}
{bf:neps fileparse} {hline 2} Helper command to parse parameters that the {cmd:neps :} prefix command might use from a file name or directory path.


{title:Table of contents}

	{help neps_fileparse##syntax:Syntax}
	{help neps_fileparse##options:Options}
	{help neps_fileparse##description:Description}
	{help neps_fileparse##remarks:Remarks}
	{help neps_fileparse##examples:Examples}
	{help neps_fileparse##author:Authors}
	{help neps_fileparse##alsosee:Also see}


{marker syntax}
{title:Syntax}

{phang}
Parse NEPS Scientific Use File parameters from dataset file path or directory path

{p 8 12 2}
{cmd:neps fileparse} {c -(} {it:filepath} | {it:filename} | {it:directory path} {c )-} [{it:, setup replace }]


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt set:up}}set parameters parsed from file or directory name as parameters for further use in the Stata session (shorthand for {cmd:neps set}){p_end}
{synopt:{opt replace}}replace already set parameters, if any (no effect unless option {opt setup} is specified){p_end}

{synoptline}
{p2colreset}{...}


{marker description}
{title:Description}

{pstd}
The {cmd:neps fileparse} command is a helper command to the {help neps:neps :} prefix command.
It enables users to read parameter that {cmd:neps :} may use lateron directly from a file specification.
{p_end}
{phang}
The basic syntax is{break}
{input:. neps fileparse {it:<path>}}{break}
where {it:<path>} is either a file name,{break}
a full file path (i.e. including a directory specification),{break}
or a directory path holding dataset files.{break}
Be sure to specify {it:<path>} in double quotes if it contains spaces.{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt setup} if specified, parameters read from the given {it:<path>} will be directly passed on to {cmd:neps set}.{p_end}

{phang}
{opt replace} if specified in combination with option {opt setup}, {cmd:neps set} will be invoked with option {opt replace}.
{break}If specified, but option {opt setup} is ommited, {opt replace} has no effect.{p_end}


{marker remarks}
{title:Remarks}

{pstd}
When {cmd:neps fileparse} splits the specified {it:<path>} into parts, it does so by following a simple assumption:
A valid NEPS Scientific Use File dataset file name consists of four elements
({it:sub-study}, {it:basename}, {it:access level}, and {it:version}, in this exact order;
see the {help neps##action1:neps : prefix help} for details),
suffixed by a file extension, and possibly prefixed by a directory path.{break}
These elements are separated by underscore characters.
Thus, a dataset name should contain three underscore characters.
A directory name holding dataset files,
to the contrary,
should only contain two underscore characters, as it does not contain a {it:basename} element.
{p_end}

{pstd}
The logic of counting underscore characters for parsing chunks is the only logic {cmd:neps fileparse} assumes.
There is no consistency check for the chunks being valid parameter values for the {cmd: neps :} prefix command. 
There is not even a crosscheck if the specified {it:<path>} string represents an existing file name or directory.
{p_end}

{pstd}
This command is part of the NEPStools bundle, written to assist with the {browse "https://www.neps-data.de/":NEPS} dataset files.
{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}


{marker examples}
{title:Examples}

{phang}Display the parsed chunks from "{it:C:\my path\SC4_pTargetCATI_D_9-1-1.dta}":{break}
{input:. neps fileparse "C:\my path\SC4_pTargetCATI_D_9-1-1.dta"}{p_end}

{phang}Do the same, but directly record the chunks as parameters with {cmd:neps set}:{break}
{input:. neps fileparse "C:\my path\SC4_pTargetCATI_D_9-1-1.dta" , setup}{p_end}


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
