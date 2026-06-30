clear all
set more off

cd "/.../"

use "data/diving.dta",clear


**** Variable construction 

* Outcome variable
g change_ref=0
replace change_ref=1 if difference_difficulty>0
replace change_ref=1 if difference_difficulty<0


g stay_ref=0
replace stay_ref=1 if change_ref==0

g pr_score = pr_stylepoints_3 * pr_diff
g diff_score = Score - pr_score

g diff_stylepoints_3 = stylepoints_3 - pr_stylepoints_3

* Treatment indicators
g pr_bad=0
replace pr_bad=1 if pr_diff_stylepoints_3<=-.5

g pr_good=0
replace pr_good=1 if pr_diff_stylepoints_3>=.5

g pr_positiveness=0
replace pr_positiveness=1 if pr_good==1
replace pr_positiveness=-1 if pr_bad==1

* Treatment-by-gender interactions
g pr_bad_fem = pr_bad * female
g pr_good_fem = pr_good * female
g pr_positiveness_fem = pr_positiveness * female



********************************************************************************
********************************************************************************

********************************************************************************
*                               Variable labels
********************************************************************************

label variable pr_good                 "Positive Information"
label variable pr_good_fem             "Positive Information x Female"
label variable pr_bad                  "Negative Information"
label variable pr_bad_fem              "Negative Information x Female"
label variable pr_positiveness         "Positiveness"
label variable pr_positiveness_fem     "Positiveness x Female"
label variable female                  "Female"

label variable change_ref              "Change away from reference"
label variable Difficulty              "Subsequent difficulty"


********************************************************************************
*                               Tables
********************************************************************************


*** Table 1: Linear regression on stay with the reference ***

reg stay_ref pr_good pr_bad female i.AthleteID, ///
    vce(cluster AthleteID)
estimates store rel_3_ac


reg stay_ref pr_bad pr_good female pr_bad_fem pr_good_fem ///
    i.AthleteID, vce(cluster AthleteID)
estimates store rel_3_bc

lincom pr_bad + pr_bad_fem
lincom pr_good + pr_good_fem


reg stay_ref pr_positiveness female i.AthleteID, ///
    vce(cluster AthleteID)
estimates store rel_3_apc


reg stay_ref pr_positiveness female pr_positiveness_fem ///
    i.AthleteID, vce(cluster AthleteID)
estimates store rel_3_bpc

lincom pr_positiveness + pr_positiveness_fem


* Display Table 1 in Results window
esttab rel_3_ac rel_3_bc rel_3_apc rel_3_bpc, ///
    label ///
    keep( ///
        pr_good ///
        pr_good_fem ///
        pr_bad ///
        pr_bad_fem ///
        pr_positiveness ///
        pr_positiveness_fem ///
        female ///
    ) ///
    order( ///
        pr_good ///
        pr_good_fem ///
        pr_bad ///
        pr_bad_fem ///
        pr_positiveness ///
        pr_positiveness_fem ///
        female ///
    ) ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    b(3) ///
    se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, ///
        labels("N" "Adjusted R-squared") ///
        fmt(%9.0fc %9.4f)) ///
    title("Table 1: Linear regression on stay with the reference") ///
    compress


* Export Table 1 to LaTeX
esttab rel_3_ac rel_3_bc rel_3_apc rel_3_bpc ///
    using "Table_1.tex", ///
    replace ///
    booktabs ///
    label ///
    keep( ///
        pr_good ///
        pr_good_fem ///
        pr_bad ///
        pr_bad_fem ///
        pr_positiveness ///
        pr_positiveness_fem ///
        female ///
    ) ///
    order( ///
        pr_good ///
        pr_good_fem ///
        pr_bad ///
        pr_bad_fem ///
        pr_positiveness ///
        pr_positiveness_fem ///
        female ///
    ) ///
    mgroups("Stay with reference difficulty", ///
        pattern(1 0 0 0) ///
        span ///
        prefix(\multicolumn{@span}{c}{) ///
        suffix(}) ///
        erepeat(\cmidrule(lr){@span})) ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    b(3) ///
    se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, ///
        labels("N" "\(R^2_{adj}\)") ///
        fmt(%9.0fc %9.4f)) ///
    title("Linear regression on stay with the reference") ///
    nonotes ///
    addnotes( ///
        "Notes: *, **, and *** denote statistical significance at the 10\%, 5\%, and 1\% levels, respectively." ///
        "Individual fixed effects are included. Robust standard errors (in parentheses)." ///
    )



********************************************************************************
*                               Appendix
********************************************************************************


*** Table A.2: Momentum vs. regression-to-the-mean ***

reg diff_stylepoints_3 pr_good pr_bad, ///
    vce(cluster AthleteID)
estimates store rel_4x_b


reg diff_stylepoints_3 pr_good pr_bad pr_diff Difficulty ///
    i.AthleteID, vce(cluster AthleteID)
estimates store rel_4x_bi


