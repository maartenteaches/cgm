{smcl}
{* *! version 1.2 18 June 2019}{...}
{vieweralsosee "nepstools" "help NEPStools"}{...}
{viewerjumpto "Syntax" "neps##syntax"}{...}
{viewerjumpto "Features of the neps prefix command" "neps##features"}{...}
{viewerjumpto "  (1) Filename concatenation" "neps##action1"}{...}
{viewerjumpto "  (2) Dataset localization" "neps##action2"}{...}
{viewerjumpto "Options" "neps##options"}{...}
{viewerjumpto "Supporting commands" "neps##helpers"}{...}
{viewerjumpto "Remarks" "neps##remarks"}{...}
{viewerjumpto "Examples" "neps##examples"}{...}
{viewerjumpto "Authors" "neps##author"}{...}
{viewerjumpto "Also see" "neps##alsosee"}{...}
help for {cmd:neps:}{right:version 1.2 (18 June 2019)}
{hline}


{title:Title}

{phang}
{bf:neps:} {hline 2} Prefix command to conveniently handle NEPS Scientific Use File (SUF) data


{title:Table of contents}

	{help neps##syntax:Syntax}
	{help neps##features:Features of the {cmd:neps:} prefix command}
	  {help neps##action1:(1) Filename concatenation}
	  {help neps##action2:(2) Dataset localization}
	{help neps##options:Options}
	{help neps##helpers:Supporting commands}
	{help neps##remarks:Remarks}
	{help neps##examples:Examples}
	{help neps##author:Authors}
	{help neps##alsosee:Also see}


{marker syntax}
{title:Syntax}

{phang}
Run any Stata {it:command} with convenience features for working with NEPS Scientific Use Files (NEPS SUFs)

{p 8 12 2}
{cmd:neps} [{it:, prefixoptions}] {cmd::} {it:command}


{synoptset 30 tabbed}{...}
{synopthdr:prefixoptions}
{synoptline}

{syntab:options for filename concatenation}
{synopt:{opt s:tudy(shortcode)}}NEPS sub-study short code (e.g. {it:study(SC4)}){p_end}
{synopt:{opt ver:sion(version number)}}NEPS SUF dataset version (e.g. {it:version(9.1.1)}){p_end}
{synopt:{opt lev:el(anonymisation level)}}NEPS SUF access level 
(i.e. one of {it:level(S)}=semantic data structure file, {it:level(D)}=download, {it:level(R)}=RemoteNEPS, {it:level(O)}=on-site){p_end}
{synopt:{opt dir:ectory(dirname)}}directory path to NEPS SUF datasets{p_end}

{syntab:options for dataset localization}
{synopt:{opt lang:uage(language code)}}label language to use (e.g. {it:language(en)}){p_end}

{syntab:advanced options}
{synopt:{opt set:up}}record manually specified NEPS parameters as preferences for further use within the Stata session (shorthand for {cmd:neps set}){p_end}
{synopt:{opt replace}}replace already set parameters, if any (no effect unless option {opt setup} is specified){p_end}

{synoptline}
{p2colreset}{...}
{pstd}The {cmd:neps:} prefix command is accompanied by supporting commands for setting up, displaying, and clearing NEPS preferences.
{break}See {help neps##helpers:section supporting commands} for an overview,
or {help neps_set:neps set} and {help neps_fileparse:neps fileparse},
{help neps_query:neps query},
and {help neps_clear:neps clear} for details.
{p_end}


{marker features}
{title:Features of the {cmd:neps:} prefix command}

{pstd}
The {cmd:neps:} {help prefix} command acts as a wrapper for literally any Stata command.
Before invoking the specified command, however, it will perform some convenience actions on the user's syntax in order to ease usability or use enhanced features of NEPS Scientific Use File datasets.
If none of these actions is required in order to execute the desired command, the {cmd:neps:} prefix command has no effect.
{p_end}

{phang}
Currently, the performed convenience actions are:{break}
(1) auto-concatenate the full file path to a NEPS dataset{break}
(2) pre-set a file's {help label language} to the desired language before loading it
{p_end}

{pstd}
With regards to actions (1) and (2), the {cmd:neps:} prefix command is considered the successor to the older, now deprecated, {cmd:nepsuse} command.
{p_end}


{marker action1}
{title:(1) Filename concatenation}

{pstd}
NEPS Scientific Use File dataset filenames look something alike "{it:SC4_pTarget_D_9-1-1.dta}".{p_end}
{pstd}
More generically put, they consist of four elements, separated by an underscore character, plus a file extension ("{it:.dta}" for Stata files).{p_end}
{phang}These elements are:{break}
(1) a shorthand for the NEPS sub-study the file originates from (most common: one of the NEPS Starting Cohorts 1 through 6, e.g. "{it:SC4}"){break}
(2) a basename indicating the file's contents (e.g. "{it:pTarget}"){break}
(3) an indicator for the access level the file is available from (i.e. one of "{it:S}"=semantic data structure file, "{it:D}"=download, "{it:R}"=RemoteNEPS, "{it:O}"=on-site){break}
(4) a three-digit version number, separated by dashes (e.g. {it:"9-1-1"})
{p_end}

{pstd}When data users need to use several files throughout a project,
it might be cumbersome to copy and paste the constant parts of the file names over and over again in order to {cmd:use}, {cmd:describe}, {cmd:merge} or {cmd:append} them.
They could, of course, replace these parts in their do-files with global macros. But, if done so, it is the global macros' names that have to be repeated in a syntax file.{p_end}

{pstd}The {cmd:neps:} prefix command is designed to enable users to remove this redundancy from their syntax files.
In order to do so, users can {cmd:neps set} the constant parameters once for the session, and only specify the {it:basename} [part (2) in the above example]
whenever they need to access files with any Stata command that is prefixed with {cmd:neps:}.
All other parts of the file name, and (if specified) the file's directory path, are automatically detected and inserted into the invoked Stata command's syntax.
{p_end}


{marker action2}
{title:(2) Dataset localization}

{pstd}
NEPS Scientific Use File datasets ship with multi-lingual variable and value labels.
Whilst we think this is very helpful for both our international data users,
and even national users who want to publish non-german articles,
Stata's implementation of multi-lingual labels has some peculiarities.
{break}The most grievous one is that multi-lingual labels only are read from a data file on opening it with {cmd:use}.
As soon as the data file is loaded with any other command,
for instance when it is the using-file in a {cmd:merge} or {cmd:append} procedure,
only labels in the active language are read.{p_end}
{pstd}A workaround to this behavior is to {cmd:use} each dataset in a project once,
then switch the active label language to the desired language,
(temporary) save the file and use this altered copy for any further data management.{p_end}
{pstd}This leads to long do-file code with much repetition that could be avoided or automated.
The {cmd:neps:} prefix command will automate the steps outlined above if the parameter {it:<language>} is specified.
{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Filename concatenation}

{phang}
{opt study(shortcode)} is mandatory for filename concatenation; {it:shortcode} is a NEPS sub-study short code, most commonly one of the NEPS Starting Cohorts
(i.e. {it:SC#}, where {it:#} denominates the Starting Cohort number).{p_end}

{phang}
{opt version(version number)} is mandatory for filename concatenation; {it:version number} is a version number of a NEPS Scientific Use File.{break}
Version numbers may be specified either with dashes or dots as separators (i.e. {it:9-1-1} vs {it:9.1.1}).{p_end}

{phang}
{opt level(anonymisation level)} is mandatory for filename concatenation; {it:anonymisation level} is one of the capital letters {it:S}, {it:D}, {it:R} or {it:O},
corresponding to the NEPS anonymisation levels {it:semantic data structure file}, {it:download}, {it:RemoteNEPS} and {it:on-site}.{p_end}

{phang}
{opt directory(dirname)} is optional; if specified, {it:dirname} will be used as path for filename concatenation.{break}
If omitted, the current working directory is assumed to hold the dataset files.{break}
If a directory path contains parts of the mandatory parameters above,
they can be incorporated as @-strings (see {help neps##remarks:section remarks} for details).{p_end}

{dlgtab:Dataset localization}

{phang}
{opt language(lang)} is optional; if specified, labels will be read in language {it:lang}.{break}
If omitted, the active dataset label language will be read.{p_end}

{dlgtab:Advanced}

{phang}
{opt setup} if specified, {cmd:neps:} will record all manually specified options as preferences for further use in the Stata session.{break}
This is done by automatically invoking {help neps_set:neps set} with the specified parameters.
Thus, the setup option is no more than a shorthand for manually invoking {cmd:neps set} at the beginning of a session.{p_end}

{phang}
{opt replace} will be silently passed through to {cmd:neps set} if the option {opt setup} is also specified.{break}
Otherwise, it does not have an effect.{p_end}


{marker helpers}
{title:Supporting commands}

{pstd}
{cmd:neps set} is a helper command to set up all parameters that the {cmd:neps:} prefix command might use.
See {help neps_set:neps set}.
{p_end}

{pstd}
{cmd:neps query} is a helper command to display all previously set up parameters that the {cmd:neps:} prefix command might use.
See {help neps_query:neps query}.
{p_end}

{pstd}
{cmd:neps clear} is a helper command to clear all previously set up parameters for the {cmd:neps:} prefix command.
See {help neps_clear:neps clear}.
{p_end}

{pstd}
{cmd:neps fileparse} is a helper command to parse parameters that the {cmd:neps:} prefix command might use from a file name or directory path.
See {help neps_fileparse:neps fileparse}.
{p_end}


{marker remarks}
{title:Remarks}

{pstd}
Note that manually specifying parameters as option to the {cmd:neps:} prefix command always takes precedence over recorded parameters from {cmd:neps set}.
{p_end}

{pstd}
When a directory path is read for file name concatenation,
either from a recorded preference or an option to the {cmd:neps:} prefix command itself,
it is allowed to contain signal words starting with the at-character {it:@} in all-uppercase letters denoting the mandatory parameters for file name concatenation.
They will be automatically replaced by the content of each parameter.
This enables a permanent setting of a generic directory path via {help profile:(sys)profile.do}, if it is constant for all NEPS Scientific Use Files on a machine.{break}
Thus, specifying a directory named after a specific NEPS Scientific Use File is simplified; there is no difference between specifying{break}
{input:. neps set directory "neps set directory Z:/SUF/Download/SC4/SC4_D_9-1-1/Stata14"}{break}
{input:. neps : use "spEmp"}{break}
and{break}
{input:. neps set directory "neps set directory Z:/SUF/Download/@STUDY/@STUDY_@LEVEL_@VERSION/Stata14"}{break}
{input:. neps : use "spEmp"}{break}
Note that the parameter {it:@VERSION} always represents the version number separated by dashes {e.g. {it:9-1-1}).
It is equivalent to specifying {it:@DASHEDVERSION}.
The variant separated by dots is available as {it:@DOTTEDVERSION}.
{p_end}

{pstd}
For switching the language of an addressed dataset, the {cmd:neps:} prefix command opens the dataset in question,
changes its language to the desired one, temporarily saves the file,
and injects the temporary file name instead of the original one into the called Stata command.
{break}This necessarily increases the time Stata needs to open the file.
Also, said procedure means that the file name that Stata sees on opening the file is only the temporary file path.
Thus, after {cmd:use}ing a dataset that way, it is not reasonable to use {cmd:save , replace} (without a file name specification),
nor Stata's internal macro {it:{c 'g}c(filename)'}.
{break}If this situation occurs, {cmd:neps:} will issue a corresponding warning message to the user.
{p_end}

{pstd}
This command is part of the NEPStools bundle, written to assist with the {browse "https://www.neps-data.de/":NEPS} dataset files.
{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}

{pstd}
We like to thank Daniel Klein (INCHER-Kassel),
one of our active and committed NEPS data users,
for his valuable bug hunt and suggestions on how to further improve {cmd:neps:}'s predecessor, {cmd:nepsuse}.{break}
His feedback led to the creation of {cmd:neps:},
and some of the concepts used in the source code originate from a quite similar, unpublished command he created for his own and his colleagues' use, {it:nepsfile}.
{p_end}


{marker examples}
{title:Examples}

{phang}Open the {it:spEmp} file of NEPS Starting Cohort {it:4}, version {it:9.1.1}, in its {it:download} version:{break}
{input:. neps , study(SC4) version(9.1.1) level(D): use "spEmp"}{p_end}

{phang}Open the {it:pTargetCATI} dataset from the same SUF, but only data from wave 4:{break}
{input:. neps , study(SC4) version(9.1.1) level(D) : use using "pTarget" if wave==4 , clear}{p_end}

{phang}Merge variables with interviewer characteristics from the {it:TargetMethods} dataset from the same SUF, in its label language {it:en}:{break}
{input:. neps , study(SC4) version(9.1.1) level(D) language(en) : merge 1:1 ID_t wave using "TargetMethods" , keepusing(tx8030?) keep(match master)}{p_end}

{phang}Shorten all three examples above by recording preferences with option {opt setup}:{break}
{input:. neps , study(SC4) version(9.1.1) level(D) setup : use "spEmp"}{break}
{text:. * ... more commands go here ...}{break}
{input:. neps : use using "pTargetCATI" if wave==4 , clear}{break}
{text:. * ... more commands go here ...}{break}
{input:. neps , language(en): merge 1:1 ID_t wave using "TargetMethods" , keepusing(tx8030?) keep(match master)}{break}
{text:. * ... more commands go here ...}{p_end}

{phang}Same as above, but explicitly using {cmd:neps set} for recording parameters, and invoking {cmd:neps:} afterwards:{break}
{input:. neps set study SC4}{break}
{input:. neps set version 9.1.1}{break}
{input:. neps set level D}{break}
{input:. neps : use "spEmp"}{break}
{text:. * ... more commands go here ...}{break}
{input:. neps : use using "pTargetCATI" if wave==4 , clear}{break}
{text:. * ... more commands go here ...}{break}
{input:. neps , language(en): merge 1:1 ID_t wave using "TargetMethods" , keepusing(tx8030?) keep(match master)}{break}
{text:. * ... more commands go here ...}{p_end}


{marker author}
{title:Authors}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}), Leibniz Institute for Educational Trajectories (LIfBi), Germany.{break}
Daniel Klein, INCHER-Kassel.
{p_end}


{marker alsosee}
{title:Also see}

{psee}
{help NEPStools}
{p_end}
