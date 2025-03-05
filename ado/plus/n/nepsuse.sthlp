{smcl}
{* *! version 1.2.1 04 May 2018}{...}
{vieweralsosee "neps" "help neps"}{...}
{vieweralsosee "nepstools" "help NEPStools"}{...}
{vieweralsosee "use" "help use"}{...}
{vieweralsosee "label language" "help label language"}{...}
{viewerjumpto "Syntax" "nepsuse##syntax"}{...}
{viewerjumpto "Description" "nepsuse##description"}{...}
{viewerjumpto "Options" "nepsuse##options"}{...}
{viewerjumpto "Remarks" "nepsuse##remarks"}{...}
{viewerjumpto "Examples" "nepsuse##examples"}{...}
{viewerjumpto "Authors" "nepsuse##author"}{...}
{viewerjumpto "Also see" "nepsuse##alsosee"}{...}
help for {cmd:nepsuse}{right:version 1.2.1 (04 May 2018)}
{hline}

{phang}{error}{bf:Warning: nepsuse} is deprecated; please consider migrating your syntax to use its successor, {bf:neps}.{break}
{tab}See {help neps:help neps} for details on this more powerful command.{text}


{title:Title}

{phang}
{bf:nepsuse} {hline 2} Conveniently open a NEPS Scientific Use File (SUF) dataset



