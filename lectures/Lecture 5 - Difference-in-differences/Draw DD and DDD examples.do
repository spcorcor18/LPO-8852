
cd "C:\Users\corcorsp\Dropbox\_TEACHING\Regression II\Lectures\Lecture 5 - diff in diff"


// Graph 1a: traditional DD picture (version 1)

graph twoway ///
   (function y=3+1.5*x, range(0 20) lcolor(green) lwidth(medthick)) ///
   (function y=7+1.5*x, range(0 10.5) lcolor(midblue) lwidth(thick)) ///
   (function y=11+1.5*x, range(10.5 20) lcolor(midblue) lwidth(thick)), ///
   legend(off) xline(10.5, lpattern(shortdash) lcolor(gs9) lwidth(vthin))  ///
   yscale(range(0 40)) ylabel(none, nogrid) ytitle("") ///
   yline(7, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///
   yline(41, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///
   yline(3, lcolor(green) lwidth(thin) lpattern(shortdash)) ///
   yline(33, lcolor(green) lwidth(thin) lpattern(shortdash)) ///
   xscale(range(0 20)) xlabel(none, nogrid) xtitle("") ///
   text(3 -1 "a", size(medlarge)) text(33 -1 "b", size(medlarge)) ///
   text(7 -1 "c", size(medlarge)) text(41 -1 "d", size(medlarge)) /// 
   title("Traditional DD example") name(graph1a,replace) nodraw
   
// Graph 1b: traditional DD picture (version 2)

graph twoway ///
   (function y=11+1.5*x, range(10.5 20) lcolor(midblue) lwidth(thick)) ///
   (function y=7+1.5*x, range(0 10.5) lcolor(green) lwidth(thick)) ///   
   (function y=7+1.5*x, range(10.5 20) lcolor(green) lwidth(medthick) lpattern(shortdash)) , ///
   legend(off) xline(10.5, lpattern(shortdash) lcolor(gs9) lwidth(vthin))  ///
   yscale(range(0 40)) ylabel(none, nogrid) ytitle("") ///
   yline(7, lcolor(green) lwidth(thin) lpattern(shortdash)) ///
   yline(41, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///
   yline(37, lcolor(green) lwidth(thin) lpattern(shortdash)) ///
   xscale(range(0 20)) xlabel(none, nogrid) xtitle("") ///
   text(41 -1 "d", size(medlarge)) text(37 -1 "b2", size(medlarge)) ///
   text(7 -1 "c", size(medlarge))  ///
   name(graph1b,replace) nodraw
   
graph combine graph1a graph1b, col(1) xsize(4) ysize(6)
graph export "graph1.png", as(png) replace

// Graph 2a: non-parallel trend (version 1)

graph twoway ///
   (function y=3+1.5*x, range(0 20) lcolor(green) lwidth(medthick)) ///
   (function y=7+2.7*x, range(0 10.5) lcolor(midblue) lwidth(thick)) ///
   (function y=11+2.7*x, range(10.5 20) lcolor(midblue) lwidth(thick)), ///
   legend(off) xline(10.5, lpattern(shortdash) lcolor(gs9) lwidth(vthin))  ///
   yscale(range(0 40)) ylabel(none, nogrid) ytitle("") ///
   yline(7, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///
   yline(65, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///
   yline(3, lcolor(green) lwidth(thin) lpattern(shortdash)) ///
   yline(33, lcolor(green) lwidth(thin) lpattern(shortdash)) ///
   xscale(range(0 20)) xlabel(none, nogrid) xtitle("") ///
   text(3 -1 "a", size(medlarge)) text(33 -1 "b", size(medlarge)) ///
   text(7 -1 "c", size(medlarge)) text(65 -1 "d", size(medlarge)) /// 
   title("Non-parallel trend") name(graph2a, replace) nodraw
   
// Graph 2b: non-parallel trend (version 2)

graph twoway ///
   (function y=7+1.5*x, range(0 20) lcolor(green) lwidth(medthick)) ///
   (function y=7+2.7*x, range(0 10.5) lcolor(midblue) lwidth(thick)) ///
   (function y=7+2.7*x, range(10.5 20) lcolor(midblue) lwidth(thick) lpattern(dash)) ///   
   (function y=11+2.7*x, range(10.5 20) lcolor(midblue) lwidth(thick)), ///
   legend(off) xline(10.5, lpattern(shortdash) lcolor(gs9) lwidth(vthin))  ///
   yscale(range(0 40)) ylabel(none, nogrid) ytitle("") ///
   yline(7, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///
   yline(65, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///
   yline(61, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///   
   yline(37, lcolor(green) lwidth(thin) lpattern(shortdash)) ///
   xscale(range(0 20)) xlabel(none, nogrid) xtitle("") ///
   text(37 -1 "b2", size(medlarge)) text(7 -1 "c", size(medlarge)) ///
   text(65 -1 "d", size(medlarge)) text(61 -1 "d2", size(medlarge)) /// 
   name(graph2b, replace) nodraw
   
graph combine graph2a graph2b, col(1) xsize(4) ysize(6)
graph export "graph2.png", as(png) replace

// Graph 3a: third difference example

graph twoway ///
   (function y=3+1.5*x, range(0 20) lcolor(green) lwidth(medthick)) ///
   (function y=7+2.7*x, range(0 10.5) lcolor(midblue) lwidth(thick)) ///
   (function y=11+2.7*x, range(10.5 20) lcolor(midblue) lwidth(thick)) ///
   (function y=60+1.5*x, range(0 20) lcolor(cranberry) lwidth(medthick)) ///
   (function y=67+2.7*x, range(0 20) lcolor(stone) lwidth(thick)), ///   
   legend(off) xline(10.5, lpattern(shortdash) lcolor(gs9) lwidth(vthin))  ///
   yscale(range(0 100)) ylabel(none, nogrid) ytitle("") ///
   yline(7, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///
   yline(65, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///
   yline(3, lcolor(green) lwidth(thin) lpattern(shortdash)) ///
   yline(33, lcolor(green) lwidth(thin) lpattern(shortdash)) ///
   yline(60, lcolor(cranberry) lwidth(thin) lpattern(shortdash)) ///
   yline(90, lcolor(cranberry) lwidth(thin) lpattern(shortdash)) ///
   yline(67, lcolor(stone) lwidth(thin) lpattern(shortdash)) ///
   yline(121, lcolor(stone) lwidth(thin) lpattern(shortdash)) ///
   xscale(range(0 20)) xlabel(none, nogrid) xtitle("") ///
   text(3 -1 "a", size(medlarge)) text(33 -1 "b", size(medlarge)) ///
   text(7 -1 "c", size(medlarge)) text(65 -1 "d", size(medlarge)) /// 
   text(60 -1 "e", size(medlarge)) text(90 -1 "f", size(medlarge)) ///    
   text(67 -1 "g", size(medlarge)) text(121 -1 "h", size(medlarge)) ///       
   title("Third difference (a)") ///
   name(graph3a, replace) xsize(4) ysize(7)
graph export "graph3a.png", as(png) replace
 
// Graph 3a: third difference example (versoin 2)

graph twoway ///
   (function y=7+1.5*x, range(0 20) lcolor(green) lwidth(medthick)) ///
   (function y=7+2.7*x, range(0 10.5) lcolor(midblue) lwidth(thick)) ///
   (function y=7+2.7*x, range(10.5 20) lcolor(stone) lwidth(thick) lpattern(shortdash)) ///   
   (function y=11+2.7*x, range(10.5 20) lcolor(midblue) lwidth(thick)) ///
   (function y=67+1.5*x, range(0 20) lcolor(cranberry) lwidth(medthick)) ///
   (function y=67+2.7*x, range(0 20) lcolor(stone) lwidth(thick)), ///   
   legend(off) xline(10.5, lpattern(shortdash) lcolor(gs9) lwidth(vthin))  ///
   yscale(range(0 100)) ylabel(none, nogrid) ytitle("") ///
   yline(7, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///
   yline(65, lcolor(midblue) lwidth(thin) lpattern(shortdash)) ///
   yline(62, lcolor(stone) lwidth(thin) lpattern(shortdash)) ///   
   yline(37, lcolor(green) lwidth(thin) lpattern(shortdash)) ///
   yline(97, lcolor(cranberry) lwidth(thin) lpattern(shortdash)) ///
   yline(67, lcolor(stone) lwidth(thin) lpattern(shortdash)) ///
   yline(121, lcolor(stone) lwidth(thin) lpattern(shortdash)) ///
   xscale(range(0 20)) xlabel(none, nogrid) xtitle("") ///
   text(37 -1 "b2", size(medlarge)) ///
   text(7 -1 "c", size(medlarge)) text(65 -1 "d", size(medlarge)) ///
   text(61 -1 "d2", size(medlarge)) /// 
   text(97 -1 "f2", size(medlarge)) ///    
   text(67 -1 "g", size(medlarge)) text(121 -1 "h", size(medlarge)) ///       
   title("Third difference (b)") ///
   name(graph3a, replace) xsize(4) ysize(7)  
graph export "graph3b.png", as(png) replace
