
//===========================================================//
// Individual DID Analysis Main File
// O. General Settings
clear all
global Codes="D:\行庫使用專區\中央研究院_楊老師\Codes"
global Data="D:\行庫使用專區\中央研究院_楊老師\Data\"
global Input="YM201-I-4-CIF2.dta"

adopath + "C:\安裝軟體_勿刪\Stata\ado\plus"


cd "$Codes"
//===========================================================//


//===========================================================//
// A1. DID 分析: 第一波LTV限制2vs3 (2020M1-2021M12)
// with Many Collateral
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=202001 & Data_YM<=202112 // 丟去994,754

// 3. 擔保品不含多戶及青安樣本
// keep if NoManyCol_Sample==1
drop if YoungMG==1

// 4. DID 變數建立
gen Treat=1 if Hous==3 & Luxury==0
replace Treat=0 if Hous==2 & Luxury==0

gen Post=0 if Data_YM>=202001 & Data_YM<=202011
replace Post=1 if Data_YM>=202012 & Data_YM<=202112

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.
tab Treat

// 98. 檔案名稱設定(需與資料夾同名)
global Output="First_LTV2vs3"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202011).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#202001.Data_YM 1.Treat#202002.Data_YM 1.Treat#202003.Data_YM 1.Treat#202004.Data_YM 1.Treat#202005.Data_YM 1.Treat#202006.Data_YM 1.Treat#202007.Data_YM 1.Treat#202008.Data_YM 1.Treat#202009.Data_YM 1.Treat#202010.Data_YM 1o.Treat#202011b.Data_YM 1.Treat#202012.Data_YM 1.Treat#202101.Data_YM 1.Treat#202102.Data_YM 1.Treat#202103.Data_YM 1.Treat#202104.Data_YM 1.Treat#202105.Data_YM 1.Treat#202106.Data_YM 1.Treat#202107.Data_YM 1.Treat#202108.Data_YM 1.Treat#202109.Data_YM 1.Treat#202110.Data_YM 1.Treat#202111.Data_YM 1.Treat#202112.Data_YM"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/


//===========================================================//
// A2. DID 分析: 第一波LTV限制2vs3 (2020M1-2021M12)
// No Many Collateral
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=202001 & Data_YM<=202112 // 丟去994,754

// 3. 擔保品不含多戶及青安樣本
keep if NoManyCol_Sample==1
drop if YoungMG==1

// 4. DID 變數建立
gen Treat=1 if Hous==3 & Luxury==0
replace Treat=0 if Hous==2 & Luxury==0

gen Post=0 if Data_YM>=202001 & Data_YM<=202011
replace Post=1 if Data_YM>=202012 & Data_YM<=202112

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.
tab Treat

// 98. 檔案名稱設定(需與資料夾同名)
global Output="First_LTV2vs3_NMC"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202011).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#202001.Data_YM 1.Treat#202002.Data_YM 1.Treat#202003.Data_YM 1.Treat#202004.Data_YM 1.Treat#202005.Data_YM 1.Treat#202006.Data_YM 1.Treat#202007.Data_YM 1.Treat#202008.Data_YM 1.Treat#202009.Data_YM 1.Treat#202010.Data_YM 1o.Treat#202011b.Data_YM 1.Treat#202012.Data_YM 1.Treat#202101.Data_YM 1.Treat#202102.Data_YM 1.Treat#202103.Data_YM 1.Treat#202104.Data_YM 1.Treat#202105.Data_YM 1.Treat#202106.Data_YM 1.Treat#202107.Data_YM 1.Treat#202108.Data_YM 1.Treat#202109.Data_YM 1.Treat#202110.Data_YM 1.Treat#202111.Data_YM 1.Treat#202112.Data_YM"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/



//===========================================================//
// Y1. DID 分析: 新青安1vs1 (2023M1-2023M12)
// With Many Collateral
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=202301 & Data_YM<=202312 //

// 3. 擔保品不含多戶
// keep if NoManyCol_Sample==1

// 4. DID 變數建立 
gen Treat=1 if YoungMG>=1 & Hous==1 // 央行: 青安可以不用是第一戶(可房屋移轉)
replace Treat=0 if YoungMG==0 & Hous==1

gen Post=0 if Data_YM>=202204 & Data_YM<=202307
replace Post=1 if Data_YM>=202308 & Data_YM<=202312

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.
tab Treat

// 6. 調整錯誤青安利率 (2023年7月 2023年1 2 3月)
// 利率經過加權因此要四捨五入

// 2023年
// 1-3 月 1384戶青安用2.025(應為1.9) 154戶用1.815(應為1.69)
count if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=2.024 & Rate<=2.026
count if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=1.814 & Rate<=1.816
replace Rate=1.9 if Treat==1 & Data_YM>=202301 & Data_YM<=202303  & Rate >=2.024 & Rate<=2.026
replace Rate=1.69 if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=1.814 & Rate<=1.816

// 4-6 月 314人用2.15(應為2.025)
tab Rate if Treat==1 & Data_YM>=202304 & Data_YM<=202306
count if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=2.14 & Rate<=2.16
replace Rate=2.025 if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=2.14 & Rate<=2.16
replace Rate=1.815 if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=1.93 & Rate<=1.95

