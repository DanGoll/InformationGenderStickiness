clear all
set more off

cd "/.../"


import excel "data/data_experiment.xlsx", sheet("Sheet1") firstrow clear



********************************************************************************
* Table 2: Linear regression on investment into the reference lottery
********************************************************************************

* Variable labels
label variable pos_info      "Positive Information"
label variable pos_info_fem  "Positive Information x Female"
label variable neg_info      "Negative Information"
label variable neg_info_fem  "Negative Information x Female"
label variable positiveness  "Positiveness"
label variable positiv_fem   "Positiveness x Female"
label variable female_self   "Female"


* Column (1)
reg invest_ref pos_info neg_info female_self, vce(robust)
estimates store reg1


* Column (2)
reg invest_ref pos_info neg_info pos_info_fem neg_info_fem ///
    female_self, vce(robust)
estimates store reg2


* Column (3)
reg invest_ref positiveness female_self, vce(robust)
estimates store reg3


* Column (4)
reg invest_ref positiveness positiv_fem female_self, vce(robust)
estimates store reg4


* ============================================================
* Display Table 2 in Results window
* ============================================================

esttab reg1 reg2 reg3 reg4, ///
    label ///
    keep( ///
        pos_info ///
        pos_info_fem ///
        neg_info ///
        neg_info_fem ///
        positiveness ///
        positiv_fem ///
        female_self ///
    ) ///
    order( ///
        pos_info ///
        pos_info_fem ///
        neg_info ///
        neg_info_fem ///
        positiveness ///
        positiv_fem ///
        female_self ///
    ) ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    b(3) ///
    se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, ///
        labels("N" "Adjusted R-squared") ///
        fmt(%9.0fc %9.4f)) ///
    title("Table 2: Linear regression on investment into the reference lottery") ///
    compress


* ============================================================
* Export Table 2 to LaTeX
* ============================================================

esttab reg1 reg2 reg3 reg4 ///
    using "Table_2.tex", ///
    replace ///
    booktabs ///
    label ///
    keep( ///
        pos_info ///
        pos_info_fem ///
        neg_info ///
        neg_info_fem ///
        positiveness ///
        positiv_fem ///
        female_self ///
    ) ///
    order( ///
        pos_info ///
        pos_info_fem ///
        neg_info ///
        neg_info_fem ///
        positiveness ///
        positiv_fem ///
        female_self ///
    ) ///
    mgroups("\textbf{Investment into the reference}", ///
        pattern(1 0 0 0) ///
        span ///
        prefix(\multicolumn{@span}{l}{) ///
        suffix(}) ///
        erepeat(\cmidrule(lr){@span})) ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    b(3) ///
    se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, ///
        labels("N" "\(R^2_{adj}\)") ///
        fmt(%9.0fc %9.4f)) ///
    title("Linear regression on investment into the reference lottery") ///
    nonotes ///
    addnotes( ///
        "Notes: *, **, and *** denote statistical significance at the 10\%, 5\%, and 1\% levels, respectively." ///
        "Heteroskedasticity-robust standard errors are reported in parentheses." ///
    )


********* Figures 3a and 3b ***********

sort positiveness female_self high_reference
by positiveness: egen investment_mean_all = mean(invest_ref)
by positiveness female_self: egen investment_mean_gender = mean(invest_ref)
by positiveness female_self high_reference: egen investment_mean_detail = mean(invest_ref)


local f 1.5

scatter investment_mean_gender positiveness if female == 1, ///
    mcolor(black) msymbol(circle) ///
||  line investment_mean_gender positiveness if female == 1, ///
    lpattern(solid) lwidth(thick) lcolor(gs4) ///
||  scatter investment_mean_detail positiveness if female == 1 & high_reference == 0, ///
    mcolor(gs8) msymbol(triangle) ///
||  line investment_mean_detail positiveness if female == 1 & high_reference == 0, ///
    lpattern(dash_dot) lwidth(thin) lcolor(gs8) ///
