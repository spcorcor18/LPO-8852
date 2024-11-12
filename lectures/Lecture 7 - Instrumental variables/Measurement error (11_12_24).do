

clear 
cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 7 - Instrumental variables\Graphics\"
set seed 108
global s=0.25

set obs 300
gen x=runiform()
gen y=x
scatter y x, xlabel(-2(1)2) ylabel(-1(1)2)
reg y x
local a=round(_b[x],0.001)
twoway (lfitci y x) (scatter y x), xlabel(-2(1)2) ylabel(-1(1)2) legend(off) text(1.5 1.25 "Estimated {&beta}=`a'")
*graph export "ex1.png", as(png) replace

// y measured with noise
gen u =rnormal(0,$s)
gen y2=x+u
scatter y2 x, xlabel(-2(1)2) ylabel(-1(1)2)
reg y2 x
local a=round(_b[x],0.001)
twoway (scatter y2 x) (lfitci y2 x) , xlabel(-2(1)2) ylabel(-1(1)2) legend(off) text(1.5 1.25 "Estimated {&beta}=`a'")
*graph export "ex2.png", as(png) replace

// x measured with noise
gen v = rnormal(0,$s)
gen x2=x+v
scatter y x2, xlabel(-2(1)2) ylabel(-1(1)2)
reg y x2
local a=round(_b[x2],0.001)
twoway (scatter y x2) (lfitci y x2) , xlabel(-2(1)2) ylabel(-1(1)2) legend(off) text(1.5 1.25 "Estimated {&beta}=`a'")
*graph export "ex3.png", as(png) replace

// more noise
local s2=$s+0.25
gen w = rnormal(0,`s2')
gen x3=x+w
scatter y x3, xlabel(-2(1)2) ylabel(-1(1)2)
reg y x3
local a=round(_b[x3],0.001)
twoway (scatter y x3) (lfitci y x3) , xlabel(-2(1)2) ylabel(-1(1)2) legend(off) text(1.5 1.25 "Estimated {&beta}=`a'")
*graph export "ex4.png", as(png) replace

// same but using noisy y
scatter y2 x3, xlabel(-2(1)2) ylabel(-1(1)2)
reg y2 x3
local a=round(_b[x3],0.001)
twoway (scatter y2 x3) (lfitci y2 x3) , xlabel(-2(1)2) ylabel(-1(1)2) legend(off) text(1.5 1.25 "Estimated {&beta}=`a'")
*graph export "ex5.png", as(png) replace

// instrument: whether x is above or below 0.5
gen byte z=(x>0.5)
// 1st stage
reg x3 z
predict x3hat, xb
egen meany=mean(y2),by(z)
egen meanx=mean(x3),by(z)
// 2sls
reg y2 x3hat
local a=round(_b[x3hat],0.001)
twoway (scatter y2 x3 if x<=0.5) (scatter y2 x3 if x>0.5) ///
	   (scatter meany meanx if x<=0.5, mcolor(navy*0.75) msize(huge) mlcolor(white)) ///
	   (scatter meany meanx if x>0.5, mcolor(maroon*0.75) msize(huge) mlcolor(white)), ///
	   xlabel(-2(1)2) ylabel(-1(1)2) legend(off) text(1.5 1.25 "Estimated {&beta}=`a'") ///
	   xline(0.5, lpattern(dash))
*graph export "ex6.png", as(png) replace
ivregress 2sls y2 (x3=z), robust

tabstat y2, by(z)
tabstat x3, by(z)