// 7月1148戶青安有66人用1.565(應為1.815) 779人用1.775(應為2.025)的新青安利率 有49人用2.15(應為2.025)
count if Data_YM==202307 & Hous==1 & YoungMG>=1 & Rate >=1.564 & Rate<=1.566
count if Data_YM==202307 & Hous==1 & YoungMG>=1 & Rate >=1.774 & Rate<=1.776
replace Rate=1.815 if Treat==1 & Data_YM==202307 & Rate >=1.564 & Rate<=1.566
replace Rate=2.025 if Treat==1 & Data_YM==202307 & Rate >=1.774 & Rate<=1.776
replace Rate=2.025 if Treat==1 & Data_YM==202307 & Rate >=2.014 & Rate<=2.16
replace Rate=1.815 if Treat==1 & Data_YM==202307 & Rate >=1.93 & Rate<=1.95

// 8-12 月 564人用2.15(應為1.775) 529人用2.025(應為1.775)
replace Rate=1.775 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=2.14 & Rate<=2.16
replace Rate=1.775 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=2.024 & Rate<=2.026
replace Rate=1.565 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=1.93 & Rate<=1.95
replace Rate=1.565 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=1.814 & Rate<=1.816



// 98. 檔案名稱設定(需與資料夾同名)
global Output="PHLY1vs1"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202307).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#202301.Data_YM 1.Treat#202302.Data_YM 1.Treat#202303.Data_YM 1.Treat#202304.Data_YM 1.Treat#202305.Data_YM 1.Treat#202306.Data_YM 1o.Treat#202307b.Data_YM 1.Treat#202308.Data_YM 1.Treat#202309.Data_YM 1.Treat#202310.Data_YM 1.Treat#202311.Data_YM 1.Treat#202312.Data_YM"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/


//===========================================================//
// Y2. DID 分析: 新青安1vs1 (2023M1-2023M12)
// No Many Collateral
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=202301 & Data_YM<=202312 //

// 3. 擔保品不含多戶
keep if NoManyCol_Sample==1

// 4. DID 變數建立 
gen Treat=1 if YoungMG>=1 & Hous==1 // 央行: 青安可以不用是第一戶(可房屋移轉)
replace Treat=0 if YoungMG==0 & Hous==1

gen Post=0 if Data_YM>=202204 & Data_YM<=202307
replace Post=1 if Data_YM>=202308 & Data_YM<=202312

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.
tab Treat

// 6. 調整錯誤青安利率 (2023年7月 2023年1 2 3月)
// 利率經過加權因此要四捨五入

// 2023年
// 1-3 月 1384戶青安用2.025(應為1.9) 154戶用1.815(應為1.69)
count if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=2.024 & Rate<=2.026
count if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=1.814 & Rate<=1.816
replace Rate=1.9 if Treat==1 & Data_YM>=202301 & Data_YM<=202303  & Rate >=2.024 & Rate<=2.026
replace Rate=1.69 if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=1.814 & Rate<=1.816

// 4-6 月 314人用2.15(應為2.025)
tab Rate if Treat==1 & Data_YM>=202304 & Data_YM<=202306
count if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=2.14 & Rate<=2.16
replace Rate=2.025 if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=2.14 & Rate<=2.16
replace Rate=1.815 if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=1.93 & Rate<=1.95

// 7月1148戶青安有66人用1.565(應為1.815) 779人用1.775(應為2.025)的新青安利率 有49人用2.15(應為2.025)
count if Data_YM==202307 & Hous==1 & YoungMG>=1 & Rate >=1.564 & Rate<=1.566
count if Data_YM==202307 & Hous==1 & YoungMG>=1 & Rate >=1.774 & Rate<=1.776
replace Rate=1.815 if Treat==1 & Data_YM==202307 & Rate >=1.564 & Rate<=1.566
replace Rate=2.025 if Treat==1 & Data_YM==202307 & Rate >=1.774 & Rate<=1.776
replace Rate=2.025 if Treat==1 & Data_YM==202307 & Rate >=2.014 & Rate<=2.16
replace Rate=1.815 if Treat==1 & Data_YM==202307 & Rate >=1.93 & Rate<=1.95

// 8-12 月 564人用2.15(應為1.775) 529人用2.025(應為1.775)
replace Rate=1.775 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=2.14 & Rate<=2.16
replace Rate=1.775 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=2.024 & Rate<=2.026
replace Rate=1.565 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=1.93 & Rate<=1.95
replace Rate=1.565 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=1.814 & Rate<=1.816


// 98. 檔案名稱設定(需與資料夾同名)
global Output="PHLY1vs1_NMC"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202307).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#202301.Data_YM 1.Treat#202302.Data_YM 1.Treat#202303.Data_YM 1.Treat#202304.Data_YM 1.Treat#202305.Data_YM 1.Treat#202306.Data_YM 1o.Treat#202307b.Data_YM 1.Treat#202308.Data_YM 1.Treat#202309.Data_YM 1.Treat#202310.Data_YM 1.Treat#202311.Data_YM 1.Treat#202312.Data_YM"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/


//===========================================================//
// A3. DID 分析: 第一波LTV限制2vs3 (2020M1-2021M12)
// with Many Collateral + Propensity Score Matching
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=202001 & Data_YM<=202112 // 丟去994,754

// 3. 擔保品不含多戶及青安樣本
// keep if NoManyCol_Sample==1
drop if YoungMG==1

// 4. DID 變數建立
gen Treat=1 if Hous==3 & Luxury==0
replace Treat=0 if Hous==2 & Luxury==0

gen Post=0 if Data_YM>=202001 & Data_YM<=202011
replace Post=1 if Data_YM>=202012 & Data_YM<=202112

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.

