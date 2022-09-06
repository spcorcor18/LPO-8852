
// Lecture 2 - exmaples of matching and weighting syntax
// Last updated: 9/6/22

cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 2 - Matching estimators\"
use NHIS2009_subset.dta, clear

// Health status an ordinal variable 1-5 (1=Excellent 5=Poor)
ssc install fre
fre health

// Health status by uninsured status
tabstat health, by(uninsured)
ttest health, by(uninsured)

// Highest education completed
fre educrec1

// Reduce number of categories
gen educnew = 1 if educrec1<=12
replace educnew = 2 if educrec1==13
replace educnew = 3 if educrec1==14
replace educnew = 4 if educrec1==15
replace educnew = 5 if educrec1==16
tabulate educnew, miss

// Exact matching based on educnew
teffects nnmatch (health) (uninsured), ematch(educnew) atet

// Attempted exact matching based on age (doesn't work--some nonoverlap)
teffects nnmatch (health) (uninsured), ematch(age) atet

// Nearest neighbor distance matching based on age
teffects nnmatch (health age) (uninsured), atet

// Same, request 5 nearest neighbors and variables indicating obs no of matches
teffects nnmatch (health age) (uninsured), atet nneighbor(5) gen(nn)
drop nn*
