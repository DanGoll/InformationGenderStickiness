clear all
set more off

cd "/.../data/"

import excel "Diving.xlsx", sheet("Data") firstrow allstring


* Additional date variables: day, month, and year
split Date,p("/")

rename Date1 Month
destring Month,replace

rename Date2 Day
destring Day,replace

rename Date3 Year
destring Year,replace


* Construct variables for estimation
g Final=0
replace Final=1 if Round=="Final"

g home_event=0
replace home_event=1 if Land==Athlete_nation

g event_1m=0
replace event_1m=1 if Event=="1m"

g event_3m=0
replace event_3m=1 if Event=="3m"

g event_10m=0
replace event_10m=1 if Event=="10m"

g female=0
replace female=1 if Gender=="Ladies"

g Penalty=0
replace Penalty=1 if Penalties=="2"
drop Penalties


* Convert string variables to numeric variables
destring Competitors,replace
destring Tournament_event,replace
destring Jump,replace
destring DD,replace
rename DD Difficulty
destring J1,replace
destring J2,replace
destring J3,replace
destring J4,replace
destring J5,replace
destring J6,replace
destring J7,replace
destring Score,replace
destring RankJump,replace
destring Total,replace
destring RankTotal,replace
destring Behind,replace
replace Behind=0 if Behind==.&RankTotal==1
destring AthleteID,replace
destring Treshold,replace
destring WEIRD,replace
destring Ostasien,replace
destring Startorder,replace
destring cult_dist_toUS,replace
destring individualism,replace



* Rename variables to facilitate reshaping
rename J1 Points_1
rename J2 Points_2
rename J3 Points_3
rename J4 Points_4
rename J5 Points_5
rename J6 Points_6
rename J7 Points_7

g kont_af=0
replace kont_af=1 if Kontinent=="Africa"
label variable kont_af "Kontinent: Africa"

g kont_as=0
replace kont_as=1 if Kontinent=="Asia"
label variable kont_as "Kontinent: Asia"

g kont_ee=0
replace kont_ee=1 if Kontinent=="EuropeEast"
label variable kont_ee "Kontinent: Eastern Europe"

g kont_ew=0
replace kont_ew=1 if Kontinent=="EuropeWest"
label variable kont_ew "Kontinent: Western Europe"

g kont_la=0
replace kont_la=1 if Kontinent=="LatinAmerica"
label variable kont_la "Kontinent: Latin America"

g kont_na=0
replace kont_na=1 if Kontinent=="Northamerica"
label variable kont_na "Kontinent: North America"

g kont_oc=0
replace kont_oc=1 if Kontinent=="Oceania"
label variable kont_oc "Kontinent: Oceania"

* Date and age

g actualdate=date(Date,"MDY",1960)
g bidate=date(bdate,"MDY",1960)

g age=floor((actualdate-bidate)/365)

drop actualdate bidate bdate


* Identify judges who share the athlete's nationality
g J1_compat=0
replace J1_compat=1 if J1_nation==Athlete_nation

g J2_compat=0
replace J2_compat=1 if J2_nation==Athlete_nation

g J3_compat=0
replace J3_compat=1 if J3_nation==Athlete_nation

g J4_compat=0
replace J4_compat=1 if J4_nation==Athlete_nation

g J5_compat=0
replace J5_compat=1 if J5_nation==Athlete_nation

g J6_compat=0
replace J6_compat=1 if J6_nation==Athlete_nation

g J7_compat=0
replace J7_compat=1 if J7_nation==Athlete_nation

* Identify whether any judge shares the athlete's nationality
g J_any_compat=0
replace J_any_compat=1 if J1_compat|J2_compat|J3_compat|J4_compat|J5_compat|J6_compat|J7_compat

* Check the data for duplicates or errors
sort Date Starttime AthleteID Jump
quietly by Date Starttime AthleteID Jump:  gen dup = cond(_N==1,0,_n)
tab dup /* No duplicates found */
drop dup