// 6. Propensity Score Matching (Post=0 Post=1分開Match)
gen Obs_ID=_n

// Pre-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==0, atet nn(3) gen(MatchID)
// predict ps0 ps1, ps

// 3:1 Matching
forvalues i=1/3{
preserve
keep if Treat==1 & Post==0
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta",replace
restore
}


drop MatchID*

// Post-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==1, atet nn(3) gen(MatchID)
forvalues i=1/3{
preserve
keep if Treat==1 & Post==1
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta",replace
restore
}

drop MatchID*

preserve
use "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_1.dta", clear
forvalues i=2/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta"
}
forvalues i=1/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta"
}
drop if Obs_ID==.
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta",replace
restore


merge 1:m Obs_ID Post using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta", gen(_mergePSM)
drop if _mergePSM!=3 & Treat==0
drop _mergePSM Obs_ID

tab Treat

// 98. 檔案名稱設定(需與資料夾同名)
global Output="First_LTV2vs3_PSM"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202011).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#202001.Data_YM 1.Treat#202002.Data_YM 1.Treat#202003.Data_YM 1.Treat#202004.Data_YM 1.Treat#202005.Data_YM 1.Treat#202006.Data_YM 1.Treat#202007.Data_YM 1.Treat#202008.Data_YM 1.Treat#202009.Data_YM 1.Treat#202010.Data_YM 1o.Treat#202011b.Data_YM 1.Treat#202012.Data_YM 1.Treat#202101.Data_YM 1.Treat#202102.Data_YM 1.Treat#202103.Data_YM 1.Treat#202104.Data_YM 1.Treat#202105.Data_YM 1.Treat#202106.Data_YM 1.Treat#202107.Data_YM 1.Treat#202108.Data_YM 1.Treat#202109.Data_YM 1.Treat#202110.Data_YM 1.Treat#202111.Data_YM 1.Treat#202112.Data_YM"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/

//===========================================================//
// A4. DID 分析: 第一波LTV限制2vs3 (2020M1-2021M12)
// No Many Collateral + Propensity Score Matching
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=202001 & Data_YM<=202112 // 丟去994,754

// 3. 擔保品不含多戶及青安樣本
keep if NoManyCol_Sample==1
drop if YoungMG==1

// 4. DID 變數建立
gen Treat=1 if Hous==3 & Luxury==0
replace Treat=0 if Hous==2 & Luxury==0

gen Post=0 if Data_YM>=202001 & Data_YM<=202011
replace Post=1 if Data_YM>=202012 & Data_YM<=202112

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.

// 6. Propensity Score Matching (Post=0 Post=1分開Match)
gen Obs_ID=_n

// Pre-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==0, atet nn(3) gen(MatchID)
// predict ps0 ps1, ps

// 3:1 Matching
forvalues i=1/3{
preserve
keep if Treat==1 & Post==0
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta",replace
restore
}


drop MatchID*

// Post-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==1, atet nn(3) gen(MatchID)
forvalues i=1/3{
preserve
keep if Treat==1 & Post==1
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta",replace
restore
}

drop MatchID*

preserve
use "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_1.dta", clear
forvalues i=2/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta"
}
forvalues i=1/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta"
}
drop if Obs_ID==.
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta",replace
restore


merge 1:m Obs_ID Post using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta", gen(_mergePSM)
drop if _mergePSM!=3 & Treat==0
drop _mergePSM Obs_ID

tab Treat

// 98. 檔案名稱設定(需與資料夾同名)
global Output="First_LTV2vs3_NMC_PSM"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202011).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#202001.Data_YM 1.Treat#202002.Data_YM 1.Treat#202003.Data_YM 1.Treat#202004.Data_YM 1.Treat#202005.Data_YM 1.Treat#202006.Data_YM 1.Treat#202007.Data_YM 1.Treat#202008.Data_YM 1.Treat#202009.Data_YM 1.Treat#202010.Data_YM 1o.Treat#202011b.Data_YM 1.Treat#202012.Data_YM 1.Treat#202101.Data_YM 1.Treat#202102.Data_YM 1.Treat#202103.Data_YM 1.Treat#202104.Data_YM 1.Treat#202105.Data_YM 1.Treat#202106.Data_YM 1.Treat#202107.Data_YM 1.Treat#202108.Data_YM 1.Treat#202109.Data_YM 1.Treat#202110.Data_YM 1.Treat#202111.Data_YM 1.Treat#202112.Data_YM"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/




//===========================================================//
// Y3. DID 分析: 新青安1vs1 (2023M1-2023M12)
// With Many Collateral + PSM
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=202301 & Data_YM<=202312 //

// 3. 擔保品不含多戶
// keep if NoManyCol_Sample==1

// 4. DID 變數建立 
gen Treat=1 if YoungMG>=1 & Hous==1 // 央行: 青安可以不用是第一戶(可房屋移轉)
replace Treat=0 if YoungMG==0 & Hous==1

gen Post=0 if Data_YM>=202204 & Data_YM<=202307
replace Post=1 if Data_YM>=202308 & Data_YM<=202312

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.

// 6. Propensity Score Matching (Post=0 Post=1分開Match)
gen Obs_ID=_n

// Pre-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==0, atet nn(3) gen(MatchID)
// predict ps0 ps1, ps

// 3:1 Matching
forvalues i=1/3{
preserve
keep if Treat==1 & Post==0
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta",replace
restore
}


drop MatchID*

