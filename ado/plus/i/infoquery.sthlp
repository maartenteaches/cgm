{smcl}
{* *! version 1.11 31 May 2021}{...}
{vieweralsosee "nepstools" "help NEPStools"}{...}
{vieweralsosee "char" "help char"}{...}
{vieweralsosee "label language" "help label language"}{...}
{vieweralsosee "EMD (if installed from SSC)" "help emd"}{...}
{viewerjumpto "Syntax" "infoquery##syntax"}{...}
{viewerjumpto "Description" "infoquery##description"}{...}
{viewerjumpto "Options" "infoquery##options"}{...}
{viewerjumpto "Remarks" "infoquery##remarks"}{...}
{viewerjumpto "Examples" "infoquery##examples"}{...}
{viewerjumpto "Authors" "infoquery##author"}{...}
{viewerjumpto "Also see" "infoquery##alsosee"}{...}
help for {cmd:infoquery}{right:version 1.11 (31 May 2021)}
{hline}


{title:Title}

{phang}
{bf:infoquery} {hline 2} query information attached to variables{p_end}


{marker syntax}
{title:Syntax}
{p 8 17 2}
{cmd:infoquery} {varlist} [, {opt alllang:uages} {opt char:list(string)} {opt ID:s}]{p_end}


{marker description}
{title:Description}

{pstd}
{cmd:infoquery} fetches information saved in characteristics of any variable (using the command {cmd:char define {varname}[charname] {it:"text"}}) in {varlist} and prints them to standard output.{p_end}

{pstd}
In the NEPS datasets, question texts and instrument variable names are saved as variable characteristics, both in german as well as in english language (where applicable). This program makes it easy to access this information,
but may also be used for other purposes.{p_end}

{pstd}
{opt varlist} is the main parameter interpreted. Characteristics for every variable in {varlist} will be processed. Wildcards and variable abbreviation are supported.{break}
If option {opt alllanguages} is specified, information will be queried and displayed not only in the active dataset language, but in all languages saved in the dataset (see {help label language}).{break}
By default, characteristics ending on the string "{it:id}" are not displayed. If option {opt ids} is specified, these contents are also reported.
{p_end}

{pstd}
{opt charlist(string)} can be used to specify a list of characteristics to be displayed; this option may be useful when applying {cmd:infoquery} to other datasets than NEPS SUFs.
If omitted, {it:string} defaults to usual NEPS values (i.e. {it:NEPS_instname NEPS_sufname NEPS_varlabel_\`lang' NEPS_questiontext_\`lang' NEPS_variablequestion_\`lang'} and some more,
with `lang' being an unexpanded macro representing the active dataset language).{p_end}


{marker remarks}
{title:Remarks}

{pstd}
This command is part of the NEPStools bundle, written to assist with the {browse "https://www.neps-data.de/":NEPS} dataset files.{p_end}

{pstd}
As of version 1.11 or newer, {cmd:infoquery} is based on the EMD (extended metadata) framework. The framework documentation, and corresponding user commands, can be downloaded from SSC with the package {net `"describe emd , from("http://fmwww.bc.edu/repec/bocode/e")"':from SSC}.{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.{p_end}


{marker examples}
{title:Examples}

{phang}Query information for variables {it:t514001_w1} and {it:t514002_w1} in {browse "https://doi.org/10.5157/NEPS:SC4:1.1.0":doi:10.5157/NEPS:SC4:1.1.0}:{p_end}
{phang}{cmd:. use "SC4_xTarget_D_1-1-0.dta"}{p_end}
{phang}{cmd:. label language en}{p_end}
{phang}{cmd:. infoquery t514001_w1 t514002_w1}
{p_end}


{marker author}
{title:Author}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}), Leibniz Institute for Educational Trajectories, Germany. 


{marker alsosee}
{title:Also see}

{psee}
{space 2}Help: {help NEPStools}, {help char}, {help label language}, {help emd:help EMD} (if installed from SSC){p_end}
