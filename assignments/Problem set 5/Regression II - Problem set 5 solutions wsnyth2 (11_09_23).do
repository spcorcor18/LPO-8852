
// ***********************************************************************
// LPO-8852 Problem set 5 solutions [using synth2]
// Last updated: November 9, 2023
// ***********************************************************************

clear all
set more off
capture log close
set linesize 85

cd "D:\corcorsp\My Files\Home Folder"
*global db  "C:\Users\corcorsp\Dropbox"
*cd "$db\_TEACHING\Regression II\Problem sets\Problem set 5 - Synthetic control"
global datetag: display %td!(NN!_DD!_YY!) date(c(current_date), "DMY")

log using "PS5_solutions_wsynth2.txt", text replace nomsg

// ***********************************************************************
// LPO-8852 Problem set 5 solutions
// Last updated: November 9, 2023
// ***********************************************************************

// ***********************************************************************
// Enrollment data
// ***********************************************************************

// *****************
// Setup
// *****************

	use https://github.com/spcorcor18/LPO-8852/raw/main/data/nys_data_enroll.dta, clear

	// There are 276 school districts x 14 years = 3864 observations
	// Syracuse is id==238

	tabulate year, miss
	unique district
	unique id
	tabulate id if substr(district,1,4)=="SYRA"

	// District name is too long for use with synth command; try creating a
	// truncated version. Also make sure it doesn't vary over time within id.
	
	by id: gen temp=district_name if _n==1
	egen district_name2=mode(temp), by(id)
	
	gen district2=proper(substr(district_name2,1,12))
	labmask id, values(district2)
	drop temp district_name2
	
	xtset id year
	
	// ulocal07 codes 11, 12, and 13 are large, midsize, and small cities

	tabulate ulocal07
	tabulate local07

	// Note: use the dataset's target_donor flag, though not 100% clear
	// how it is defined. The paper says the restricted donor pool includes
	// Rochester, Buffalo, Yonkers, and the districts the NYS Association of
	// Small City School Districts Defines as "small city" districts. Their
	// n=22 total, although the NYSA says there are 57 small city dists.
	// https://www.nyssba.org/clientuploads/nsbmx/forms/small_city_districts.pdf

	tabulate year target_donor
	tabulate year small_index
	

// ******************************************************
// synth2 - enrollment
// ******************************************************

// ***********************************************************************
// Specification 2 - full donor pool
// ***********************************************************************

	synth2 no_enroll_k12 no_enroll_k12(1998) no_enroll_k12(2002) ///
		no_enroll_k12(2007) p_lunch p_black p_hispanic, ///
		trunit(238) trperiod(2008) mspeperiod(1998(1)2007) ///
		placebo(unit) loo savegraph(spec2_, replace) frame(espec2)

	matrix ew2  = e(U_wt)
	matrix ebal2= e(bal)

	
// ***********************************************************************
// Specification 2 - restricted donor pool
// ***********************************************************************

	preserve
	keep if target_donor==1

	synth2 no_enroll_k12 no_enroll_k12(1998) no_enroll_k12(2002) ///
		no_enroll_k12(2007) p_lunch p_black p_hispanic, ///
		trunit(238) trperiod(2008) mspeperiod(1998(1)2007) ///
		placebo(unit) loo savegraph(spec2r_, replace) frame(espec2r)

	matrix ew2r  = e(U_wt)
	matrix ebal2r= e(bal)
	restore
		
		
// ***********************************************************************
// Specification 4 - full donor pool
// ***********************************************************************

	synth2 no_enroll_k12 no_enroll_k12(1998(1)2006) no_enroll_k12(2007) ///
		p_lunch p_black p_hispanic, ///
		trunit(238) trperiod(2008) mspeperiod(1998(1)2007) ///
		placebo(unit) loo savegraph(spec4_, replace) frame(espec4)

	matrix ew4  = e(U_wt)
	matrix ebal4= e(bal)

	