||  scatter investment_mean_detail positiveness if female == 1 & high_reference == 1, ///
    mcolor(gs8) msymbol(square) ///
||  line investment_mean_detail positiveness if female == 1 & high_reference == 1, ///
    lpattern(longdash) lwidth(thin) lcolor(gs8) ///
    graphregion(color(white)) ///
    xlabel(-1 "Negative" 0 "No info" 1 "Positive", labsize(*`f')) ///
    xtitle("", size(*`f')) ///
    ylabel(140(20)280, angle(0) labsize(*`f')) ///
    legend(order(1 3 5) ///
           label(1 "Female") label(3 "Female Low") label(5 "Female High") ///
           size(*`f')) ///
    name(female, replace)

graph export "Figure_3a.pdf", replace



local f 1.5

scatter investment_mean_gender positiveness if female == 0, ///
    mcolor(black) msymbol(circle) ///
||  line investment_mean_gender positiveness if female == 0, ///
    lpattern(solid) lwidth(thick) lcolor(gs4) ///
||  scatter investment_mean_detail positiveness if female == 0 & high_reference == 0, ///
    mcolor(gs8) msymbol(triangle) ///
||  line investment_mean_detail positiveness if female == 0 & high_reference == 0, ///
    lpattern(dash_dot) lwidth(thin) lcolor(gs8) ///
||  scatter investment_mean_detail positiveness if female == 0 & high_reference == 1, ///
    mcolor(gs8) msymbol(square) ///
||  line investment_mean_detail positiveness if female == 0 & high_reference == 1, ///
    lpattern(longdash) lwidth(thin) lcolor(gs8) ///
    graphregion(color(white)) ///
    xlabel(-1 "Negative" 0 "No info" 1 "Positive", labsize(*`f')) ///
    xtitle("", size(*`f')) ///
    ylabel(140(20)280, angle(0) labsize(*`f')) ///
    legend(order(1 3 5) ///
           label(1 "Male") label(3 "Male Low") label(5 "Male High") ///
           size(*`f')) ///
    name(male, replace)

graph export "Figure_3b.pdf", replace


******************************
********************************************************************************
* Mediation analyses
********************************************************************************


********************************************************************************
* Program: Run medeff, display results, and export LaTeX table
********************************************************************************

capture program drop make_mediation_table

program define make_mediation_table

    version 15.0

    syntax, ///
        MEDIATOR(name) ///
        FEMALE(integer) ///
        FILE(string) ///
        NUMBER(string) ///
        CAPTION(string) ///
        GROUP(string) ///
        LABEL(string)


    * --------------------------------------------------------
    * Number of observations
    * --------------------------------------------------------

    quietly count if female_self == `female' ///
        & !missing(invest_ref, positiveness, `mediator')

    local N = r(N)


    * --------------------------------------------------------
    * Temporary objects
    * --------------------------------------------------------

    tempfile medeff_log

    tempname ///
        med_mean med_low med_high ///
        dir_mean dir_low dir_high ///
        tot_mean tot_low tot_high ///
        pct_mean pct_low pct_high ///
        logfile texfile


    * --------------------------------------------------------
    * Run medeff and save its printed output
    * --------------------------------------------------------

    capture log close medeff_capture

    log using "`medeff_log'", ///
        text replace name(medeff_capture)


    medeff ///
        (regress `mediator' positiveness) ///
        (regress invest_ref positiveness `mediator') ///
        if female_self == `female', ///
        treat(positiveness) ///
        mediate(`mediator') ///
        sims(1000) ///
        level(90)


    * --------------------------------------------------------
    * Immediately save returned medeff results
    * --------------------------------------------------------

    scalar `med_mean' = r(delta0)
    scalar `med_low'  = r(delta0lo)
    scalar `med_high' = r(delta0hi)

    scalar `dir_mean' = r(zeta0)
    scalar `dir_low'  = r(zeta0lo)
    scalar `dir_high' = r(zeta0hi)

    scalar `tot_mean' = r(tau)
    scalar `tot_low'  = r(taulo)
    scalar `tot_high' = r(tauhi)


    log close medeff_capture


    * --------------------------------------------------------
    * Read percentage mediated from medeff output
    * --------------------------------------------------------

    scalar `pct_mean' = .
    scalar `pct_low'  = .
    scalar `pct_high' = .

    local pct_found = 0

    file open `logfile' using "`medeff_log'", read text
    file read `logfile' line

    while r(eof) == 0 {

        if strpos(`"`line'"', "% of Tot Eff mediated") > 0 {

            local bar_position = strpos(`"`line'"', "|")

            if `bar_position' > 0 {

                local right_side = substr( ///
                    `"`line'"', ///
                    `bar_position' + 1, ///
                    strlen(`"`line'"') ///
                )

                tokenize `"`right_side'"'

                scalar `pct_mean' = real("`1'")
                scalar `pct_low'  = real("`2'")
                scalar `pct_high' = real("`3'")

                local pct_found = 1
            }
        }

        file read `logfile' line
    }

    file close `logfile'


    if `pct_found' == 0 {

        display as error ///
            "The percentage-mediated results could not be read from medeff."

        exit 498
    }


    * --------------------------------------------------------
    * Display table in Results window
    * --------------------------------------------------------

    display _newline
    display as text "`number': `caption'"
    display as text "{hline 72}"

    display as text ///
        %-26s "Effect" ///
        %11s "Mean" ///
        %31s "90% CI"

    display as text "{hline 72}"

    display as text %-26s "Mediation effect" ///
        as result %11.2f scalar(`med_mean') ///
        as text "    [" ///
        as result %8.2f scalar(`med_low') ///
        as text " ; " ///
        as result %8.2f scalar(`med_high') ///
        as text "]"

    display as text %-26s "Direct effect" ///
        as result %11.2f scalar(`dir_mean') ///
        as text "    [" ///
        as result %8.2f scalar(`dir_low') ///
        as text " ; " ///
        as result %8.2f scalar(`dir_high') ///
        as text "]"

    display as text %-26s "Total effect" ///
        as result %11.2f scalar(`tot_mean') ///
        as text "    [" ///
        as result %8.2f scalar(`tot_low') ///
        as text " ; " ///
        as result %8.2f scalar(`tot_high') ///
        as text "]"

    display as text %-26s "% mediated" ///
        as result %11.2f scalar(`pct_mean') ///
        as text "    [" ///
        as result %8.2f scalar(`pct_low') ///
        as text " ; " ///
        as result %8.2f scalar(`pct_high') ///
        as text "]"

    display as text "{hline 72}"

    display as text ///
        "Notes: Mediation analysis. 90% confidence intervals based on " ///
        "1,000 bootstrap simulations. `group', N=`N'."


    * --------------------------------------------------------
    * Format results for LaTeX
    * --------------------------------------------------------

    local med_mean_tex : display %9.2f scalar(`med_mean')
    local med_low_tex  : display %9.2f scalar(`med_low')
    local med_high_tex : display %9.2f scalar(`med_high')

    local dir_mean_tex : display %9.2f scalar(`dir_mean')
    local dir_low_tex  : display %9.2f scalar(`dir_low')
    local dir_high_tex : display %9.2f scalar(`dir_high')

    local tot_mean_tex : display %9.2f scalar(`tot_mean')
    local tot_low_tex  : display %9.2f scalar(`tot_low')
    local tot_high_tex : display %9.2f scalar(`tot_high')

    local pct_mean_tex : display %9.2f scalar(`pct_mean')
    local pct_low_tex  : display %9.2f scalar(`pct_low')
    local pct_high_tex : display %9.2f scalar(`pct_high')


    local med_mean_tex = strtrim("`med_mean_tex'")
    local med_low_tex  = strtrim("`med_low_tex'")
    local med_high_tex = strtrim("`med_high_tex'")

    local dir_mean_tex = strtrim("`dir_mean_tex'")
    local dir_low_tex  = strtrim("`dir_low_tex'")
    local dir_high_tex = strtrim("`dir_high_tex'")

    local tot_mean_tex = strtrim("`tot_mean_tex'")
    local tot_low_tex  = strtrim("`tot_low_tex'")
    local tot_high_tex = strtrim("`tot_high_tex'")

    local pct_mean_tex = strtrim("`pct_mean_tex'")
    local pct_low_tex  = strtrim("`pct_low_tex'")
    local pct_high_tex = strtrim("`pct_high_tex'")


    * --------------------------------------------------------
    * Export LaTeX table
    * --------------------------------------------------------

    file open `texfile' using "`file'.tex", ///
        write replace text

    file write `texfile' "\begin{table}[htbp]" _n
    file write `texfile' "\centering" _n
    file write `texfile' "\caption{`caption'}" _n
    file write `texfile' "\label{`label'}" _n
    file write `texfile' "\begin{threeparttable}" _n
    file write `texfile' "\begin{tabular}{@{}lcc@{}}" _n

    file write `texfile' "\toprule" _n
    file write `texfile' "Effect & Mean & 90\% CI \\" _n
    file write `texfile' "\midrule" _n

    file write `texfile' ///
        "Mediation effect & `med_mean_tex' & " ///
        "[`med_low_tex' ; `med_high_tex'] \\" _n

    file write `texfile' ///
        "Direct effect & `dir_mean_tex' & " ///
        "[`dir_low_tex' ; `dir_high_tex'] \\" _n

    file write `texfile' ///
        "Total effect & `tot_mean_tex' & " ///
        "[`tot_low_tex' ; `tot_high_tex'] \\" _n

    file write `texfile' ///
        "\% mediated & `pct_mean_tex' & " ///
        "[`pct_low_tex' ; `pct_high_tex'] \\" _n

    file write `texfile' "\bottomrule" _n
    file write `texfile' "\end{tabular}" _n

    file write `texfile' "\begin{tablenotes}[flushleft]" _n
    file write `texfile' "\footnotesize" _n

    file write `texfile' ///
        "\item[] \textit{Notes:} Mediation analysis. " ///
        "90\% confidence intervals (CI) are based on 1,000 " ///
        "bootstrapsimulations. `group', \(N=`N'\)." _n

    file write `texfile' "\end{tablenotes}" _n
    file write `texfile' "\end{threeparttable}" _n
    file write `texfile' "\end{table}" _n

    file close `texfile'

end




********************************************************************************
* Probability as mediator
********************************************************************************

* Table B.2: Men

make_mediation_table, ///
    mediator(norm_rel_prob) ///
    female(0) ///
    file("Table_B2") ///
    number("Table B.2") ///
    caption("Mediation result men") ///
    group("Men") ///
    label("tab:mediation_probability_men")


* Table B.3: Women

make_mediation_table, ///
    mediator(norm_rel_prob) ///
    female(1) ///
    file("Table_B3") ///
    number("Table B.3") ///
    caption("Mediation result women") ///
    group("Women") ///
    label("tab:mediation_probability_women")



********************************************************************************
* Relative attractiveness as mediator
********************************************************************************

* Table B.4: Men

make_mediation_table, ///
    mediator(norm_rel_attract) ///
    female(0) ///
    file("Table_B4") ///
    number("Table B.4") ///
    caption("Mediation result men") ///
    group("Men") ///
    label("tab:mediation_attractiveness_men")


* Table B.5: Women

make_mediation_table, ///
    mediator(norm_rel_attract) ///
    female(1) ///
    file("Table_B5") ///
    number("Table B.5") ///
    caption("Mediation result women") ///
    group("Women") ///
    label("tab:mediation_attractiveness_women")


********************************************************************************
********************************************************************************
