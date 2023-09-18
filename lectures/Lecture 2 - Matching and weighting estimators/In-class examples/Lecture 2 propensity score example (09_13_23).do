
// Lecture 2 in-class example 2.2
// Propensity score matching example with Writing Center data 

// *************************************************************************
// Read Writing Center dataset 
// *************************************************************************
// These data represent 4,727 community college students enrolled in an 
// English 1 course on their first attempt. The variable "wr_center" is an
// indicator equal to 1 if the student enrolled in a supplementary writing 
// center course. This 1/2 credit course provided access to a writing center
// with study space, resources, and assistance or feedback from staff. 

// The examples below will use propensity scores to estimate the impact of
// writing center use on course success. There are two measures of success in
// English 1: the main_course_successflag (earning a "C" or higher) and the
// main_course_gradepoints (0-4).

// NOTE: related example using the same dataset (but with R and machine learning):
// https://cran.r-project.org/web/packages/IRexamples/vignettes/Ex-01-Propensity-Score-Weights-Using-GBM.html

	clear all
	use "https://github.com/spcorcor18/LPO-8852/raw/main/data/writing_center.dta"
	
// Look at course success measures by writing center use

	tabulate wr_center main_course_successflag, row
	tabstat main_course_gradepoints, by(wr_center) stat(n mean)
	
	reg main_course_successflag wr_center
	reg main_course_gradepoints wr_center
	
// Look at possible predictors of treatment

	encode ethnicity, gen(ethnicityn)
	encode gender, gen(gendern)
	encode term, gen(termn)
	
	summ age age i.gendern ibn.ethnicityn firstgen military foster finaid ///
		units_attempt gpa_beg first_time international nonresident hs_gpa ///
		online i.termn, sep(0)

		
