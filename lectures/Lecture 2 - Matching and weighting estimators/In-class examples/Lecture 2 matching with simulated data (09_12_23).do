
// Lecture 2 in-class example 1
// Exact and nearest neighbor matching examples with simulated data and teffects

// *************************************************************************
// Create a dataset with age (18-40), education (binary), treatment, outcome
// *************************************************************************

	clear all
	set seed 1234
	set obs 750
	gen age=int(runiform(18,40))

	// Probability of higher education increases with age--starting at 0.4 for
	// age 18 and rising to 0.50 at age 40
	gen preduc= (7/22) + (0.1/(40-18))*age

	// Assign a binary higher education variable
	gen educ=rbinomial(1,preduc)

	// Probability of treatment increases with age and educ
	gen prtreat= 0.036 + 0.01*age + 0.14*educ

	// Assign a binary treatment based on probability of treatment
	gen treat=rbinomial(1,prtreat)
	tabulate age treat
	tabulate educ treat, row
	corr age educ treat

	// Outcome is a function of age, educ, and treatment. Constant treatment 
	// effect of 30
	gen y= -70 + (30*treat) + (6*age) + (10*educ) + rnormal(5,5)
	summ y,detail
	drop preduc

	// Simple regression with OVB. Controlling for age and education would
	// suffice in this example, but we want to illustrate matching below.
	reg y treat
	

// *************************************************************************
// Matching examples
// *************************************************************************

	// Exact matching on age
	// Note: dmvariables option asks stata to display the names of the matching variables 
	teffects nnmatch (y age) (treat) , ematch(age) ate  dmvariables
	teffects nnmatch (y age) (treat) , ematch(age) atet dmvariables

	// Compare means and variances of matching variables
	tebalance summarize
	tebalance summarize, baseline
	
	// Quietly matching on age so that ate is suppressed from view
	quietly: teffects nnmatch (y age) (treat), ematch(age) ate
	tebalance summarize

	// Exact matching on age and education
	// Note: default std error calculation requires 2+ matches so using vce(iid)
	teffects nnmatch (y age educ) (treat) , ematch(age educ) ate vce(iid) dmvariables
	teffects nnmatch (y age educ) (treat) , ematch(age educ) atet vce(iid) dmvariables
	tebalance summarize

	// Show how to store the observation number of exact matches on age. em* is
	// the stub for the new variables containing the exact matches.
	// Note: when exact matching, the default is to use ALL exact matches.
	// Note: because sort order may change, when storing observation numbers
	// it is useful to capture the current order of observations as a variable.
	gen obsno = _n
	teffects nnmatch (y age) (treat), ematch(age) ate dmvariables gen(em)
	drop em*
	
	// Before doing nearest neighbor examples, drop some observations so that
	// exact matches are not so easy to make
	sample 200, count

	// Nearest neighbor (Euclidean)
	teffects nnmatch (y age educ) (treat) , metric(euclidean) nneighbor(5) ate vce(iid) dmvariables
	teffects nnmatch (y age educ) (treat) , metric(euclidean) nneighbor(5) atet vce(iid) dmvariables
	// Compare means and variances of matching variables
	tebalance summarize
	// Boxplot distribution and kernel density of matching variable (age)
	tebalance box age
	tebalance density age

	// Nearest neighbor (Mahalanobis = default)
	teffects nnmatch (y age educ) (treat) , nneighbor(5) ate vce(iid) dmvariables
	teffects nnmatch (y age educ) (treat) , nneighbor(5) atet vce(iid) dmvariables
	tebalance summarize
	
	// Example combining nearest neighbor and exact match (on educ)
	teffects nnmatch (y age ) (treat) , ematch(educ) nneighbor(5) atet vce(iid) dmv

	// Show how to store the observation number of nearest neighbor matches on age
	// and education. Also, store the Mahalanobis distance to neighbors using the
	// predict command. em* is the stub for the new variables containing 
	// matches, di* is the stub for the new variables containing distance.
	// Note: we requested only 5 nearest neighbors but there may be ties leading
	// to more matches in practice.
	drop obsno
	gen obsno = _n
	teffects nnmatch (y age educ) (treat) , nneighbor(5) ate vce(iid) dmvariables gen(em)
	predict di*, distance
	
	drop em* di*

	// With and without bias adjustment (Abadie and Imbens, 2011)
	teffects nnmatch (y age educ) (treat) , nneighbor(5) atet vce(iid)
	tebalance summarize
	teffects nnmatch (y age educ) (treat) , nneighbor(5) atet vce(iid) biasadj(age educ)

	// Predicting "potential outcomes" and individual "treatment effects"
	// Note: requires store observation number of nearest neighbors.
	// First, after requesting ATET - no po1 or te for untreated cases
	teffects nnmatch (y age educ) (treat) , nneighbor(5) atet vce(iid) gen(em*)
	predict po0, po tlevel(0)
	predict po1, po tlevel(1)
	predict te, te
	list y treat po0 po1 te in 1/5
	summ te
	drop em* po* te

	// Second, after requesting ATE - now we get a po1 and te for untreated cases
	teffects nnmatch (y age educ) (treat) , nneighbor(5) ate vce(iid) gen(em*)
	predict po0, po tlevel(0)
	predict po1, po tlevel(1)
	predict te, te
	list y treat po0 po1 te in 1/5
	summ te
	drop em* po* te

	// Example of using mahapick to identify nearest neighbor matches (using
	// Mahalanobis measure) and output those matches to a file. Note: mahapick
	// is a user-written command, so need to ssc install first
	
	// change directory to destination for this file
	cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 2 - Matching and weighting estimators"
	
	mahapick age educ, idvar(obsno) treated(treat) nummatches(5) genfile(nnmatches) score
	
	// the resulting dataset has the original treated cases plus 5 nearest 
	// neighbors for each treated case
	clear
	use nnmatches
	
	
	
	// Propensity score matching example -- using earlier data (clear and 
	// reload this data)
	sample 150, count
	
	teffects psmatch (y) (treat age educ, logit), ate
	// The following shows the distribution of estimated propensity scores for
	// the treated and untreated groups. ptlevel(1) tells stata to plot the
	// propensity to be treated (the default is propensity to be untreated, for
	// some reason). Note this command will work once, but may give you an error
	// message when run a second time. To get the command to work repeatedly, be
	// sure to save the nearest neighbor ids (gen option)
	teffects overlap, ptlevel(1)
	
	teffects psmatch (y) (treat age educ, logit), ate gen(ps)
	teffects overlap, ptlevel(1)
	teffects overlap, ptlevel(0)
	
	// Can check for balance on the covariates themselves
	tebalance summarize age educ

	// Using psmatch2 for propensity score matching
	psmatch2 treat age educ, logit outcome(y)
