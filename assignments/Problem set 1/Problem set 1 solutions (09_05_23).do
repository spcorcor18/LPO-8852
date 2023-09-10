
cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Problem sets\Problem set 1 - Potential outcomes"
capture log close
log using PS1.txt, text replace


// ***************************************************************
//
// Problem set 1
// Last updated: September 5, 2023
//
// ***************************************************************

// *********************************
// Question 1
// *********************************

	// Set up data
	clear all
	set seed 3791
	set obs 100
	gen x  = 1
	gen y0 = 25
	gen y1 = 35
	gen d  = runiform()<=0.20
	set obs 250
	replace x = 2 if d==.
	replace y0= 50 if d==.
	replace y1= 90 if d==.
	replace d = runiform()<=0.80 if d==.
	set obs 450
	replace x = 3 if d==.
	replace y0= 40 if d==.
	replace y1= 60 if d==.
	replace d = runiform()<=0.50 if d==.
	set obs 600
	replace x = 4 if d==.
	replace y0= 30 if d==.
	replace y1= 45 if d==.
	replace d = runiform()<=0.40 if d==.
	table x
	tabstat d, by(x)


// *********************************
// 1a - treatment effects
// *********************************

	// Individual treatment effects
	gen te = y1 - y0
	// ATE
	summ te
	scalar ate=r(mean)
	// ATT
	summ te if d==1
	scalar att=r(mean)
	// ATU
	summ te if d==0
	scalar atu=r(mean)

	// ATE is a weighted average of ATT and ATU
	qui summ d
	scalar p=r(mean)
	display (p*att)+((1-p)*atu)

	// As seen above, ATT > ATE > ATU. The last line above demonstrates that
	// ATE = p*ATT + (1-p)*ATU
	

// *********************************
// 1b - differences in student types
// *********************************

	// Treatment effects and potential outcomes by type
	tabstat te, by(x)
	tabstat y0, by(x)
	// Probability of treatment varies by type
	tabstat d, by(x)
	// Treated are most likely to be group 2, followed by 3
	tabulate x if d==1
	
	// As shown above, there are heterogeneous treatment effects, wtih group
	// 2 having the largest te=40, and group 1 having the smallest te=10. The
	// groups also differ by potential outcomes, with y0 varying from 25 
	// (group 1) to 50 (group 2). The probability of treatment also varies,
	// from 27% of group 1 treated to 80% of group 2. By design (for sake of
	// this example), the group with the largest expected effect from treatment
	// is also the one most likely to be treated. There is likely to be positive
	// selection bias in the naive simple difference estimator in that the mean
	// y0 is larger for the groups most likely to be treated (2 and 3). There 
	// is also likely to be positive heterogeneous treatment effect bias, since
	// the treated tend to have higher tes on average than the untreated. 
	
	// Another way to see the latter points:
	tabstat y0, by(d)
	tabstat te, by(d)

	
// *********************************
// 1c - simple diff in means
// *********************************
		
	// Observed Y ("switching equation")
	gen y=(d*y1) + (1-d)*y0

	// Simple difference in means--will have selection bias 
	ttest y, by(d)
	scalar sdo = r(mu_2) - r(mu_1)
	display sdo

	// Selection bias: difference in y0 for D=1 and D=0 groups
	qui ttest y0, by(d)
	scalar selbias = r(mu_2) - r(mu_1)
	display selbias
	
	// Heterogeneous treatment effect bias: difference in te for D=1 and D=0
	// NOTE: ATT, ATU, and ATE were calculated in part 1a
	qui summ d
	scalar ptreat=r(mean)
	scalar htebias = (1-ptreat)*(att-atu)
	display htebias
	
	// Note that SDO = ATE + selbias + htebias
	display sdo - selbias - htebias
	display ate
	
	