// Post-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==1, atet nn(3) gen(MatchID)
forvalues i=1/3{
preserve
keep if Treat==1 & Post==1
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta",replace
restore
}

drop MatchID*

preserve
use "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_1.dta", clear
forvalues i=2/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta"
}
forvalues i=1/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta"
}
drop if Obs_ID==.
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta",replace
restore


merge 1:m Obs_ID Post using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta", gen(_mergePSM)
drop if _mergePSM!=3 & Treat==0
drop _mergePSM Obs_ID

tab Treat

// 6. 調整錯誤青安利率 (2023年7月 2023年1 2 3月)
// 利率經過加權因此要四捨五入

// 2023年
// 1-3 月 1384戶青安用2.025(應為1.9) 154戶用1.815(應為1.69)
count if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=2.024 & Rate<=2.026
count if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=1.814 & Rate<=1.816
replace Rate=1.9 if Treat==1 & Data_YM>=202301 & Data_YM<=202303  & Rate >=2.024 & Rate<=2.026
replace Rate=1.69 if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=1.814 & Rate<=1.816

// 4-6 月 314人用2.15(應為2.025)
tab Rate if Treat==1 & Data_YM>=202304 & Data_YM<=202306
count if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=2.14 & Rate<=2.16
replace Rate=2.025 if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=2.14 & Rate<=2.16
replace Rate=1.815 if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=1.93 & Rate<=1.95

// 7月1148戶青安有66人用1.565(應為1.815) 779人用1.775(應為2.025)的新青安利率 有49人用2.15(應為2.025)
count if Data_YM==202307 & Hous==1 & YoungMG>=1 & Rate >=1.564 & Rate<=1.566
count if Data_YM==202307 & Hous==1 & YoungMG>=1 & Rate >=1.774 & Rate<=1.776
replace Rate=1.815 if Treat==1 & Data_YM==202307 & Rate >=1.564 & Rate<=1.566
replace Rate=2.025 if Treat==1 & Data_YM==202307 & Rate >=1.774 & Rate<=1.776
replace Rate=2.025 if Treat==1 & Data_YM==202307 & Rate >=2.014 & Rate<=2.16
replace Rate=1.815 if Treat==1 & Data_YM==202307 & Rate >=1.93 & Rate<=1.95

// 8-12 月 564人用2.15(應為1.775) 529人用2.025(應為1.775)
replace Rate=1.775 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=2.14 & Rate<=2.16
replace Rate=1.775 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=2.024 & Rate<=2.026
replace Rate=1.565 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=1.93 & Rate<=1.95
replace Rate=1.565 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=1.814 & Rate<=1.816


// 98. 檔案名稱設定(需與資料夾同名)
global Output="PHLY1vs1_PSM"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202307).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#202301.Data_YM 1.Treat#202302.Data_YM 1.Treat#202303.Data_YM 1.Treat#202304.Data_YM 1.Treat#202305.Data_YM 1.Treat#202306.Data_YM 1o.Treat#202307b.Data_YM 1.Treat#202308.Data_YM 1.Treat#202309.Data_YM 1.Treat#202310.Data_YM 1.Treat#202311.Data_YM 1.Treat#202312.Data_YM"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/

/*
//===========================================================//
// Y3B. DID 分析: 新青安1vs1 (2023M1-2023M12)
// With Many Collateral + PSM 1:10
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=202301 & Data_YM<=202312 //

// 3. 擔保品不含多戶
// keep if NoManyCol_Sample==1

// 4. DID 變數建立 
gen Treat=1 if YoungMG>=1 & Hous==1 // 央行: 青安可以不用是第一戶(可房屋移轉)
replace Treat=0 if YoungMG==0 & Hous==1

gen Post=0 if Data_YM>=202204 & Data_YM<=202307
replace Post=1 if Data_YM>=202308 & Data_YM<=202312

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.

// 6. Propensity Score Matching (Post=0 Post=1分開Match)
gen Obs_ID=_n

// Pre-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==0, atet nn(10) gen(MatchID)
// predict ps0 ps1, ps

// 10:1 Matching
forvalues i=1/10{
preserve
keep if Treat==1 & Post==0
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta",replace
restore
}


drop MatchID*

// Post-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==1, atet nn(10) gen(MatchID)
forvalues i=1/10{
preserve
keep if Treat==1 & Post==1
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta",replace
restore
}

drop MatchID*

preserve
use "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_1.dta", clear
forvalues i=2/10{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta"
}
forvalues i=1/10{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta"
}
drop if Obs_ID==.
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta",replace
restore


merge 1:m Obs_ID Post using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta", gen(_mergePSM)
drop if _mergePSM!=3 & Treat==0
drop _mergePSM Obs_ID

tab Treat

// 6. 調整錯誤青安利率 (2023年7月 2023年1 2 3月)
// 利率經過加權因此要四捨五入

// 2023年
// 1-3 月 1384戶青安用2.025(應為1.9) 154戶用1.815(應為1.69)
count if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=2.024 & Rate<=2.026
count if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=1.814 & Rate<=1.816
replace Rate=1.9 if Treat==1 & Data_YM>=202301 & Data_YM<=202303  & Rate >=2.024 & Rate<=2.026
replace Rate=1.69 if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=1.814 & Rate<=1.816

// 4-6 月 314人用2.15(應為2.025)
tab Rate if Treat==1 & Data_YM>=202304 & Data_YM<=202306
count if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=2.14 & Rate<=2.16
replace Rate=2.025 if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=2.14 & Rate<=2.16
replace Rate=1.815 if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=1.93 & Rate<=1.95

// 7月1148戶青安有66人用1.565(應為1.815) 779人用1.775(應為2.025)的新青安利率 有49人用2.15(應為2.025)
count if Data_YM==202307 & Hous==1 & YoungMG>=1 & Rate >=1.564 & Rate<=1.566
count if Data_YM==202307 & Hous==1 & YoungMG>=1 & Rate >=1.774 & Rate<=1.776
replace Rate=1.815 if Treat==1 & Data_YM==202307 & Rate >=1.564 & Rate<=1.566
replace Rate=2.025 if Treat==1 & Data_YM==202307 & Rate >=1.774 & Rate<=1.776
replace Rate=2.025 if Treat==1 & Data_YM==202307 & Rate >=2.014 & Rate<=2.16
replace Rate=1.815 if Treat==1 & Data_YM==202307 & Rate >=1.93 & Rate<=1.95

// 8-12 月 564人用2.15(應為1.775) 529人用2.025(應為1.775)
replace Rate=1.775 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=2.14 & Rate<=2.16
replace Rate=1.775 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=2.024 & Rate<=2.026
replace Rate=1.565 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=1.93 & Rate<=1.95
replace Rate=1.565 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=1.814 & Rate<=1.816


// 98. 檔案名稱設定(需與資料夾同名)
global Output="PHLY1vs1_PSM10"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202307).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#202301.Data_YM 1.Treat#202302.Data_YM 1.Treat#202303.Data_YM 1.Treat#202304.Data_YM 1.Treat#202305.Data_YM 1.Treat#202306.Data_YM 1o.Treat#202307b.Data_YM 1.Treat#202308.Data_YM 1.Treat#202309.Data_YM 1.Treat#202310.Data_YM 1.Treat#202311.Data_YM 1.Treat#202312.Data_YM"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/

*/
//===========================================================//
// Y4. DID 分析: 新青安1vs1 (2023M1-2023M12)
// No Many Collateral + PSM
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=202301 & Data_YM<=202312 //

