
// Simple matching examples with simulated data and teffects

// *************************************************************************
// Create a dataset with age (18-40), education (binary), treatment, outcome
// *************************************************************************
clear all
set seed 1234
set obs 750
gen age=int(runiform(18,40))

// Probability of higher education increases with age--starting at 0.4 for age
// 18 and rising to 0.50 at age 40
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

// Outcome is a function of age, educ, and treatment. Constant treatment effect
// of 30
gen y= -70 + (30*treat) + (6*age) + (10*educ) + rnormal(5,5)
summ y,detail
drop preduc

// Simple regression with OVB
reg y treat

// *************************************************************************
// Matching examples
// *************************************************************************

// Exact matching on age
teffects nnmatch (y age) (treat) , ematch(age) ate  dmvariables
teffects nnmatch (y age) (treat) , ematch(age) atet dmvariables
tebalance summarize
tebalance summarize, baseline

// Exact matching on age and education
// Note: default std error calculation requires 2+ matches so using vce(iid)
teffects nnmatch (y age educ) (treat) , ematch(age educ) ate vce(iid) dmvariables
teffects nnmatch (y age educ) (treat) , ematch(age educ) atet vce(iid) dmvariables
tebalance summarize

// Before nearest neighbor, drop some observations so that exact matches not
// so easy
sample 200, count

// Nearest neighbor (Euclidean)
teffects nnmatch (y age educ) (treat) , metric(euclidean) nneighbor(5) ate vce(iid) dmvariables
teffects nnmatch (y age educ) (treat) , metric(euclidean) nneighbor(5) atet vce(iid) dmvariables
tebalance summarize

// Nearest neighbor (Mahalanobis = default)
teffects nnmatch (y age educ) (treat) , nneighbor(5) ate vce(iid) dmvariables
teffects nnmatch (y age educ) (treat) , nneighbor(5) atet vce(iid) dmvariables
tebalance summarize

// with and without bias adjustment
teffects nnmatch (y age educ) (treat) , nneighbor(5) atet vce(iid)
tebalance summarize
teffects nnmatch (y age educ) (treat) , nneighbor(5) atet vce(iid) biasadj(age)

// Propensity score
// note: predict commands require the "gen()" option storing the index of nearest neighbor
teffects psmatch (y) (treat age educ, logit), ate
teffects psmatch (y) (treat age educ, logit), atet gen(mvar)
predict ps
tebalance summarize
teffects overlap

