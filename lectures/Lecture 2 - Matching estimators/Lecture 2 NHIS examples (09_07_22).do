
// Lecture 2 - exmaples of matching and weighting syntax
// Last updated: 9/7/22

// Source: subsample of National Household Interview Survey data used in 
// Angrist & Pischke Mastering Metrics chapter 1

clear all
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
	
	
// Exact matching based on educnew
teffects nnmatch (health) (uninsured), ematch(educnew) atet

// Attempted exact matching based on age (doesn't work--some nonoverlap)
teffects nnmatch (health) (uninsured), ematch(age) atet osample(unmatch)
drop unmatch

// Nearest neighbor distance matching based on age
teffects nnmatch (health age) (uninsured), atet

// Obs# of nnmatches can depend on sort order. I'm going to fix the sort order
// by sorting on the unique IDs and creating a "obsno" variable for my reference
duplicates report serial pernum
sort serial pernum
gen obsno=_n

// Same matching based on age, but request 5 nneighbors and variables 
// indicating obs # of matches
teffects nnmatch (health age) (uninsured), atet nneighbor(5) gen(nn)


// *************************************************************************
// Requested 5 neighbors, but gen() yields up to 86 neighbors. Why? Let's 
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
// resulting in >5 matches
teffects nnmatch (health age educrec1 inc famsize) (uninsured), atet nneighbor(5) gen(nn)
drop nn*

// teffects does not save the distance measure--what if we want it? mahapick
// is one use-written command that will find k nearest neighbors using 
// Mahalanobis and then save results (below example finds 3 nearest)
ssc install mahapick
mahapick age educrec1 inc famsize , idvar(obsno) treated(treat) ///
	nummatches(3) genfile(matches.dta) replace score
	
clear
use matches
sum _score if _matchnum~=0,detail
// only matches for the treated
unique _prime_id

setup

// Another alternative for Mahalanobis matching: psmatch2
ssc install psmatch2
psmatch2 treat , mahalanobis(age educrec1 inc famsize) neighbor(3)
drop _*
