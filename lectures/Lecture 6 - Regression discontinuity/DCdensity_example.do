//Example code of how to use DCdensity.ado
//First put DCdensity.ado in your ado folder
//if you dont know where your ado folder is
//issue
//sysdir
//at the Stata prompt
capture log close
log using DCdensity_example, text replace

clear
set mem 2G
set more off
set seed 1234567

set obs 10000
gen Z=invnorm(uniform())
DCdensity Z, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) /*graphname(DCdensity_example.eps)*/

capture program drop dog
program define dog, rclass
{
  syntax [, n(real 500)]
  drop _all
  set obs `n'
  gen Z=invnorm(uniform())
  //gen r0=0 in 1
  //DCdensity Z, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) nograph
  DCdensity Z, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) nograph
  local h=r(bandwidth)/2
  drop Xj Yj r0 fhat se_fhat
  DCdensity Z, breakpoint(0) h(`h') generate(Xj Yj r0 fhat se_fhat) nograph
  return scalar bandwidth=r(bandwidth)
  return scalar theta=r(theta)
  return scalar se_theta=r(se)
  ereturn clear
}
end

simulate, reps(1000): dog

gen t=theta/se_theta
//2 views regarding the issue of normal approximation
kdensity t, normal
qnorm t

log close