// 3. 擔保品不含多戶
keep if NoManyCol_Sample==1

// 4. DID 變數建立 
gen Treat=1 if YoungMG>=1 & Hous==1
replace Treat=0 if YoungMG==0 & Hous==1

gen Post=0 if Data_YM>=202204 & Data_YM<=202307
replace Post=1 if Data_YM>=202308 & Data_YM<=202312

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.

// 6. Propensity Score Matching (Post=0 Post=1分開Match)
gen Obs_ID=_n

// Pre-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==0, atet nn(3) gen(MatchID)
// predict ps0 ps1, ps

// 3:1 Matching
forvalues i=1/3{
preserve
keep if Treat==1 & Post==0
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta",replace
restore
}


drop MatchID*

// Post-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==1, atet nn(3) gen(MatchID)
forvalues i=1/3{
preserve
keep if Treat==1 & Post==1
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta",replace
restore
}

drop MatchID*

preserve
use "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_1.dta", clear
forvalues i=2/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta"
}
forvalues i=1/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta"
}
drop if Obs_ID==.
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta",replace
restore


merge 1:m Obs_ID Post using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta", gen(_mergePSM)
drop if _mergePSM!=3 & Treat==0
drop _mergePSM Obs_ID

tab Treat


// 6. 調整錯誤青安利率 (2023年7月 2023年1 2 3月)
// 利率經過加權因此要四捨五入

// 2023年
// 1-3 月 1384戶青安用2.025(應為1.9) 154戶用1.815(應為1.69)
count if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=2.024 & Rate<=2.026
count if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=1.814 & Rate<=1.816
replace Rate=1.9 if Treat==1 & Data_YM>=202301 & Data_YM<=202303  & Rate >=2.024 & Rate<=2.026
replace Rate=1.69 if Treat==1 & Data_YM>=202301 & Data_YM<=202303 & Rate >=1.814 & Rate<=1.816

// 4-6 月 314人用2.15(應為2.025)
tab Rate if Treat==1 & Data_YM>=202304 & Data_YM<=202306
count if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=2.14 & Rate<=2.16
replace Rate=2.025 if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=2.14 & Rate<=2.16
replace Rate=1.815 if Treat==1 & Data_YM>=202304 & Data_YM<=202306 & Rate >=1.93 & Rate<=1.95

// 7月1148戶青安有66人用1.565(應為1.815) 779人用1.775(應為2.025)的新青安利率 有49人用2.15(應為2.025)
count if Data_YM==202307 & Hous==1 & YoungMG>=1 & Rate >=1.564 & Rate<=1.566
count if Data_YM==202307 & Hous==1 & YoungMG>=1 & Rate >=1.774 & Rate<=1.776
replace Rate=1.815 if Treat==1 & Data_YM==202307 & Rate >=1.564 & Rate<=1.566
replace Rate=2.025 if Treat==1 & Data_YM==202307 & Rate >=1.774 & Rate<=1.776
replace Rate=2.025 if Treat==1 & Data_YM==202307 & Rate >=2.014 & Rate<=2.16
replace Rate=1.815 if Treat==1 & Data_YM==202307 & Rate >=1.93 & Rate<=1.95

// 8-12 月 564人用2.15(應為1.775) 529人用2.025(應為1.775)
replace Rate=1.775 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=2.14 & Rate<=2.16
replace Rate=1.775 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=2.024 & Rate<=2.026
replace Rate=1.565 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=1.93 & Rate<=1.95
replace Rate=1.565 if Treat==1 & Data_YM>=202308 & Data_YM<=202312 & Rate >=1.814 & Rate<=1.816


