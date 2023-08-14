

// **************************************************************************
// Synthetic control example from The Mixtape
// Last update: December 8, 2022
// **************************************************************************

// Location to store temporary files
global temp "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 7 - Synthetic control methods\Mixtape example\temp"
cd "$temp"

set matsize 1000
ssc install synth, all 
ssc install mat2txt
// synth_runner:
net install st0500.pkg, from(http://www.stata-journal.com/software/sj17-4/)


// *****
// (1)
// *****
// **************************************************************************
// Use synth to obtain weights and construct a synthetic control.
// Outcome: black male prisoners (per capita)
// Treated state: Texas (state 48)
// Year of treatment: 1993
// **************************************************************************

use https://github.com/scunning1975/mixtape/raw/master/texas.dta, clear

// Note data has already been "tsset" with statefip as cross sectional-unit 
// and year as time period
tsset

// For synth command: choose variables (and time period[s]) used to find weights
// Options include the treated unit ID, treatment year (1993), names of cross-
// sectional units, pre-intervention time period for minimizing prediction
// error (1985-1993), results period for the optional figure and saved data,
// name of file for saved results, request for figure. 

#delimit; 
synth   bmprison  
            bmprison(1990) bmprison(1992) bmprison(1991) bmprison(1988)
            alcohol(1990) aidscapita(1990) aidscapita(1991) 
            income ur poverty black(1990) black(1991) black(1992) 
            perc1519(1990)
            ,       
        trunit(48) trperiod(1993) unitnames(state) 
        mspeperiod(1985(1)1993) resultsperiod(1985(1)2000)
        keep(synth_bmprate.dta) replace fig;

graph save Graph synth_tx.gph, replace;

// See the v matrix;
mat list e(V_matrix);
#delimit cr

	
	
// *****
// (2)
// *****
// **************************************************************************
// Take the saved results and plot gap Texas vs. synthetic Texas
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

#delimit ; 
twoway (line gap48 year,lp(solid)lw(vthin)lcolor(black)), yline(0, lpattern(shortdash) lcolor(black)) 
    xline(1993, lpattern(shortdash) lcolor(black)) xtitle("",si(medsmall)) xlabel(#10) 
    ytitle("Gap in black male prisoner prediction error", size(medsmall)) legend(off); 
    #delimit cr
graph save Graph synth_tx_gap.gph, replace

// save gap data for later
save synth_bmprate_48.dta, replace


// *****
// (3)
// *****
// **************************************************************************
// Placebo inference part 1: run synth for ALL states in the dataset with the
// same treatment year (1993), save the results
// **************************************************************************

#delimit; 
set more off; 
use https://github.com/scunning1975/mixtape/raw/master/texas.dta, clear;
local statelist  1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 20 21 22 23 24 25 
	26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 45 46 47 48 49 51 53 55; 

foreach i of local statelist {;
synth   bmprison  
        bmprison(1990) bmprison(1992) bmprison(1991) bmprison(1988) 
        alcohol(1990) aidscapita(1990) aidscapita(1991)  
        income ur poverty black(1990) black(1991) black(1992)  
        perc1519(1990) 
        ,        
            trunit(`i') trperiod(1993) unitnames(state)  
            mspeperiod(1985(1)1993) resultsperiod(1985(1)2000) 
            keep(synth_bmprate_`i'.dta) replace; 
            matrix state`i' = e(RMSPE); /* check the V matrix*/ 
};

# delimit cr

// Take results from each state, calculate gap, and resave data for later combining
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
        merge year using synth_gap_bmprate`i' 
        drop _merge 
        sort year 
    save placebo_bmprate.dta, replace 
    }
   
// NOTE: take a look at the placebo_bmprate.dta data to see what it contains
*browse

	
// *****
// (4)
// *****
// **************************************************************************
// Placebo inference part 2: plot placebos on the same graph
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
xtitle("",si(small)) xlabel(#10) ytitle("Gap in black male prisoners prediction error", size(small))
    legend(off);
#delimit cr
graph save Graph placebo_overlay.gph, replace


// *****
// (5)
// *****
// **************************************************************************
// Placebo inference part 3: estimate the pre- and post-RMSPE and calculate
// the ratio of the post to pre RMSPE. Show histogram of these ratios
// **************************************************************************
// NOTE: this section could have been done more efficiently. Not sure why it
// was coded this way.

#delimit; 
set more off; 
use https://github.com/scunning1975/mixtape/raw/master/texas.dta, clear;
local statelist  1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 20 21 22 23 24 25 26 27 28 29 30 31 32  
    33 34 35 36 37 38 39 40 41 42 45 46 47 48 49 51 53 55; 
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
* Show the post/pre RMSPE ratio for all states, generate the histogram.
    list rank p if state==48
	

	
// *****
// (6)
// *****
// **************************************************************************
// Use synth_runner package
// **************************************************************************

use https://github.com/scunning1975/mixtape/raw/master/texas.dta, clear

// synth_runner calls the synth package, so it uses many of the same options.
// The code below will obtain the treatment effects, placebo effects, and p-vals:

#delimit; 
synth_runner bmprison  
            bmprison(1990) bmprison(1992) bmprison(1991) bmprison(1988)
            alcohol(1990) aidscapita(1990) aidscapita(1991) 
            income ur poverty black(1990) black(1991) black(1992) 
            perc1519(1990)
            ,       
        trunit(48) trperiod(1993) unitnames(state) 
        gen_vars;

// get standard plots
effect_graphs, trlinediff(0)

// plot the gap for TX vs all of the placebos
single_treatment_graphs, trlinediff(0) do_color(gs12)

// plot pvalue by time period
pval_graphs