/* Identify which judges' scores are discarded and which judges assigned them */
* Reshape from one observation to seven judge-level observations
reshape long Points_, i(Date Starttime AthleteID Jump) j(JudgeNummer)
rename Points_ Points

sort Date Starttime AthleteID Jump Points

by Date Starttime AthleteID Jump (Points), sort: gen rank_order = _n


g Points_min1x=Points if rank_order==1
g Points_min2x=Points if rank_order==2
g Points_min3x=Points if rank_order==3
g Points_min4x=Points if rank_order==4
g Points_min5x=Points if rank_order==5
g Points_min6x=Points if rank_order==6
g Points_min7x=Points if rank_order==7

g Points_sd=Points if rank_order==3|rank_order==4|rank_order==5

egen stylepoints_sd=sd(Points_sd), by (Date Starttime AthleteID Jump)
drop Points_sd

egen Points_min1=max(Points_min1x), by (Date Starttime AthleteID Jump)
egen Points_min2=max(Points_min2x), by (Date Starttime AthleteID Jump)
egen Points_min3=max(Points_min3x), by (Date Starttime AthleteID Jump)
egen Points_min4=max(Points_min4x), by (Date Starttime AthleteID Jump)
egen Points_min5=max(Points_min5x), by (Date Starttime AthleteID Jump)
egen Points_min6=max(Points_min6x), by (Date Starttime AthleteID Jump)
egen Points_min7=max(Points_min7x), by (Date Starttime AthleteID Jump)

* Identify scores assigned by a judge who shares the athlete's nationality
g rank_judge_compatx=0
replace rank_judge_compatx=rank_order if J1_compat&JudgeNummer==1
replace rank_judge_compatx=rank_order if J2_compat&JudgeNummer==2
replace rank_judge_compatx=rank_order if J3_compat&JudgeNummer==3
replace rank_judge_compatx=rank_order if J4_compat&JudgeNummer==4
replace rank_judge_compatx=rank_order if J5_compat&JudgeNummer==5
replace rank_judge_compatx=rank_order if J6_compat&JudgeNummer==6
replace rank_judge_compatx=rank_order if J7_compat&JudgeNummer==7

egen rank_judge_compat=max(rank_judge_compatx), by (Date Starttime AthleteID Jump)

drop Points_min1x Points_min2x Points_min3x Points_min4x Points_min5x Points_min6x Points_min7x rank_order rank_judge_compatx

* Return to the original format: one observation per dive
reshape wide Points, i(Date Starttime AthleteID Jump) j(JudgeNummer)


* Generate outcome variables
g stylepoints_3 = (Points_min3+Points_min4+Points_min5)/3
g stylepoints_5 = (Points_min2+Points_min3+Points_min4+Points_min5+Points_min6)/5
g stylepoints_7 = (Points_min1+Points_min2+Points_min3+Points_min4+Points_min5+Points_min6+Points_min7)/7


g dev_neg= Points_min3 - Points_min1
label variable dev_neg "min minus lowest gewertete"
g dev_pos=Points_min7 - Points_min5
label variable dev_pos "max minus highest gewertete"

g dev_neg_m=  stylepoints_3 - Points_min1
label variable dev_neg_m "min minus mean"
g dev_pos_m=Points_min7 - stylepoints_3
label variable dev_pos_m "max minus mean"

g dev_neg2_m= stylepoints_3 - (Points_min1+Points_min2)/2 
label variable dev_neg_m "min 2 minus mean"
g dev_pos2_m=(Points_min7+Points_min6)/2 - stylepoints_3
label variable dev_pos_m "max 2 minus mean"

g dev_points=stylepoints_7-stylepoints_3

sort Tournament_event AthleteID
egen AthleteContestID=group (Tournament_event AthleteID)


sort AthleteID Year
egen AthleteYearID=group (AthleteID Year)

egen tournament_round_id=group(Date Starttime)

