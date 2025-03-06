# Loophole or second chance?
## Track mobility and inequality of educational outcomes in Germany

*Maarten L. Buis*

*University of Konstanz*

## Description

These are the replication files for the project Loophole or second chance? Track 
mobility and inequality of educational outcomes in Germany. The aim of this 
project is investigate how different disadvantaged groups make use of the 
possiblities afforded by track mobility. In particular we look at three types of
disadvantage: 
  - children from parents with less education
  - children from migrants
  - women (at least in the early cohorts they can be classified as disadvantaged)
  
Theoretically, we have no reason to believe that these different types of 
disadvantaged groups will respond in the same way to track mobility. 

I would expect that children from less educated parents will be *less* likely to 
use track mobility compared to children from better educated parents. Children
from better educated parents who could do track mobility are likely in a lower 
track than there parents, and thus are at risk of downward mobility. Avoiding a
loss (downward mobility) is often a much stronger motivating factor than getting 
a win (upward mobility). 

I would expect that children from migrants will be *more* likely to use track 
mobility compared to children with a migration background. Children with a 
migration background may face discrimination and the family may have less 
knowledge about the German education system. Which may lead to them being 
initially assigned to lower tracks. At the same time there is a consistent 
finding that children with a migration background tend to have significantly 
higher educational aspirations than their counterparts without a migration 
background. So children with a migration background are more likely to need 
track mobility and have the motivation to use it.

I would expect that women were *less* likely to use track mobility, but that 
this *difference has reduced* in more recent cohorts. In early cohorts being in 
a lower track would have less long term consequences for women compared to men, 
as women were not expected to become the main breadwinner. So in those early 
cohorts, women in lower tracks would face less pressure to change track than men. 
In more recent cohorts this has likely changed. 


## Requirements and use

These .do files require Stata 18 or higher.

To use these .do files you:

1. fork this repository
2. create a directory `cgm\data\`
3. Obtain the raw data files starting cohort 6 version 15.0.0 from https://doi.org/10.5157/NEPS:SC6:15.0.0 and save those in the directory `data`
4. In ana/cgm_main.do change line 7 (`cd ..."`) to where your directory is
5. run cgm_main.do 
