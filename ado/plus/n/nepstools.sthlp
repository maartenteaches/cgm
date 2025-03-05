{smcl}
{* *! version 2.14 30 August 2021}{...}
{vieweralsosee "NEPSmgmt" "help nepsmgmt"}{...}
{vieweralsosee "charren" "help charren"}{...}
{vieweralsosee "infoquery" "help infoquery"}{...}
{vieweralsosee "nepsmiss" "help nepsmiss"}{...}
{vieweralsosee "neps :" "help neps"}{...}
{vieweralsosee "comp2long" "help comp2long"}{...}
{viewerjumpto "Description" "nepstools##description"}{...}
{viewerjumpto "Remarks" "nepstools##remarks"}{...}
{viewerjumpto "Author" "nepstools##author"}{...}
{viewerjumpto "Also see" "nepstools##alsosee"}{...}
documentation file for {cmd:nepstools}{right:Version 2.14 (30 August 2021)}
{hline}


{title:Title}

{phang}
{bf:NEPStools} {hline 2} handy tools to work with NEPS Scientific Use Files
{p_end}


{marker description}{...}
{title:Description}

{pstd}
{bf:NEPStools} are a bundle of Stata commands to be used with {browse "https://www.neps-data.de/":NEPS} Scientific Use Files.
Nonetheless, most of these commands could also be used with other dataset files (although NEPS staff will not give any support for it).
{break}Use at your own risk.
{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
{bf:NEPStools} currently consists of the commands {cmd:charren}, {cmd:infoquery}, {cmd:nepsmiss}, the {cmd:neps:} prefix command, and {cmd:comp2long}.
{p_end}

{pstd}
The source code of all {bf:NEPStools} programs is licensed under the GNU General Public License version 3 or later.
The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}


{marker author}{...}
{title:Author}

{pstd}
LIfBi Research Data Center ({browse "mailto:fdz@lifbi.de":fdz@lifbi.de}), Leibniz Institute for Educational Trajectories (LIfBi), Germany. Contact: Daniel Bela.
{p_end}


{marker alsosee}{...}
{title:Also see}

{psee}
{space 2}Help: {help charren}, {help infoquery}, {help nepsmiss}, {help neps:neps:}, {help comp2long}
{p_end}

{psee}
{space 2}NEPSmgmt: data management tools developed for NEPS Scientific Use File generation - {stata "net describe nepsmgmt, from(http://nocrypt.neps-data.de/stata)"}
{p_end}
