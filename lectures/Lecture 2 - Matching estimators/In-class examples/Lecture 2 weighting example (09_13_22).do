
// Lecture 2 weighting example
// Last updated: September 13, 2022

// Create dataset with counts in each group
clear
input group male treat y num
 1 1 1 1 60
 2 1 1 0 20
 3 0 1 1 12
 4 0 1 0 8
 5 1 0 1 350
 6 1 0 0 150
 7 0 0 1 275
 8 0 0 0 225
 end

// Expand from aggregate to individual data 
expand num
sort group
tabulate male treat, row

// naive difference in means (9.5 ppt treatment effect)
ttest y, by(treat)

// conditional on male, treatment effect is constant (5 ppt)
ttest y if male==1, by(treat)
ttest y if male==0, by(treat)

// treatment group is more male than comparison group (0.8 vs 0.5)
tabstat male,by(treat)

// this is why the naive difference in means differs from the true
// treatment effect. Even among the untreated, males have higher
// mean y (0.7 for males and 0.55 for females)
tabstat y if treat==0, by(male)

// the naive estimator is the true effect (5 ppts) plus selection
// bias (4.5 ppts). The selection bias is the difference in mean 
// y in the untreated state between the treated and untreated groups.
// Here the mean y0 is 0.7 for men and 0.55 for women:
di ((0.8*0.7)+(0.2*0.55))-0.625

// Re-weight observations in the untreated group to "look like" the treated
// The weight is 80/500 (0.16) for untreated men
// The weight is 20/500 (0.04) for untreated women
gen wt = (80/500) if treat==0 & male==1
replace wt = (20/500) if treat==0 & male==0
replace wt = 1 if treat==1

// incidentally the above weights for the untreated are P(X)/(1-P(X)) where 
// P(X) is the probably of treatment given X (male)
summ treat if male==1
display r(mean)/(1-r(mean))
summ treat if male==0
display r(mean)/(1-r(mean))

// compare "balance" in treated and (weighted) untreated groups
tabstat male [weight=wt], by(treat)

// get mean y for each group using weights
tabstat y [weight=wt], by(treat)
// the difference between the two groups is 0.05 (the true treatment effect)

// NOTE regression controlling for male will yield the same result
reg y i.treat i.male

// inverse probability weighting gives the same result for ATE, ATT
teffects ipw (y) (treat male), ate
teffects ipw (y) (treat male), atet

// doing IPW manually gives the same result
logit treat male
predict phat
// weights for ATT
gen ipw=1 if treat==1
replace ipw=phat/(1-phat) if treat==0
reg y treat [pw=ipw]
table ipw male

// weights for ATE
gen ipw2=1/phat if treat==1
replace ipw2=1/(1-phat) if treat==0
reg y treat [pw=ipw2]
table ipw2 male
