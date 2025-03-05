{smcl}
{* *! version 2.6 18 July 2016}{...}
{vieweralsosee "nepstools" "help NEPStools"}{...}
{vieweralsosee "char" "help char"}{...}
{vieweralsosee "label language" "help label language"}{...}
{vieweralsosee "mvencode" "help mvencode"}{...}
{vieweralsosee "mvdecode" "help mvdecode"}{...}
{vieweralsosee "recode" "help recode"}{...}
{viewerjumpto "Syntax" "nepsmiss##syntax"}{...}
{viewerjumpto "Description" "nepsmiss##description"}{...}
{viewerjumpto "Options" "nepsmiss##options"}{...}
{viewerjumpto "Remarks" "nepsmiss##remarks"}{...}
{viewerjumpto "Examples" "nepsmiss##examples"}{...}
{viewerjumpto "Authors" "nepsmiss##author"}{...}
{viewerjumpto "Saved results" "nepsmiss##results"}{...}
{viewerjumpto "Also see" "nepsmiss##alsosee"}{...}
help for {cmd:nepsmiss}{right:version 2.6 (18 July 2016)}
{hline}


{title:Title}

{phang}
{bf:nepsmiss} {hline 2} Create Stata extended missing codes from NEPS missing codes


{title:Table of contents}

	{help nepsmiss##syntax:Syntax}
	{help nepsmiss##description:Description}
	{help nepsmiss##options:Options}
	{help nepsmiss##remarks:Remarks}
	{help nepsmiss##examples:Examples}
	{help nepsmiss##author:Authors}
	{help nepsmiss##results:Saved results}
	{help nepsmiss##alsosee:Also see}


{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmd:nepsmiss} {varlist} [, {it:options}]
{p_end}

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt r:everse}}revert previously encoded extended missing values to original{p_end}

{syntab:Advanced}
{synopt:{opt k:eeplabels}}do not change value labels{p_end}
{synopt:{opt m:isslist(numlist)}}use self-defined list of missing values instead of NEPS missing values{p_end}
{synopt:{opt legacy:default}}use legacy default NEPS missing values{p_end}
{synopt:{opt v:erbose}}give verbose output{p_end}
{synoptline}
{p2colreset}{...}


{marker description}
{title:Description}

{pstd}
{cmd:nepsmiss} transforms numerical missing values as provided by NEPS Scientific Use Files to Stata extended missing values (e.g. {it:-97} to {it:.c}) and vice versa (with the {opt reverse} option).
In contrast to Stata's {help mvencode} and {help mvdecode}, it will preserve the value labels associated, thus the resulting extended missing values are labeled accordingly.
For the NEPS Scientific Use Files being multilingually labeled, {cmd:nepsmiss} takes care of multilingual value labels.{p_end}

{pstd}
Both the original values, the assigned extended missing values and the value labels detected by {cmd:nepsmiss} are saved as {help char:characteristics} attached to the variable,
and re-interpreted when reverting to the original values with the {opt reverse} option. Thus, the reverse procedure is only possible when the encoding
has been done with {cmd:nepsmiss}. However, the attached information will be saved with the dataset and can be used in later sessions with the dataset.{p_end}

{pstd}
Note that {cmd:nepsmiss} does not generate new variables but rather overwrites the value labels and variables directly, so be careful when saving your dataset.{p_end}

{pstd}
{cmd:nepsmiss} is quite similar to Daniel Klein's {net "describe labmv":labmv} (which actually was developed at the same time), but comes with NEPS missing codes as default value list.
Acknowledgements go to Daniel Klein for reviewing the {cmd:nepsmiss} code and giving hints for optimization.
{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt reverse} if specified, {cmd:nepsmiss} will search for previously saved characteristics and revert the procedure.
{break}Note that this will only work when extended missing values have been encoded with {cmd:nepsmiss} in normal mode, otherwise it drop an error message and exit.{p_end}

{dlgtab:Advanced}

{phang}
{opt keeplabels} if specified, value labels will not be changed; only values will be recoded.{p_end}

{phang}
{opt misslist(numlist)} if given, {cmd:nepsmiss} will process the specified {help numlist} instead of NEPS' default missing values. If ommitted,
it defaults to {it:-99/-92 -90 -56/-51 -29/-20}, covering all possible missing values in NEPS Scientific Use Files.
{break}Note that this option makes {cmd:nepsmiss} quite versatile and applicable to nearly every dataset using numeric missing values, although
we will only provide support when using it with NEPS Scientific Use Files.{p_end}


{phang}
{opt legacydefault} if specified, {cmd:nepsmiss} will use a legacy, deprecated default list of missing values: {it:-99/-92 -90 -56/-51 -25/-20 -9/-5} (as opposed to the default list above).{break}
This makes {cmd:nepsmiss} behave in the same way as older versions (prior to version 2.6, before 18 July 2016). It should only be needed when using {cmd:nepsmiss} on very old NEPS Scientific Use Files,
which probably should be avoided anyways.{p_end}

{phang}
{opt verbose} drops verbose output during the process. Possibly needed for debugging your syntax.{p_end}


{marker remarks}
{title:Remarks}

{pstd}
This command is part of the NEPStools bundle, written to assist with the {browse "https://www.neps-data.de/":NEPS} dataset files.
{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}

{pstd}
Two non-critical warning messages may be dropped by {cmd:nepsmiss}.{p_end}
{phang}One is self-explanatory:{break}
{error}{bf:Warning:} value label {it:name} is also attached to variables {it:varlist};{break}
these surplus variables will not be recoded!{break}
Consider running nepsmiss on those variables as well to correctly recode them!{p_end}
{pstd}{text}This means: Other variables also use the value label container {it:name}, and they should also be treated with {cmd:nepsmiss}, for the {it:name} has been modified.{p_end}
{phang}The second warning might be harder:{break}
{error}...detected value {it:value} in variable {it:varname}, but it has no entry in value label {it:name}; this might be a metadata or data error!{p_end}
{pstd}{text}This means: You {cmd:nepsmiss}ed variable {it:varname} (at least). While scanning the variable for missing values, {cmd:nepsmiss}
encountered observations holding the value {it:value}. However, this value is not labeled in value label container {it:name}.
This could be an error in your dataset, or in your data's metadata. To keep things short: You have to decide what to do. You have (at least) one value without value label.
You can live with it, or you can investigate the source of the problem. It may originate from a {cmd:merge} operation and therefore be harmless.{p_end}


{marker examples}
{title:Examples}

{phang}Encode NEPS missing values to extended missing values in variables {it:mpg} and {it:weight}:{p_end}
{phang}{cmd:. nepsmiss mpg weight}{p_end}

{phang}Encode NEPS missing values to extended missing values in all variables:{p_end}
{phang}{cmd:. nepsmiss _all}{p_end}

{phang}Decode extended missing values to NEPS missing values in variable {it:foreign}:{p_end}
{phang}{cmd:. nepsmiss foreign, reverse}{p_end}


{marker author}
{title:Authors}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}), Leibniz Institute for Educational Trajectories (LIfBi), Germany.{break}
Jan Skopek
{p_end}


{marker results}
{title:Saved results}

{pstd}
{cmd:nepsmiss} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(changed)}}total of recoded values in the dataset{p_end}
{p2colreset}{...}


{marker alsosee}
{title:Also see}

{psee}
{help NEPStools}, {help char}, {help label language}, {help mvencode}, {help mvdecode}, {help recode}, {help labmv} (if installed)
{p_end}
