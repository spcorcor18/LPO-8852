

// *********************************************************
// Simulated data -- example 1
// Last updated: September 18, 2024
// *********************************************************

// Two groups (N=250 per group) - illustration of between vs
// within group variation and xtsum

clear
set obs 250
gen group = 1
gen x = rnormal(500,150)
set obs 500
replace group = 2 if group==.
replace x = rnormal(1200,200) if x==.

xtset group
xtsum x

summ x
tabstat x, by(group)

summ x if group==1
local m1=round(r(mean))

summ x if group==2
local m2=round(r(mean))

summ x
local mo=round(r(mean))

twoway (histogram x if group==1, fcolor(navy%50) lcolor(navy%50)) ///
	   (histogram x if group==2, fcolor(forest_green%50) lcolor(forest_green%50)), ///
	   legend(order(1 "Group 1" 2 "Group 2")) ///
	   xline(`m1', lpattern(dash)) xline(`m2', lpattern(dash))  ///
	   xline(`mo', lpattern(dash)) ///
	   text(0.003 `m1' "xbar1=`m1'") text(0.003 `m2' "xbar2=`m2'") ///
	   text(0.003 `mo' "xbar=`mo'")
	   

// *********************************************************
// Simulated data -- example 2
// *********************************************************

// Simulated panel data to show xtsum calculations
// and different estimates of FE, constant term

// for reference on generating simulated panel data see
// https://blog.stata.com/2014/07/18/how-to-simulate-multilevellongitudinal-data/

clear all
set seed 6534

// create 3 classrooms with different effects (32, 54, 68)
set obs 3
gen classroom = _n
gen u_i = round(rnormal(60,15),1)
list

// create 3 students per classroom with random student effect 
expand 3
list
bysort classroom: gen studentid=_n 
gen e_ij = round(rnormal(0,15),1)
list

// outcome is 5 + classroom effect + student effect 
gen y = 5 + u_i + e_ij
list

// within classroom means - based on both classroom effect and student effects
// (35, 51, 59). Note in small sample of 3 the mean student effect is not zero, 
// so this becomes part of the classroom mean 
egen ym = mean(y), by(classroom)
list

// see what xtsum calculates 
xtset classroom studentid 
xtsum y 
sum y
// 48.333 is the grand mean (yg)
// 15.058 is the overall sd
// 12.220 is the between sd
// 10.712 is the within sd

gen yg=r(mean)

// show how between sd is calculated (use only 1 obs per school)
gen  temp2=(ym-yg)^2 if studentid==1
egen temp3=sum(temp2)
replace temp3=sqrt((1/2)*temp3)
summ temp3
// 12.022 is the between sd

drop temp2 temp3

// show how within sd is calculated
gen dy = y-ym
gen temp2=dy^2
egen temp3=sum(temp2)
replace temp3=sqrt((1/8)*temp3)
summ temp3
// 10.712 is the within sd

drop temp2 temp3

// FE regressions
// regress y on classroom dummies
reg y i.classroom
// the constant term is the within-group mean for the first classroom
// (the omitted classroom, an arbitrary group)

// areg y with classroom absorbed (followed by predict, absorbed variable)
areg y, absorb(classroom)
predict uhat, d
table uhat
summ uhat if studentid==1
drop uhat 
// the constant term is the grand mean; the predicted classroom effects are
// deviations from the grandmean (-13.333, 2.667, 10.667). Mean of FE is zero.

// xtreg, fe - within transformation (followed by predict, fixed error
// component)
xtreg y, i(classroom) fe
predict uhat2, u
table uhat2
summ uhat2 if studentid==1
drop uhat2
// the constant term is the grand mean; the predicted fixed effects are 
// deviations from the grandmean. Mean of FE is zero.



	   