reg diff_stylepoints_3 pr_positiveness, ///
    vce(cluster AthleteID)
estimates store rel_4x_c


reg diff_stylepoints_3 pr_positiveness pr_diff Difficulty ///
    i.AthleteID, vce(cluster AthleteID)
estimates store rel_4x_ci


reg diff_score pr_good pr_bad i.AthleteID, ///
    vce(cluster AthleteID)
estimates store rel_4x_d


reg diff_score pr_positiveness i.AthleteID, ///
    vce(cluster AthleteID)
estimates store rel_4x_e


* Display Table A.2 in Results window
esttab rel_4x_bi rel_4x_ci rel_4x_d rel_4x_e, ///
    label ///
    keep( ///
        pr_good ///
        pr_bad ///
        pr_positiveness ///
    ) ///
    order( ///
        pr_good ///
        pr_bad ///
        pr_positiveness ///
    ) ///
    mgroups( ///
        "Difference Performance" ///
        "Difference Score", ///
        pattern(1 0 1 0) ///
        span ///
    ) ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    b(3) ///
    se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, ///
        labels("N" "Adjusted R-squared") ///
        fmt(%9.0fc %9.4f)) ///
    title("Table A.2: Momentum vs. regression-to-the-mean") ///
    compress


* Export Table A.2 to LaTeX
esttab rel_4x_bi rel_4x_ci rel_4x_d rel_4x_e ///
    using "Table_A2.tex", ///
    replace ///
    booktabs ///
    label ///
    keep( ///
        pr_good ///
        pr_bad ///
        pr_positiveness ///
    ) ///
    order( ///
        pr_good ///
        pr_bad ///
        pr_positiveness ///
    ) ///
    mgroups( ///
        "Difference Performance" ///
        "Difference Score", ///
        pattern(1 0 1 0) ///
        span ///
        prefix(\multicolumn{@span}{c}{) ///
        suffix(}) ///
        erepeat(\cmidrule(lr){@span}) ///
    ) ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    b(3) ///
    se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, ///
        labels("N" "\(R^2_{adj}\)") ///
        fmt(%9.0fc %9.4f)) ///
    title("Momentum vs. regression-to-the-mean") ///
    nonotes ///
    addnotes( ///
        "Notes: *, **, and *** denote statistical significance at the 10\%, 5\%, and 1\% levels, respectively." ///
        "Linear regressions using diving data. Individual fixed effects are included. Robust standard errors (in parentheses)." ///
    )



*** Table A.3: Changing away from the reference difficulty on performance ***

reg diff_stylepoints_3 change_ref i.AthleteID, ///
    vce(cluster AthleteID)
estimates store ch_ref_0


reg diff_stylepoints_3 change_ref Difficulty i.AthleteID, ///
    vce(cluster AthleteID)
estimates store ch_ref_1


reg diff_score change_ref i.AthleteID, ///
    vce(cluster AthleteID)
estimates store ch_ref_s0


reg diff_score change_ref Difficulty i.AthleteID, ///
    vce(cluster AthleteID)
estimates store ch_ref_s1


* Display Table A.3 in Results window
esttab ch_ref_0 ch_ref_1 ch_ref_s0 ch_ref_s1, ///
    label ///
    keep( ///
        change_ref ///
        Difficulty ///
    ) ///
    order( ///
        change_ref ///
        Difficulty ///
    ) ///
    mgroups( ///
        "Difference Performance" ///
        "Difference Score", ///
        pattern(1 0 1 0) ///
        span ///
    ) ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    b(3) ///
    se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, ///
        labels("N" "Adjusted R-squared") ///
        fmt(%9.0fc %9.4f)) ///
    title("Table A.3: Changing away from the reference difficulty on performance") ///
    compress


* Export Table A.3 to LaTeX
esttab ch_ref_0 ch_ref_1 ch_ref_s0 ch_ref_s1 ///
    using "Table_A3.tex", ///
    replace ///
    booktabs ///
    label ///
    keep( ///
        change_ref ///
        Difficulty ///
    ) ///
    order( ///
        change_ref ///
        Difficulty ///
    ) ///
    mgroups( ///
        "Difference Performance" ///
        "Difference Score", ///
        pattern(1 0 1 0) ///
        span ///
        prefix(\multicolumn{@span}{c}{) ///
        suffix(}) ///
        erepeat(\cmidrule(lr){@span}) ///
    ) ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    b(3) ///
    se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, ///
        labels("N" "\(R^2_{adj}\)") ///
        fmt(%9.0fc %9.4f)) ///
    title("Changing away from the reference difficulty on performance") ///
    nonotes ///
    addnotes( ///
        "Notes: *, **, and *** denote statistical significance at the 10\%, 5\%, and 1\% levels, respectively." ///
        "Linear regressions using diving data. Individual fixed effects are included. Robust standard errors (in parentheses)." ///
    )


********************************************************************************
********************************************************************************
********************************************************************************
