
// Lecture 8 in-class examples
// Regression discontinuity

// Last updated: 11/11/23

cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 8 - Regression discontinuity\In-class example"

// installs rdplot, rdrobust, rdbwselect
ssc install rdrobust, replace

// installs rddensity
ssc install rddensity, replace
	
// installs older rd command
ssc install rd, replace	
	

// *******
// (1) 
// *******
// **************************************************************************
// Mastering Metrics chapter 4 RD example based on Carptenter &
// Dobkin (2009) 
// **************************************************************************

// Read source data 

	clear
	estimates drop _all
	use https://github.com/spcorcor18/LPO-8852/raw/main/data/AEJfigs.dta

// (a) recenter running variable at 21 and define treatment assignment variable

	gen age = agecell - 21
	gen over21 = agecell >= 21

// (b) scatter and RD plots for all-causes mortality

	scatter all age, xline(0) name(graph1, replace)
	graph export graph1.png, name(graph1) as(png) replace

	// RD plot - binmethod qsmv, 4th order polynomial (default)
	rdplot all agecell, c(21) binmethod(qsmv) graph_options(legend(position(6)) name(graph2, replace))
	// RD plot - binmethod qsmv, 4th order polynomial (default)
	rdplot all agecell, c(21) binmethod(esmv) graph_options(legend(position(6)) name(graph3, replace))
	// RD plot - binmethod qsmv, 2nd order polynomial (default)
	rdplot all agecell, c(21) p(2) binmethod(qsmv) graph_options(legend(position(6)) name(graph4, replace))
	// RD plot - binmethod qsmv, 1st order polynomial (default)
	rdplot all agecell, c(21) p(1) binmethod(qsmv) graph_options(legend(position(6)) name(graph5, replace))
	
	graph combine graph2 graph3 graph4 graph5, rows(2) xsize(8) ysize(6.5) title(RD plots)
	graph export rdplots.png, as(png) replace
	
// (c) OLS regressions - linear and quadratic fits
	
	// linear model in age with intercept shift at over21
	reg all age over21
	predict allfitlin
	
	// linear model in age with intercept shift at over21, different slope
	// below and above c
	reg all c.age##i.over21
	predict allfitlini

	label variable all       "Mortality rate from all causes (per 100,000)"
	label variable allfitlin "Mortality rate from all causes (per 100,000)"

	// Figure 4.2 in Mastering Metrics (uses agecell on x-axis, not age)
	twoway (scatter all agecell) ///
		(line allfitlin agecell if age<0, lcolor(black) lwidth(medthick)) ///
		(line allfitlin agecell if age>=0, lcolor(black red) lwidth(medthick medthick)), ///
		legend(off) yline(91.84137, lpattern(dash)) yline(99.504079, lpattern(dash)) ///
		text(92.5 21 "91.84") text(100 21 "99.50") name(fit1, replace)

	// Figure 4.2 using linear model with different slopes below/above c
	twoway (scatter all agecell) ///
		(line allfitlini agecell if age<0, lcolor(black) lwidth(medthick)) ///
		(line allfitlini agecell if age>= 0, lcolor(black red) lwidth(medthick medthick)), ///
		legend(off) name(fit2, replace)

	// quadratic model in age with intercept shift at over21
	reg all c.age##c.age over21
	predict allfitq
	
	// quadratic model in age with intercept shift at over21, different slopes
	// below and above c
	reg all c.age##c.age##i.over21
	predict allfitqi

	label variable allfitq  "Mortality rate from all causes (per 100,000)"
	label variable allfitqi "Mortality rate from all causes (per 100,000)"

	// Figure overlaying scatter with linear and quadratic fits		 
	twoway (scatter all agecell) ///
		(line allfitlini allfitqi agecell if age<0, lcolor(red black) ///
		lwidth(medthick medthick) lpattern(dash)) ///
		(line allfitlini allfitqi agecell if age>=0, lcolor(red black) ///
		lwidth(medthick medthick) lpattern(dash)), legend(off) name(fit3, replace)

	graph combine fit1 fit2 fit3, rows(2) xsize(8) ysize(6.5) title(Scatter plots with fitted lines)
	graph export fitted.png, as(png) replace
		
// (d) Repeat for motor vehicle accidents, internal causes

	// linear model same slope on both sides (MVA)
	reg mva age over21
	predict exfitlin
	
	// quadratic model, different slopes on each side (MVA)
	reg mva c.age##c.age##i.over21
	predict exfitqi

	// linear model same slope on both sides (internal)
	reg internal age over21
	predict infitlin
	
	// quadratic model, different sloeps on each side (internal)
	reg internal c.age##c.age##i.over21
	predict infitqi

	label variable mva  "Mortality rate (per 100,000)"
	label variable infitqi  "Mortality rate (per 100,000)"
	label variable exfitqi  "Mortality rate (per 100,000)"

	// Figure 4.5 in Mastering Metrics
	twoway (scatter mva internal agecell) ///
		(line exfitqi infitqi agecell if agecell < 21) ///
        (line exfitqi infitqi agecell if agecell >= 21), ///
		legend(off) text(28 20.1 "Motor Vehicle Fatalities") ///
		text(17 22 "Deaths from Internal Causes") name(placebo, replace)
		
	graph export placebo.png, as(png) replace 