sort tournament_round_id
by tournament_round_id: gen thres_points=Total if Treshold==RankTotal 
sort tournament_round_id Jump
by tournament_round_id Jump: egen thres_points2=max(thres_points)
g behind_thres=thres_points2-Total
g in_close_range=1
replace in_close_range=0 if behind_thres<-5
replace in_close_range=0 if behind_thres>5

g in_range=1
replace in_range=0 if behind_thres<-10
replace in_range=0 if behind_thres>10

sort Date Starttime AthleteID Jump 

by Date Starttime AthleteID: egen Pos_roundw=mean(RankTotal) if Jump==5&Gender=="Ladies"
by Date Starttime AthleteID: egen Pos_roundm=mean(RankTotal) if Jump==6&Gender=="Men"
by Date Starttime AthleteID: egen Pos_roundw2=max(Pos_roundw)
by Date Starttime AthleteID: egen Pos_roundm2=max(Pos_roundm)

drop Pos_roundm Pos_roundw

/* Generate a unique tournament identifier */
replace Ort="Guadalajara2" if Ort=="Guadalajara"&Date=="5/25/2013"
replace Ort="Guadalajara2" if Ort=="Guadalajara"&Date=="5/26/2013"

replace Ort="Kazan1" if Ort=="Kazan"&Date=="4/25/2015"
replace Ort="Kazan1" if Ort=="Kazan"&Date=="4/26/2015"

g Pos_round=Pos_roundw2 
replace Pos_round=Pos_roundm2 if Pos_round==.

g tempRound=3 if Round=="Final"
replace tempRound=2 if Round=="Semifinal"
replace tempRound=1 if Round=="Preliminary"

sort Year Ort Gender Event AthleteID tempRound Jump

by Year Ort Gender Event AthleteID: gen prevPos2=Pos_round[_n-1] if Jump==1
by Year Ort Gender Event AthleteID tempRound: egen prevPos=max(prevPos2)
g Start2=Competitors+1-prevPos if prevPos!=.

replace Startorder=Start2 if Startorder==.

drop prevPos2 tempRound Pos_roundm2 Pos_roundw2 Start2

replace Round="1" if Round=="Preliminary"
replace Round="2" if Round=="Semifinal"
replace Round="3" if Round=="Final"

destring Round,replace

lab var Round "Round"
lab def Roundlb ///
1	"Preliminary" ///
2	"Semifinal" ///
3	"Final"

lab val Round Roundlb


sort Tournament_event Round AthleteID
by Tournament_event Round AthleteID: egen av_stylepoints=mean(stylepoints_3)

g diff_stylepoints=round(stylepoints_3-av_stylepoints,.1)


sort Year Month Day Starttime AthleteID Jump
by Year Month Day Starttime AthleteID: gen lag_dev_neg = dev_neg[_n-1]
by Year Month Day Starttime AthleteID: gen lag_dev_neg_m = dev_neg_m[_n-1]

by Year Month Day Starttime AthleteID: gen lag_dev_pos = dev_pos[_n-1]
by Year Month Day Starttime AthleteID: gen lag_dev_pos_m = dev_pos_m[_n-1]


sort Tournament_event AthleteID Jump Round
by Tournament_event AthleteID Jump: gen pr_diff=Difficulty[_n-1]
by Tournament_event AthleteID Jump: gen pr_stylepoints_3 = stylepoints_3[_n-1]
by Tournament_event AthleteID Jump: gen pr_diff_stylepoints_3=diff_stylepoints[_n-1]

by Tournament_event AthleteID Jump: gen pr_dev_neg = dev_neg[_n-1]
by Tournament_event AthleteID Jump: gen pr_dev_neg_m = dev_neg_m[_n-1]

by Tournament_event AthleteID Jump: gen pr_dev_points = dev_points[_n-1]

by Tournament_event AthleteID Jump: gen pr_dev_pos = dev_pos[_n-1]
by Tournament_event AthleteID Jump: gen pr_dev_pos_m = dev_pos_m[_n-1]

keep if pr_diff!=.

g difference_difficulty=round(Difficulty-pr_diff,.01)


save "diving.dta",replace