// 98. 檔案名稱設定(需與資料夾同名)
global Output="PHLY1vs1_NMC_PSM"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202307).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#202301.Data_YM 1.Treat#202302.Data_YM 1.Treat#202303.Data_YM 1.Treat#202304.Data_YM 1.Treat#202305.Data_YM 1.Treat#202306.Data_YM 1o.Treat#202307b.Data_YM 1.Treat#202308.Data_YM 1.Treat#202309.Data_YM 1.Treat#202310.Data_YM 1.Treat#202311.Data_YM 1.Treat#202312.Data_YM"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/



//===========================================================//
// Individual DID Analysis Main File
// O. General Settings
clear all
global Codes="D:\行庫使用專區\中央研究院_楊老師\Codes"
global Data="D:\行庫使用專區\中央研究院_楊老師\Data\"
global Input="YM201-I-4-CIF2.dta"

adopath + "C:\安裝軟體_勿刪\Stata\ado\plus"


cd "$Codes"
//===========================================================//


//===========================================================//
// A1. DID 分析: 第一波LTV限制2vs3 (2020M1-2021M12)
// with Many Collateral
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=201912 & Data_YM<=202108 // 丟去994,754

// 3. 擔保品不含多戶及青安樣本
// keep if NoManyCol_Sample==1
drop if YoungMG==1

// 4. DID 變數建立
gen Treat=1 if Hous==3 & Luxury==0
replace Treat=0 if Hous==2 & Luxury==0

gen Post=0 if Data_YM>=201912 & Data_YM<=202011
replace Post=1 if Data_YM>=202012 & Data_YM<=202108

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.
tab Treat

// 98. 檔案名稱設定(需與資料夾同名)
global Output="First_LTV2vs3"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202011).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#201912.Data_YM 1.Treat#201912.Data_YM 1.Treat#202001.Data_YM 1.Treat#202002.Data_YM 1.Treat#202003.Data_YM 1.Treat#202004.Data_YM 1.Treat#202005.Data_YM 1.Treat#202006.Data_YM 1.Treat#202007.Data_YM 1.Treat#202008.Data_YM 1.Treat#202009.Data_YM 1.Treat#202010.Data_YM 1o.Treat#202011b.Data_YM 1.Treat#202012.Data_YM 1.Treat#202101.Data_YM 1.Treat#202102.Data_YM 1.Treat#202103.Data_YM 1.Treat#202104.Data_YM 1.Treat#202105.Data_YM 1.Treat#202106.Data_YM 1.Treat#202107.Data_YM 1.Treat#202108.Data_YM"

gen Q=0
replace Q=1 if Data_YM==201912 | Data_YM==202001 | Data_YM==202002
replace Q=2 if Data_YM==202003 | Data_YM==202004 | Data_YM==202005
replace Q=3 if Data_YM==202006 | Data_YM==202007 | Data_YM==202008
replace Q=4 if Data_YM==202009 | Data_YM==202010 | Data_YM==202011
replace Q=5 if Data_YM==202012 | Data_YM==202101 | Data_YM==202102
replace Q=6 if Data_YM==202103 | Data_YM==202104 | Data_YM==202105
replace Q=7 if Data_YM==202106 | Data_YM==202107 | Data_YM==202108

gen TreatQ1=0
gen TreatQ2=0
gen TreatQ3=0
gen TreatQ5=0
gen TreatQ6=0
gen TreatQ7=0

replace TreatQ1=1 if Treat==1 & Q==1
replace TreatQ2=1 if Treat==1 & Q==2
replace TreatQ3=1 if Treat==1 & Q==3
replace TreatQ5=1 if Treat==1 & Q==5
replace TreatQ6=1 if Treat==1 & Q==6
replace TreatQ7=1 if Treat==1 & Q==7

global VarXQ="TreatQ1 TreatQ2 TreatQ3 TreatQ5 TreatQ6 TreatQ7 Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"

global TimeListQ="TreatQ1 TreatQ2 TreatQ3 TreatQ5 TreatQ6 TreatQ7"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
// do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/


//===========================================================//
// A2. DID 分析: 第一波LTV限制2vs3 (2020M1-2021M12)
// No Many Collateral
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=201912 & Data_YM<=202108 // 丟去994,754

// 3. 擔保品不含多戶及青安樣本
keep if NoManyCol_Sample==1
drop if YoungMG==1

// 4. DID 變數建立
gen Treat=1 if Hous==3 & Luxury==0
replace Treat=0 if Hous==2 & Luxury==0

gen Post=0 if Data_YM>=201912 & Data_YM<=202011
replace Post=1 if Data_YM>=202012 & Data_YM<=202108

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.
tab Treat

// 98. 檔案名稱設定(需與資料夾同名)
global Output="First_LTV2vs3_NMC"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202011).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#201912.Data_YM 1.Treat#202001.Data_YM 1.Treat#202002.Data_YM 1.Treat#202003.Data_YM 1.Treat#202004.Data_YM 1.Treat#202005.Data_YM 1.Treat#202006.Data_YM 1.Treat#202007.Data_YM 1.Treat#202008.Data_YM 1.Treat#202009.Data_YM 1.Treat#202010.Data_YM 1o.Treat#202011b.Data_YM 1.Treat#202012.Data_YM 1.Treat#202101.Data_YM 1.Treat#202102.Data_YM 1.Treat#202103.Data_YM 1.Treat#202104.Data_YM 1.Treat#202105.Data_YM 1.Treat#202106.Data_YM 1.Treat#202107.Data_YM 1.Treat#202108.Data_YM"