// (e) Try linear and quadratic fits using rdrobust, uniform kernel
//     and use a bandwith of 2 for comparability with (c).

	rdrobust all age, c(0) h(2) kernel(uniform) p(1)
	rdrobust all age, c(0) h(2) kernel(uniform) p(2)
	
// (f) Use rdbwselect to find optimal bandwidths for the linear and
//     quadratic fits, triangular or uniform kernel

	rdbwselect all age, c(0) bwselect(mserd) kernel(triangular) p(1)
	rdbwselect all age, c(0) bwselect(mserd) kernel(triangular) p(2)

	rdbwselect all age, c(0) bwselect(mserd) kernel(uniform) p(1)
	rdbwselect all age, c(0) bwselect(mserd) kernel(uniform) p(2)
	
//     Pass through the optimal bandwidth to rdrobust and rdplot
//     (just using the quadratic, triangular case)

	rdrobust all age, c(0) bwselect(mserd) kernel(triangular) p(2)
    
	// capture the optimal bw used
	// NOTE: this doesn't work in this example--too few observations.
	// Code here is for reference only
	local bandwidth = e(h_l)
	rdplot all age if abs(age) <= `bandwidth', p(2) h(`bandwidth') kernel(triangular)
	
	rdrobust all age, c(0) bwselect(mserd) kernel(triangular) p(2) all
	
	// manipulation test -- awkward in this case since variable is age
	// and treatment is defined as age>=21. Also, data are already
	// binned. Wouldn't expect to see anything here.
	rddensity age, plot
	

// *******
// (2) 
// *******
// **************************************************************************
// Simulated data (based on a Dale Ballou example)
// **************************************************************************

// (a) create simulated data

	clear
	set seed 1234
	drawnorm x w e u, n(1000)
	gen y = 3 + 3*x + .5*x^2 + w + u
	gen t = (x >= 1)
	replace y = y + 0.5*t
	
	// View a graph of known functional form (assuming w=u=0)
	graph twoway function y=3+(3*x)+(0.5*x^2), range(-4 4) xline(1)
	
	// centered version of x--use this below
	gen xc = x-1
	
// (b) scatterplot of y vs x - hard to see any evidence of a break. Try
//     binscatter and rdplot. For the latter use default polynomial order 4 
//     4 and a quadratic. The known discontinuity is most evidence when using
//     the quadratic (makes sense, since we know the original DGP is quadratic
//     in x)

	scatter y xc, xline(0) name(scat, replace) 
	binscatter y xc, xline(0) name(binscat, replace) 
	rdplot y xc, c(0) graph_options(legend(position(6)) name(rdp1,replace))
	rdplot y xc, c(0) p(2)  graph_options(legend(position(6)) name(rdp2,replace))	
	
	graph combine scat binscat rdp1 rdp2, rows(2) xsize(8) ysize(6)
	graph export "scatters.png", as(png) replace
	
// (c) linear and quadratic models via OLS (ignore the standard errors)
//     Use the full range of data (global, parametric approach) and no kernel.
//     Try same slopes on either side, and then different.

	reg y xc t 
	reg y xc t c.xc#c.xc
	
	reg y c.xc##i.t
	reg y c.xc##c.xc##i.t
	
// (d) now use rdrobust and optimal bandwidth selection

	rdrobust y xc, c(0) p(1) bwselect(mserd) kernel(triangular)
	local bandwidth = e(h_l)
	display `bandwidth'
	
	// pass through bandwidth to get local RD plot

	rdplot y xc if abs(xc) <= `bandwidth', c(0) p(1) h(`bandwidth') ///	
		kernel(triangular) graph_options(legend(position(6)) name(ballou, replace))
	graph export ballou.png, as(png) replace
		
	// example using older rd command with ad hoc bandwidth of 0.4
	
	rd y xc, z0(0) bwidth(0.4) graph
	rd y xc, z0(0) bwidth(0.4) graph noscatter
	
// (e) manipulation test

	// first some histograms
	histogram xc, fcolor(bluishgray%70) lcolor(bluishgray%70) ///
		xline(0, lwidth(medium) lcolor(cranberry)) name(hist1, replace)
	histogram xc if abs(xc)<=0.413, fcolor(bluishgray%70) lcolor(bluishgray%70) ///
		xline(0, lwidth(medium) lcolor(cranberry)) name(hist2, replace)

	// now rddensity
	rddensity xc, c(0) plot graph_opt(name(denstest,replace) legend(off))
	
	graph combine hist1 hist2 denstest, rows(2) xsize(8) ysize(6)
	graph export maniptest.png, as(png) replace
	
