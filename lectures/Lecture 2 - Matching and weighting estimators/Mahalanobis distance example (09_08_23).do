

// ****************************************************************************
// Mahalnobis distance illustration
// Note: this example inspired by the description of Mahalanobis distance at:
// https://mccormickml.com/2014/07/22/mahalanobis-distance/
// Last updated: 9/8/2023
// ****************************************************************************

	cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 2 - Matching and weighting estimators\In-class exercise"

// Two random variables x1 and x2
// Each is mean zero, x1 has a variance of 10 and x2 has a variance of 5
// Covariance between x1 and x2 is 3.5 which in this case corresponds to a
// correlation of about 0.5 (i.e. 3.5/(sqrt(10)*sqrt(5)))

	clear
	set seed 4321
	matrix C = (10, 3.5 \ 3.5, 5)
	drawnorm x1 x2, n(100) cov(C)
	summ
	corr x1 x2
	scatter x1 x2, name(g0, replace) scheme(538) xline(0) yline(0) title("Raw data")
	// For later use, record the original sort order
	gen sortorder = _n
	label var sortorder "original sort order"

	
// ****************************************************************************
// First lets find nearest neighbors based on (x1,x2) and Euclidean distance.
// Euclidean (straight-line) distance is based on the Pythagorean theorem:
// sqrt((y2 - y1)^2 + (x2 - x1)^2))
// ****************************************************************************

// NOTE: the teffects command requires an outcome variable (y). If you just
// want to find nearest neighbor matches using (x1,x2) without any particular
// outcome in mind, you'll need to use another command. The user-written 
// command "nearest" will identify nearest neighbors based on straight-line
// distance.

	ssc install nearest, replace
	nearest x1 x2, dist(dist) id(id)
	label var dist "nearest neighbor: straight line distance"
	label var id   "nearest neighbor: ID number"
	// The generated variable "id" will contain the ID of the nearest neighbor,
	// and "dist" will contain the Euclidean distance to that nearest neighbor.

	// Let's plot the first 10 pairs of nearest neighbors. This loop identifies
	// the nearest neighbor for the first 10 observations and labels it.
	gen pairno=0
	forvalues j=1/10 {
	   replace pairno=`j' if _n==`j'
	   levelsof id if _n==`j'
	   replace pairno=`j' if _n==`r(levels)' & pairno==0
	   }
	table pairno

	twoway (scatter x1 x2 if pairno==1, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno==2, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno==3, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno==4, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno==5, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno==6, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno==7, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno==8, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno==9, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno==10, mlabel(sortorder)), legend(off) ///
		scheme(538) xline(0) yline(0) name(g1, replace) ///
		title("Nearest neighbors: Euclidean", size(medsmall)) 

// An unattractive feature of the straight-line distance is that it weights 
// equally the y2-y1 distance and x2-x1 distance. In this example y is more
// spread out (a variance of 10) than is x (a variance of 5). We would expect
// two points to vary more with respect to y than with x.

	// An alternative is the standardized Euclidean distance where we standardize 
	// y and x to have the same variance:
	egen zx1=std(x1)
	egen zx2=std(x2)

	// Then get nearest neighbors based on this
	nearest zx1 zx2, dist(distz) id(idz)
	label var distz "nearest neighbor (z-score): straight line distance"
	label var idz   "nearest neighbor (z-score): ID number"

	// And plot first 10 pairs of neighbors, as before
	gen pairnoz=0
	forvalues j=1/10 {
	   replace pairnoz=`j' if _n==`j'
	   levelsof idz if _n==`j'
	   replace pairnoz=`j' if _n==`r(levels)' & pairnoz==0
	   }
	table pairnoz

	twoway (scatter zx1 zx2 if pairnoz==1, mlabel(sortorder)) ///
	(scatter zx1 zx2 if pairnoz==2, mlabel(sortorder)) ///
	(scatter zx1 zx2 if pairnoz==3, mlabel(sortorder)) ///
	(scatter zx1 zx2 if pairnoz==4, mlabel(sortorder)) ///
	(scatter zx1 zx2 if pairnoz==5, mlabel(sortorder)) ///
	(scatter zx1 zx2 if pairnoz==6, mlabel(sortorder)) ///
	(scatter zx1 zx2 if pairnoz==7, mlabel(sortorder)) ///
	(scatter zx1 zx2 if pairnoz==8, mlabel(sortorder)) ///
	(scatter zx1 zx2 if pairnoz==9, mlabel(sortorder)) ///
	(scatter zx1 zx2 if pairnoz==10, mlabel(sortorder)), legend(off) ///
		scheme(538) xline(0) yline(0) name(g2, replace) ///
		title("Nearest neighbors: standardized Euclidean", size(medsmall))

		
// ****************************************************************************
// Next lets find the nearest neighbor based on (x1,x2) and Mahalanobis distance. 
// ****************************************************************************