gen Q=0
replace Q=1 if Data_YM==201912 | Data_YM==202001 | Data_YM==202002
replace Q=2 if Data_YM==202003 | Data_YM==202004 | Data_YM==202005
replace Q=3 if Data_YM==202006 | Data_YM==202007 | Data_YM==202008
replace Q=4 if Data_YM==202009 | Data_YM==202010 | Data_YM==202011
replace Q=5 if Data_YM==202012 | Data_YM==202101 | Data_YM==202102
replace Q=6 if Data_YM==202103 | Data_YM==202104 | Data_YM==202105
replace Q=7 if Data_YM==202106 | Data_YM==202107 | Data_YM==202108

gen TreatQ1=0
gen TreatQ2=0
gen TreatQ3=0
gen TreatQ5=0
gen TreatQ6=0
gen TreatQ7=0

replace TreatQ1=1 if Treat==1 & Q==1
replace TreatQ2=1 if Treat==1 & Q==2
replace TreatQ3=1 if Treat==1 & Q==3
replace TreatQ5=1 if Treat==1 & Q==5
replace TreatQ6=1 if Treat==1 & Q==6
replace TreatQ7=1 if Treat==1 & Q==7

global VarXQ="TreatQ1 TreatQ2 TreatQ3 TreatQ5 TreatQ6 TreatQ7 Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"

global TimeListQ="TreatQ1 TreatQ2 TreatQ3 TreatQ5 TreatQ6 TreatQ7"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// // 200. Permutation Placebo Test
// do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/


//===========================================================//
// A3. DID 分析: 第一波LTV限制2vs3 (2020M1-2021M12)
// with Many Collateral + Propensity Score Matching
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=201912 & Data_YM<=202108 // 丟去994,754

// 3. 擔保品不含多戶及青安樣本
// keep if NoManyCol_Sample==1
drop if YoungMG==1

// 4. DID 變數建立
gen Treat=1 if Hous==3 & Luxury==0
replace Treat=0 if Hous==2 & Luxury==0

gen Post=0 if Data_YM>=201912 & Data_YM<=202011
replace Post=1 if Data_YM>=202012 & Data_YM<=202108

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.

// 6. Propensity Score Matching (Post=0 Post=1分開Match)
gen Obs_ID=_n

// Pre-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==0, atet nn(3) gen(MatchID)
// predict ps0 ps1, ps

// 3:1 Matching
forvalues i=1/3{
preserve
keep if Treat==1 & Post==0
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta",replace
restore
}


drop MatchID*

// Post-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==1, atet nn(3) gen(MatchID)
forvalues i=1/3{
preserve
keep if Treat==1 & Post==1
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta",replace
restore
}

drop MatchID*

preserve
use "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_1.dta", clear
forvalues i=2/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta"
}
forvalues i=1/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta"
}
drop if Obs_ID==.
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta",replace
restore


merge 1:m Obs_ID Post using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta", gen(_mergePSM)
drop if _mergePSM!=3 & Treat==0
drop _mergePSM Obs_ID

tab Treat

// 98. 檔案名稱設定(需與資料夾同名)
global Output="First_LTV2vs3_PSM"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202011).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#201912.Data_YM 1.Treat#202001.Data_YM 1.Treat#202002.Data_YM 1.Treat#202003.Data_YM 1.Treat#202004.Data_YM 1.Treat#202005.Data_YM 1.Treat#202006.Data_YM 1.Treat#202007.Data_YM 1.Treat#202008.Data_YM 1.Treat#202009.Data_YM 1.Treat#202010.Data_YM 1o.Treat#202011b.Data_YM 1.Treat#202012.Data_YM 1.Treat#202101.Data_YM 1.Treat#202102.Data_YM 1.Treat#202103.Data_YM 1.Treat#202104.Data_YM 1.Treat#202105.Data_YM 1.Treat#202106.Data_YM 1.Treat#202107.Data_YM 1.Treat#202108.Data_YM"

gen Q=0
replace Q=1 if Data_YM==201912 | Data_YM==202001 | Data_YM==202002
replace Q=2 if Data_YM==202003 | Data_YM==202004 | Data_YM==202005
replace Q=3 if Data_YM==202006 | Data_YM==202007 | Data_YM==202008
replace Q=4 if Data_YM==202009 | Data_YM==202010 | Data_YM==202011
replace Q=5 if Data_YM==202012 | Data_YM==202101 | Data_YM==202102
replace Q=6 if Data_YM==202103 | Data_YM==202104 | Data_YM==202105
replace Q=7 if Data_YM==202106 | Data_YM==202107 | Data_YM==202108


gen TreatQ1=0
gen TreatQ2=0
gen TreatQ3=0
gen TreatQ5=0
gen TreatQ6=0
gen TreatQ7=0

replace TreatQ1=1 if Treat==1 & Q==1
replace TreatQ2=1 if Treat==1 & Q==2
replace TreatQ3=1 if Treat==1 & Q==3
replace TreatQ5=1 if Treat==1 & Q==5
replace TreatQ6=1 if Treat==1 & Q==6
replace TreatQ7=1 if Treat==1 & Q==7

global VarXQ="TreatQ1 TreatQ2 TreatQ3 TreatQ5 TreatQ6 TreatQ7 Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"