{title:Table of contents}

	{help nepsuse##syntax:Syntax}
	{help nepsuse##description:Description}
	{help nepsuse##options:Options}
	{help nepsuse##remarks:Remarks}
	{help nepsuse##examples:Examples}
	{help nepsuse##author:Authors}
	{help nepsuse##alsosee:Also see}


{marker syntax}
{title:Syntax}

{phang}
Load NEPS Scientific Use File dataset

{p 8 12 2}
{cmd:nepsuse} {it:NEPS dataset name} [{cmd:, options}]


{phang}
Load subset of NEPS Scientific Use File dataset

{p 8 12 2}
{cmd:nepsuse} [{varlist}] {ifin} {cmd:using} {it:NEPS dataset name} [{cmd:, options}]{p_end}

{phang}
Pre-record option preferences for all further {cmd:nepsuse} invocations in this Stata session:

{p 8 12 2}
{cmd:nepsuse} [{varlist}] {ifin} [{cmd:using} {it:NEPS dataset name}] [{cmd:, options}] setup{p_end}

{phang}
Display previously recorded option preferences (if any), and version information, then exit:

{p 8 12 2}
{cmd:nepsuse}{p_end}

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt dir:ectory(dirname)}}directory name of the file to open{p_end}
{synopt:{opt c:ohort(shortcode)}}NEPS Starting Cohort short code (e.g. {it:SC6}){p_end}
{synopt:{opt ver:sion(version number)}}NEPS SUF dataset version (e.g, {it:6.0.1}){p_end}
{synopt:{opt lev:el(anonymisation level)}}access level of the dataset (i.e. one of {it:S}=semantic data structure file, {it:D}=download, {it:R}=RemoteNEPS, {it:O}=on-site){p_end}
{synopt:{opt lang:uage(language code)}}language to open the dataset in (e.g. {it:en}){p_end}

{syntab:Advanced}
{synopt:{opt set:up}}set manually speficied options as global macros for further use in the Stata session{p_end}
{synopt:{opt other}}all options for Stata's {cmd:use} are allowed and will be passed to {cmd:use} itself{p_end}
{synoptline}
{p2colreset}{...}


{marker description}
{title:Description}

{pstd}
{cmd:nepsuse} is a wrapper for Stata's regular command {cmd:use}.
It eases access to datasets from {browse "https://www.neps-data.de/":NEPS} Scientific Use Files (SUFs) from within Stata by automatically concatenating the file name of the target file.
This enables NEPS users to only code{break}
{input:. nepsuse "pTarget"}{break}
where Stata's default {cmd:use} would need{break}
{input:. use "/any/directory/name/SC6_pTarget_D_6-0-1.dta"}
{p_end}

{pstd}
All parts of the file path needed by {cmd:use}, besides the pure NEPS file title (e.g. {it:pTarget} in the above illustration) can either be specified manually as options,
or defined as {help macro:global macros} (i.e. {c S|}{c -(}NEPSuse_{it:optionname}{c )-}). {cmd:nepsuse} will take care of file path concatenation.
{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt directory(dirname)} is optional; if specified, {it:dirname} will be used to concatenate the file path (instead of the current working directory).{break}
Will be automatically filled if the global macro {it:{c S|}{c -(}NEPSuse_directory{c )-}} is defined.{p_end}

{phang}
{opt cohort(shortcode)} is mandatory; {it:shortcode} is a NEPS Starting Cohort short code.{break}
Will be automatically filled if the global macro {it:{c S|}{c -(}NEPSuse_cohort{c )-}} is defined; in this case, the option can be omitted.{p_end}

{phang}
{opt version(version number)} is mandatory; {it:version number} is a version number of a NEPS Scientific Use file.{break}
Will be automatically filled if the global macro {it:{c S|}{c -(}NEPSuse_version{c )-}} is defined; in this case, the option can be omitted.{p_end}

{phang}
{opt level(anonymisation level)} is mandatory; {it:anonymisation level} is one of the capital letters {it:S}, {it:D}, {it:R} or {it:O},
corresponding to the NEPS anonymisation levels {it:semantic data structure file}, {it:download}, {it:RemoteNEPS} and {it:on-site}.{break}
Will be automatically filled if the global macro {it:{c S|}{c -(}NEPSuse_level{c )-}} is defined; in this case, the option can be omitted.{p_end}

{phang}
{opt language(lang)} is optional; if specified, labels will be read in language {it:lang}.{break}
Will be automatically filled if the global macro {it:{c S|}{c -(}NEPSuse_language{c )-}} is defined.{p_end}

{dlgtab:Advanced}

{phang}
{opt setup} if specified, {cmd:nepsuse} will save all manually specified options as global macros in the Stata session.{break}
On further invocations of {cmd:nepsuse}, these pre-saved options will automatically be read, eliminating the need to re-specify each option in the session.{break}
This is a shorthand for manually defining the global macros at the beginning of a session, and re-using them afterwards.{break}
When this option is used, invoking {cmd:nepsuse} without a file name specification is {p_end}

{phang}
{opt other} options will silently be passed to Stata's {cmd:use} itself.
Please refer to the {help use:corresponding help file} for a {help use##options:list of allowed options}.{p_end}


{marker remarks}
{title:Remarks}

{pstd}
While {cmd:nepsuse} eases opening NEPS SUF dataset files, entering all parameters manually upon each and any occasion of opening a file might be cumbersome.
Thus, {cmd:nepsuse} features a way for automatically reading each option from a global macro named {c S|}{c -(}NEPSuse_{it:optionname}{c )-}.
This enables the user to only define, say, the NEPS {it:Starting Cohort} in question once.{p_end}

{pstd}
This means that invoking{break}
{input:. nepsuse "pTarget" , cohort("SC6") ...}{break}
{input:. nepsuse "spEmp" , cohort("SC6") ...}{break}
is identical to writing{break}
{input:. global NEPSuse_cohort "SC6"}{break}
{input:. nepsuse "pTarget" , ...}{break}
{input:. nepsuse "spEmp" , ...}{break}
This is helpful for do-files that have to open several datasets, so that {cmd:nepsuse}'s parameters can be defined once at the beginning of the do-file.
{p_end}

{pstd}
Upon user request, the option {opt setup} has been implemented as a variant of the latter example above. It enables a work flow where the options are manually set once, and a global macro is automatically recorded for further use:{break}
{input:. nepsuse "pTarget" , cohort("SC6") setup ...}{break}
{input:. nepsuse "spEmp" , ...}{break}
{p_end}

{pstd}
When {cmd:nepsuse} is invoked without arguments, it will display version information and information about all previously recorded option preferences, and exit.
{p_end}

{pstd}
Note that if both a global macro {c S|}{c -(}NEPSuse_{it:optionname}{c )-} and a manual option {opt optionname()} statement are used, the manual option always takes precedence.
{p_end}

{pstd}
This command is part of the NEPStools bundle, written to assist with the {browse "https://www.neps-data.de/":NEPS} dataset files.
{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}

{pstd}
We like to thank Daniel Klein (University of Kassel), one of our active and committed NEPS data users, for his valuable bug hunt and suggestions on how to further improve {cmd:nepsuse}.{break}
His feedback led to version 1.2, which fixes several issues in special use cases, and adds the option {opt setup} to the command.
{p_end}


{marker examples}
{title:Examples}

{phang}Open the {it:spEmp} file of NEPS Starting Cohort {it:6}, version {it:6.0.1}, in its {it:download} version:{break}
{input:. nepsuse "spEmp" , cohort(SC6) version(6.0.1) level(D)}{p_end}

{phang}Open the {it:pTarget} dataset from the same SUF, but only data from wave 4:{break}
{input:. nepsuse using "pTarget" if wave==4 , cohort(SC6) version(6.0.1) level(D) clear}{p_end}

{phang}Open the {it:Methods} dataset from the same SUF, but only data from wave 4 and variables {it:ID_t wave inty intm intd}, and activate its label language {it:en}:{break}
{input:. nepsuse ID_t wave inty intm intd using "Methods" if wave==4 , cohort(SC6) version(6.0.1) level(D) language(en) clear}{p_end}

{phang}Shorten all three examples above by pre-defining parameters as global macros, and invoking {cmd:nepsuse} afterwards:{break}
{input:. global NEPSuse_cohort SC6}{break}
{input:. global NEPSuse_version 6.0.1}{break}
{input:. global NEPSuse_level D}{break}
{input:. nepsuse "spEmp"}{break}
{text:. * ... more commands go here ...}{break}
{input:. nepsuse using "pTarget" if wave==4 , clear}{break}
{text:. * ... more commands go here ...}{break}
{input:. nepsuse ID_t wave inty intm intd using "Methods" if wave==4 , language(en) clear}{break}
{text:. * ... more commands go here ...}{p_end}

{phang}Same as above, but with using the option {opt setup} to pre-save the global macros:{break}
{input:. nepsuse , setup cohort(SC6) version(6.0.1) level(D)}{break}
{input:. nepsuse "spEmp"}{break}
{text:. * ... more commands go here ...}{break}
{input:. nepsuse using "pTarget" if wave==4 , clear}{break}
{text:. * ... more commands go here ...}{break}
{input:. nepsuse ID_t wave inty intm intd using "Methods" if wave==4 , language(en) clear}{break}
{text:. * ... more commands go here ...}{p_end}

{marker author}
{title:Authors}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}), Leibniz Institute for Educational Trajectories (LIfBi), Germany.
{p_end}


{marker alsosee}
{title:Also see}

{psee}
{help neps}, {help NEPStools}, {help use}, {help label language}
{p_end}
