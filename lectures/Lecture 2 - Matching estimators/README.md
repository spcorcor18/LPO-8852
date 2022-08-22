# Lecture 2: Matching estimators

## Topics covered:

* Review of concepts: potential outcomes and treatment effects, ATE vs. ATT, selection bias
* Subclassification as a method of estimating treatment effects: grouping treated and untreated observations into strata, calculating differences within strata, and taking a weighted average across strata.
* The conditional independence assumption (CIA) and methods relying on selection on observables.
* The role of common support
* Matching methods: exact matching, approximate matching (e.g., nearest neighbor)
* The propensity score: use in weighting and matching

## Video resources

[Stata introduction to teffects Part 1](https://www.youtube.com/watch?v=p578jxAPJT4) - uses birthweight and smoking example

[Stata introduction to teffects Part 2](https://www.youtube.com/watch?v=v4l3F3BrtlQ)

[Stata nearest neighbor matching with teffects](https://www.youtube.com/watch?v=mEqwQ0FI2Vg) - uses birthweight and smoking example

[Stata propensity score matching with teffects](https://www.youtube.com/watch?v=hnyh1cUFiOE) - uses birthweight and smoking example

[Stata inverse probability weighting with teffects](https://www.youtube.com/watch?v=fmnkEmlJPOU) - uses birthweight and smoking example

[Gary King lecture on matching](https://www.youtube.com/watch?v=tvMyjDi4dyg) - great lecture on matching methods and their connection to RCTs and blocked randomization. Covers nearest neighbors, coarsened exact matching, and propensity score matching. Also gives an overview of the problems of using propensity scores for matching.

[Gary King on why propensity scores should not be used for matching](https://www.youtube.com/watch?v=rBv39pK1iEs)

[Chris Curran on psmatch2 in Stata](https://www.youtube.com/watch?v=7RT8zFC5Rac) - uses an ECLS-K example

[Logic of inverse probability weighting](https://www.youtube.com/watch?v=VJhLaOdpUv0) - from UPenn

## Syllabus readings:

* :star: MM chapter 2 (especially pp. 47-59)
* :star: MIX, *Matching and Subclassification*
* :star: MW chapter 12
* :star: Guo & Fraser (2015), *Propensity Score Analysis: Statistical Methods and Applications, 2e*
* HK chapter 14
* Caliendo, M., & Kopeinig, S. (2008). Some Practical Guidance for the Implementation of Propensity Score Matching. *Journal of Economic Surveys*, 22(1), 31–72. https://onlinelibrary.wiley.com/doi/pdf/10.1111/j.1467-6419.2007.00527.x
* Imbens, G. W. (2015). Matching Methods in Practice: Three Examples. *Journal of Human Resources*, 50(2), 373–419. https://doi.org/10.3368/jhr.50.2.373 
* Morgan, S. L., & Harding, D. J. (2006). Matching Estimators of Causal Effects: Prospects and Pitfalls in Theory and Practice. *Sociological Methods & Research*, 35(1), 3–60. https://doi.org/10.1177/0049124106289164

## Other references:

* [U of Wisconsin article on propensity score matching in Stata using teffects](https://www.ssc.wisc.edu/sscc/pubs/stata_psmatch.htm)

## Example studies:

[List of example studies and other matching references](https://github.com/spcorcor18/LPO-8852/blob/main/lectures/Lecture%202%20-%20Matching%20estimators/Example%20studies%20-%20matching.md)
