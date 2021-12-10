
// Lecture 11 in-class exercise (RD)
// Last updated: November 12, 2019


// Question 1 - simulated data (adapted from Ballou)

clear
set seed 1234
drawnorm x w e u, n(1000)

// Relationship between outcome and running variable
gen y = 3 + 3*x + .5*x^2 + w + u 

// View a graph of y versus x (assuming w=u=0)
graph twoway function y=3+(3*x)+(0.5*x^2), range(-4 4) xline(1)

// Treatment assignment and treatment effect
gen t = (x > 1)
replace y = y + .5*t
summ y x t w u

// scatter
scatter y x, name(scat, replace) xline(1, lpattern(dash))
binscatter y x, name(binscat, replace) xline(1, lpattern(dash))
scatter t x , xline(1, lpattern(dash))
graph combine scat binscat, rows(1) xsize(6) ysize(3)
graph export "scatters.png", as(png) replace

// here is what the functional relationship looks like between y and x 
// without any randomness (conditional on w and u = 0). The jump is small.
graph twoway (function y= 3+ 3*x + 0.5*x^2, range(-4 1)) ///
			 (function y= 3.5 + 3*x + 0.5*x^2, range(1 4))

// Estimate RD model assuming linear relationship between y and x
reg y t x 

// Estimate RD model using a quadratic
reg y t c.x##c.x

// Non-parameteric estimates using RD
rd y x, z0(1) strineq bwidth(.4)
rd y x, z0(1) strineq bwidth(.4) graph 
rd y x, z0(1) strineq bwidth(.4) graph noscatter

// Check for manipulation - using visual inspection, and McCrary test

histogram x, kdens name(hist, replace)  xline(1, lpattern(dash))
DCdensity x, breakpoint(1) gen(Xj Yj r0 fhat se_fhat) graphname(mccrary.png)
graph combine hist mccrary.gph, rows(1) xsize(6) ysize(3)
graph export "hists.png", as(png) replace


// Introduce some manipulation in x and re-run McCrary test

gen manipulated=(x>0.65 & x<1 & e>0)
replace x = x + .4 if manipulated==1
// For half of the observations in the interval (.65, 1), we increase x by .4,
// which is enough to get them into the eligible group 

capture drop Xj Yj r0 fhat se_fhat
DCdensity x, breakpoint(1) gen(Xj Yj r0 fhat se_fhat) graphname(mccrary2.png)

// Estimate RD model using a quadratic (note manipulation is present)
// For those bumped into the treatment via manipulation, give them the treatment
// effect.
replace y = y+0.5 if manipulated==1
reg y t c.x##c.x

// Non-parameteric estimates using RD (note manipulation is present)
rd y x, z0(1) strineq bwidth(.4)


//*****************************************************************************
//*****************************************************************************
// Question 2 - simulated data (adapted from Carruthers 2012)

* Example: grade 3 students are automatically recommended to gifted & talented
* programs if their end-of-grade test exceeds a certain threshold (X=56). This code
* simulates data for 10,000 hypothetical grade 3 students and shows how we could
* use regression discontinuity to test whether GT placement increases grade 4
* test scores.

// Step 0: build out sample of 10,000 students with unique identifiers.
clear
set seed 195423
set obs 10000
gen id=_n

// Step 1: draw measures of true ability from the normal distribution (mean=50,
// sd=4) and grade 3 test scores. Let test scores be in 0.25-point increments.
gen trueability=50+4*rnormal()
gen grade3test=trueability+rnormal()
replace grade3test=round(grade3test, 0.25)

// Step 2: identify students scoring above the threshold of 56 and create a gap 
// variable measuring the distance between test scores and the threshold.
gen above56=(grade3test>=56)
gen gap=grade3test-56

// Step 3: assuming perfect compliance create a treatment indicator
gen inGT=(above56==1)
sum inGT
reg inGT gap above56

// Step 4: create the outcome variable (grade 4 test scores) such that GT
// placement is effective in increasing achievement. Assume baseline growth (in
// the absence of treatment) is 5 points over grade3-normed true ability. The
// treatment effect of GT placement is 3 additional scale points, on average.
gen grade4test = round(trueability + 5 + rnormal() + (3*inGT), 0.25)

// Step 5: linear RD model
reg grade4test gap inGT
reg grade4test c.gap##i.inGT

