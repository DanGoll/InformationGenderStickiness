Replication package for the results of the manuscript “Information, gender, and the stickiness of the reference in decision-making under risk”.

by:

Daniel Goller, University of Bern, daniel.goller@unibe.ch
Maximilian Späth, University of Potsdam.

The package contains 2 .xlsx files that contain the raw data for Study 1 and Study 2.

- Diving.xlsx (Study 1)
- data_experiment.xlsx (Study 2)

In the .do files one needs to change the working direction to the path of the folder "Replication" that contains the "data"-folder. Tables and Figures are stored in the working direction as jpeg/pdf/tex files. There are 5 .do files (STATA format) that replicate all the tables and figures:

edit_diving.do
- includes all the data preparation steps from the raw data (Diving.xlsx) to the data used for the regression (diving.dta)

reg_diving.do
- replicates Table 1
- replicates Table A.2
- replicates Table A.3

descriptive_diving.do
- replicates Figures 2a and 2b
- replicates Table A.1

reg_experiment.do
- replicates Table 2
- replicates Figures 3a and 3b
- replicates the mediation analysis including the Tables B.2-B.5

balancing_experiment.do
- replicates the Table B.1 “Balance table, demographics across experimental conditions”
- replicates the minimum detectable effects (MDEs) that are reported in Footnote 3.




VARIABLE DEFINITIONS

Diving data

AthleteID Athlete identifier. Used to define individual fixed effects and to cluster standard errors at the athlete level.

stay_ref Stay with reference difficulty. Binary indicator equal to 1 if the athlete remains with the reference difficulty and 0 if the athlete changes away from it.

female Female indicator. Equal to 1 for women and 0 for men.

pr_good Positive Information. Indicator for assignment to the positive-information treatment.

pr_bad Negative Information. Indicator for assignment to the negative-information treatment.

pr_positiveness Positiveness of the information treatment. Coded as -1 for negative information, 0 for no or neutral information, and 1 for positive information.

pr_good_fem Positive Information x Female. Interaction between pr_good and female.

pr_bad_fem Negative Information x Female. Interaction between pr_bad and female.

pr_positiveness_fem Positiveness x Female. Interaction between pr_positiveness and female.

diff_stylepoints_3 Difference Performance. Difference in the performance measure used as the outcome in Tables A.2 and A.3.

diff_score Difference Score. Difference in the score measure used as the outcome in Tables A.2 and A.3.

change_ref Change away from reference. Binary indicator equal to 1 if the athlete changes away from the reference difficulty.

Difficulty Subsequent difficulty. Difficulty selected for the subsequent dive.



experiment data


invest_ref Investment into the reference lottery. Outcome variable in Table 2 and in the mediation analyses.

female_self Female indicator. Equal to 1 for women and 0 for men.

pos_info Positive Information. Indicator for assignment to the positive-information treatment.

neg_info Negative Information. Indicator for assignment to the negative-information treatment.

positiveness Positiveness of the information treatment. Coded as -1 for negative information, 0 for no or neutral information, and 1 for positive information.

pos_info_fem Positive Information x Female. Interaction between pos_info and female_self.

neg_info_fem Negative Information x Female. Interaction between neg_info and female_self.

positiv_fem Positiveness x Female. Interaction between positiveness and female_self.

norm_rel_prob Normalized relative probability assessment. Mediator used in the probability mediation analyses reported in Tables B.2 and B.3.

norm_rel_attract Normalized relative attractiveness assessment. Mediator used in the attractiveness mediation analyses reported in Tables B.4 and B.5.