// (f) simulate manipulation

	// for half of the observations in this interval (e>0) from
	// 0.65 to 1 we increase x enough to get them into the eligible group
	gen xm = x
	replace xm = xm + .4 if xm < 1 & xm > .65 & e > 0 
	
	// newly centered variable
	gen xmc = xm-1
	
	// try rddensity again
	rddensity xmc, c(0) plot graph_opt(name(denstest2,replace) legend(off))
	graph export maniptest2.png, as(png) replace
	
// (g) try rdrobust in the presence of manipulation. For this step it is 
//  worth thinking about how y should be changed, if at all. If we assume 
//  that cases manipulated into the treatment group get the same effect from
//  being exposed to the treatment, then we can add the 0.5 to these cases
// (as below). One could also leave the original y intact, but this would 
// be assuming no treatment effect for these manipulated cases.

	gen y2=y
	replace y2=y+0.5 if (x<1 & x>0.65 & e>0)

	rdrobust y2 xmc, c(0) p(1) bwselect(mserd) kernel(triangular)	
	
	
// *******
// (3) 
// *******
// **************************************************************************
// Simulated data (based on a Celeste Carruthers example) - for estimating
// the effect of participation in a G&T program
// **************************************************************************

//	(a) 10,000 observations with "true ability" N(50,4) and grade 3 test
//	    score which is a noisy measure of true ability. Rounded to nearest
//		0.25 to create a more realistic "scale score"

	clear
	set seed 195423
	set obs 10000
	gen id=_n
	gen trueability = 50 + 4*rnormal()
	gen grade3test  = trueability + rnormal()
	replace grade3test = round(grade3test, 0.25)
	
//	(b) students at or above 56 are eligible for G&T. Create a "gap" variable
//	    centered at 56

	gen above56 = (grade3test>=56)
	gen gap = grade3test-56	
	
//	(c) assuming perfect compliance, everyone above 56 is treated (inGT) and
//	    everyone below is not

	gen inGT = above56
	
	// what proportion are treated?
	summ inGT
	
	// regress inGT on the gap and a treatment indicator--not really
	// estimable since inGT is a perfect function of above56
	reg inGT gap i.above56
	
//	(d) create a grade 4 outcome variable

	gen grade4test = round(trueability + 5 + rnormal() + (3*inGT), 0.25)
	
//	(e) RD model using OLS - first assume constant slope below/above c
//	    and then differing slopes

	reg grade4test gap i.above56
	reg grade4test c.gap##i.above56
	
	// rdrobust using default options
	
	rdrobust grade4test gap, c(0) p(1) kernel(triangular)

	// Note: due to the rounding of test scores, rdrobust detects "mass points"
	// (concentrations of observations with the same gap values). It accounts
	// for the effect of these by default unless you turn this feature off:
	
	rdrobust grade4test gap, c(0) p(1) kernel(triangular) masspoints(off)
	
//	(f) introduce some fuzziness into treatment assignment

	drop inGT grade4test
	gen inGT=round(-.77+.007*grade3test+0.7*above56+runiform())
	gen grade4test = round(trueability + 5 + rnormal() + (3*inGT), 0.25)
	
	summ inGT
	summ inGT if grade3test<56
	summ inGT if grade3test>=56
	
	binscatter inGT gap, rd(0)
	graph export ingt.png, as(png) replace
	
//	(g) regress treatment (inGT) on gap and a treatment indcator, like (c)

	reg inGT gap i.above56
	reg inGT c.gap##i.above56
	
	// get predicted treatment for later use
	predict predGT
	
//	(h) try RD model again assuming (wrongly) sharp RD

	reg grade4test gap i.above56
	reg grade4test c.gap##i.above56	
	rdrobust grade4test gap, c(0) p(1) kernel(triangular)
	
//	(i) fuzzy RD

	// first using rdrobust with default options
	rdrobust grade4test gap, c(0) p(1) kernel(triangular) fuzzy(inGT)
	
	// then 2SLS (second stage shown here using predicted GT)
	reg grade4test gap predGT
	
	// ivregress is tricky here since "above56" is an exogenous instrument
	// conditional on grade3test. Can't use above56 both as the instrument
	// and in the interaction with "gap". So manually created an interaction
	// below
	
	gen gapabove = gap*above56
	gen gapbelow = gap*(1-above56)
	// note gapbelow and gapabove estimate slope on gap below and above
	ivregress 2sls grade4test (inGT=above56) gapbelow gapabove , first
	
	// using older rd command--instead of y x, syntax is y d x
	// NOTE: results will include the "numerator" reduced form (ITT) and
	// "denominator" first stage. "local Wald" is the ITT/first stage.
	
	rd grade4test inGT grade3test, z0(56) graph noscatter
	
//	(j) manipulation test

	rddensity gap, c(0) plot graph_opt(name(fuzzy, replace) legend(off))
	graph export fuzzy.png, as(png) replace
	
