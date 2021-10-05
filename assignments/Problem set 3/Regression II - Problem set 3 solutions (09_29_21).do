
// ***********************************************************************
// LPO-8852 Problem set 3 solutions
// Last updated: September 29, 2021
// ***********************************************************************

clear all
set more off
capture log close
set linesize 80

global db  "C:\Users\corcorsp\Dropbox"
cd "$db\_TEACHING\Regression II\Problem sets\Problem set 3 - DD"
global datetag: display %td!(NN!_DD!_YY!) date(c(current_date), "DMY")

log using "PS3_solutions_$datetag.txt", text replace nomsg

// ***********************************************************************
// LPO-8852 Problem set 3 solutions
// Last updated: September 29, 2021
// ***********************************************************************

// ****
// (a)
// ****
// Get data
use https://github.com/spcorcor18/LPO-8852/raw/main/data/NYCbkfastlunch.dta, clear
summ bkfast_part lunch_part


// ****
// (b)
// ****
// Set panel
xtset schoolid year
xtdescribe


// ****
// (c)
// ****
// Simple DD for limited sample (those who adopt BIC in 2010, or not at all)
tabulate year bic2010
gen byte ansample=0
replace  ansample=1 if bic2010==1 | bicever==0

gen	post2010=(year>=2010 & year~=.)

_eststo bk1: reg bkfast_part i.bic2010##i.post2010 if ansample
_eststo lu1: reg lunch_part i.bic2010##i.post2010 if ansample


// ****
// (d)
// ****
// Descriptive statistics for BIC 2010 adopters and those who never adopt BIC
sum totalenrollment- pctfemale free1 redu1 if ansample & bic2010==0, sep(0)
sum totalenrollment- pctfemale free1 redu1 if ansample & bic2010==1, sep(0)


// ****
// (e)
// ****
// Simple DD with covariates
global covars "pctell pctsped totalenrollment pctasian pctblack pcthisp"
global covars "$covars pctfemale free1 redu1"

_eststo bk2: reg bkfast_part i.bic2010##i.post2010 $covars if ansample
margins bic2010#post2010
marginsplot, xdim(post2010)  name(parte,replace)
graph export parte.pdf, name(parte) as(pdf) replace

_eststo lu2: reg lunch_part i.bic2010##i.post2010 $covars if ansample


// ****
// (f)
// ****
// Simple DD with linear time trend
gen time=year-2010
label var time "linear time trend (0 = 2010)"

_eststo bk3: reg bkfast_part i.bic2010##i.post2010 time if ansample
_eststo lu3: reg lunch_part i.bic2010##i.post2010 time if ansample

_eststo bk4: reg bkfast_part i.bic2010##i.post2010 $covars time if ansample
_eststo lu4: reg lunch_part i.bic2010##i.post2010 $covars time if ansample


// ****
// (g)
// ****
// Simple DD with year effects
_eststo bk5: reg bkfast_part i.bic2010##i.post2010 i.year if ansample
_eststo lu5: reg lunch_part i.bic2010##i.post2010 i.year if ansample

_eststo bk6: reg bkfast_part i.bic2010##i.post2010 $covars i.year if ansample
_eststo lu6: reg lunch_part i.bic2010##i.post2010 $covars i.year if ansample


// ****
// (h)
// ****
// Two-way fixed effects model
_eststo bk7: xtreg bkfast_part i.bic2010##i.post2010 i.year $covars  if ansample, fe
_eststo lu7: xtreg lunch_part i.bic2010##i.post2010 i.year $covars  if ansample, fe


// ****
// (i)
// ****
// Event study using xtreg and interaction of treatment and individual years
_eststo bk8: xtreg bkfast_part i.bic2010##ib2009.year $covars  if ansample, fe
coefplot bk8, vertical keep(1.bic2010#*.year) name(parti)
graph export parti.pdf, name(parti) as(pdf) replace

_eststo lu8: xtreg lunch_part i.bic2010##ib2009.year $covars  if ansample, fe


// ****
// (j)
// ****
// Event study using eventdd
* ssc install eventdd
* ssc install matsort
gen timetoevent=year-2010 if bic2010==1
eventdd bkfast_part $covars i.year if ansample, method(fe) timevar(timetoevent) ci(rcap) 
graph export partj.pdf, replace as(pdf)


// ****
// (k)
// ****
// Two-way fixed effects model with full sample of schools (variable timing)
tabulate year bicpost
_eststo bk9: xtreg bkfast_part i.bicpost i.year, fe
_eststo bk10: xtreg bkfast_part i.bicpost i.year $covars i.year, fe

_eststo lu9: xtreg lunch_part i.bicpost i.year, fe
_eststo lu10: xtreg lunch_part i.bicpost i.year $covars i.year, fe


// ****
// (l)
// ****
// Event study using eventdd
// first find year of BIC implementation
egen temp=min(year) if bicpost==1, by(schoolid)
egen bicevent=max(temp), by(schoolid)
drop temp timetoevent
// Create new time to event variable based on when school adopted BIC
gen timetoevent=year-bicevent if bicever==1
_eststo bk11: eventdd bkfast_part $covars i.year, method(fe) timevar(timetoevent) ci(rcap) 
graph export partj.pdf, replace as(pdf)

esttab bk* using breakfast_results.csv, csv drop(0.*) replace
esttab lu* using lunch_results.csv, csv drop(0.*) replace
capture log close

graphlog using "PS3_solutions_$datetag.txt",replace keeptex lspacing(1) fwidth(0.8) openpdf


erase "parte.pdf"
erase "parti.pdf"
erase "partj.pdf"
