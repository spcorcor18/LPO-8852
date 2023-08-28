
// Lecture 5 in-class examples
// Instrumental variables

// Last updated: 11/3/22

cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 9 - IV\In-class Example"

// ************
// Example 1
// ************

// *****
// 1
// *****

use http://fmwww.bc.edu/ec-p/data/wooldridge/card,clear

// *****
// 2 
// *****
// OLS log wage and education
reg lwage educ 

// *****
// 3a 
// *****
// IV estimator using covariance(z,y) / covariance(z,x)
corr lwage educ nearc4, cov
matrix list r(C)
display el(r(C),3,1) / el(r(C),3,2)

// *****
// 3b
// *****
// Reduced form and first stage
reg lwage nearc4
scalar rho = _b[nearc4]

reg educ nearc4
scalar phi = _b[nearc4]

display rho/phi

// *****
// 3c
// *****
// 2SLS manually
reg educ nearc4
predict educhat, xb
summ educ educhat

reg lwage educhat
drop educhat

// *****
// 3d
// *****
// 2SLS using ivregress
ivregress 2sls lwage (educ = nearc4), first
estat firststage

// *****
// 4
// *****
// OLS
global covars "exper black smsa* south mar reg662-reg669"
reg lwage educ $covars
// 2SLS manually
reg educ nearc4 $covars
predict educhat, xb
reg lwage educhat $covars
drop educhat

// 2SLS using ivregress
ivregress 2sls lwage $covars (educ = nearc4), first
estat firststage

// *****
// 5
// *****
// 2SLS using ivregress
ivregress 2sls lwage $covars (educ = nearc4)
estat endogenous

// *****
// 6
// *****
// 2SLS using ivregress - two instruments
ivregress 2sls lwage $covars (educ = nearc2 nearc4), first
estat firststage

// *****
// 7
// *****

estat endog
estat overid

// *****
// 8
// *****
// LIML using ivregress -- two instruments
ivregress liml lwage $covars (educ = nearc4 nearc2)


// ************
// Example 2
// ************
// y depends on x and an omitted variable w
// x depends on z and the omitted variable w
// z is a valid instrument bc it is related to z but unrelated to y except through x

clear
set obs 1000
gen z = rnormal()
gen w = rnormal()
gen x = -2*z + 2*w + rnormal()
gen y = 5*x + 10*w + rnormal()
corr y x z w
corr y x z w, cov

// OLS with OVB
reg y x
// IV with z as an instrument
ivregress 2sls y (x=z), first

// A bad "diagnostic" regression
reg y x z

// Frisch-Waugh-Lovell
// partial out x--get "the part of z not explained by x"
reg z x
predict ztilde, r
// then regress y on ztilde--its the same coefficient as on z in the bad diagnostic
reg y ztilde
// ztilde is positively correlated with w
corr ztilde y x z w
twoway (scatter z x) (lfit z x)

// if   x = -2*z + 2*w + u
// then 2z = -x + 2*w + u
//       z = -0.5x + w + 0.5u

// Regressing y on z is ok--z is exogenous
// Regressing y on z and x is not ok
