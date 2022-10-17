
// Lecture 4 in-class example
// Panel data commands and fixed/random effects models

// Last updated: 10/17/22

cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 4 - Panel data"

// ************
// Example 1
// ************
// Illustrating reshape command

use https://github.com/spcorcor18/LPO-8852/raw/main/data/Census_states_1970_2000.dta

// panel is currently in long format; browse to see which variables are fixed 
// and which are time varying
browse

// panel is balanced - there are 4 obs per state
table state_name

// reshape to wide
reshape wide medhhinc unemp, i(state state_name) j(year)

// looks good
browse

// reshape back to long
reshape long

// looks good
browse

clear


// ************
// Example 2
// ************

use https://github.com/spcorcor18/LPO-8852/raw/main/data/State_school_finance_panel_1990_2010.dta, clear

// xtset state year doesn't work since state is non-numeric
xtset state year
// create a numeric version of state
encode state , gen(staten)
xtset staten year

// panel of participation
xtdescribe

// descriptives
summ expp_co2,detail
xtsum expp_co2

// for graphing purposes identify Mid Atlantic states
gen midatl=0
replace midatl=1 if inlist(state,"DC","DE","MD","NJ","NY","PA","VA","WV")
table state midatl

// use xtline to plot time series for Mid Atlantic states
xtline expp_co if midatl==1
xtline expp_co if midatl, overlay

// calculate within-state mean expenditure per pupil
egen statemean=mean(expp_co),by(state)

// scatter plot that illustrates within-state variation over time
twoway scatter expp_co2 staten
twoway scatter expp_co2 staten, xlabel(1(1)51, valuelabel alternate) xsize(10) ysize(4)

// bar graph showing state means (descending)
// only need one year (arbitrary) since statemean is the same in all years within state
graph bar (asis) statemean if year==1990, over(state, sort(statemean) descending) xsize(10) ysize(4)
clear


// ************
// Example 3
// ************

use https://github.com/spcorcor18/LPO-8852/raw/main/data/Texas_elementary_panel_2004_2007.dta, clear

// (a) Declare panel structure

xtset campus year
xtdescribe
duplicates report campus year

// (b) Average passing rate across subjects, grades is called "ca311tar"

rename ca311tar avgpassing
xtsum avgpassing

// (c) Average class size across grades

egen avgclass=rowmean(cpctg01a-cpctgmea)

// (d) Cross sectional OLS regression, 2007 only

reg avgpassing avgclass if year==2007

// (e) First difference OLS regression, 2007 only

reg d.avgpassing d.avgclass if year==2007, noconstant
reg d.avgpassing d.avgclass if year==2007
// re-run the cross sectional OLS limited to those observation used in the first diff
reg avgpassing avgclass if e(sample) & year==2007
table year if e(sample)

// (f) How much within-school variation is there in avgclass? avgpassing?

gen davgpassing=d.avgpassing
gen davgclass=d.avgclass
twoway (histogram davgclass if year==2007)
summ davgclass, detail

// (g) First difference OLS regression, all years

reg d.avgpassing d.avgclass, noconstant
reg d.avgpassing d.avgclass
table year if e(sample)

// (h) LSDV regression
// Limit to Houston from 2006 on given the large number of schools (campus)

reg avgpassing avgclass i.campus if houston==1 & year>=2006
areg avgpassing avgclass if houston==1 & year>=2006, absorb(campus)
table year if e(sample)

// (i) LSDV regression with a tiny subset of schools--for interpretation of FEs

// identify largest average enrollment schools in Houston to include
egen meanenroll=mean(cpetallc) if houston==1 & year>=2006,by(campus)
egen enrollrank=rank(meanenroll) if houston==1 & year>=2006, field
reg avgpassing avgclass i.campus if enrollrank<=16
predict avgpassinghat if e(sample), xb
sort campus year
browse campus year avgpassing avgpassinghat avgclass if e(sample)
drop avgpassinghat

// (j) Fixed effects (within) version

// first Houston subsample
xtreg avgpassing avgclass if houston==1 & year>=2006, fe
// now all schools all years
xtreg avgpassing avgclass , fe

// (k) Get predicted school effects from xtreg
xtreg avgpassing avgclass, fe
predict schlfe, u
browse campus year schlfe if e(sample)

// histogram of estimated school effects--keep only one per school
preserve
duplicates drop campus, force
histogram schlfe
restore

// compare to mini dataset with largest districts in Houston
xtreg avgpassing avgclass if enrollrank<=16
predict schlfe2 if e(sample), u
reg avgpassing avgclass i.campus if enrollrank<=16
// the FE estimate is not the same as the dummy coefficient in reg. Re: different
// reference category
summ schlfe2 if campus==101912158

// (l) Two-way fixed effects model with year effects

xtreg avgpassing avgclass i.year , fe
table year if e(sample)

// alternative command reghdfe
reghdfe avgpassing avgclass, absorb(campus year)


// ********************************************
// OTHER:
// Compare results using FD, FE when T=2

reg d.avgpassing d.avgclass if year==2007, noconstant
xtreg avgpassing avgclass if year>=2006, fe
areg avgpassing avgclass if year>=2006, absorb(campus)

// Heteroskedasticity test following xtreg, fe
// Ho is homoskedasticity--equal variance for all i

ssc install xttest3
xtreg avgpassing avgclass, fe
xttest3

// Transitions between accountability ratings
// Interpret these as transition probabilities
// A = Academically Acceptable
// E = Exemplary
// L = "School Leaver" Provision
// R = Recognized
// X = Exception

encode c_rating, gen(c_rating2)
xttrans c_rating2
xttrans c_rating2, freq

// Exmaple of xttab
xttab c_rating2
// Here "overall" refers to campus-years. "Between" counts the number of
// schools who ever had a given value (categories are not mutually exclusive).
// "Within" refers to fraction of time a campus has a given rating, conditional
// on ever having that rating.
