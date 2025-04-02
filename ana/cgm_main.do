version 18
clear all
macro drop _all

// use only community contributed packages from 
// the ado directory local to this project
*cd "D:\Mijn documenten\projecten\track_mobility\cgm\"
cd "c:\active\cgm"
sysdir set PLUS     "`c(pwd)'/ado/plus"
sysdir set PERSONAL "`c(pwd)'/ado/personal"
sysdir set OLDPLACE "`c(pwd)'/ado"
mata: mata mlib index

// set the working directory
cd ana

do cgm_dta01.do // merge educational trajectories
do cgm_dta02.do // explanatory variables
do cgm_dta03.do // clean spells
do cgm_dta04.do // make consistent spells
do cgm_dta05.do // turns spells into transitions
do cgm_dta06.do // merge explanatory vars into transitions
do cgm_ana01.do // descriptives
do cgm_ana02.do // estimate the sequential logit models and present results
exit
