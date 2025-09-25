# Example studies - matching and re-weighting

## Applications: matching methods in education

Attewell, P., & Domina, T. (2008). Raising the Bar: Curricular Intensity and Academic Performance. *Educational Evaluation and Policy Analysis*, 30(1), 51-71. https://journals.sagepub.com/doi/abs/10.3102/0162373707313409
> An older, straightforward propensity score matching example: logistic regression and nearest neighbor matching within a caliper.

Gurantz, O., & Tsai, Y.-Y. (2023). The impact of federal administrative burdens on college enrollment. *Economics of Education Review*, 97, 102461. https://doi.org/10.1016/j.econedurev.2023.102461
> Uses machine learning (regression trees) to identify matching variables and entropy balancing for matching.

Hill, C. J., Gormley, W. T., & Adelstein, S. (2015). Do the short-term effects of a high-quality preschool program persist? *Early Childhood Research Quarterly*, 32, 60-79. https://doi.org/10.1016/j.ecresq.2014.12.005
> Boosted regression and propensity score matching.
 
Kearns, C., Lauen, D. L., & Fuller, B. (2020). Competing With Charter Schools: Selection, Retention, and Achievement in Los Angeles Pilot Schools. *Evaluation Review*, 44(2-3), 111-144. https://journals.sagepub.com/doi/abs/10.1177/0193841X20946221
> Propensity score matching

Long, M. C., Conger, D., & Iatarola, P. (2012). Effects of High School Course-Taking on Secondary and Postsecondary Success. *American Educational Research Journal*, 49(2), 285-322. https://journals.sagepub.com/doi/abs/10.3102/0002831211431952
> Propensity score matching

Zhao, T., Perez-Felkner, L., & Hu, S. (2025). The Impact of Merit Aid on STEM Major Choices: A Propensity Score Approach. *Educational Evaluation and Policy Analysis*, 47(3), 939-959. https://journals.sagepub.com/doi/abs/10.3102/01623737241254842
> Propensity score matching. Uses Beginning Postsecondary Students study data.

## Applications: inverse probability weighting

Ben-Michael, E., Feller, A., & Rothstein, J. (2023). Varying Impacts of Letters of Recommendation on College Admissions. National Bureau of Economic Research Working Paper Series, No. 30940. http://www.nber.org/papers/w30940

Cellini, S. R., & Grueso, H. (2021). Student Learning in Online College Programs. National Bureau of Economic Research Working Paper Series, No. 28552. http://www.nber.org/papers/w28552

Edmunds, J., Unlu, F., Phillips, B., Mulhern, C., & Hutchins, B. C. (2023). CTE-Focused Dual Enrollment: Participation and Outcomes. *Education Finance and Policy*, 1-40. https://doi.org/10.1162/edfp_a_00414
> Uses TWANG (generalized boosted modeling) to estimate propensity score weights

Frank, K. A., et al. (2008). Does NBPTS Certification Affect the Number of Colleagues a Teacher Helps With Instructional Matters? *Educational Evaluation and Policy Analysis* 30(1): 3-30. https://journals.sagepub.com/doi/abs/10.3102/0162373707313781
> Straightforward examples of inverse propensity score weighting.

Swiderski, T. (2024). The Effect of Early College High Schools on STEM Bachelor's Degree Attainment: Evidence from North Carolina. *Education Finance and Policy*, 19(3), 437-460. https://doi.org/10.1162/edfp_a_00404

Yoo, P., Domina, T., McEachin, A., Clark, L., Hertenstein, H., & Penner, A. M. (2023). Virtual Charter Students Have Worse Labor Market Outcomes as Young Adults. Retrieved from http://www.edworkingpapers.com/ai23-773
> Uses TWANG and inverse probability weighting

## Applying matching to experimental data

Fortson, K., Gleason, P., Kopa, E., & Verbitsky-Savitz, N. (2015). Horseshoes, hand grenades, and treatment effects? Reassessing whether nonexperimental estimators are biased. *Economics of Education Review*, 44(0), 100--113. http://dx.doi.org/10.1016/j.econedurev.2014.11.001

Wilde, E. T., & Hollister, R. (2007). How Close is Close Enough? Evaluating Propensity Score Matching Using Data from a Class Size Reduction Experiment. *Journal of Policy
Analysis and Management*, 26(3), 455–477. https://doi.org/10.1002/pam.20262

## Applications: matching or weighting with difference-in-differences

Bennett, C. T. (2021). Untested Admissions: Examining Changes in Application Behaviors and Student Demographics Under Test-Optional Policies. *American Educational Research Journal*, 59(1), 180-216. https://doi.org/10.3102/00028312211003526

Bross, W., Harris, D. N., & Liu, L. (2023). The effects of performance-based school closure and restart on student performance. *Economics of Education Review*, 94, 102368. https://doi.org/10.1016/j.econedurev.2023.102368

Kim, J. (2024). The Long Shadow of School Closures: Impacts on Students' Educational and Labor Market Outcomes. Retrieved from http://www.edworkingpapers.com/ai24-963

Nomi, T., et al. Project Lead the Way: Impacts of a High School Applied STEM Program on Early Post-Secondary Outcomes. *Journal of Research on Educational Effectiveness*. https://doi.org/10.1080/19345747.2025.2518995

Swain, W. A., Rodriguez, L. A., & Springer, M. G. (2019). Selective retention bonuses for highly effective teachers in high poverty schools: Evidence from Tennessee. *Economics of Education Review*, 68, 148--160. https://doi.org/https://doi.org/10.1016/j.econedurev.2018.12.008 

## Matching and weighting: methodological papers

:star: Ho, D. E., et al. (2007). Matching as Nonparametric Preprocessing for Reducing Model Dependence in Parametric Causal Inference. *Political Analysis* 15(3): 199-236.
> Excellent intuitive introduction to matching techniques and how they improve upon traditional parametric (regression-based) methods. Also includes a lot of practical guidance on testing for balance.

Iacus, S. M., King, G., & Porro, G. (2012). Causal Inference without Balance Checking: Coarsened Exact Matching. *Political Analysis*, 20(1), 1-24. https://doi.org/10.1093/pan/mpr013 

Keele, L., et al. (Forthcoming). Balancing Weights for Estimating Treatment Effects in Educational Studies. *Journal of Research on Educational Effectiveness*.
> Introduces an alternative to inverse probability weighting using "balancing weights" that focus on balance in covariates between treatment and control groups. Illustrated using an example of evaluation of a Pre-K program in Wake County, NC.

:star: King, G., & Nielsen, R. (2019). Why Propensity Scores Should Not Be Used for Matching. *Political Analysis*, 27(4), 435-454. https://www.cambridge.org/core/article/why-propensity-scores-should-not-be-used-for-matching/94DDE7ED8E2A796B693096EB714BE68B

Kush, J. M., Pas, E. T., Musci, R. J., & Bradshaw, C. P. (2022). Covariate Balance for Observational Effectiveness Studies: A Comparison of Matching and Weighting. *Journal Of Research on Educational Effectiveness*, 1-24. https://doi.org/10.1080/19345747.2022.2110545
