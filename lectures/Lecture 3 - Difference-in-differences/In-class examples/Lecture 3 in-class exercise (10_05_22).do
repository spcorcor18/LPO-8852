
// ****************************************************************************
// Lecture 3 in-class exercises
// Last updated: October 5, 2022
// ****************************************************************************

cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 3 - Difference-in-differences"
ssc install outreg2, replace
ssc install statastates, replace
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
// Replication of Carpenter & Dobkin (2011) from Mastering Metrics -- effect
// of lowering the mininum legal drinking age (MLDA) on fatalities from motor
// vehicle accidents
// ****************************************************************************

// Read annual mortality rates by state, year, age group, and mortality type

	clear all
	use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear

	// Utility to look up state name using fips code (requires user-written
	// ado file statastates)

	statastates, fips(state) nogen

	
// #1 
// Data structure - confirming observations are unique by state, year, age
// group, and mortality type

	unique year
	unique state
	table year
	table state

	duplicates report state year
	fre agegr
	fre dtype
	duplicates report state year agegr dtype

	
// #2
// Limit data to age 18-20 (agegr==2) and motor vehicle fatalities (dtype==2)

	keep if agegr==2
	keep if dtype==2
	duplicates report state year

	
// #3 
// Descriptive statistics on "legal" variable which represents the mean percent
// of adults age 18-20 in a state who can legally drink in a given year

	tabstat legal, by(year)

	// plot time series - state mean %legal to drink by year
	// note the 26th amendment in 1971 (lowered voting age to 18) and the National
	// Minimum Drinking Age Act in 1984

	preserve
	collapse (mean) legal , by(year)
	twoway (connected legal year), xline(1971 1984)
	restore

	
// #4 
// Two way fixed effects model--only for observations before the National
// MLDA Act was passed (1984). Show results with and without adjusting
// standard errors for clustering by state.

	reg mrate legal i.state i.year if year < 1984
	reg mrate legal i.state i.year if year < 1984, cluster(state)

	// Could also use xtreg

	_eststo q4:   xtreg mrate legal i.year if year < 1984, fe i(state)
	_eststo q4cl: xtreg mrate legal i.year if year < 1984, fe i(state) cluster(state)

	
// #5 
// Reload original data to get back other causes of mortality and age groups. 
// Estimate TWFE model for four categories of mortality, age 18-20, before 1984.
// Mortality causes: 1=all, 2=MVA, 3=suicide, 6=internal

	use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear
	statastates, fips(state) nogen

	foreach i in 1 2 3 6 {
	   _eststo q5type`i': xtreg mrate legal i.year if year < 1984 & agegr == 2 ///
			& dtype == `i', fe i(state) cluster(state)
	   }

	   
// #6 
// Estimate TWFE model using age 21-24 group (agegr==3) instead of 18-20.
// NOTE: the variable "legal" refers to the specific age group. The variable
// "legal1820" contains the percent age 18-20 who can legally drink. "legal"
// is always =1 for the age 21+ groups. Here we are looking for an effect of
// changes in the MLDA (age 18-20) on mortality among age 21-24--a placebo test

	foreach i in 1 2 3 6 {
	   _eststo q6age2024type`i': xtreg mrate legal1820 i.year if year < 1984 & ///
			agegr == 3 & dtype == `i', fe i(state) cluster(state)
	   }

	   
// #7
// Original TWFE model but add beertax covariate

	_eststo q7cl: xtreg mrate legal beertax i.year if year < 1984 & agegr==2 & ///
		dtype==2, fe i(state) cluster(state)

		
// #8 
// Original TWFE model but weight by state population (note: switching back
// to reg from xtreg due to use of weights)

	_eststo q8wt: reg mrate legal i.year i.state if year < 1984 & agegr==2 & ///
		dtype==2 [weight=pop], cluster(state)

		
// #9 
// Triple difference including another unaffected age group (21-24). First
// reload data and keep only MVAs (dtype==2) and age 18-20, 21-24 (agegr==3 or 4)

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
	//    addl change associated with legal1820 (20-24)
	//    addl change associated with legal1820 (18-20)--differential **the TD

	// same using reghdfe--absorbs multiple fixed effects + interactions

	reghdfe mrate c.legal1820##ib3.agegr, absorb(i.state##ib3.agegr i.year##ib3.agegr)