// NOTE: the teffects command requires an outcome variable (y). If you just
// want to find nearest neighbor matches using (x1,x2) without any particular
// outcome in mind, you'll need to use another command. As of yet I have not
// found an easy command to simply identify nearest neighbors using Mahalanobis
// distance that also provides the distance measure. As a workaround, the user-
// written Stata command mahascore will do this one focal observation at a time.
// (Two other commands are also required for mahascore to work). I use a loop to
// get nearest neighbors one at a time. 

	ssc install mahapick, replace
	ssc install moremata, replace
	ssc install kdens, replace

	gen distm=.
	gen idm  =.
	label var distm "nearest neighbor: Mahalanobis distance"
	label var idm   "nearest neighbor: ID number (Mahala)"

	quietly {
	forvalues j=1/100 {
	   // mahascore computes the mahalanobis distance between the focal
	   // observation j and all other observations, saves that distance as 
	   // variable temp
	   mahascore x1 x2, gen(temp) refobs(`j') compute_invcovarmat unsquared
	   // distance (temp) will be 0 for reference observation so replace with .
	   replace temp=. if _n==`j'
	   // sort in ascending order of distance
	   sort temp
	   // identify id# (sortorder) for nearest neighbor
	   levelsof sortorder if _n==1, local(id)
	   // identify distance (temp) for nearest neighbor
	   levelsof temp if _n==1, local(dm)
	   // store the nearest neighbor distance and id for focal observation j
	   replace distm=`dm' if sortorder==`j'
	   replace idm = `id' if sortorder==`j'
	   drop temp
	   sort sortorder
	   }
	   }

	// As before, plot the first 10 pairs of neighbors
	gen pairnom=0
	forvalues j=1/10 {
	   replace pairnom=`j' if _n==`j'
	   levelsof idm if _n==`j'
	   replace pairnom=`j' if _n==`r(levels)' & pairnom==0
	   }
	table pairnom

	twoway (scatter x1 x2 if pairnom==1, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom==2, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom==3, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom==4, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom==5, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom==6, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom==7, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom==8, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom==9, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom==10, mlabel(sortorder)), legend(off) ///
		scheme(538) xline(0) yline(0) name(g3, replace) ///
		title("Nearest neighbors: Mahalanobis", size(medsmall))
		
	graph combine g0 g1 g2 g3, cols(2) xsize(10) ysize(8.5)
	graph export neighbors1.png, as(png) replace


// ****************************************************************************
// In many cases the nearest neighbor will be the same using all three methods.
// This next section will specifically plot some cases where idm differs from id
// ****************************************************************************

	gen diff=(id~=idm)
	gsort -diff sortorder
	table diff

	gen diffz=(idz~=id)
	gen diffz2=(idz~=idm)
	table diffz
	table diffz2

	// NOTE: sort order has changed so be attentive to how we refer to case #s

	// Re-plot first ten cases where neighbors are different (Euclidean--z score)
	gen pairno2=0
	forvalues j=1/10 {
	   replace pairno2=`j' if _n==`j'
	   levelsof id if _n==`j'
	   replace pairno2=`j' if sortorder==`r(levels)' & pairno2==0
	   // Note change in above line to address change in sort order
	   }
	table pairno2

	twoway (scatter x1 x2 if pairno2==1, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno2==2, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno2==3, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno2==4, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno2==5, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno2==6, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno2==7, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno2==8, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno2==9, mlabel(sortorder)) ///
	(scatter x1 x2 if pairno2==10, mlabel(sortorder)), legend(off) ///
		scheme(538) xline(0) yline(0) name(g2b, replace) ///
		title("Nearest Neighbors (standardized Euclidean)", size(medsmall)) nodraw


	// Re-plot first ten cases where neighbors are different (Mahalanobis)
	gen pairnom2=0
	forvalues j=1/10 {
	   replace pairnom2=`j' if _n==`j'
	   levelsof idm if _n==`j'
	   replace pairnom2=`j' if sortorder==`r(levels)' & pairnom2==0
	   // Note change in above line to address change in sort order
	   }
	table pairnom2

	twoway (scatter x1 x2 if pairnom2==1, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom2==2, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom2==3, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom2==4, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom2==5, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom2==6, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom2==7, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom2==8, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom2==9, mlabel(sortorder)) ///
	(scatter x1 x2 if pairnom2==10, mlabel(sortorder)), legend(off) ///
		scheme(538) xline(0) yline(0) name(g3b, replace) ///
		title("Nearest Neighbors (Mahalanobis)") nodraw
		
	graph combine g2b g3b, cols(1) xsize(8) ysize(10) xcommon ycommon ///
		title("Select neighbors that differ (Euclidean vs Mahalanobis)", size(medsmall))
	graph export neighbors2.png, as(png) replace
