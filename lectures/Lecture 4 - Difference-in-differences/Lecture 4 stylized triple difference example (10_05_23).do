

// ****************************************************************************
// Lecture 4 stylized triple difference example
// Last updated: October 5, 2023
// ****************************************************************************

	cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 4 - Difference-in-differences"

	set more off
	clear all
	use https://github.com/spcorcor18/LPO-8852/raw/main/data/Stylized%20triple%20diff%20example.dta, clear

// ****************************************************************************
// This stylized example corresponds to the one in the Lecture 4 notes on triple
// difference. The dataset above consists of the following variables:
// 
// y = outcome
//
// time = time (1-4)
//
// post = 1 in "post" (treatment) period. Here, periods 3 and 4
//
// evertreatgroup = 1 for the "ever treated" group. NOTE: only the "primary"
//    group is *actually* ever treated. The "secondary" group where 
//    evertreatgroup=1 corresponds to the group that we believe follows the
//    same time trend as the actual ever treated group. They may be households
//    in the same village who were not treated, or kids in the same school (but
//    different grade) who were not treated, etc.
//
// primary = 1 for the "primary" groups. These are the groups that would be 
//    used in the standard difference-in-difference. The "secondary" groups are
//    those that we believe follow the same time trends as the primary groups.
//	  The secondary groups provide the triple difference.
//
// id = unique id for combinations of evertreatgroup + primary (for plotting)
// ****************************************************************************


// ****************************************************************************
// For the moment forget about the triple diff and "secondary" group. Just 
// estimate the difference-in-difference for the primary group:
// ****************************************************************************
	
	reg y i.evertreatgroup##i.post if primary==1
	
	// Interpretation:
	// constant (+9): the mean outcome in the "pre" period for the never treated
	// post (+4): the change in mean outcome pre-post for the never treated
	// evertreatedgroup (+8): the difference between the ever treated and never
	//   treated in the "pre" period
	// evertreatedgroup*post (+10): the *differential* change pre-post for the
	//   ever treated vs. never treated. This is the difference in difference.
	
	// Below: time trends are clearly not the same for the two groups, pre-
	// treatment. The DID estimator would be biased since it uses the post
	// time trend of the untreated as what would have happened to the treated
	// had treatment not occurred.
	
	xtset id time
	xtline y if primary==1, overlay xline(2.5) legend(label(1 "Never treated") ///
	   label(2 "Ever treated")) recast(connected) plot1opts(mlabel(y) mlabposition(12)) ///
	   plot2opts(mlabel(y) mlabposition(12))
	
	// FYI: what does the event study look like?
	// cannot estimate standard errors here because there is only one obs per
	// group per year, but this shows a non zero coefficient on the period1*
	// evertreated interaction.
	
	reg y i.evertreatgroup##ib2.time if primary==1
	
	// FYI: using eventdd - first create timetoevent (must be missing for
	// never treated). Gives same result as above, with event study graph.
	
	gen timetoevent = time - 3
	replace timetoevent=. if evertreatgroup==0
	eventdd y i.evertreatgroup i.time if primary==1, timevar(timetoevent)


// ****************************************************************************
// Now the triple diff. First, view the data by year for the four groups:
// ****************************************************************************

	xtline y , overlay xline(2.5) legend(label(1 "Never treated (primary)") ///
	   label(2 "Ever treated (primary)") label(3 "Never treated (secondary)") ///
	   label(4 "Ever treated (secondary)")) recast(connected) ///
	   plot1opts(mlabel(y) mlabposition(12)) plot2opts(mlabel(y) mlabposition(12)) ///
	   plot3opts(mlabel(y) mlabposition(12)) plot4opts(mlabel(y) mlabposition(12))
		

   // Triple diff regression:
   
   reg y i.post i.evertreatgroup i.post#i.evertreatgroup i.primary i.post#i.primary ///
      i.evertreatgroup#i.primary i.post#i.evertreatgroup#i.primary
		
   // Interpretation:
   // constant (34): the mean outcome in the "pre" period for the never treated 
   //   (secondary)
   //
   // evertreatedgroup (+10): the difference between the ever treated (secondary)
   //   and never treated (secondary) in the "pre" period
   //
   // post (+4): the change from pre to post for the never treated (secondary)
   //
   // post*evertreatedgroup (+4): the *differential* change from pre to post for
   //   the ever treated, secondary (vis a vis the never treated, secondary).
   //   Think of this as the diff-in-diff for the secondary group.
   //
   // primary (-25): the difference in the "pre" period between the never treated
   //   (primary) and never treated (secondary).
   //
   // post*primary (0): the *differential* change from pre to post for the never
   //   treated (primary) and never treated (secondary). This is zero since
   //   these groups have the same time trend (by design for this example).
   //
   // evertreatedgroup*primary (-2): if -25 was the difference in the pre period
   //   between the never treated (primary) and never treated (secondary), this
   //   is how *different* the difference is in the pre period betwen the ever
   //   treated (primary) and ever treated (secondary).
   //   
   // post*evertreatgroup*primary (6): THIS IS THE TRIPLE DIFFERENCE. If post*
   //   evertreatedgroup is the diff-in-diff for the secondary group, then this
   //   is how *different* the diff-in-diff is for the primary group.
   
   
   // Note the syntax below will produce the same results

      reg y i.evertreatgroup##i.post##i.primary
		
		
// ****************************************************************************
// Compare the regression results to the tables of means below
// ****************************************************************************

/* 
Primary:
          | Pre | Post | diff
----------|------------------
Treated   | 17  | 31   | 14
Untreated |  9  | 13   | 4
----------|-----|------|-----
Diff      |  8  | 18   | 10

Secondary:
          | Pre | Post | diff
----------|------------------
Treated   | 44  | 52   | 8
Untreated | 34  | 38   | 4
----------|-----|------|-----
Diff      | 10  | 14   | 4

*/
