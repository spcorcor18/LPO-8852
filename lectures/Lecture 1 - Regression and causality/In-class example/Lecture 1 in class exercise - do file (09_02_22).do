
// Lecture 1 in-class exercise questions 2 and 3
// September 2, 2022

// ***********
// Question 2
// ***********

clear
set seed 626
// random draws of x1 x2 u (independent, standard normal variables)
drawnorm x1 x2 u, n(100) 
corr

// outcomes y1 and y2 
gen y1 = 10 + x1 + u
gen y2 = 10 + x1 + 2*x2 + u
summ

// part c
reg y1 x1

// part d
reg y2 x1

// part e
reg y2 x1 x2

// part g
reg x2 x1
predict x2a, resid

// part h - outcome y2 using residualized version of x2
gen y2a = 10 + x1 + 2*x2a + u
reg y2a x1
reg y2a x1 x2a

// part i - manually calculate the population se(b1) but
// use sample variation in X in place of population variation in X
summ x1
local varx1 r(Var)
local nobs r(N)
display sqrt(1/((`nobs'-1)*(`varx1')))
// compare to se(b1) in sample:
reg y1 x1
display _se[x1]

// part j
clear
drawnorm x1 x2 u, n(10000) 
gen y1 = 10 + x1 + u
sum x1

local varx1 r(Var)
local nobs r(N)
display sqrt(1/((`nobs'-1)*(`varx1')))
display _se[x1]


// ***********
// Question 3
// ***********
clear
matrix C = (1, .5 , 0 \ .5, 1, 0 \ 0, 0, 1)
drawnorm x1 x2 u, n(100) corr(C)
corr
gen y2 = 10 + x1 + 2*x2 + u

summ y2, detail

// part b
ssc install tddens
*tddens x1 x2
// also look at:
*scatter x1 x2

// part c
reg y2 x1

// part d
reg y2 x1 x2

// part e - "regression anatomy"
reg x2 x1
predict uhat, resid
reg y2 uhat

//alternative calculation
//option below obtains the covariance between y and uhat
corr y2 uhat, covar
local covyu `r(cov_12)'
summ uhat
local varu `r(Var)'
display `covyu' / `varu'

// part f - OVB formula
reg y2 x1 x2
local x1long = _b[x1]
local x2long = _b[x2]

reg y2 x1
local x1short = _b[x1]

reg x2 x1
local pi = _b[x1]

display `x1long'
display `x2long'
display `pi'
display `x1long' + (`x2long'*`pi')
// compare to:
display `x1short'