// **************************************************************
// 1d - calculate diff in means separately by group, then average
// **************************************************************
	
	qui ttest y if x==1, by(d)
	scalar te1 = r(mu_2) - r(mu_1)

	qui ttest y if x==2, by(d)
	scalar te2 = r(mu_2) - r(mu_1)

	qui ttest y if x==3, by(d)
	scalar te3 = r(mu_2) - r(mu_1)

	qui ttest y if x==4, by(d)
	scalar te4 = r(mu_2) - r(mu_1)

	// simple average of these four estimates
	di (te1 + te2 + te3 + te4) / 4

	// The average te across these four groups is 21.25, which differs a bit
	// from the simple difference in outcomes (32.08), known ATT (25.8), and
	// known ATE (22.1). It is arguably better than the simple differnce since
	// it compares treated and untreated within group. All units with the same
	// group have the same y0, so this is removing the selection bias.
	

// *****************************************************************
// 1e - calculate a weighted average of the above group differences
// *****************************************************************

	// weighted average of these four estimates (using # in each type as weights)
	di ((te1*100)+(te2*150)+(te3*200)+(te4*150))/600
	di ate
	
	// This is 22.1, equal to the ATE. This makes sense as we are calculating
	// the ATE separately for each group (without concern for selection bias)
	// and then weighting each group according to the number of units in each
	// group. This improves on the mean in part d since the groups vary in size.
	// The straight average of the four groups weights these groups equally.
		

// *****************************************************************
// 1f - OLS regression controlling for group/type
// ****************************************************************

	// regression of y on d controlling for type
	reg y d i.x

	// The coefficient on d is 20.9, again different from all of the above
	// estimates and known ATT and ATE. A regression like this provides a
	// variance-weighted average treatment effect, in which groups with more
	// treatment variance get more weight.
	

// *****************************************************************
// 1g - What if d were randomly assigned? Would this guarantee that
// the SDO would equal the ATE?
// *****************************************************************

	// Randomization will eliminate selection bias and heterogeneous treatment
	// effect bias in EXPECTATION, but it is possible that the SDO will differ
	// from the ATE simply due to chance (sampling error).
	
	gen drand  = runiform()<=0.50
	gen y2 = (drand*y1) + ((1-drand)*y0)
	ttest y2, by(drand)
	
	// In the above random assignment of d, the simple difference in means is 
	// 23.9. This is not too far from the ATE, but it is not exactly right.

	

// *********************************
// Question 3
// *********************************
	
	// Set up data
	use https://github.com/spcorcor18/LPO-8852/raw/main/data/LUSD4_5.dta, clear
	
	// NOTE: keep grade 5 and year 2005 as instructed
	keep if grade==5 & year==2005
	// NOTE: I am keeping only cases with nonmissing mathz, totexp, and econdis,
	// the three variables used below. (Not doing so will create a small problem
	// below where the long and short regressions have different numbers of 
	// observations.
	keep if mathz~=. & totexp~=. & econdi~=.
	
	// part a
	reg mathz totexp
	scalar b=_b[totexp]

	summ totexp
	display b*r(sd)

	// part d
	// "long" regression
	reg mathz totexp econdis
	scalar gamma=_b[econdis]
	scalar b = _b[totexp]

	// "auxiliary regression"
	reg econdis totexp
	scalar pi1=_b[totexp]

	// "short" regression
	reg mathz totexp
	display b + (pi1*gamma) /* this should be the same as the OLS slope */

	// part e
	// get residual from regressing totexp on econdis
	reg totexp econdis
	predict uhat, resid

	// regression anatomy formula: b1 = COV(Y,RESID)/VAR(RESID)

	corr mathz uhat, cov
	scalar cov=r(cov_12)
	display cov
	summ uhat
	scalar vuhat=r(Var)
	display uhat
	display cov/vuhat

	reg mathz totexp econdis

	// part f
	reg mathz totexp econdis mathz_1 lep


	
// Close log and convert to PDF
log close
translate PS1.txt PS1.pdf, translator(txt2pdf) cmdnumber(off) logo(off) header(off) replace
