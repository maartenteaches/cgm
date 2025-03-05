{smcl}
{* *! version 1.3 16 Jan 2024}{...}
{vieweralsosee "nepstools" "help NEPStools"}{...}
{vieweralsosee "char" "help char"}{...}
{vieweralsosee "label language" "help label language"}{...}
{viewerjumpto "Syntax" "comp2long##syntax"}{...}
{viewerjumpto "Description" "infoquery##description"}{...}
{viewerjumpto "Options" "comp2long##options"}{...}
{viewerjumpto "Remarks" "comp2long##remarks"}{...}
{viewerjumpto "Examples" "comp2long##examples"}{...}
{viewerjumpto "Authors" "comp2long##author"}{...}
{viewerjumpto "Also see" "comp2long##alsosee"}{...}
help for {cmd:comp2long}{right:version 1.3 (15 Jan 2024)}
{hline}

comp2long
{title:Title}

{phang}
{bf:comp2long} {hline 2} reshape NEPS competency data from wide to long {p_end}


{marker syntax}
{title:Syntax}
{p 8 17 2}
{cmd:comp2long} 
{it:{help filename}}
[{cmd:,} {opt clear} {opt save} {opt replace} {opt harm:onize} {opt onlyharm:onized} {opt drops:ingle} {opt verbose} {opt ignore}]


{synoptset 20 tabbed}{...}
{marker comopt}{synopthdr:options}
{synoptline}
{synopt :{opt clear}}allows you to clear dataset in memory {p_end}
{synopt :{opth save(string)}}save data to desired filepath and filename {p_end}
{synopt :{opth replace(string)}}overwriting former saved file {p_end}
{synopt :{opt harm:onize}}keeps only harmonized variables {p_end}
{synopt :{opt onlyharm:onized}}renames repeated items to same variable name{p_end}
{synopt :{opt drops:ingle}}option is obsolete: single-items are not being harmonized anymore {p_end}
{synopt :{opt ignore}}ignores misspecified items{p_end}
{synopt :{opt verbose}}shows more detail during process{p_end}
{synoptline}


{marker description}
{title:Description}

{pstd}
{cmd:comp2long} reshapes NEPS competency data from wide format to long format and automatically sorts variables to the waves in which data was collected.{p_end}

{pstd}
NEPS competency data is stored in wide-format but survey data in pTarget-datasets is stored in long format. The different ways data is stored in competency data and survey data inevitably leads to data management issues users have to solve before data can by used in a combined dataset. This tool should reduce the amount of work and time users have to invest to achieve this goal. {p_end}

{pstd}
{opt clear} specifies that it is okay to replace the data in memory, even though the current data have not been saved to disk.{p_end}

{pstd}
{opt replace} overwrite existing reshaped competency dataset.{break}
If option {opt replace} is specified, a former saved file will be overwritten.
{p_end}

{pstd}
{opt save} stores data to a desired filepath and filename.{break}
If option {opt replace} is specified, a former saved file will be overwritten.
{p_end}

{pstd}
{opt harmonize} renames the repeated scored items so they share the same variable name.{break}
The new variable name consists of the variable name's root, followed by the suffix "_ha",  e.g. variable {bf:scg9_sc1} and variable {bf:scg11_sc1} will share the variable name sc_sc1_ha. The label of the variable tells you if a variable was harmonized. Single items will be just sorted into the proper wave.
{p_end}

{pstd}
{opt onlyharmonized} keeps only harmonized scored variables (single items will be dropped). onlyharmonized triggers the option {bf: harmonize}, when harmonize is not chosen.
{p_end}

{pstd}
{opt dropsingle} dropsingle is obsolete; to drop single items simply choose option {bf: onlyharmonized} to keep only scored items; harmonization of single items is no longer supported; 
{p_end}

{pstd}
{opt ignore} is forcing the process to go on even there are some misspecified items which can't be harmonized. This misspecification occurs when wave_w*-variables were calculated incorrectly. In this case please contact {browse "mailto:fdz@lifbi.de":fdz@lifbi.de} for further help!
{p_end}

{pstd}
{opt verbose} shows you some of the magic that happens during the process.
{p_end}

{marker remarks}
{title:Remarks}

{pstd}
This command is part of the NEPStools bundle, written to assist with the {browse "https://www.neps-data.de/":NEPS} dataset files.{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.{p_end}


{marker examples}
{title:Examples}

{phang}reshapes competency data from wide to long without saving data {browse "https://doi.org/10.5157/NEPS:SC4:12.0.0":doi:10.5157/NEPS:SC4:12.0.0}:{p_end}
{phang}{cmd:. comp2long "C:/NEPS/SC4/12-0-0/SC4_xTargetCompetencies_D_12-0-0.dta"}{p_end}

{phang}reshapes competency data from wide to long without saving data and clears existing dataset in memory {browse "https://doi.org/10.5157/NEPS:SC4:12.0.0":doi:10.5157/NEPS:SC4:12.0.0}:{p_end}
{phang}{cmd:. comp2long "C:/NEPS/SC4/12-0-0/SC4_xTargetCompetencies_D_12-0-0.dta", clear}{p_end}

{phang}reshapes competency data from wide to long, saving and replacing data {browse "https://doi.org/10.5157/NEPS:SC4:12.0.0":doi:10.5157/NEPS:SC4:12.0.0}:{p_end}
{phang}{cmd:. comp2long "C:/NEPS/SC4/12-0-0/SC4_xTargetCompetencies_D_12-0-0.dta", save("Y:/NEPS_workingdata/SC4/pTargetCompetencies.dta") replace} {p_end}

{phang}reshapes competency data from wide to long, saving and replacing data and harmonizes variable names of scored items {browse "https://doi.org/10.5157/NEPS:SC4:12.0.0":doi:10.5157/NEPS:SC4:12.0.0}:{p_end}
{phang}{cmd:. comp2long "C:/NEPS/SC4/12-0-0/SC4_xTargetCompetencies_D_12-0-0.dta", save("Y:/NEPS_workingdata/SC4/pTargetCompetencies.dta") replace harmonize} {p_end}

{phang}reshapes competency data from wide to long, saving and replacing data, harmonizes variable names of scored items and keeps only scored harmonized variables {browse "https://doi.org/10.5157/NEPS:SC4:12.0.0":doi:10.5157/NEPS:SC4:12.0.0}:{p_end}
{phang}{cmd:. comp2long "C:/NEPS/SC4/12-0-0/SC4_xTargetCompetencies_D_12-0-0.dta", save("Y:/NEPS_workingdata/SC4/pTargetCompetencies.dta") replace harmonize onlyharmonized} {p_end}


{marker limitations}
{title:Limitations}

{phang}use {bf:comp2long} {ul:{bf:before}} you use {bf:nepsmiss}, otherwise this tool will {bf:crash}!{p_end}
{phang}This syntax will crash if the same number of cases with wave_wX==0 occurs in two or more wave_wX-variables (e.g. wave_w1 and wave_w4 have equal numbers of non-participating individuals). This is VERY unlikely but yet possible!{p_end}

{pstd}
{bf: We cannot guarantee that it is usefull to treat all harmonized variables as longitudinal variables.}{p_end}


{marker author}
{title:Author}

{pstd}
Dietmar Angerer ({browse "mailto:dietmar.angerer@lifbi.de":dietmar.angerer@lifbi.de}), Leibniz Institute for Educational Trajectories, Germany. 


{marker alsosee}
{title:Also see}

{psee}
{space 2}Help: {help NEPStools}, {help merge}, {help append}{p_end}