// *************************************************************************
// Propensity score matching (teffects)
// *************************************************************************

	// Use shorter variable names
	rename main_course_successflag success
	rename main_course_gradepoints grade

	// Initial set of predictors
	teffects psmatch (success) (wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg first_time), atet

	// Compare means and variances of predictior variables
	tebalance summarize
	
	// Look at distribution of pscores for treated and untreated observations
	// Note 1: this shows distributions for ALL treated and untreated, not just
	//   those in matched sample. (The matched sample may exclude some untreated
	//   obs if they aren't anyone's nearest neighbor).
	// Note 2: this particular sample is pretty balanced at the outset. Treated
	//   students are already similar to untreated in many respects.
	teffects overlap, ptlevel(1)

	// teffects doesn't show you the coefficients from the propensity score
	// model but you can run your own logit
	logit wr_center age i.gendern i.ethnicityn firstgen gpa_beg first_time
	
	// Same set of predictors -- but now keep observation numbers of nearest 
	// neighbors and keep estimated propensity scores and distance to neighbors.
	gen obsno = _n
	teffects psmatch (success) (wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg first_time), atet gen(psm*)
	predict pscore, ps tlevel(1)
	predict di*, distance

	// Note: because of ties there are as many as 107 nearest neighbors
	// Stata does not create a variable containing the number of matched 
	// neighbors, but you could create one yourself like this:
	gen nmatches = 0
	foreach j of varlist psm* {
	   replace nmatches = nmatches + 1 if `j'~=.
	   }
	label var nmatches "number of nearest neighbors"
	tabulate nmatches
	
	// We can look at di1 for distance to nearest neighbor. (All other di's 
	// are ties, so they should be the same).
	histogram di1
	summ di1, detail

	// We can create our own overlap plot for pscores - this shows what teffects
	// overlap is doing
	twoway (kdensity pscore if wr_center==1) (kdensity pscore if wr_center==0), ///
		legend(label(1 "Enrolled in writing center") label(2 "Did not enroll"))
	
	capture drop psm* di* pscore nmatches
	
	// More extensive set of predictors - switched to course grade outcome
	// (note hs_gpa has some missing values)
	teffects psmatch (grade) (wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits  ///
		nonresident_tu international online i.termn), atet gen(psm*)
	predict pscore, ps tlevel(1)
	predict di*, distance
	predict po0, po tlevel(0)
	predict po1, po tlevel(1)
	predict te, te
	
	// Note: with more predictor variables there are fewer ties. Now no more
	// than 2 nearest neighbors

	tebalance summarize
	teffects overlap, ptlevel(1)
		
	capture drop psm* di* pscore po0 po1 te obsno

	// Now look at other outcome (success 0-1)
	teffects psmatch (success) (wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits  ///
		nonresident_tu international online i.termn), atet

	// Look at logit
	logit wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits  ///
		nonresident_tu international online i.termn
		
	// For comparison use multiple regression, same predictors
	reg success wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits  ///
		nonresident_tu international online i.termn, robust
	reg grade wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits  ///
		nonresident_tu international online i.termn, robust

		
// *************************************************************************
// Propensity score matching (psmatch2)
// *************************************************************************

	// psmatch2 is user-written and may need to be installed
	*ssc install psmatch2, replace
	
	// A nice feature of psmatch2 is that you don't have to see the treatment
	// effect estimate if you don't want it. Add outcome() option to see it.
	// Another nice feature is that it automatically shows you the coefficients
	// from the propensity score model. Note in psmatch2 the default is probit.
	// For comparison with teffects use logit. The default is not to keep ties
	// so sort order will matter. Can add ties option to take ties (like teffects).
	
	psmatch2 wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits  ///
		nonresident_tu international online i.termn, logit ties

	// Balance checking with pstest	
	pstest age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits  ///
		nonresident_tu international online i.termn
		
	// Could experiment with alternative specifications to improve balance on
	// hs gpa (variance ratio)--e.g., quadratic term for HS GPA, interact GPA
	// with other categorical variables (e.g., gender, first gen)
		
	psmatch2 wr_center age i.ethnicityn firstgen ///
		i.gendern##c.hs_gpa##c.hs_gpa gpa_beg first_time finaid units_attempted ///
		termunits nonresident_tu international online i.termn, logit ties

	// Balance checking with pstest	
	pstest age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits  ///
		nonresident_tu international online i.termn
	
	// A look at hs_gpa for the matched sample (compare means to pstest)
	tabstat hs_gpa [aweight=_weight], by(wr_center) stat(n mean sd var)
	
	// psmatch2 creates a set of variables starting with _*	
	summ _*

	// _pscore is the estimated propensity score
	// _treated just flags the treated observations
	table _treated wr_center
	// _support is a flag for "common support"
	// _weight is 1 for treated cases and an integer (or missing) for untreated
	//    cases. The integer is the number of times the case was used as a
	//    match. Note some treated cases are not used here because they are 
	//    missing data on hs_gpa.
	tabulate _weight wr_center, miss
	// _id is a unique ID number assigned to observations
	// _n1 is the ID number of the nearest neighbor
	// _nn is the number of nearest neighbors
	unique _n1
	tabulate wr_center _nn, miss
	// _pdif is the distance to the nearest neighbor
	
	// Densities of propensity scores--ALL treated and untreated cases. Compare
	// to teffects overlap
	twoway (kdensity _pscore if _treated==1) (kdensity _pscore if _treated==0), ///
		legend(label(1 "Enrolled in writing center") label(2 "Did not enroll")) ///
		title("Estimated propensity scores: all observations")

	// Densities of propensity scores--MATCHED treated and untreated cases
	// Note: _weight will ensure right observations are used and multiple 
	// matches weights appopriately. (Odd case of non-integer weight that we 
	// will overwrite)
	gen _weight2 = _weight
	replace _weight2=. if _weight>0 & _weight<1
	twoway (kdensity _pscore if _treated==1 [fweight=_weight2]) ///
		   (kdensity _pscore if _treated==0 [fweight=_weight2]), ///
		   legend(label(1 "Enrolled in writing center") label(2 "Did not enroll")) ///
		   title("Estimated propensity scores: matched sample")

	// off by one obs here because of non-integer weight issue
	tabulate wr_center [fweight=_weight2]
		   
	// Another way of seeing distribution of propensity scores (all cases)	   
	histogram _pscore, kdensity kdenopts(gaussian) by(wr_center, cols(1) legend(off)) ///
		ytitle(Frequency) xtitle(Estimated Propensity Scores)
		
	// Yet another way using psgraph (part of psmatch2)
	psgraph
	
	// Still another way--overlapping histograms (matched sample)
	twoway (histogram _pscore if wr_center==0 [fweight = _weight2], bin(20) ///
		fcolor(none) lcolor(blue)) (histogram _pscore if wr_center==1, bin(20) ///
		fcolor(none) lcolor(red))
		
	// Could look at distribution of distance to nearest neighbor
	histogram _pdif
	summ _pdif
	
	// When happy with propensity score model request treatment effect
	psmatch2 wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits nonresident_tu ///
		international online i.termn, logit ties outcome(success)
		
	psmatch2 wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted ///
		international online i.termn, logit ties outcome(grade)
	
	// Regress outcome on treatment (wr_center) and use _weights (same integer
	// issue as before). Should be same point estimate though different SE.
	// Note: sometimes researchers will estimate a regression like this and
	// include covariates again to try to address any remaining imbalance.
	gen _weight3=_weight
	replace _weight3=. if _weight>0 & _weight<1
	reg grade wr_center [pweight=_weight3]
	
	// Compare point estimates and SEs to teffects--first ATT matches, though
	// second one doesn't (not sure why)
	teffects psmatch (success) (wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits  ///
		nonresident_tu international online i.termn), atet
		
	teffects psmatch (grade) (wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits  ///
		nonresident_tu international online i.termn), atet		
		
	capture drop _*

// *************************************************************************
// Inverse propensity score weighting (teffects)
// *************************************************************************

	// Inverse probability weighting (IPW)
	teffects ipw (grade) (wr_center age i.gendern i.ethnicityn firstgen ///
		gpa_beg hs_gpa first_time finaid units_attempted termunits  ///
		nonresident_tu international online i.termn), atet logit

	predict pscore, ps tlevel(1)
	
	// Create our own overlap plot for pscores
	twoway (kdensity pscore if wr_center==1) (kdensity pscore if wr_center==0), ///
		legend(label(1 "Enrolled in writing center") label(2 "Did not enroll"))

	teffects overlap, ptlevel(1)	
	
	// Show the IPW weighted averages (ATT)
	gen ipw=1 if wr_center==1
	replace ipw=(pscore/(1-pscore)) if wr_center==0
	
	tabstat grade if pscore~=. [weight=ipw] , by(wr_center)
		
