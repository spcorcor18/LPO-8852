

*** MLDA Regression Discontinuity (based on data from Carpenter and Dobkin 2009)
*** Mastering Metrics Chapter 4
*** Figures 4.2 4.4 4.5
*** Tables 4.1

clear
estimates drop _all
use https://github.com/spcorcor18/LPO-8852/raw/main/data/AEJfigs.dta

// re-center running variable at 21 and define treatment assignment variable
gen age = agecell - 21
gen over21 = agecell >= 21

* Regressions for Figure 4.2.
* linear trend, and linear on each side
* All = all deaths
reg all age over21
predict allfitlin
reg all c.age##i.over21
predict allfitlini
label variable all       "Mortality rate from all causes (per 100,000)"
label variable allfitlin "Mortality rate from all causes (per 100,000)"

* Figure 4.2. 
twoway (scatter all agecell) (line allfitlin agecell if age < 0,  lcolor(black)     lwidth(medthick)) ///
                             (line allfitlin agecell if age >= 0, lcolor(black red) lwidth(medthick medthick)), ///
							 legend(off) yline(91.84137, lpattern(dash)) yline(99.504079, lpattern(dash)) ///
							 text(92.5 21 "91.84") text(100 21 "99.50")

* Figure 4.2. 
twoway (scatter all agecell) (line allfitlini agecell if age < 0,  lcolor(black)     lwidth(medthick)) ///
                             (line allfitlini agecell if age >= 0, lcolor(black red) lwidth(medthick medthick)), ///
							 legend(off) 

							 
* Regressions for Figure 4.4.
* Quadratic, and quadratic on each side
reg all c.age##c.age over21
predict allfitq
reg all c.age##c.age##i.over21
predict allfitqi

label variable allfitqi  "Mortality rate from all causes (per 100,000)"

* Figure 4.4.		 
twoway (scatter all agecell) (line allfitlin allfitqi agecell if age < 0,  lcolor(red black) lwidth(medthick medthick) lpattern(dash)) ///
                             (line allfitlin allfitqi agecell if age >= 0, lcolor(red black) lwidth(medthick medthick) lpattern(dash)), legend(off)


* Regressions for Fig 4.5
* "Motor Vehicle Accidents" on linear, and quadratic on each side
reg mva age over21
predict exfitlin
reg mva c.age##c.age##i.over21
predict exfitqi

reg suicide age over21
predict sufitlin

* "Internal causes" on linear, and quadratic on each side
reg internal age over21
predict infitlin
reg internal c.age##c.age##i.over21
predict infitqi

label variable mva  "Mortality rate (per 100,000)"
label variable infitqi  "Mortality rate (per 100,000)"
label variable exfitqi  "Mortality rate (per 100,000)"

* figure 4.5
twoway (scatter  mva internal agecell) (line exfitqi infitqi agecell if agecell < 21) ///
                                       (line exfitqi infitqi agecell if agecell >= 21), ///
									   legend(off) text(28 20.1 "Motor Vehicle Fatalities") ///
									               text(17 22 "Deaths from Internal Causes")

/*
* Table 4.1
* dummy for first month after 21st birthday
gen exactly21 = agecell >= 21 & agecell < 21.1

* doesn't change 
* drop if agecell>20.99 & agecell<21.01

* Other causes
gen ext_oth = external - homicide - suicide - mva

foreach x in all mva suicide homicide ext_oth internal alcohol {

reg `x' age over21, robust
if ("`x'"=="all"){
	outreg2 over21 using ../Output/table41.xls, replace bdec(2) sdec(2) noaster excel
}
else{
	outreg2 over21 using ../Output/table41.xls, append  bdec(2) sdec(2) noaster excel
}

reg `x' age age2 over21 over_age over_age2, robust
outreg2 over21 using ../Output/table41.xls, append bdec(2) sdec(2) noaster excel

reg `x' age over21 if agecell >= 20 & agecell <= 22, robust
outreg2 over21 using ../Output/table41.xls, append bdec(2) sdec(2) noaster excel

reg `x' age age2 over21 over_age over_age2 if agecell >= 20 & agecell <= 22, robust
outreg2 over21 using ../Output/table41.xls, append bdec(2) sdec(2) noaster excel

}
*/


