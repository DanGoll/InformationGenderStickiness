clear all
set more off

cd "/.../"

use "data/diving.dta",clear

g change_ref=0
replace change_ref=1 if difference_difficulty>0
replace change_ref=1 if difference_difficulty<0


g stay_ref=0
replace stay_ref=1 if change_ref==0

g pr_bad=0
replace pr_bad=1 if pr_diff_stylepoints_3<=-.5

g pr_good=0
replace pr_good=1 if pr_diff_stylepoints_3>=.5

g pr_positiveness=0
replace pr_positiveness=1 if pr_good==1
replace pr_positiveness=-1 if pr_bad==1



* ============================================================
* Figures 2a and 2b: Stay with reference difficulty
* ============================================================

preserve

keep if inlist(female, 0, 1) ///
    & inlist(pr_positiveness, -1, 0, 1) ///
    & !missing(stay_ref)

collapse (mean) stay_ref, by(female pr_positiveness)

gen x = pr_positiveness + 2
sort female x


* ============================================================
* Figure 2a: Men
* ============================================================

twoway ///
    (line stay_ref x if female == 0, ///
        sort ///
        lcolor(black) ///
        lwidth(medthick) ///
        lpattern(solid)), ///
    xlabel( ///
        1.09 "Negative" ///
        2    "NoInfo" ///
        2.91 "Positive", ///
        labsize(large) ///
        labcolor(gs6) ///
        noticks) ///
    xline(1(0.25)3, ///
        lcolor(gs14) ///
        lwidth(vthin) ///
        lpattern(solid)) ///
    xscale( ///
        range(0.9 3.1) ///
        noline) ///
    ylabel( ///
        0.970(0.005)0.990, ///
        angle(horizontal) ///
        format(%5.3f) ///
        labsize(large) ///
        labcolor(gs6) ///
        noticks ///
        grid ///
        glcolor(gs14) ///
        glwidth(vthin) ///
        glpattern(solid)) ///
    ymtick( ///
        0.9725(0.005)0.9875, ///
        grid ///
        glcolor(gs14) ///
        glwidth(vthin) ///
        glpattern(solid) ///
        tlength(0)) ///
    yscale( ///
        range(0.969 0.991) ///
        noline) ///
    xtitle("") ///
    ytitle("") ///
    legend(off) ///
    graphregion( ///
        color(white) ///
        margin(l=4 r=4 t=3 b=4)) ///
    plotregion( ///
        color(white) ///
        margin(l=0 r=0 t=2 b=5)) ///
    xsize(10) ///
    ysize(6) ///
    name(Figure_2a, replace)

graph export "Figure_2a.jpeg", ///
    as(jpg) ///
    width(1000) ///
    height(600) ///
    quality(100) ///
    replace


* ============================================================
* Figure 2b: Women
* ============================================================

twoway ///
    (line stay_ref x if female == 1, ///
        sort ///
        lcolor(black) ///
        lwidth(medthick) ///
        lpattern(solid)), ///
    xlabel( ///
        1.09 "Negative" ///
        2    "NoInfo" ///
        2.91 "Positive", ///
        labsize(large) ///
        labcolor(gs6) ///
        noticks) ///
    xline(1(0.25)3, ///
        lcolor(gs14) ///
        lwidth(vthin) ///
        lpattern(solid)) ///
    xscale( ///
        range(0.9 3.1) ///
        noline) ///
    ylabel( ///
        0.980(0.005)1.000, ///
        angle(horizontal) ///
        format(%5.3f) ///
        labsize(large) ///
        labcolor(gs6) ///
        noticks ///
        grid ///
        glcolor(gs14) ///
        glwidth(vthin) ///
        glpattern(solid)) ///
    ymtick( ///
        0.9825(0.005)0.9975, ///
        grid ///
        glcolor(gs14) ///
        glwidth(vthin) ///
        glpattern(solid) ///
        tlength(0)) ///
    yscale( ///
        range(0.979 1.001) ///
        noline) ///
    xtitle("") ///
    ytitle("") ///
    legend(off) ///
    graphregion( ///
        color(white) ///
        margin(l=4 r=4 t=3 b=4)) ///
    plotregion( ///
        color(white) ///
        margin(l=0 r=0 t=2 b=5)) ///
    xsize(10) ///
    ysize(6) ///
    name(Figure_2b, replace)

graph export "Figure_2b.jpeg", ///
    as(jpg) ///
    width(1000) ///
    height(600) ///
    quality(100) ///
    replace

restore


* ============================================================
* Table A.1: Descriptive statistics
* ============================================================

quietly summarize stay_ref ///
    if pr_positiveness == -1 & !missing(stay_ref), detail

local mean_neg : display %5.3f r(mean)
local median_neg : display %1.0f r(p50)
local sd_neg : display %5.3f r(sd)
local n_neg : display %9.0fc r(N)
local n_neg = strtrim("`n_neg'")


quietly summarize stay_ref ///
    if pr_positiveness == 0 & !missing(stay_ref), detail

local mean_neutral : display %5.3f r(mean)
local median_neutral : display %1.0f r(p50)
local sd_neutral : display %5.3f r(sd)
local n_neutral : display %9.0fc r(N)
local n_neutral = strtrim("`n_neutral'")


quietly summarize stay_ref ///
    if pr_positiveness == 1 & !missing(stay_ref), detail

local mean_pos : display %5.3f r(mean)
local median_pos : display %1.0f r(p50)
local sd_pos : display %5.3f r(sd)
local n_pos : display %9.0fc r(N)
local n_pos = strtrim("`n_pos'")


quietly summarize stay_ref ///
    if inlist(pr_positiveness, -1, 0, 1) & !missing(stay_ref), detail

local mean_total : display %5.3f r(mean)
local median_total : display %1.0f r(p50)
local sd_total : display %5.3f r(sd)
local n_total : display %9.0fc r(N)
local n_total = strtrim("`n_total'")


* ============================================================
* Export LaTeX table
* ============================================================

tempname tablefile

file open `tablefile' using "Table_A1.tex", write replace text

file write `tablefile' "\begin{table}[htbp]" _n
file write `tablefile' "\centering" _n
file write `tablefile' "\caption{Descriptive statistics, stay with reference difficulty}" _n
file write `tablefile' "\label{tab:descriptive_stay_ref}" _n
file write `tablefile' "\begin{threeparttable}" _n
file write `tablefile' "\begin{tabular}{lcccc}" _n
file write `tablefile' "\hline\hline" _n
file write `tablefile' "Treatment & Mean & Median & SD & N \\" _n
file write `tablefile' "\hline" _n
file write `tablefile' "Negative Information & `mean_neg' & `median_neg' & `sd_neg' & `n_neg' \\" _n
file write `tablefile' "Neutral Information & `mean_neutral' & `median_neutral' & `sd_neutral' & `n_neutral' \\" _n
file write `tablefile' "Positive Information & `mean_pos' & `median_pos' & `sd_pos' & `n_pos' \\" _n
file write `tablefile' "\hline" _n
file write `tablefile' "Total & `mean_total' & `median_total' & `sd_total' & `n_total' \\" _n
file write `tablefile' "\hline\hline" _n
file write `tablefile' "\end{tabular}" _n
file write `tablefile' "\begin{tablenotes}[flushleft]" _n
file write `tablefile' "\footnotesize" _n
file write `tablefile' "\item[] \textit{Notes:} SD denotes the standard deviation. N denotes the number of observations." _n
file write `tablefile' "\end{tablenotes}" _n
file write `tablefile' "\end{threeparttable}" _n
file write `tablefile' "\end{table}" _n

file close `tablefile'
