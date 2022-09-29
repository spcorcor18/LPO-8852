
// Lecture 3 in-class exercise
// Last updated: September 29, 2022

cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 3 - Difference-in-differences"
* ssc install outreg2
* ssc install statastates
ssc install reghdfe, replace
ssc install ftools, replace


// ****************************************************************************
// Part 1 
// Replication of Dynarski (2003) from Murnane & Willett chapter 8
// ****************************************************************************

set more off
clear all
use https://github.com/spcorcor18/LPO-8852/raw/main/data/dynarski.dta, clear

// #1
tabulate yearsr offer
tabulate yearsr fatherdec

// #2
// "First difference"
reg coll offer if fatherdec==1 [weight=wt88]
reg hgc23 offer if fatherdec==1 [weight=wt88]

// #3
// Difference-in-differences
reg coll i.offer##i.fatherdec [weight=wt88]

// #4
// Graph of means
preserve
collapse (mean) coll [weight=wt88], by(fatherdec yearsr)
twoway (connected coll yearsr if fatherdec==1) ///
	   (connected coll yearsr if fatherdec==0), ///
	   legend(order(1 "Eligible group" 2 "Non-eligible group"))
restore


// ****************************************************************************
// Part 2
// Replication of Carpenter & Dobkin (2011) from Mastering Metrics
// ****************************************************************************

clear all
use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear

// look up state name using fips code (make sure statastates.ado is installed)
statastates, fips(state) nogen

// #1

unique year
unique state
table year
table state

duplicates report state year
table agegr
table dtype
duplicates report state year agegr dtype
// the unique observations are by state, year, age group, and mortality rate type

// #2
keep if agegr==2
keep if dtype==2
duplicates report state year

// #3
tabstat legal, by(year)

// time series - state mean %legal to drink by year
// note the 26th amendment in 1971 (lowered voting age to 18) and the National
// Minimum Drinking Age Act in 1984
preserve
collapse (mean) legal , by(year)
twoway (connected legal year), xline(1971 1984)
restore

// #4
reg mrate legal i.state i.year if year < 1984, cluster(state)
reg mrate legal i.state i.year if year < 1984

// Could also use xtreg
_eststo q4:   xtreg mrate legal i.year if year < 1984, fe i(state)
_eststo q4cl: xtreg mrate legal i.year if year < 1984, fe i(state) cluster(state)

// #5
// Reload data to get back other causes of mortality and age groups
use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear
statastates, fips(state) nogen

// Regression DD Estimates of MLDA-Induced Deaths among 18-20 Year Olds, from 1970-1983
// death cause: 1=all, 2=MVA, 3=suicide, 6=internal

foreach i in 1 2 3 6 {
   _eststo q5type`i': xtreg mrate legal i.year if year < 1984 & agegr == 2 ///
		& dtype == `i', fe i(state) cluster(state)
   }

// #6
// Using age 20-24 instead
// NOTE: the variable "legal" refers to the specific age group. The variable
// "legal1820" contains the percent age 18-20 who can legally drink.

foreach i in 1 2 3 6 {
   _eststo q6age2024type`i': xtreg mrate legal1820 i.year if year < 1984 & ///
		agegr == 3 & dtype == `i', fe i(state) cluster(state)
   }

// #7
// add beertax covariate
_eststo q7cl: xtreg mrate legal beertax i.year if year < 1984 & agegr==2 & ///
	dtype==2, fe i(state) cluster(state)

// #8
// use population weights
// note: switching back to reg from xtreg due to weights
_eststo q8wt: reg mrate legal i.year i.state if year < 1984 & agegr==2 & ///
	dtype==2 [weight=pop], cluster(state)

// #9
// triple difference
// reload data and keep MVAs, age groups 2 (18-20) and 3 (21-24) only

// NOTE: the variable "legal" refers to the specific age group. The variable
// "legal1820" contains the percent age 18-20 who can legally drink.

use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear
keep if dtype==2 & (agegr==2 | agegr==3) & year<1984
duplicates report state year

reg mrate c.legal1820##ib3.agegr i.state##ib3.agegr i.year##ib3.agegr 

// understanding the list of coefficients (parameters estimated by the
// triple difference)
//    state intercept (20-24)
//    state intercept (18-20)--differential
//    yearly time trend (20-24)
//    yearly time trend (18-20)--differential
//    additional change associated with legal1820 (20-24)
//    additional change associated with legal1820 (18-20)--differential **the TD