// #10 
// Original TWFE model but with state specific time trends

	_eststo q9b: reg mrate legal i.state##c.year i.year if year < 1984 & ///
		agegr == 2 & dtype ==2, cluster(state)

	// understanding the list of coefficients (parameters estimated by the 
	// triple difference)
	//    state intercept (18-20)
	//    state specific linear time trend (18-20)
	//    yearly time shift (18-20)
	//    additional change associated with legal (18-20)

	// same using reghdfe

	reghdfe mrate legal i.year if year<1984 & agegr==2 & dtype==2, ///
		absorb(i.state##c.year) cluster(state)

		
// Collect saved results for comparison

	esttab q4* q5* q6* q7* q8* q9b using results.csv, csv ///
		se(%5.3f) mtitles order(legal*) replace


// #11 
// Event study--for this example create a crude 0-1 version of "legal"--
// will be equal to 1 if anyone age 18-20 can legally drink within a state/year.
// First reload data and keep MVAs, age group 2 (18-20), 1983 and before

	use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear
	statastates, fips(state) nogen
	keep if (agegr==2 & dtype==2) & year<=1983

	// Define legal2=1 if ANY adults age 18-20 can legally drink
	gen legal2=(legal>0) if legal~=.
	label var legal2 "=1 if anyone under 21 can legally drink during year"
	
	// identify when states switched from 0 to 1 (or 1 to 0)
	sort state year
	gen legalchange=(legal2~=legal2[_n-1] & state==state[_n-1])
	gen temp1=year if legalchange==1
	
	// identify first year of change and later (last) change (if any)--for this
	// example I only want to keep states that switched treatment status once
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

	// as a point of reference estimate TWFE model using this modified sample
	// and binary definition of "legal"

	xtreg mrate legal2 i.year, fe i(state) cluster(state)

	// use eventdd to estimate event study model

	eventdd mrate i.year i.state, timevar(timetoevent)


// ****************************************************************************
// Part 3
// Additional analysis of MLDA data - focus on differential timing
// ****************************************************************************
// NOTE: continue using data from last part of Part 2--with legal2 and without
// Illinois and Michigan

// #1
// another nifty utility that labels values using another variable--here label
// the state variable with "state_name" for later graph labels

	net install labutil.pkg, from("http://fmwww.bc.edu/RePEc/bocode/l/")
	labmask state, values(state_name)
	table state

	label dir
	label list state


// #2
// Which states vary over time in their legalized drinking below age 21?

	tabstat legal, by(state) stat(n mean sd)
	tabstat legal2, by(state) stat(n mean sd)


// #3
// Sample time series graph of %legal for a few states
// note CT changes in 1972, 1973, 1982

	xtset state year
	xtline legal if inlist(state,1,2,4,9,10), overlay xlabel(1970(1)1983)
	xtline legal2 if inlist(state,1,2,4,9,10), overlay xlabel(1970(1)1983)

	// time series graph with panels (to see each individual state)
	xtline legal2

	// time series of outcome variable mrate
	xtline mrate if inlist(state,1,2,4,9,10), overlay xlabel(1970(1)1983)


// #4
// TWFE model (no controls) - sample is limited to age 18-20, MVA, pre-1984

	reg mrate legal i.state i.year, cluster(state)
	reg mrate legal2 i.state i.year, cluster(state)

	// alternatively xtreg
	xtreg mrate legal i.year, fe cluster(state)
	xtreg mrate legal2 i.year, fe cluster(state)


// #5
// Illustration of Bacon decomposition: ddtiming and bacondecomp (these two
// commands do the same thing)

	net describe ddtiming, from(https://tgoldring.com/code)
	net install ddtiming
	ssc install bacondecomp

	// Bacon decomposition (note must be xtset, as was done above)
	bacondecomp mrate legal2, ddetail

	// alternatively using ddtiming
	ddtiming mrate legal2, i(state) t(year)


// #X 
// Event study

	eventdd mrate i.year i.state, timevar(timetoevent)
	

// #X
// Robust DID estimators
// Continue to use data created in last part of section 2

	ssc install did_imputation
	ssc install did_multiplegt
	ssc install eventstudyinteract
	ssc install csdid
	ssc install drdid /* called for by csdid */
	ssc install event_plot
	net install github, from("https://haghish.github.io/github/") replace
	github install joshbleiberg/stackedev

// Callaway and Sant'Anna
// timinggroup is either 0 (never treated) or first year of treatment

	gen timinggroup=cond(changeyear1==.,0,changeyear1)
	csdid mrate, ivar(state) time(year) gvar(timinggroup) notyet
	estat event, estore(cs) // this produces and stores the estimates at the same time
	event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-5(1)12) ///
		title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together
	estat pretrend
	estat simple
	estat group

// Cengiz et al (2010) - stacked event study
// stackdev command needs dummies for lags and leads as would be manually
// included in an event study regression

	gen nevertreat=timinggroup==0
	forvalues j=1/6 {
	   gen pre`j' = (timetoevent==(-1)*`j')
	   }
	forvalues j=0/12 {
	   gen post`j' = (timetoevent==`j')
	   }
	stackedev mrate pre6 pre5 pre4 pre3 pre2 post0-post12, cohort(changeyear1) time(year) never_treat(nevertreat) ///
		unit_fe(state) clust_unit(state)

	
	
