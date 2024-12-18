

// ****************************************************************************
// Lecture 4 in-class exercises (part 1)
// Last updated: September 26, 2024
// ****************************************************************************

	cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 4 - Difference-in-differences"

	ssc install statastates, replace

// ****************************************************************************
// Q1
// Replication of Dynarski (2003) from Murnane & Willett chapter 8
// ****************************************************************************

	set more off
	clear all
	use https://github.com/spcorcor18/LPO-8852/raw/main/data/dynarski.dta, clear
	desc
	
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
		   legend(order(1 "Eligible group" 2 "Non-eligible group")) ///
		   xline(81.5)
	restore


// ****************************************************************************
// Q2
// Replication of Carpenter & Dobkin (2011) from Mastering Metrics -- effect
// of lowering the mininum legal drinking age (MLDA) on fatalities from motor
// vehicle accidents
// ****************************************************************************

// Read annual mortality rates by state, year, age group, and mortality type

	clear all
	use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear
	describe
	
	// Utility to look up state name using fips code (requires user-written
	// ado file statastates, installed above)

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

	tabstat legal, by(year) stat(mean min max n) col(stat)

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
// Original TWFE model but add beertax covariate

	_eststo q5cl: xtreg mrate legal beertax i.year if year < 1984, ///
		fe i(state) cluster(state)

		
// #6 
// Original TWFE model but weight by state population (note: switching back
// to reg from xtreg due to use of weights, which would have to be constant
// within state to use)

	_eststo q6wt: reg mrate legal i.year i.state if year < 1984, ///
		[weight=pop], cluster(state)


// #7
// Reload original data to get back other causes of mortality and age groups. 
// Estimate TWFE model for four categories of mortality, age 18-20, before 1984.
// Mortality causes: 1=all, 2=MVA, 3=suicide, 6=internal

	use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear
	statastates, fips(state) nogen

	foreach i in 1 2 3 6 {
	   _eststo q5type`i': xtreg mrate legal i.year if year < 1984 & agegr == 2 ///
			& dtype == `i', fe i(state) cluster(state)
	   }

  
// #8 
// Estimate TWFE model using age 21-24 group (agegr==3) instead of 18-20.
// NOTE: the variable "legal" refers to the specific age group. The variable
// "legal1820" contains the percent age 18-20 who can legally drink in that 
// state and year. "legal" is always =1 for the age 21+ groups. Here we are 
// looking for an effect of changes in the MLDA (age 18-20) on mortality
// among age 21-24--a placebo test

	foreach i in 1 2 3 6 {
	   _eststo q6age2024type`i': xtreg mrate legal1820 i.year if year < 1984 & ///
			agegr == 3 & dtype == `i', fe i(state) cluster(state)
	   }

	
// #9
// Original TWFE model but with state specific time trends

	_eststo q9b: reg mrate legal i.state##c.year i.year if year < 1984 & ///
		agegr == 2 & dtype ==2, cluster(state)

	// understanding the list of coefficients (parameters estimated by the 
	// triple difference)
	//    state intercepts (age 18-20)
	//    state specific linear time trend (age 18-20)
	//    yearly intercept shift common to all states (age 18-20)
	//    additional change associated with legal (age 18-20)

	// same using reghdfe

	reghdfe mrate legal i.year if year<1984 & agegr==2 & dtype==2, ///
		absorb(i.state##c.year) cluster(state)
		

// #10
// Triple difference including another unaffected age group (21-24). First
// reload data and keep only MVAs (dtype==2) and age 18-20, 21-24 (agegr==3 or 4)

	use https://github.com/spcorcor18/LPO-8852/raw/main/data/deaths.dta, clear
	keep if dtype==2 & (agegr==2 | agegr==3) & year<1984
	duplicates report state year
	
	reg mrate c.legal1820##ib3.agegr i.state##ib3.agegr i.year##ib3.agegr 
	
	// understanding the list of coefficients (parameters estimated by the
	// triple difference)
	//    state intercepts (pertain to age 20-24)
	//    state intercepts * age18-20 (differential vs. age 20-24)
	//    yearly time trend (pertain to age 20-24)
	//    yearly time trend * age18-20 (differential vs. age 20-24)
	//    legal1820 (additional change associated with legal18-20, pertains to age 20-24)
	//    legal1820 * age18-20 (differential vs. age 20-24) **the TD

	// same using reghdfe--absorbs multiple fixed effects + interactions

	reghdfe mrate c.legal1820##ib3.agegr, absorb(i.state##ib3.agegr i.year##ib3.agegr)