// same using reghdfe--absorbs multiple fixed effects + interactions
reghdfe mrate c.legal1820##ib3.agegr, absorb(i.state##ib3.agegr i.year##ib3.agegr)


// #BONUS
// state-specific time trend
_eststo q9b: reg mrate legal i.state##c.year i.year if year < 1984 & agegr == 2 & dtype ==2, cluster(state)

// understanding the list of coefficients (parameters estimated by the 
// triple difference)
//    state intercept (18-20)
//    state specific linear time trend (18-20)
//    yearly time shift (18-20)
//    additional change associated with legal (18-20)

// same using reghdfe
reghdfe mrate legal i.year if year<1984 & agegr==2 & dtype==2, absorb(i.state##c.year) cluster(state)

esttab q4* q5* q6* q7* q8* q9b using results.csv, csv se(%5.3f) mtitles order(legal*) replace


// #10
// Event study
// Create a crude 0-1 version of legal for use in event study
// First reload data and keep MVAs, age group 2 (18-20), 1983 and before

use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear
statastates, fips(state) nogen
keep if (agegr==2 & dtype==2) & year<=1983

// Define legal2=1 if ANY adults age 18-20 can legally drink
gen legal2=(legal>0) if legal~=.

// identify when states switched from 0 to 1 (or 1 to 0)
sort state year
gen legalchange=(legal2~=legal2[_n-1] & state==state[_n-1])
gen temp1=year if legalchange==1
// identify first year of change and later (last) change (if any)--for this
// example I only want states that switched treatment status once
egen changeyear1=min(temp1),by(state)
egen changeyear2=max(temp1),by(state)
preserve
collapse (max) legal2 legalchange (first) changeyear1 changeyear2, by(state_name)
table legal2 legalchange
list, noobs
restore
// drop Illinois and Michigan for this example--they change treatment status twice
drop if state==17 | state==26
drop temp1 changeyear2
// create relative time to treatment (0 in first year of treatment)
gen timetoevent=year-changeyear1
table year timetoevent

// as a reference estimate TWFE model 
xtreg mrate legal2 i.year, fe i(state) cluster(state)

eventdd mrate i.year i.state, timevar(timetoevent)


// ****************************************************************************
// Part 3
// Additional analysis of MLDA data - focus on differential timing
// ****************************************************************************
// NOTE: continue using data from last part of Part 2--with legal2 and without
// Illinois and Michigan

// #1
// another nifty utility that labels values using another variable
net install labutil.pkg, from("http://fmwww.bc.edu/RePEc/bocode/l/")
labmask state, values(state_name)
table state

label dir
label list state

// #2
// which states vary over time in their legalized drinking below age 21?
tabstat legal, by(state) stat(n mean sd)
tabstat legal2, by(state) stat(n mean sd)

// #3
// time series graph of %legal for a few states
// note CT changes in 1972, 1973, 1982
xtset state year
xtline legal if inlist(state,1,2,4,9,10), overlay xlabel(1970(1)1983)
xtline legal2 if inlist(state,1,2,4,9,10), overlay xlabel(1970(1)1983)

// time series graph with panels (to see each individual state)
xtline legal2

// time series of outcome variable mrate
xtline mrate if inlist(state,1,2,4,9,10), overlay xlabel(1970(1)1983)

// #4
// generalized DD model, state and year effects (no controls)
reg mrate legal i.state i.year
reg mrate legal2 i.state i.year
// alternatively
xtreg mrate legal i.year, fe 
xtreg mrate legal2 i.year, fe

// #5
// illustration of ddtiming and bacondecomp (these do the same thing)
net describe ddtiming, from(https://tgoldring.com/code)
net install ddtiming
ssc install bacondecomp

// Bacon decomposition (note must be xtset, as was done above)
bacondecomp mrate legal2, ddetail

ddtiming mrate legal2, i(state) t(year)


// BONUS
// basic DD model, state and year effects (again)
// view predicted values by year for Connecticut
// plot predictions and actual (note CT lowered MLDA in 1972)
reg mrate legal2 i.state i.year
sort state year
margins i.state i.year if state_abb=="CT"
marginsplot, xdim(year) noci addplot(connected mrate year if state_abb=="CT")