global TimeListQ="TreatQ1 TreatQ2 TreatQ3 TreatQ5 TreatQ6 TreatQ7"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
// do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/

//===========================================================//
// A4. DID 分析: 第一波LTV限制2vs3 (2020M1-2021M12)
// No Many Collateral + Propensity Score Matching
//===========================================================//

// 1. Data Processing
do "20250210 DID_fun_Data_Processing (v1)"

// 2. 樣本期間限縮
keep if Data_YM>=201912 & Data_YM<=202108 // 丟去994,754

// 3. 擔保品不含多戶及青安樣本
keep if NoManyCol_Sample==1
drop if YoungMG==1

// 4. DID 變數建立
gen Treat=1 if Hous==3 & Luxury==0
replace Treat=0 if Hous==2 & Luxury==0

gen Post=0 if Data_YM>=201912 & Data_YM<=202011
replace Post=1 if Data_YM>=202012 & Data_YM<=202108

gen TreatPost=Treat*Post

// 5. 限制樣本為實驗組對照組
keep if Treat!=.

// 6. Propensity Score Matching (Post=0 Post=1分開Match)
gen Obs_ID=_n

// Pre-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==0, atet nn(3) gen(MatchID)
// predict ps0 ps1, ps

// 3:1 Matching
forvalues i=1/3{
preserve
keep if Treat==1 & Post==0
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta",replace
restore
}


drop MatchID*

// Post-treatment
teffects psmatch (Price) (Treat Age_I Gender Edu_year, logit) if Post==1, atet nn(3) gen(MatchID)
forvalues i=1/3{
preserve
keep if Treat==1 & Post==1
keep MatchID`i' Post
rename MatchID`i' Obs_ID
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta",replace
restore
}

drop MatchID*

preserve
use "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_1.dta", clear
forvalues i=2/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Pre_`i'.dta"
}
forvalues i=1/3{
append using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_Post_`i'.dta"
}
drop if Obs_ID==.
save "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta",replace
restore


merge 1:m Obs_ID Post using "D:\行庫使用專區\中央研究院_楊老師\Data\temp\Match_PrePost.dta", gen(_mergePSM)
drop if _mergePSM!=3 & Treat==0
drop _mergePSM Obs_ID

tab Treat

// 98. 檔案名稱設定(需與資料夾同名)
global Output="First_LTV2vs3_NMC_PSM"

// 99. Defining Independent Variables for each Model
global VarX1="TreatPost Treat Post"
global VarX2="TreatPost Treat i.Data_YM"
global VarX3="TreatPost Treat i.Data_YM i.Age_I"
global VarX4="TreatPost Treat i.Data_YM i.Age_I i.Gender"
global VarX5="TreatPost Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準
global VarXD="Treat##ib(202011).Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"
global VarXP="PlaceboPost Placebo i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6" //大學為基準

global TimeList="1.Treat#201912.Data_YM 1.Treat#202001.Data_YM 1.Treat#202002.Data_YM 1.Treat#202003.Data_YM 1.Treat#202004.Data_YM 1.Treat#202005.Data_YM 1.Treat#202006.Data_YM 1.Treat#202007.Data_YM 1.Treat#202008.Data_YM 1.Treat#202009.Data_YM 1.Treat#202010.Data_YM 1o.Treat#202011b.Data_YM 1.Treat#202012.Data_YM 1.Treat#202101.Data_YM 1.Treat#202102.Data_YM 1.Treat#202103.Data_YM 1.Treat#202104.Data_YM 1.Treat#202105.Data_YM 1.Treat#202106.Data_YM 1.Treat#202107.Data_YM 1.Treat#202108.Data_YM"

gen Q=0
replace Q=1 if Data_YM==201912 | Data_YM==202001 | Data_YM==202002
replace Q=2 if Data_YM==202003 | Data_YM==202004 | Data_YM==202005
replace Q=3 if Data_YM==202006 | Data_YM==202007 | Data_YM==202008
replace Q=4 if Data_YM==202009 | Data_YM==202010 | Data_YM==202011
replace Q=5 if Data_YM==202012 | Data_YM==202101 | Data_YM==202102
replace Q=6 if Data_YM==202103 | Data_YM==202104 | Data_YM==202105
replace Q=7 if Data_YM==202106 | Data_YM==202107 | Data_YM==202108

gen TreatQ1=0
gen TreatQ2=0
gen TreatQ3=0
gen TreatQ5=0
gen TreatQ6=0
gen TreatQ7=0

replace TreatQ1=1 if Treat==1 & Q==1
replace TreatQ2=1 if Treat==1 & Q==2
replace TreatQ3=1 if Treat==1 & Q==3
replace TreatQ5=1 if Treat==1 & Q==5
replace TreatQ6=1 if Treat==1 & Q==6
replace TreatQ7=1 if Treat==1 & Q==7

global VarXQ="TreatQ1 TreatQ2 TreatQ3 TreatQ5 TreatQ6 TreatQ7 Treat i.Data_YM i.Age_I i.Gender edu_D1 edu_D2 edu_D4 edu_D5 edu_D6"

global TimeListQ="TreatQ1 TreatQ2 TreatQ3 TreatQ5 TreatQ6 TreatQ7"

// 100. Estimation
do "20250716 DID_fun_Estimation (v2)"

// 200. Permutation Placebo Test
// do "20250804 DID_fun_Placebo (v1)"

/*------------------------------------------------------------*/






















