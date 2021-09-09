
// Lecture 3 in-class exercise 
// September 9, 2021

// Lalonde (1986) NSW experiment data -- add nonexperimental control group 
// from CPS and PSID and use matching estimators for comparison.

// original source of data: http://users.nber.org/~rdehejia/data/nswdata2.html

// ***********
// Question 1
// ***********

use https://github.com/spcorcor18/LPO-8852/raw/main/data/nsw_dw.dta, clear
tabulate treat
reg re78 treat
ttest re78, by(treat)

foreach j in re74 re75 educ age black {
   ttest `j', by(treat)
   }

   
// ************
// Question 2-3
// ************
// Append CPS and PSID data to NSW
// sort order can matter so set seed and sort by a random number
set seed 1234
use https://github.com/spcorcor18/LPO-8852/raw/main/data/nsw_dw.dta, clear

//keep only treated cases for matching
drop if treat==0

//append CPS and PSID data
append using https://github.com/spcorcor18/LPO-8852/raw/main/data/cps_controls.dta
append using https://github.com/spcorcor18/LPO-8852/raw/main/data/psid_controls.dta
gen randno=runiform()
sort randno

nmissing
tabulate treat


// ***********
// Question 4
// ***********
// OLS estimation of treatment effect
reg re78 treat
reg re78 treat age educ re74 re75 black hispanic


// ***********
// Question 5
// ***********
// Nearest neighbor matching based on covariates

teffects nnmatch (re78 age educ re74 re75 black hispanic) (treat) , ematch(black hispanic) atet
tebalance summarize


// ***********
// Question 6
// ***********
// Estimate propensity scores

*ssc install psmatch2, replace
psmatch2 treat age educ black hispanic re74 re75
summ _*
summ age-re75 if treat==1
table treat _weight, row col


// ***********
// Question 7
// ***********
// Distribution of propensity scores-all observations

histogram _pscore , name(pscore1, replace) nodraw
histogram _pscore if _pscore>0.01, name(pscore2, replace) nodraw
graph combine pscore1 pscore2, ysize(4) xsize(8) 


// ***********
// Question 8
// ***********
// Distribution of propensity scores--separately for treated and untreated

histogram _pscore, kdensity kdenopts(gaussian) by(treat, cols(1) legend(off)) ///
	ytitle(Frequency) xtitle(Estimated Propensity Scores)

histogram _pscore if _pscore>0.01, kdensity kdenopts(gaussian) by(treat, cols(1) legend(off)) ///
	ytitle(Frequency) xtitle(Estimated Propensity Scores)	
	
psgraph

// all cases with _pscore>0.01 (omit those on common support but very tiny p-score)
twoway (histogram _pscore if treat==0 & _pscore>0.01, ///
   bin(20) fcolor(none) lcolor(blue)) (histogram _pscore if treat==1 & _pscore>0.01, ///
   bin(20) fcolor(none) lcolor(red)), name(pscore3, replace) nodraw

// matched sample
twoway (histogram _pscore if treat==0 & _pscore>0.01 [fweight = _weight], ///
   bin(20) fcolor(none) lcolor(blue)) (histogram _pscore if treat==1 & _pscore>0.01, ///
   bin(20) fcolor(none) lcolor(red)), name(pscore4, replace) nodraw
   
graph combine pscore3 pscore4, ysize(4) xsize(8)

// only uses nonmissing weights (185 + 185)
tabulate treat [fweight=_weight]


// ***********
// Question 9
// ***********
// Use pstest to check balance on covariates

pstest age educ black hispanic re74 re75
// note: J Hill has ado file called psbal2 that tests balance

// looking at %bias measure
tabstat age [aweight=_weight], by(treat) stat(n mean sd var)

twoway (histogram re74 if treat==0 & _pscore>0.01 [fweight = _weight], ///
   bin(20) fcolor(none) lcolor(blue)) (histogram re74 if treat==1 & _pscore>0.01, ///
   bin(20) fcolor(none) lcolor(red))

   
// ***********
// Question 10
// ***********
// Request ATT

psmatch2 treat age educ black hispanic re74 re75, outcome(re78)

// NOTE the sort order of data can affect results when using NN matching on
// a pscore estimated with categorical variables (or when there are untreated
// with identical propensity scores).


// ***********
// Question 11
// ***********
// Regression of re78 on treatment for the matched sample; use _weight
regress re78 treat [pw=_weight]
// notice same estimate here (though different se)


// ***********
// Question 12
// ***********
// additional adjustment with covariates

regress re78 treat age educ black hisp re74 re75 [pw=_weight]


// ***********
// Question 13
// ***********
// bootstrap standard errors

bootstrap att=r(att), rep(1000): psmatch2 treat age educ black hispanic re74 re75, outcome(re78)


// ***********
// Question 14
// ***********
// try 5 nearest neighbors

psmatch2 treat age educ black hisp re74t re75t, outcome(re78) neighbor(5)


// ***********
// Question 15
// ***********
// teffects for comparison (note different number of nearest neighbors)

teffects psmatch (re78) (treat age educ black hispanic re74 re75, probit), atet gen(mvar)
predict ps
tebalance summarize
teffects overlap



// Miscellany

// example of creating weights
psmatch2 treat age educ black hisp re74t re75t
gen wts=1
replace wts=_pscore/(1-_pscore) if treat==0
sum wts
*** you might notice here that some weights too large!
replace wts=15 if wts>15
replace _weight=wts
regress re78 treat age educ black hisp re74 re75 [pw=_weight]

// try other specifications for pscore model
gen re74tL = ln(re74t + 0.001)
gen re75tL = ln(re75t + 0.001)
psmatch2 treat age educ black hisp re74t re75t re74tL re75tL

// J Hill examples show histograms pre and post match (for x's)

psmatch2 treat age educ black hisp re74t re75t

// all cases with _pscore>0.01 (omit those on common support but very tiny p-score)
twoway (histogram re75t if treat==0 , ///
   bin(20) fcolor(none) lcolor(blue)) (histogram re75t if treat==1, ///
   bin(20) fcolor(none) lcolor(red))

// matched sample
twoway (histogram re75t if treat==0 [fweight = _weight], ///
   bin(20) fcolor(none) lcolor(blue)) (histogram re75t if treat==1, ///
   bin(20) fcolor(none) lcolor(red))
