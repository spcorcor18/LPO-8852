
// Lecture 5 in-class exercise
// Last updated: September 30, 2021

cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 5 - diff in diff\In-class exercise"
* ssc install outreg2
* ssc install statastates

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
// First difference
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
reg mrate legal i.state i.year if year < 1984
reg mrate legal i.state i.year if year < 1984, cluster(state)

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
use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear
keep if dtype==2 & (agegr==2 | agegr==3) & year<1984
duplicates report state year

reg mrate c.legal1820##ib3.agegr i.state#i.agegr i.year##i.agegr 

// #BONUS
// state-specific time trend
_eststo q9b: reg mrate legal i.state##c.year i.year if year < 1984 & agegr == 2 & dtype ==2, cluster(state)

esttab q4* q5* q6* q7* q8* q9b using results.csv, csv se(%5.3f) mtitles order(legal*) replace

// #10
// Create a crude 0-1 version of legal for use in event study
use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear
statastates, fips(state) nogen
keep if (agegr==2 & dtype==2) & year<=1983
// Define legal2=1 if ANY adults age 18-20 can legally drink
gen legal2=(legal>0) if legal~=.
// identify when states switched from 0 to 1 (or 1 to 0)
sort state year
gen legalchange=(legal2~=legal2[_n-1] & state==state[_n-1])
gen temp1=year if legalchange==1
egen changeyear1=min(temp1),by(state)
egen changeyear2=max(temp1),by(state)
preserve
collapse (max) legal2 legalchange (first) changeyear1 changeyear2, by(state_name)
table legal2 legalchange
list, noobs
restore
// drop Illinois and Michigan--they change legal status twice
drop if state==17 | state==26
drop temp1 changeyear2
// create relative time to legal change
gen timetoevent=year-changeyear1

reg mrate legal2 i.year i.state
eventdd mrate i.year i.state, timevar(timetoevent)


***************************************************

