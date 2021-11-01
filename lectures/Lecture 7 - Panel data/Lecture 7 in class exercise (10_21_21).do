
// Lecture 7 in-class exercise
// Panel data commands and fixed effects models

// Last updated: 10/21/21

cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 7 - panel data 1\In-class exercise"

// ************
// Exercise 1
// ************

use https://github.com/spcorcor18/LPO-8852/raw/main/data/Census_states_1970_2000.dta

// examine which variables are fixed and which are time varying
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
// Exercise 2
// ************

use https://github.com/spcorcor18/LPO-8852/raw/main/data/State_school_finance_panel_1990_2010.dta

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

// part c
// dummy variable for Mid-Atlantic
gen midatl=0
replace midatl=1 if inlist(state,"DC","DE","MD","NJ","NY","PA","VA","WV")
table state midatl

// part d
xtline expp_co if midatl==1
xtline expp_co if midatl, overlay

// part e
egen statemean=mean(expp_co),by(state)

// part f
twoway scatter expp_co2 staten
twoway scatter expp_co2 staten, xlabel(1(1)51, valuelabel alternate) xsize(10) ysize(4)

// part g
graph bar (asis) statemean if year==1990, over(state, sort(statemean) descending) xsize(10) ysize(4)


// ************
// Exercise 3
// ************

use https://github.com/spcorcor18/LPO-8852/raw/main/data/Texas_elementary_panel_2004_2007.dta

// (a) Declare panel structure

xtset campus year
xtdescribe
duplicates report campus year

// (b) Average passing rate across subjects, grades

rename ca311tar avgpassing
xtsum avgpassing

// (c) Transitions between accountability ratings
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


// (d) Average class size across grades

egen avgclass=rowmean(cpctg01a-cpctgmea)

// (e) Cross sectional OLS regression, 2007 only

reg avgpassing avgclass if year==2007

// (f) First difference OLS regression, 2007 only

reg d.avgpassing d.avgclass if year==2007, noconstant
reg d.avgpassing d.avgclass if year==2007
table year if e(sample)

// (g) First difference OLS regression, all years

reg d.avgpassing d.avgclass, noconstant
reg d.avgpassing d.avgclass
table year if e(sample)

// (h) LSDV regression--limit to Houston from 2006 on

reg avgpassing avgclass i.campus if houston==1 & year>=2006
areg avgpassing avgclass if houston==1 & year>=2006, absorb(campus)
table year if e(sample)

// (i) Fixed effects (within) version--first Houston subsample, then all

xtreg avgpassing avgclass if houston==1 & year>=2006, fe
xtreg avgpassing avgclass , fe

// (j) Two-way fixed effects model with year effects

xtreg avgpassing avgclass i.year , fe
table year if e(sample)

// Other: get predicted school effects

predict schlfe, u
preserve
duplicates drop campus, force
histogram schlfe
restore

// Compare results using FD, FE when T=2

reg d.avgpassing d.avgclass if year==2007, noconstant
xtreg avgpassing avgclass if year>=2006, fe
areg avgpassing avgclass if year>=2006, absorb(campus)

// Heteroskedasticity test following xtreg, fe
// Ho is homoskedasticity--equal variance for all i

ssc install xttest3
xtreg avgpassing avgclass, fe
xttest3

