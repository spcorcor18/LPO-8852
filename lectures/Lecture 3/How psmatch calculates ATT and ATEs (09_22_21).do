
// This do file demonstrates how the ATT and ATE are calculated following
// teffects psmatch

clear all
set seed 1234
use https://stats.idre.ucla.edu/stat/stata/examples/methods_matter/chapter12/catholic, clear

gen faminc8b=0 if faminc8==1
replace faminc8b = (0+1000)/2 if faminc8==2
replace faminc8b = (1000+2999)/2 if faminc8==3
replace faminc8b = (3000+4999)/2 if faminc8==4
replace faminc8b = (5000+7499)/2 if faminc8==5
replace faminc8b = (7500+9999)/2 if faminc8==6
replace faminc8b = (10000+14999)/2 if faminc8==7
replace faminc8b = (15000+19999)/2 if faminc8==8
replace faminc8b = (20000+24999)/2 if faminc8==9
replace faminc8b = (25000+34999)/2 if faminc8==10
replace faminc8b = (35000+49999)/2 if faminc8==11
replace faminc8b = (50000+74999)/2 if faminc8==12
label var faminc8b "family income in 8th grade (dollars)"

   
// note these two commands yield the same point estimates:
// ATT: 1.15278715
// ATE: 1.88951851
psmatch2 catholic math8 read8 faminc8b, outcome(math12) ate ties
teffects psmatch (math12) (catholic math8 read8 faminc8b, probit), ate nn(1)
teffects psmatch (math12) (catholic math8 read8 faminc8b, probit), atet nn(1)

// since these produce the same results, can just work with the variables
// conveniently created by psmatch (e.g. _weight)
tabulate _treated,miss
table _weight _treated, row
// the sum of the weights for the untreated = 592 (the number of treated cases)
tabstat _weight if _treated==0, stat(sum)
// the sum of the weights for the treated = 5079 (the number of untreated cases)
tabstat _weight if _treated==1, stat(sum)

// Note the psmatch procedure has identifed nearest neighbors based on pscores.
// The 592 treated cases are matched to 521 untreated cases (some of these are
// used more than once; the _weight variable tells us how many times so that we
// can upweight them). The 5,079 untreated cases are matched to 550 treated cases
// (most of these are used more than once; the _weight variable tells us how
// many times so that we can upweight them).

unique _n1 if _treated==1
unique _n1 if _treated==0

// The 521 untreated cases "stand in" as the counterfactual for the 592 treated
// when calculating the ATT. The 550 treated cases "stand in" for the 5,079
// untreated cases when calculating the ATU.


// ************************************************************
// manually calculate the ATT and ATE using weighted averages
// ************************************************************
// first get a count of the treated and untreated (592 and 5,079)
count if _treated==1
local tr=r(N)
count if _treated==0
local un=r(N)

// **************
// the ATT
// **************
// The mean for the treated (where each observation has a weight of 1) minus
// the mean for the matched untreated (using _weight as a frequency weight 
// since one untreated obs can be matched multiple times). Operationalized
// here as a sum (1.152787)
gen att = math12/`tr' if _treated==1
replace att = (-1*(_weight*math12))/`tr' if _treated==0
qui summ att
local att=r(sum)
display `att'

// **************
// the ATE
// **************
// The ATE is a weighted average of the ATT (above) and ATU (below), where the
// weights are the number of treated and untreated in each group, respectively.

// the ATU:
// The mean for the matched treated (using _weight as a frequency weight since
// one treated obs can be matched multiple times) minus the mean for the 
// untreated (where each observation has a weight of 1). Operationalized here
// as a sum (1.9753907) 
gen atu = (-1)*math12/`un' if _treated==0
replace atu = (_weight*math12)/`un' if _treated==1
qui summ atu
local atu=r(sum)
display `atu'

// weighted average of ATT and ATU = ATE (1.8895185)
display ((`tr'*`att') + (`un'*`atu'))/(`tr'+`un')




// Miscellanous - merge the untreated observations to the treated to see how
// the map on, for calculating ATU
/*
preserve
tempfile treated
keep if _treated==1
keep _id math12
rename _id _n1
rename math12 math12match
save `treated'
restore
keep if _treated==0
merge m:1 _n1 using `treated',nogen keep(1 3)
summ math12 math12match
*/
