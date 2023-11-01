

// **************************************************************************
// Synthetic control example from The Mixtape
// Last update: October 31, 2023
// **************************************************************************

// Location to store temporary files

	global temp "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 6 - Synthetic control methods\In-class exercise"
	cd "$temp"

	set more off
	set matsize 1000

// synth package and necessary mat2txt:
	*ssc install synth, all 
	*ssc install mat2txt
// synth_runner package:
	*net install st0500.pkg, from(http://www.stata-journal.com/software/sj17-4/)
// synth2:
	*ssc install synth2, all replace
	

// *****
// (1)
// *****
// **************************************************************************
// Use synth command to obtain weights and construct a synthetic control.
// Outcome: Black male prisoners (per 100,000 population)
// Treated state: Texas 
// Year of treatment: 1993
// **************************************************************************

// Read source data - panel data from 1985 to 2000

	use https://github.com/scunning1975/mixtape/raw/master/texas.dta, clear

// Note data has already been "xtset" with statefip as cross sectional-unit 
// and year as time period

	xtset

// Attach labels to state FIPS codes. Texas is state 48.

	labmask statefip, values(state)
	label list

// Note: the Mixtape chapter is unclear about which outcome variable should be
// used. bmprison is the total number of incarcerated black males. bmprate is
// the number of incarcerated per 100,000 population (bmprison/bmpop)*100000. 
// The code in the book chapter uses the count (bmprison) but the rate makes
// more sense. Cunningham recommends comparing the results when using rates
// vs. levels. (One notable differences is in the states given weights).

	list statefip state bmprison bmprate if statefip==48
	
// synth command syntax: 
//   bmprate = Black male incarceration rate per 100,000 
//   next 14 variables = pre-treatment outcomes and covariates
//   truint(48) = Texas (state 48) is the treated unit
//   trperiod(1993) = 1993 is the first treatment year
//   unitnames( ) = tells Stata which variable contains the unit names
//   mspeperiod( )= the pre-treatment period used to minimize the RMSPE
//	    NOTE: Cunningham's code used 1985(1)1993 for the pre-period--I 
//	    think it should be 1985(1)1992. This is the default entire pre-
//		period.
//   resultsperiod( ) = the time period used in the resulting figure
//   keep( ) = name of file for the saved results (used later, below)
//   fig = tells Stata to generate the figure

	synth bmprate bmprate(1988) bmprate(1990) bmprate(1991) ///
		bmprate(1992) alcohol(1990) aidscapita(1990) aidscapita(1991) ///
		income ur poverty black(1990) black(1991) black(1992) perc1519(1990), ///
		trunit(48) trperiod(1993) unitnames(state) /// 
		mspeperiod(1985(1)1992) resultsperiod(1985(1)2000) ///
		keep(synth_bmprate.dta) replace fig

	graph save Graph synth_tx.gph, replace
	graph export "TX-vs-synthetic.png", as(png) replace

// See the v matrix of coefficient weights

	ereturn list
	mat list e(V_matrix)
	

// *****
// (2)
// *****
// **************************************************************************
// Use synth_runner package to do placebo inference
// **************************************************************************
	
	use https://github.com/scunning1975/mixtape/raw/master/texas.dta, clear

// synth_runner calls the synth package, so it uses many of the same options.
// The code below will obtain the treatment effects, placebo effects, 
// and p-vals. Notice I dropped the 'fig' and 'resultsperiod' options. The
// saved results option is also omitted.

// gen_vars = saves the variables necessary to run effect_graphs and
//    single_treatment_graphs commands

	synth_runner bmprate bmprate(1988) bmprate(1990) bmprate(1991) ///
		bmprate(1992) alcohol(1990) aidscapita(1990) aidscapita(1991) ///
		income ur poverty black(1990) black(1991) black(1992) perc1519(1990), /// 
		trunit(48) trperiod(1993) unitnames(state)  /// 
		mspeperiod(1985(1)1992) gen_vars

// see saved statistics
		
	ereturn list
		
// get standard plot of means, as well as gap between TX and synthetic control

	effect_graphs, trlinediff(0) treated_name(Texas) sc_name(Synthetic Texas) ///
		tc_gname(synth_tx2) effect_gname(synth_tx2gap) ///
		tc_ytitle(Black male incarceration rate per 100,000) ///
		effect_ytitle(Gap in Black male incarceration rate)

	graph save synth_tx2 synth_tx2, replace
	graph save synth_tx2gap synth_tx2gap, replace
		
// plot the gap for TX vs all of the placebos

	single_treatment_graphs, trlinediff(0) do_color(gs12) treated_name(Texas) ///
		raw_gname(synth_tx3) effects_gname(synth_tx3gap)

	graph save synth_tx3 synth_tx3, replace
	graph save synth_tx3gap synth_tx3gap, replace
		
// plot pvalue by time period

	pval_graphs
	
	graph save pvals pvals, replace
	graph save pvals_std pvals_std, replace

	graph combine "synth_tx2.gph" "synth_tx2gap.gph" ///
		"synth_tx3.gph" "synth_tx3gap.gph" "pvals.gph" ///
		"pvals_std.gph" , cols(2) name(synth_runner, replace)
	graph export synth_runner.png, as(png) replace

	
// *****
// (3)
// *****
// **************************************************************************
// Use synth2 package to constuct a synthetic control and perform placebo
// tests. Works only with Stata 16+
// **************************************************************************
	
	use https://github.com/scunning1975/mixtape/raw/master/texas.dta, clear
	
	// Main synthetic control results (for comparison with part 1)
	
	synth2 bmprate bmprate(1988) bmprate(1991) bmprate(1992) ///
		alcohol(1990) aidscapita(1990) aidscapita(1991) income ur ///
		poverty black(1990) black(1991) black(1992) perc1519(1990), ///
		trunit(48) trperiod(1993) unitnames(state) mspeperiod(1985(1)1992) ///
		xperiod(1985(1)1992) resultsperiod(1985(1)2000) nested allopt ///
		savegraph(set1, replace)
		
	// "In-space" placebo test
		
	synth2 bmprate bmprate(1988) bmprate(1991) bmprate(1992) ///
		alcohol(1990) aidscapita(1990) aidscapita(1991) income ur ///
		poverty black(1990) black(1991) black(1992) perc1519(1990), ///
		trunit(48) trperiod(1993) unitnames(state) mspeperiod(1985(1)1992) ///
		xperiod(1985(1)1992) resultsperiod(1985(1)2000) nested allopt ///
		placebo(unit) savegraph(set2, replace)
		
	// "In-time" placebo test (setting the treatment year to a previous "fake"
	// treatment year = 1989). Note had to remove predictors that were 1989 or
	// later. Replaced some of these with earlier years.
	
	synth2 bmprate bmprate(1988) ///
		alcohol(1986) aidscapita(1986) aidscapita(1987) income ur ///
		poverty black(1988) black(1987) black(1986) perc1519(1986), ///
		trunit(48) trperiod(1993) unitnames(state) mspeperiod(1985(1)1992) ///
		xperiod(1985(1)1992) resultsperiod(1985(1)2000) nested allopt ///
		placebo(period(1989)) savegraph(set3, replace)

	// "Leave one out" (LOO) robustness test. 
	
	synth2 bmprate bmprate(1988) bmprate(1991) bmprate(1992) ///
		alcohol(1990) aidscapita(1990) aidscapita(1991) income ur ///
		poverty black(1990) black(1991) black(1992) perc1519(1990), ///
		trunit(48) trperiod(1993) unitnames(state) mspeperiod(1985(1)1992) ///
		xperiod(1985(1)1992) resultsperiod(1985(1)2000) nested allopt ///
		loo savegraph(set4, replace)
			
	
// *****
// (4)
// *****
// **************************************************************************
// Use saved results from part 1 to manually crete a figure showing the gap
// between Texas vs. synthetic Texas. Note synth_runner does this for you.
// This code preceded synth_runner.
// **************************************************************************

// NOTE: look at the results dataset first---contains both weights and the time
// series. Just keep the time series for this part.
		
	use synth_bmprate.dta, clear
	keep _Y_treated _Y_synthetic _time
	drop if _time==.
	rename _time year
	rename _Y_treated  treat
	rename _Y_synthetic counterfact
	gen gap48=treat-counterfact
	sort year

	twoway (line gap48 year,lp(solid)lw(vthin)lcolor(black)), ///
		yline(0, lpattern(shortdash) lcolor(black)) ///
		xline(1993, lpattern(shortdash) lcolor(black)) ///
		xtitle("",si(medsmall)) xlabel(#10) ///
		ytitle("Gap in Black male incarceration rate", size(medsmall)) ///
		legend(off)
	graph save Graph synth_tx_gap.gph, replace
	graph export "synth_tx4.png", as(png) replace

	// save gap data for later
	save synth_bmprate_48.dta, replace


// *****
// (5)
// *****
// **************************************************************************
// Placebo inference part 1. Run synth for ALL states in the datasets using
// the same treatment year (1993), save the results. Note the newer synth2
// command can automate this for you (requires Stata 16+) 
// **************************************************************************

	#delimit; 
	set more off; 
	use https://github.com/scunning1975/mixtape/raw/master/texas.dta, clear;
	
	local statelist  1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 20 21 22 23 24 25 
		26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 45 46 47 48 49 51 53 55; 

	foreach i of local statelist {;
	synth bmprate bmprate(1988) bmprate(1990) bmprate(1991) bmprate(1992) 
			alcohol(1990) aidscapita(1990) aidscapita(1991) income ur poverty
			black(1990) black(1991) black(1992) perc1519(1990),        
				trunit(`i') trperiod(1993) unitnames(state)  
				mspeperiod(1985(1)1992) resultsperiod(1985(1)2000) 
				keep(synth_bmprate_`i'.dta) replace; 
				matrix state`i' = e(RMSPE); /* capture the RMSPE*/ 
	};

	# delimit cr

	// Take results from each state, calculate gap, and resave data for
	// later combining
	foreach i of local statelist {
		use synth_bmprate_`i' ,clear
		keep _Y_treated _Y_synthetic _time
		drop if _time==.
		rename _time year
		rename _Y_treated  treat`i'
		rename _Y_synthetic counterfact`i'
		gen gap`i'=treat`i'-counterfact`i'
		sort year 
		save synth_gap_bmprate`i', replace
		}
		
	use synth_gap_bmprate48.dta, clear
	sort year
	save placebo_bmprate48.dta, replace

	// Combine results from other states with TX, save as combined "placebo_bmprate.dta"
	foreach i of local statelist {
			merge 1:1 year using synth_gap_bmprate`i' , nogen 
		}
	   save placebo_bmprate.dta, replace
	// NOTE: take a look at the placebo_bmprate.dta data to see what it contains
	*browse

	
// *****
// (6)
// *****
// **************************************************************************
// Placebo inference part 2: plot placebos on the same graph. 
// Note synth_runner will automate this for you. This is code that
// preceded synth_runner.
// **************************************************************************
		
	use placebo_bmprate.dta, replace

	* Picture of the full sample, including outlier RSMPE
	#delimit;   
	twoway 
	(line gap1 year ,lp(solid)lw(vthin)) 
	(line gap2 year ,lp(solid)lw(vthin)) 
	(line gap4 year ,lp(solid)lw(vthin)) 
	(line gap5 year ,lp(solid)lw(vthin))
	(line gap6 year ,lp(solid)lw(vthin)) 
	(line gap8 year ,lp(solid)lw(vthin)) 
	(line gap9 year ,lp(solid)lw(vthin)) 
	(line gap10 year ,lp(solid)lw(vthin)) 
	(line gap11 year ,lp(solid)lw(vthin)) 
	(line gap12 year ,lp(solid)lw(vthin)) 
	(line gap13 year ,lp(solid)lw(vthin)) 
	(line gap15 year ,lp(solid)lw(vthin)) 
	(line gap16 year ,lp(solid)lw(vthin)) 
	(line gap17 year ,lp(solid)lw(vthin))
	(line gap18 year ,lp(solid)lw(vthin)) 
	(line gap20 year ,lp(solid)lw(vthin)) 
	(line gap21 year ,lp(solid)lw(vthin)) 
	(line gap22 year ,lp(solid)lw(vthin)) 
	(line gap23 year ,lp(solid)lw(vthin)) 
	(line gap24 year ,lp(solid)lw(vthin)) 
	(line gap25 year ,lp(solid)lw(vthin)) 
	(line gap26 year ,lp(solid)lw(vthin))
	(line gap27 year ,lp(solid)lw(vthin))
	(line gap28 year ,lp(solid)lw(vthin)) 
	(line gap29 year ,lp(solid)lw(vthin)) 
	(line gap30 year ,lp(solid)lw(vthin)) 
	(line gap31 year ,lp(solid)lw(vthin)) 
	(line gap32 year ,lp(solid)lw(vthin)) 
	(line gap33 year ,lp(solid)lw(vthin)) 
	(line gap34 year ,lp(solid)lw(vthin))
	(line gap35 year ,lp(solid)lw(vthin))
	(line gap36 year ,lp(solid)lw(vthin))
	(line gap37 year ,lp(solid)lw(vthin)) 
	(line gap38 year ,lp(solid)lw(vthin)) 
	(line gap39 year ,lp(solid)lw(vthin))
	(line gap40 year ,lp(solid)lw(vthin)) 
	(line gap41 year ,lp(solid)lw(vthin)) 
	(line gap42 year ,lp(solid)lw(vthin)) 
	(line gap45 year ,lp(solid)lw(vthin)) 
	(line gap46 year ,lp(solid)lw(vthin)) 
	(line gap47 year ,lp(solid)lw(vthin))
	(line gap49 year ,lp(solid)lw(vthin)) 
	(line gap51 year ,lp(solid)lw(vthin)) 
	(line gap53 year ,lp(solid)lw(vthin)) 
	(line gap55 year ,lp(solid)lw(vthin)) 
	(line gap48 year ,lp(solid)lw(thick)lcolor(black)), /*treatment unit, Texas*/
	yline(0, lpattern(shortdash) lcolor(black)) xline(1993, lpattern(shortdash) lcolor(black))
	xtitle("",si(small)) xlabel(#10) ytitle("Gap in Black male incarceration rate", size(small))
		legend(off);
	#delimit cr
	graph save Graph placebo_overlay.gph, replace
	graph export "TX-vs-placebos.png", as(png) replace

	
// *****
// (7)
// *****
// **************************************************************************
// Placebo inference part 3. Estimate the pre- and post-RMSPE and calculate
// the ratio of the post to pre RMSPE. Show histogram of these ratios. Note
// synth_runner and synth2 will automate this. No need to do this manually.
// **************************************************************************
// NOTE: this section could have been done more efficiently. Not sure why it
// was coded this way.

	#delimit; 
	set more off; 
	use https://github.com/scunning1975/mixtape/raw/master/texas.dta, clear;
	
	local statelist  1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 20 21 22 23 24
		25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 45 46 47 48
		49 51 53 55; 
	# delimit cr

	#delimit cr
	foreach i of local statelist {
	matrix rownames state`i'=`i'
	matlist state`i', names(rows)
	}

	// NOTE: I don't know why Cunningham does it this way below. Could also calc
	// RMSPE in the placebo_bmprate.dta file

	foreach i of local statelist {
		use synth_gap_bmprate`i', clear
		gen gap3=gap`i'*gap`i'
		egen postmean=mean(gap3) if year>1993
		egen premean=mean(gap3) if year<=1993
		gen rmspe=sqrt(premean) if year<=1993
		replace rmspe=sqrt(postmean) if year>1993
		gen ratio=rmspe/rmspe[_n-1] if 1994
		gen rmspe_post=sqrt(postmean) if year>1993
		gen rmspe_pre=rmspe[_n-1] if 1994
		mkmat rmspe_pre rmspe_post ratio if 1994, matrix (state`i')
		}
		
	* show post/pre-expansion RMSPE ratio for all states, generate histogram
		foreach i of local statelist {
			matrix rownames state`i'=`i'
			matlist state`i', names(rows)
										}
	#delimit ;
	mat state=state1\state2\state4\state5\state6\state8\state9\state10\state11\state12\state13\state15\state16\state17\state18\state20\state21\state22\state23\state24\state25\state26\state27\state28\state29\state30\state31\state32\state33\state34\state35\state36\state37\state38\state39\state40\state41\state42\state45\state46\state47\state48\state49\state51\state53\state55; 
	#delimit cr

		mat2txt, matrix(state) saving(rmspe_bmprate.txt) replace
		insheet using rmspe_bmprate.txt, clear
		ren v1 state
		drop v5
		gsort -ratio
		gen rank=_n
		gen p=rank/46
		export excel using rmspe_bmprate, firstrow(variables) replace
		import excel rmspe_bmprate.xls, sheet("Sheet1") firstrow clear
		
		histogram ratio, bin(20) frequency fcolor(gs13) lcolor(black) ylabel(0(2)6) ///
		xtitle(Post/pre RMSPE ratio) xlabel(0(1)5)
		graph save Graph rmspe_histogram.gph, replace
		graph export rmspe_histogram.png, as(png) replace
		* Show the post/pre RMSPE ratio for all states, generate the histogram.
		list rank p if state==48
	

// *****
// (8)
// *****
// **************************************************************************
// Clean up files
// **************************************************************************

forvalues j=1/55 {
   capture erase synth_bmprate_`j'.dta
   capture erase synth_gap_bmprate`j'.dta
   }
   
capture erase synth_tx.gph
capture erase synth_bmprate.dta
capture erase synth_tx_gap.gph
capture erase synth_bmprate_48.dta
capture erase placebo_overlay.gph
capture erase placebo_bmprate.dta
capture erase placebo_bmprate48.dta
capture erase rmspe_bmprate.txt
capture erase rmspe_bmprate.xls
capture erase rmspe_histogram.gph

foreach j in tx2 tx2gap tx3 tx3gap {
   capture erase synth_`j'.gph
   }
capture erase pvals_std.gph
capture erase pvals.gph   
   