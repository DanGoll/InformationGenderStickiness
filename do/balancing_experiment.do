*******************************************************
* Balance table (men/women panels) -> LaTeX export
*******************************************************

clear all
set more off

*------------------------------------------------------*
* 0) Set working directory
*------------------------------------------------------*
cd "/.../"

*------------------------------------------------------*
* 1) Import Excel file (adjust filename)
*------------------------------------------------------*
local excel_file "data/data_experiment.xlsx"
import excel using "`excel_file'", firstrow clear


g condition = .
replace condition = 1 if positiveness==1
replace condition = 2 if positiveness==0
replace condition = 3 if positiveness==-1

*------------------------------------------------------*
* 2) Specify the CONDITION variable (ADJUST HERE!)
*    -> must contain the experimental condition
*------------------------------------------------------*
local condvar "condition"   // <-- insert the actual variable name here

* cond3: 1=Pos, 2=No, 3=Neg (robust to string and numeric formats)
capture confirm string variable `condvar'
if !_rc {
    gen strL __c = lower(trim(`condvar'))
    gen byte cond3 = .
    replace cond3 = 1 if regexm(__c, "pos")
    replace cond3 = 2 if regexm(__c, "no")
    replace cond3 = 3 if regexm(__c, "neg")
    drop __c
}
else {
    gen double cond3 = `condvar'
}

label define cond3lbl 1 "Pos Info" 2 "No Info" 3 "Neg Info", replace
label values cond3 cond3lbl

*------------------------------------------------------*
* 3) Labels (optional but recommended)
*------------------------------------------------------*
capture label variable age                "Age"
capture label variable master             "Master"
capture label variable economics          "Economics"
capture label variable number_experiments "Number of experiments"

*------------------------------------------------------*
* 4) Variables to include in the balance table
*------------------------------------------------------*
local demo_vars "age master economics number_experiments"

*------------------------------------------------------*
* 5) Write LaTeX file
*------------------------------------------------------*
local outtex "Table_B1.tex"

tempname fh
file open `fh' using "`outtex'", write replace text

file write `fh' "\begin{table}[htbp]\centering" _n
file write `fh' "\caption{Balance table: demographics across experimental conditions}" _n
file write `fh' "\label{tab:balance_demo}" _n
file write `fh' "\begin{threeparttable}" _n
file write `fh' "\begin{tabular}{lcccc}" _n
file write `fh' "\toprule" _n
file write `fh' " & Pos Info & No Info & Neg Info & F-test (p) \\\\" _n
file write `fh' "\midrule" _n

*------------------------------------------------------*
* 6) Panels: Men (female_self==0) and Women (==1)
*------------------------------------------------------*
foreach g in 0 1 {

    if `g'==0 local panel "Panel A: Men"
    if `g'==1 local panel "Panel B: Women"

    file write `fh' "\multicolumn{5}{l}{\textbf{`panel'}} \\\\" _n
    file write `fh' "\addlinespace" _n

    foreach v of local demo_vars {

        * Row label: use the variable label if available; otherwise use the variable name
        local vlab : variable label `v'
        if "`vlab'"=="" local vlab "`v'"

        * Cells: mean (SD) by condition
        forvalues k=1/3 {
            quietly summarize `v' if female_self==`g' & cond3==`k'
local N = r(N)

if (`N'>0) {
    * Note: if N == 1, Stata reports SD as . (undefined)
    local sdstr = cond(`N'>=2, string(r(sd),"%9.2f"), ".")
    local cell`k' "`=string(r(mean),"%9.2f")' (`sdstr')"
}
else {
    local cell`k' "."
}
        }

        * F-test p-value (Regression + testparm)
        local pval "."
        capture quietly regress `v' i.cond3 if female_self==`g'
        if !_rc {
            capture quietly testparm i.cond3
            if !_rc local pval "`=string(r(p),"%9.3f")'"
        }

        file write `fh' "`vlab' & `cell1' & `cell2' & `cell3' & `pval' \\\\" _n
    }

    file write `fh' "\addlinespace" _n
}

file write `fh' "\bottomrule" _n
file write `fh' "\end{tabular}" _n
file write `fh' "\begin{tablenotes}\footnotesize" _n
file write `fh' "\item Notes: Cells report mean (SD) within gender and experimental condition. F-test reports the p-value from testing equality of means across the three conditions within each gender (regression with condition indicators; joint test)." _n
file write `fh' "\end{tablenotes}" _n
file write `fh' "\end{threeparttable}" _n
file write `fh' "\end{table}" _n

file close `fh'

display as text "Saved LaTeX table to: `outtex' (in current working directory: " c(pwd) ")"
*******************************************************

*******************************************************
* Ex-ante MDEs (alpha=0.10) for key pooled parameters
* Outcome: invest_ref
* Treatments: pos_info, neg_info, positiveness (-1/0/1)
* Gender: female_self (0=men, 1=women)
* Output: LaTeX table in working directory
*******************************************************

set more off

*-----------------------------
* SETTINGS
*-----------------------------
local y      "invest_ref"
local alpha  0.10
local power  0.80
local outtex "Footnote3.tex"

* scaling factor K = z_(1-alpha/2) + z_power
scalar K = invnormal(1-`alpha'/2) + invnormal(`power')
local Kstr = string(K,"%9.3f")

*-----------------------------
* Define No-Info control group
*-----------------------------
capture drop no_info
gen byte no_info = (pos_info==0 & neg_info==0) if !missing(pos_info) & !missing(neg_info)

*-----------------------------
* Plug-in sigma (ex-ante): SD of invest_ref in No-Info (pooled)
* fallback to overall SD if undefined
*-----------------------------
quietly summarize `y' if no_info==1 & !missing(`y')
local sigma = r(sd)

if missing(`sigma') {
    quietly summarize `y' if !missing(`y')
    local sigma = r(sd)
}

local sigstr = string(`sigma',"%9.2f")

*-----------------------------
* Realized cell sizes (non-missing y)
*-----------------------------
quietly count if female_self==0 & pos_info==1 & !missing(`y')
local n_pos_m = r(N)
quietly count if female_self==0 & neg_info==1 & !missing(`y')
local n_neg_m = r(N)
quietly count if female_self==0 & no_info==1  & !missing(`y')
local n_no_m  = r(N)

quietly count if female_self==1 & pos_info==1 & !missing(`y')
local n_pos_f = r(N)
quietly count if female_self==1 & neg_info==1 & !missing(`y')
local n_neg_f = r(N)
quietly count if female_self==1 & no_info==1  & !missing(`y')
local n_no_f  = r(N)

*-----------------------------
* Spec A: pooled regression with interactions
* (baseline group is men, so main effects use male cells)
* MDE = K * sigma * SE_design
*-----------------------------
local mde_pos = .
if (`n_pos_m'>0 & `n_no_m'>0) {
    local se_pos  = sqrt( (1/`n_pos_m') + (1/`n_no_m') )
    local mde_pos = K * `sigma' * `se_pos'
}

local mde_neg = .
if (`n_neg_m'>0 & `n_no_m'>0) {
    local se_neg  = sqrt( (1/`n_neg_m') + (1/`n_no_m') )
    local mde_neg = K * `sigma' * `se_neg'
}

local mde_pos_int = .
if (`n_pos_m'>0 & `n_no_m'>0 & `n_pos_f'>0 & `n_no_f'>0) {
    local se_pos_int  = sqrt( (1/`n_pos_m') + (1/`n_no_m') + (1/`n_pos_f') + (1/`n_no_f') )
    local mde_pos_int = K * `sigma' * `se_pos_int'
}

local mde_neg_int = .
if (`n_neg_m'>0 & `n_no_m'>0 & `n_neg_f'>0 & `n_no_f'>0) {
    local se_neg_int  = sqrt( (1/`n_neg_m') + (1/`n_no_m') + (1/`n_neg_f') + (1/`n_no_f') )
    local mde_neg_int = K * `sigma' * `se_neg_int'
}

*----------------------------
* Spec B: pooled trend with interaction
* SE(beta_m) ≈ sigma / sqrt(Sxx_m),   Sxx_m = sum (x - xbar)^2 among men
* Interaction SE(diff slopes) ≈ sigma * sqrt( 1/Sxx_m + 1/Sxx_f )
*----------------------------
quietly summarize positiveness if female_self==0 & !missing(`y') & !missing(positiveness)
local Nx_m   = r(N)
local Varx_m = r(Var)
local Sxx_m  = .
if (`Nx_m'>=2 & !missing(`Varx_m')) local Sxx_m = `Varx_m' * (`Nx_m' - 1)

quietly summarize positiveness if female_self==1 & !missing(`y') & !missing(positiveness)
local Nx_f   = r(N)
local Varx_f = r(Var)
local Sxx_f  = .
if (`Nx_f'>=2 & !missing(`Varx_f')) local Sxx_f = `Varx_f' * (`Nx_f' - 1)

local mde_trend = .
if (!missing(`Sxx_m') & `Sxx_m'>0) {
    local se_trend  = 1/sqrt(`Sxx_m')
    local mde_trend = K * `sigma' * `se_trend'
}

local mde_trend_int = .
if (!missing(`Sxx_m') & !missing(`Sxx_f') & `Sxx_m'>0 & `Sxx_f'>0) {
    local se_trend_int  = sqrt( 1/`Sxx_m' + 1/`Sxx_f' )
    local mde_trend_int = K * `sigma' * `se_trend_int'
}

* Format values for display
local mde_pos_s       = cond(missing(`mde_pos'), ".", string(`mde_pos',"%9.2f"))
local mde_neg_s       = cond(missing(`mde_neg'), ".", string(`mde_neg',"%9.2f"))
local mde_pos_int_s   = cond(missing(`mde_pos_int'), ".", string(`mde_pos_int',"%9.2f"))
local mde_neg_int_s   = cond(missing(`mde_neg_int'), ".", string(`mde_neg_int',"%9.2f"))
local mde_trend_s     = cond(missing(`mde_trend'), ".", string(`mde_trend',"%9.2f"))
local mde_trend_int_s = cond(missing(`mde_trend_int'), ".", string(`mde_trend_int',"%9.2f"))

*-----------------------------
* Write LaTeX table
*-----------------------------
tempname fh 
file open `fh' using "`outtex'", write replace text

file write `fh' "\begin{table}[htbp]\centering" _n
file write `fh' "\caption{Ex-ante minimum detectable effects (MDEs) for key parameters (\texttt{invest\_ref})}" _n
file write `fh' "\label{tab:mde_exante_keyparams}" _n
file write `fh' "\begin{threeparttable}" _n
file write `fh' "\begin{tabular}{lr}" _n
file write `fh' "\toprule" _n
file write `fh' "Parameter (pooled spec) & MDE (ECU) \\\\" _n
file write `fh' "\midrule" _n
file write `fh' "Positive Information (\texttt{pos\_info}) & `mde_pos_s' \\\\" _n
file write `fh' "Negative Information (\texttt{neg\_info}) & `mde_neg_s' \\\\" _n
file write `fh' "Positive Information $\times$ Female & `mde_pos_int_s' \\\\" _n
file write `fh' "Negative Information $\times$ Female & `mde_neg_int_s' \\\\" _n
file write `fh' "Positiveness (\texttt{positiveness}) & `mde_trend_s' \\\\" _n
file write `fh' "Positiveness $\times$ Female & `mde_trend_int_s' \\\\" _n
file write `fh' "\bottomrule" _n
file write `fh' "\end{tabular}" _n

* Notes kept short
file write `fh' "\begin{tablenotes}\footnotesize" _n
file write `fh' "\item Notes: Ex-ante MDEs are computed as $MDE=K\cdot\sigma\cdot SE_{\text{design}}$ with two-sided $\alpha=`alpha'$ and power $=`power'$ (so $K\approx `Kstr'$). $\sigma$ is the SD of \texttt{invest\_ref} in the pooled No-Info group (here: `sigstr'). $SE_{\text{design}}$ uses realized cell sizes (for \texttt{pos\_info}/\texttt{neg\_info}: treatment vs.\ No-Info within the baseline group; for interactions: the corresponding difference-in-differences across male/female cells; for \texttt{positiveness}: OLS slope precision based on $S_{xx}$ within gender)." _n
file write `fh' "\end{tablenotes}" _n

file write `fh' "\end{threeparttable}" _n
file write `fh' "\end{table}" _n

file close `fh'

display as text "Saved LaTeX table to: `outtex' (in " c(pwd) ")"
*******************************************************