// Step 6: drop the GTplacement variable and create it again assuming a "fuzzy"
// GT placement that increases smoothly with the grade 3 test score but then
// increases discontinuously (by ~70 percentage points) at the cut score. This
// might arise if GT assignment is dependent on the grade 3 test score as well
// as other factors (e.g., parental input, teacher recommendation).

drop inGT grade4test
gen inGT=round(-.77+.007*grade3test+0.7*above56+runiform())
tabstat inGT, by(above56)
tab inGT /*should be 0 or 1*/
gen grade4test = round(trueability + 5 + rnormal() + (3*inGT), 0.25)

// Step 7: estimate a regression for G&T placement. Note with a discrete 
// running variable it is usually advisable to allow for clustered errors
reg inGT gap above56, cluster(grade3test)
reg inGT c.gap##i.above56, cluster(grade3test)
predict hat_trt

// Step 8: estimate the sharp RD model even though we know assignment is fuzzy
reg grade4test c.gap##i.above56, cluster(grade3test)

// non-parametric version - local linear regression with an optimal
// bandwidth (Imbens and Kalyanaraman, 2009) and triangle kernel weights
rd grade4test grade3test, z0(56) graph noscatter

// Step 9: estimate the fuzzy RD model to account for non-compliance
rd grade4test inGT grade3test, z0(56) graph noscatter

// NOTES:
// numer - almost identical to the sharp RD estimate from (8) - reduced form
// denom - almost identical to the "above56" effect from (7) - first stage
// lwald - numer / denom

// Step 10: preview of IV

gen gapabove = gap*above56
gen gapbelow = gap*(1-above56)
ivregress 2sls grade4test (inGT=above56) gapbelow gapabove , first robust cluster(grade3test)


// Extra: graphs in case where grade3test not centered at 56
capture drop yhat1

reg grade4test c.grade3test##i.inGT
predict yhat1, xb
matrix temp1=e(b)
local pi0 = temp1[1,6]
local pi1 = temp1[1,1]
local pi2 = temp1[1,3]
local pi3 = temp1[1,5]
// rounded for graph labels
local pi0r = round(`pi0',0.01)
local pi1r = 0.939 /* having some formatting issues so directly plugged this in */
local pi2r = round(`pi2',0.01)
local pi3r = round(`pi3',0.01)
// when x=0 inGT=1
local hat1 = `pi0' + `pi2'
local hat1r= round(`hat1',0.01)
// when x=56 inGT=0
local hat2 = `pi0' + `pi1'*56
local hat2r= round(`hat2',0.01)
// when x=56 inGT=1
local hat3 = `pi0' + `pi1'*56 + `pi2' + (`pi3'*56)
local hat3r= round(`hat3',0.01)

// added text details
local tsize "small"
local t0=`pi0'-1.5
local t1=`hat1'+1.5
local t2=`hat2'-1.5
local t3=`hat3'+1.5

twoway (lfit yhat1 grade3test if grade3test<56, range(0 56)) ///
	   (lfit yhat1 grade3test if grade3test>=56, range(56 80)), ///
   legend(off) xline(56, lpattern(dash)) ///
   yline(`pi0', lpattern(dash) lcolor(gs12)) text(`t0' 10 "{&pi}{sub:0} = `pi0r'", placement(right) size(`tsize')) ///
   yline(`hat1', lpattern(dash) lcolor(gs12)) text(`t1' 10 "{&pi}{sub:0} + {&pi}{sub:2} = `pi0r' + `pi2r' = `hat1r'", placement(right) size(`tsize')) ///   
   yline(`hat2', lpattern(dash) lcolor(gs12)) text(`t2' -0.3 "{&pi}{sub:0} + {&pi}{sub:1}*56 = `pi0r' + `pi1r'*56 = `hat2r'", placement(right) size(`tsize')) ///
   yline(`hat3', lpattern(dash) lcolor(gs12)) text(`t3' -0.3 "{&pi}{sub:0} + {&pi}{sub:1}*56 + {&pi}{sub:2} + {&pi}{sub:3}*56 = `pi0r' + `pi1r'*56 + `pi2r' + `pi3r'*56 = `hat3r'", placement(right) size(`tsize')) ///   
   ylabel(0(10)80) xlabel(0(10)80) text(80 58 "56", size(large))


