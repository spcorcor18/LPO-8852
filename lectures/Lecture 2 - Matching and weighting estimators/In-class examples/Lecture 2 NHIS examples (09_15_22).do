
// ***************************************************************************
// Lecture 2 - examples of matching and weighting syntax
// Last updated: 9/15/22
// ***************************************************************************

// Source: subsample of National Household Interview Survey data used in 
// Angrist & Pischke Mastering Metrics chapter 1

// ***************************************************************************
// Data set up
// ***************************************************************************
clear all
// change working directory as needed
cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 2 - Matching estimators"

program setup
   use https://github.com/spcorcor18/LPO-8852/raw/main/data/NHIS2009_subset.dta, clear

   // Health status an ordinal variable 1-5 (1=Excellent 5=Poor)
   ssc install fre
   fre health

   // Health status by uninsured status
   tabstat health, by(uninsured)
   ttest health, by(uninsured)

   // Highest education completed
   fre educrec1

	// Reduce number of education categories
	gen educnew = 1 if educrec1<=12
	replace educnew = 2 if educrec1==13
	replace educnew = 3 if educrec1==14
	replace educnew = 4 if educrec1==15
	replace educnew = 5 if educrec1==16
	label define educnew 1 "11 or fewer years" 2 "12 years" 3 "1-3 yrs college" ///
		4 "4 yrs college/BA" 5 "5+ yrs college"
	label values educnew educnew
	tabulate educnew, miss
	
	gen treat=(uninsured==1) /* treated var used later has to be 0,1 */ 
   end

setup
	
// ***************************************************************************
// Matching examples--exact matching
// ***************************************************************************

// Exact matching based on educnew
teffects nnmatch (health) (treat), ematch(educnew) atet

// Attempted exact matching based on age (won't work--there is some nonoverlap)
// The option osample() creates a variable flagging the cases w/o overlap
teffects nnmatch (health) (treat), ematch(age) atet osample(unmatch)
drop unmatch

// ***************************************************************************
// Matching examples--nearest neighbor (Mahalanobis)
// ***************************************************************************

// Nearest neighbor distance matching based on age (rather than exact match)
teffects nnmatch (health age) (treat), atet

// teffects can save the observation number(s) of nearest neighbors. However,
// the observation number can depend on sort order. I'm going to fix the sort 
// order here by sorting on a unique ID and creating a "obsno" variable that 
// will remain fixed even if sort order changes:
duplicates report serial pernum
sort serial pernum
gen obsno=_n

// Same matching based on age, but request 5 nneighbors and variables 
// indicating obs # of matches
teffects nnmatch (health age) (treat), atet nneighbor(5) gen(nn)


// *************************************************************************
// ASIDE (FYI):
// I requested 5 neighbors, but gen() yields up to 86 neighbors. Why? Let's 
// explore. But first, teffects nnmatch does not create a variable with the
// # of matches, so we'll create one
gen nofmatches=0
forvalues j=1/86 {
  replace nofmatches=nofmatches+1 if nn`j'~=.
  }
tabulate nofmatches

// Let's look at a few cases to see how matches were picked, starting with
// the first observation (a covered/untreated person)
list unins age in 1  /* person 1 is age 65, covered, and has 5 nneighbors */ 
table unins if age==65 /* there is only 1 uncovered unit age 65 */
browse nn* if age==65 
// note ALL covered persons age 65 are matched to the SAME 5--obsnos below
// (this implies matching with replacement)
table age if inlist(obsno,4545,3144,2063,1050,833)
tabulate age if unins==1 & age>60
// covered persons age 65 are matched to ALL uncovered persons age 64 (3) and 
// ALL persons age 65 (1) and 66 (1)

// persons age 72 and uninsured were all matched to the SAME 16--obsnos below
browse nn* if age==72 & unins==1
tabulate age if inlist(obsno,234,264,561,919,1802,1989,2594,2640,2716,3197,3316,3351,3809,3989,4322,4495)
// all of their matches are age 72 and covered--there are 16 of these and ALL
// of them are matches. Conclusion: when there are ties, nnmatch uses all of 
// them
drop nn* nofmatches
// *************************************************************************


// Nearest neighbor match--Mahalanobis with four matching variables. The matching
// variables are all pretty discrete (even income) so there are still some ties
// resulting in >5 matches in some cases
teffects nnmatch (health age educrec1 inc famsize) (treat), atet nneighbor(5) gen(nn)
drop nn*

// Using predict command after estimation to get distance to nearest neighbors
teffects nnmatch (health age educrec1 inc famsize) (treat), atet nneighbor(5) gen(nn)
predict dist*, distance
drop nn* dist

// Alternative for Mahalanobis matching: mahapick user-written command--finds
// k nearest neighbors and then saves results (below example finds 3 nearest)
ssc install mahapick
mahapick age educrec1 inc famsize , idvar(obsno) treated(treat) ///
	nummatches(3) genfile(matches.dta) replace score
	
clear
use matches
sum _score if _matchnum~=0,detail
// only matches for the treated
unique _prime_id

// Start over with clean data
setup

// Another alternative for Mahalanobis matching: psmatch2
ssc install psmatch2
psmatch2 treat , mahalanobis(age educrec1 inc famsize) neighbor(3)
drop _*


// ***************************************************************************
// Matching examples--nearest neighbor (propensity scores)
// ***************************************************************************

// Start with clean data
setup

// Nearest neighbor matches using propensity scores
teffects psmatch (health) (treat age educrec1 inc famsize)

// Nearest neighbor matches using propensity scores--keep obs # of matches and
// use predict commands to get propensity scores, potential outcomes, and more
// NOTE: I am using quietly prefix to suppress the output of teffects. It is
// good practice not to see TE estimates until after all decisions are made 
// regarding matching
quietly: teffects psmatch (health) (treat age educrec1 inc famsize), gen(nn)

// predicted propensity score
predict pscore, ps

// predicted potential outcomes (two variables: untreated state, treated state)
predict pohealthu pohealtht, po

// predicted treatment effect (individual)--based on potential outcomes
predict tehealth, te

// distance to nearest neighbor(s)
predict distscore* , distance 

drop nn* pscore pohealth* tehealth distscore*

// Alternative command: psmatch2
psmatch2 treat age educrec1 inc famsize, outcome(health) ate


// ***************************************************************************
// Checking for balance on matching variables, propensity scores
// ***************************************************************************

// Start with clean data
setup

// Back to teffects nnmatch--and check for balance
quietly: teffects nnmatch (health age educrec1 inc famsize) (treat), atet nneighbor(5)
tebalance summarize age educrec1 inc famsize

tebalance box age

tebalance density age

// Back to teffects psmatch--and check for balance on pscores
teffects psmatch (health) (treat age educrec1 inc famsize), gen(nn)

// teffect overlap will show the distributions of estimated propensity scores
// for the full sample. Need to tell Stata which value of the treatment variable
// you're interested in see the propensity for (i.e., value of treat=1), else
// it uses the first value (0 here)
teffects overlap, ptlevel(1)


// ***************************************************************************
// Inverse probability weighting examples
// ***************************************************************************

// Inverse probability weighting (IPW)
teffects ipw (health) (treat age educrec1 inc famsize), atet