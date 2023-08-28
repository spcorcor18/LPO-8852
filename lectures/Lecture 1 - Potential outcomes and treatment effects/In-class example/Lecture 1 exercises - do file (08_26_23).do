
// ***************************************************************
//
// Lecture 1 - Potential outcomes and treatment effects
// Stata Examples
// August 26, 2023
//
// ***************************************************************

// *********************************
// Example 1.1
// Based on Mixtape independence.do
// *********************************

	// Outcome: post-treatment lifespan in years
	// D=1 surgery intervention D=0 chemotherapy intervention

	// Input potential outcomes (y0, y1) for 10 cases
    clear
    drop _all
    set obs 10
    gen     y1 = 7 in 1
    replace y1 = 5 in 2
    replace y1 = 5 in 3
    replace y1 = 7 in 4
    replace y1 = 4 in 5
    replace y1 = 10 in 6
    replace y1 = 1 in 7
    replace y1 = 5 in 8
    replace y1 = 3 in 9
    replace y1 = 9 in 10

    gen     y0 = 1 in 1
    replace y0 = 6 in 2
    replace y0 = 1 in 3
    replace y0 = 8 in 4
    replace y0 = 2 in 5
    replace y0 = 1 in 6
    replace y0 = 10 in 7
    replace y0 = 6 in 8
    replace y0 = 7 in 9
    replace y0 = 8 in 10
	
	// Treatment status (d) for 10 cases
	gen     d = 1 in 1
	replace d = 0 in 2
	replace d = 1 in 3
	replace d = 0 in 4
	replace d = 1 in 5
	replace d = 1 in 6
	replace d = 0 in 7
	replace d = 0 in 8
	replace d = 0 in 9
	replace d = 1 in 10

	// Individual treatment effect
	gen te=y1 - y0
	
	// Observed y
	gen y=(d*y1) + (1-d)*y0

	// ATE
	summ te
	// ATT
	summ te if d==1
	// ATU 
	summ te if d==0

	// Simple difference in means--yields neither ATE, ATT, nor ATU
	ttest y, by(d)
	scalar sdo=r(mu_2)-r(mu_1)
	
	// Selection bias
	ttest y0, by(d)
	scalar bias=r(mu_2)-r(mu_1)
	
	// Heterogeneous treatment effects bias
	ttest te, by(d)
	scalar hteb=(1-0.5)*(r(mu_2) - r(mu_1))
	
	// Simple difference in means less selection bias and het treatment 
	// effect bias equals ATE
	display sdo - bias - hteb
	
	// Simple difference in means less selection bias equals ATT
	display sdo - bias

	
// *********************************
// Example 1.2
// Based on Mixtape independence.do
// *********************************

	// This program randomly assigns treatment status to the 10 cases and
	// calculates the simple difference in means. This is repeated 10,000
	// times to show the sample distribution of this estimator.
	
	clear all
	program define gap, rclass

		version 14.2
		syntax [, obs(integer 1) mu(real 0) sigma(real 1) ]
		clear
		drop _all
		// Input potential outcomes (y0, y1) for 10 cases
		set obs 10
		gen     y1 = 7 in 1
		replace y1 = 5 in 2
		replace y1 = 5 in 3
		replace y1 = 7 in 4
		replace y1 = 4 in 5
		replace y1 = 10 in 6
		replace y1 = 1 in 7
		replace y1 = 5 in 8
		replace y1 = 3 in 9
		replace y1 = 9 in 10

		gen     y0 = 1 in 1
		replace y0 = 6 in 2
		replace y0 = 1 in 3
		replace y0 = 8 in 4
		replace y0 = 2 in 5
		replace y0 = 1 in 6
		replace y0 = 10 in 7
		replace y0 = 6 in 8
		replace y0 = 7 in 9
		replace y0 = 8 in 10
		
		// Sort in random order and then assign "treated" to the first 5
		// and "untreated" to the second 5
		drawnorm random
		sort random

		gen     d=1 in 1/5
		replace d=0 in 6/10
		gen     y=d*y1 + (1-d)*y0
		egen sy1 = mean(y) if d==1
		egen sy0 = mean(y) if d==0          
		collapse (mean) sy1 sy0
		gen sdo = sy1 - sy0
		keep sdo
		summarize sdo
		gen mean = r(mean)
		end

	simulate mean, reps(10000): gap
	su _sim_1 
	
	// See the distribution of point estimates
	// The estimator is unbiased for ATE but there is a lot of variability
	// (re: lots of variability in individual TEs and small sample size)
	twoway (histogram _sim_1) (kdensity _sim_1)
	

// *******************************************
// Example 1.3
// Based on lecture notes (potential outcomes
// depend on X and selection into treatment)
// *******************************************
	
	clear
	set obs 10000
	// assume roughly 40% of cases are treated
	gen d = runiform() < 0.40
	
	// x is related to d
	gen x = 2 + 1.5*d + rnormal(0,1)

    // random error	
	gen u = rnormal(0,5)

	// potential outcomes depend on x
	//(constant treatment effect of 6)
	gen y0 = 15 + 5*x + u
	gen y1 = 15 + 5*x + 6 + u
	gen te = y1 - y0
	tabstat y1 y0 te, by(d)

	// ATE
	summ te
	// ATT
	summ te if d==1
	// ATU
	summ te if d==0
	
	// observed y
	gen y = (d*y1)+(1-d)*y0
	
	// simple difference in means
	ttest y, by(d)
	scalar sdo=r(mu_2) - r(mu_1)
	
	// Selection bias
	ttest y0, by(d)
	scalar bias=r(mu_2)-r(mu_1)
	
	// Heterogeneous treatment effects bias (none in this case)
	ttest te, by(d)
	scalar hteb=(1-0.5)*(r(mu_2) - r(mu_1))
	
	// Simple difference in means less selection bias equals ATT
	display sdo - bias

	// Try naive regression of observed y on d (OVB since potential outcomes
	// related to x, and d related to x)
	reg y d
	
	// Regression conditional on x
	reg y d x
	scalar bl=_b[x]
	
	// OVB in short regression is 5*1.5 (coefficient on omitted variable in
	// long regression times coefficient from auxiliary regression of omitted
	// on inclued)
	reg x d
	scalar pi=_b[d]
	display bl*pi


// *******************************************
// Example 1.4
// RCT of private school vouchers in NYC
// (Howell and Peterson, 2006)
// *******************************************

	// Read dataset from Github - 521 African-American students who participated
	// in the voucher lottery
	use https://github.com/spcorcor18/LPO-8852/raw/main/data/nyvoucher.dta, clear

	// t-test for difference in student achievement (composite reading and math
	// achievement expressed as a percentile in national distribution)
	ttest post_ach, by(voucher)
	
	// same using regression
	reg post_ach voucher
	scalar b=_b[voucher]
	
	// practical significance: how does estimated treatment effect compare to
	// underlying variability in achievement?
	summ post_ach
	display b/r(sd)
	
	// check for balance in baseline achievement
	ttest pre_ach, by(voucher)
	
	// compare the whole distribution of baseline achievement
	twoway (kdensity pre_ach if voucher==1) (kdensity pre_ach if voucher==0), ///
		legend(label(1 "Voucher") label(2 "No voucher"))
	
	// include baseline achievement in regression as a control
	reg post_ach voucher pre_ach
	
	