
// Lecture 9 in-class exercise
// Instrumental variables

// Last updated: 11/3/21

cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 9 - IV\In-class exercise"

// ************
// Exercise 1
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