// ***********************************************************************
// Specification 4 - restricted donor pool
// ***********************************************************************

	preserve
	keep if target_donor==1

	synth2 no_enroll_k12 no_enroll_k12(1998(1)2006) no_enroll_k12(2007) ///
		p_lunch p_black p_hispanic, ///
		trunit(238) trperiod(2008) mspeperiod(1998(1)2007) ///
		placebo(unit) loo savegraph(spec4r_, replace) frame(espec4r)

	matrix ew4r  = e(U_wt)
	matrix ebal4r= e(bal)
	restore
		
		
// ***********************************************************************
// Graduation data
// ***********************************************************************

// *****************
// Setup
// *****************

	use https://github.com/spcorcor18/LPO-8852/raw/main/data/nys_data_grad.dta, clear

	// There are 237 school districts x 10 years = 2370 observations
	// Syracuse is id==205

	table year
	unique district
	unique id
	tabulate id if substr(district,1,4)=="SYRA"

	// District name is too long for use with synth command; try creating a
	// truncated version. Also make sure it doesn't vary over time within id.
	
	by id: gen temp=district_name if _n==1
	egen district_name2=mode(temp), by(id)
	
	gen district2=proper(substr(district_name2,1,12))
	labmask id, values(district2)
	drop temp district_name2
	
	xtset id year
	
	// ulocal07 codes 11, 12, and 13 are large, midsize, and small cities

	tabulate ulocal07
	tabulate local07

	// Note: use the dataset's target_donor flag, though not 100% clear
	// how it is defined. See earlier note.

	tabulate year target_donor
	tabulate year small_index


// ******************************************************
// synth2
// ******************************************************

// ***********************************************************************
// Specification 2 - full donor pool
// ***********************************************************************

	synth2 grad grad(2001) grad(2004) grad(2007) ///
		p_lunch p_black p_hispanic, ///
		trunit(205) trperiod(2008) mspeperiod(2001(1)2007) ///
		placebo(unit) loo savegraph(gspec2_, replace) frame(gspec2)

	matrix gw2  = e(U_wt)
	matrix gbal2= e(bal)

	
// ***********************************************************************
// Specification 2 - restricted donor pool
// ***********************************************************************

	preserve
	keep if target_donor==1

	synth2 grad grad(2001) grad(2004) grad(2007) ///
		p_lunch p_black p_hispanic, ///
		trunit(205) trperiod(2008) mspeperiod(2001(1)2007) ///
		placebo(unit) loo savegraph(gspec2r_, replace) frame(gspec2r)

	matrix gw2r  = e(U_wt)
	matrix gbal2r= e(bal)
	restore
	
	
// ***********************************************************************
// Specification 4 - full donor pool
// ***********************************************************************
	
	synth2 grad grad(2001(1)2006) grad(2007) ///
		p_lunch p_black p_hispanic, ///
		trunit(205) trperiod(2008) mspeperiod(2001(1)2007) ///
		placebo(unit) loo savegraph(gspec4_, replace) frame(gspec4)

	matrix gw4  = e(U_wt)
	matrix gbal4= e(bal)


// ***********************************************************************
// Specification 4 - restricted donor pool
// ***********************************************************************

	preserve
	keep if target_donor==1

	synth2 grad grad(2001(1)2006) grad(2007)  ///
		p_lunch p_black p_hispanic, ///
		trunit(205) trperiod(2008) mspeperiod(2001(1)2007) ///
		placebo(unit) loo savegraph(gspec4r_, replace) frame(gspec4r)

	matrix gw4r  = e(U_wt)
	matrix gbal4r= e(bal)
	restore
	
	
	matrix dir
	
	// can add: cutoff(#) for discarding fake treatment units, show(#) to show units with largest ratio

frame change espec2
save espec2.dta, replace
frame change espec2r
save espec2r.dta, replace
frame change espec4
save espec4.dta, replace
frame change espec4r
save espec4r.dta, replace

frame change gspec2
save gspec2.dta, replace
frame change gspec2r
save gspec2r.dta, replace
frame change gspec4
save gspec4.dta, replace
frame change gspec4r
save gspec4r.dta, replace
	
frame change default
log close

