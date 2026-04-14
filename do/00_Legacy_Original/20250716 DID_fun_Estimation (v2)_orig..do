//===========================================================//
// DID Analysis Function: Estimation
//
// 本函數負責將建立好Treatment變數後之樣本進行DID分析
// 包含Winsorise (+/-1%) 與 non-winsorised 都會估計一次
// 包含原始資料趨勢 敘述統計 以及DID分析
// 務必輸入好Output數值進行分類
//===========================================================//

global Results="D:\行庫使用專區\中央研究院_楊老師\Results\Individual DID(v2)/$Output"
adopath + "C:\安裝軟體_勿刪\Stata\ado\plus"

//===========================================================//
// A. Winsorise within Sample
//===========================================================//



// A4. Winsorise Outcome Variables

foreach i of varlist LTV PTV Contract_Amt Ass_Value Price Price_adj Area ///
 Ass_Value_m2 Price_m2 Price_adj_m2 Period Rate Age_Hous {
	gen `i'_win=`i'
	sum `i'_win, detail
	replace `i'_win= r(p99) if `i'_win>r(p99) 
    replace `i'_win= r(p1) if `i'_win<r(p1) 
}

// A5. 變數取log 其他貸款數太多0不適合取log
foreach i of varlist Contract_Amt Ass_Value Price Price_adj Ass_Value_m2 Price_m2 Price_adj_m2 Area ///
Contract_Amt_win Ass_Value_win Price_win Price_adj_win Ass_Value_m2_win Price_m2_win Price_adj_m2_win Area_win Age_Hous Age_Hous_win {
	gen ln_`i'=log(`i')
}

// A7. Defining Variable List
global VarlistOutcome="LTV PTV ln_Contract_Amt Period Rate ln_Ass_Value ln_Ass_Value_m2 ln_Price ln_Price_adj ln_Price_m2 ln_Price_adj_m2 ln_Area Contract_Amt Ass_Value Ass_Value_m2 Price Price_adj Price_m2 Price_adj_m2 Area CITY_Spec Six_City Five_City Taipei ln_Age_Hous Age_Hous"


global VarlistOutcomeWin="LTV_win PTV_win ln_Contract_Amt_win Period_win Rate_win ln_Ass_Value_win ln_Ass_Value_m2_win ln_Price_win ln_Price_adj_win ln_Price_m2_win ln_Price_adj_m2_win ln_Area_win Contract_Amt_win Ass_Value_win Ass_Value_m2_win Price_win Price_adj_win Price_m2_win Price_adj_m2_win Area_win ln_Age_Hous_win Age_Hous_win"

global VarlistControl="Gender Age_I edu_D1 edu_D2 edu_D3 edu_D4 edu_D5 edu_D6 Edu_year"

global Sublist="Age_I>=45 Age_I<45 Age_I>=40 Age_I<40 Gender==0 Gender==1 Edu_year>=16 Edu_year<16 Edu_year>=18 Edu_year<18"
global SublistC="Age_I<45 Age_I<40 Gender==1 Edu_year<16 Edu_year<18"


//===========================================================//
// B. 原始資料趨勢
//===========================================================//

// B2. 平均
preserve
global y="LTV"
global x="Treat"
gen Y=floor(Data_YM/100)
gen M = Data_YM-Y*100
gen T= ym( Y , M)
gen N=1
format T %tm
collapse (sum) N (mean) $VarlistOutcome $VarlistOutcomeWin $VarlistControl, by ($x T)
save "$Results/$Output Mean-Type-YM.dta", replace
twoway (line $y T  if $x ==0 ) (line $y T  if $x ==1 )
// graph save "LTV-Type-YM(NoManyHousInCol)"
restore

/*-----------------------------------------------------------*/

//===========================================================//
// C. Summary Statistics by Time by Treat
//===========================================================//

order $VarlistOutcome $VarlistOutcomeWin $VarlistControl

// C1. Summary Statistics
// Main
capture rm "$Results/$Output Summary_Full.xls"
capture rm "$Results/$Output Summary_Full.txt"

bysort Treat Post: outreg2 using "$Results/$Output Summary_Full.xls", ///
sum(detail) keep("$VarlistOutcome $VarlistOutcomeWin $VarlistControl") ///
eqkeep(mean p50 sd N) fmt(fc) excel append ///
addtext(Sample, Full)
/*-----------------------------------------------------------*/

// Subgroup
capture rm "$Results/$Output Summary_Sub.xls"
capture rm "$Results/$Output Summary_Sub.txt"

foreach g of global Sublist {
bysort Treat Post: outreg2 if `g' using "$Results/$Output Summary_Sub.xls", ///
sum(detail) keep("$VarlistOutcome $VarlistOutcomeWin $VarlistControl") ///
eqkeep(mean p50 sd N) fmt(fc) excel append ///
addtext(Sample, "`g'")

}

/*-----------------------------------------------------------*/

// C2. Pairwise Mean
// Main
capture rm "$Results/$Output Pairwise_Full.xls"
capture rm "$Results/$Output Pairwise_Full.txt"

foreach i of varlist $VarlistOutcome $VarlistOutcomeWin $VarlistControl {
    pwmean `i' if Post==0, over(Treat)
	local pw_b=e(b_vs)[1,1]
	local pw_sd=sqrt(e(V_vs)[1,1]) // 有驗證過 直接開根即可 V已經平均過
	local tstat=`pw_b'/`pw_sd'
	local df=e(df_r)
    local pval = tprob(`df', abs(`tstat'))
	outreg2 using "$Results/$Output Pairwise_Full.xls", addstat(Mean Differences, `pw_b',  Std,`pw_sd', P-value, `pval') fmt(fc) excel append ///
	addtext(Period, Pre, Sample, Full)
	
	pwmean `i' if Post==1, over(Treat)
	local pw_b=e(b_vs)[1,1]
	local pw_sd=sqrt(e(V_vs)[1,1]) // 有驗證過 直接開根即可 V已經平均過
	local tstat=`pw_b'/`pw_sd'
	local df=e(df_r)
    local pval = tprob(`df', abs(`tstat'))
	outreg2 using "$Results/$Output Pairwise_Full.xls", addstat(Mean Differences, `pw_b',  Std,`pw_sd', P-value, `pval') fmt(fc) excel append ///
	addtext(Period, Post, Sample, Full)
}
/*-----------------------------------------------------------*/

// Subgroup 
capture rm "$Results/$Output Pairwise_Sub.xls"
capture rm "$Results/$Output Pairwise_Sub.txt"

foreach g of global Sublist{
foreach i of varlist $VarlistOutcome $VarlistOutcomeWin $VarlistControl {
	pwmean `i' if Post==0 & `g', over(Treat)
	capture{
	local pw_b=e(b_vs)[1,1]
	local pw_sd=sqrt(e(V_vs)[1,1]) // 有驗證過 直接開根即可 V已經平均過
	local tstat=`pw_b'/`pw_sd'
	local df=e(df_r)
    local pval = tprob(`df', abs(`tstat'))
	outreg2 using "$Results/$Output Pairwise_Sub.xls", addstat(Mean Differences, `pw_b',  Std,`pw_sd', P-value, `pval') fmt(fc) excel append ///
	addtext(Period, Pre, Sample, "`g'")
	}
	pwmean `i' if Post==1 & `g', over(Treat)
	capture{
	local pw_b=e(b_vs)[1,1]
	local pw_sd=sqrt(e(V_vs)[1,1]) // 有驗證過 直接開根即可 V已經平均過
	local tstat=`pw_b'/`pw_sd'
	local df=e(df_r)
    local pval = tprob(`df', abs(`tstat'))
	outreg2 using "$Results/$Output Pairwise_Sub.xls", addstat(Mean Differences, `pw_b',  Std,`pw_sd', P-value, `pval') fmt(fc) excel append ///
	addtext(Period, Post, Sample, "`g'")
	}
}
}
/*-----------------------------------------------------------*/

//===========================================================//
// D. Dynamic DID (月)
//===========================================================//

// X: Model5 (VarXD)

// D1. Main
global ESDIDOutput="$Output ESDID_Full.xls"

capture rm "$Results/$Output ESDID_Full.xls"
capture rm "$Results/$Output ESDID_Full.txt"

foreach j of varlist $VarlistOutcome {
	reg `j' $VarXD, vce(cluster ID)
	outreg2 using "$Results/$ESDIDOutput", sideway excel append ///
	nocon keep( $TimeList ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Baseline, Sample, Full)
}

foreach j of varlist $VarlistOutcomeWin {	
	reg `j' $VarXD, vce(cluster ID)
	outreg2 using "$Results/$ESDIDOutput", sideway excel append ///
	nocon keep( $TimeList ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Winsorised, Sample, Full)
}
/*-----------------------------------------------------------*/

// D2. Subgroup
global ESDIDOutputSub="$Output ESDID_Sub.xls"
capture rm "$Results/$Output ESDID_Sub.xls"
capture rm "$Results/$Output ESDID_Sub.txt"

foreach g of global Sublist{
    foreach j of varlist $VarlistOutcome {
	reg `j' $VarXD if `g', vce(cluster ID)
	outreg2 using "$Results/$ESDIDOutputSub", sideway excel append ///
	nocon keep( $TimeList ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Baseline, Sample, "`g'")
}

foreach j of varlist $VarlistOutcomeWin {	
	reg `j' $VarXD if `g', vce(cluster ID)
	outreg2 using "$Results/$ESDIDOutputSub", sideway excel append ///
	nocon keep( $TimeList ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Winsorised, Sample, "`g'")
}
}
/*-----------------------------------------------------------*/


//===========================================================//
// D2. Dynamic DID (季)
//===========================================================//

// X: Model5 (VarXQ)

// D1. Main
global ESDIDQOutput="$Output ESDID_Q_Full.xls"

capture rm "$Results/$Output ESDID_Q_Full.xls"
capture rm "$Results/$Output ESDID_Q_Full.txt"

foreach j of varlist $VarlistOutcome {
	reg `j' $VarXQ, vce(cluster ID)
	outreg2 using "$Results/$ESDIDQOutput", sideway excel append ///
	nocon keep( $TimeListQ ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Baseline, Sample, Full)
}

foreach j of varlist $VarlistOutcomeWin {	
	reg `j' $VarXQ, vce(cluster ID)
	outreg2 using "$Results/$ESDIDQOutput", sideway excel append ///
	nocon keep( $TimeListQ ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Winsorised, Sample, Full)
}
/*-----------------------------------------------------------*/

// D2. Subgroup
global ESDIDQOutputSub="$Output ESDID_Q_Sub.xls"
capture rm "$Results/$Output ESDID_Q_Sub.xls"
capture rm "$Results/$Output ESDID_Q_Sub.txt"

foreach g of global Sublist{
    foreach j of varlist $VarlistOutcome {
	reg `j' $VarXQ if `g', vce(cluster ID)
	outreg2 using "$Results/$ESDIDQOutputSub", sideway excel append ///
	nocon keep( $TimeListQ ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Baseline, Sample, "`g'")
}

foreach j of varlist $VarlistOutcomeWin {	
	reg `j' $VarXQ if `g', vce(cluster ID)
	outreg2 using "$Results/$ESDIDQOutputSub", sideway excel append ///
	nocon keep( $TimeListQ ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Winsorised, Sample, "`g'")
}
}
/*-----------------------------------------------------------*/









//===========================================================//
// E. DID 
//===========================================================//

// E1. Main
global DIDOutput="$Output DID_Full.xls"

capture rm "$Results/$Output DID_Full.xls"
capture rm "$Results/$Output DID_Full.txt"


foreach j of varlist $VarlistOutcome {
	reg `j' $VarX1, vce(cluster ID)
	outreg2 using "$Results/$DIDOutput",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, X, Age FE, X, Gender, X, Education FE, X, Outcome, Baseline, Sample, Full)
	
	reg `j' $VarX2, vce(cluster ID)
	outreg2 using "$Results/$DIDOutput",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, V, Age FE, X, Gender, X, Education FE, X, Outcome, Baseline, Sample, Full)
	
	reg `j' $VarX3, vce(cluster ID)
	outreg2 using "$Results/$DIDOutput",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, V, Age FE, V, Gender, X, Education FE, X, Outcome, Baseline, Sample, Full)
	
	reg `j' $VarX4, vce(cluster ID)
	outreg2 using "$Results/$DIDOutput",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, X, Outcome, Baseline, Sample, Full)
	
	reg `j' $VarX5, vce(cluster ID)
	outreg2 using "$Results/$DIDOutput",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Baseline, Sample, Full)
}

foreach j of varlist $VarlistOutcomeWin {	
	reg `j' $VarX1, vce(cluster ID)
	outreg2 using "$Results/$DIDOutput",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, X, Age FE, X, Gender, X, Education FE, X, Outcome, Winsorised, Sample, Full)
	
	reg `j' $VarX2, vce(cluster ID)
	outreg2 using "$Results/$DIDOutput",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, V, Age FE, X, Gender, X, Education FE, X, Outcome, Winsorised, Sample, Full)
	
	reg `j' $VarX3, vce(cluster ID)
	outreg2 using "$Results/$DIDOutput",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, V, Age FE, V, Gender, X, Education FE, X, Outcome, Winsorised, Sample, Full)
	
	reg `j' $VarX4, vce(cluster ID)
	outreg2 using "$Results/$DIDOutput",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, X, Outcome, Winsorised, Sample, Full)
	
	reg `j' $VarX5, vce(cluster ID)
	outreg2 using "$Results/$DIDOutput",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Winsorised, Sample, Full)
}
/*-----------------------------------------------------------*/

// E2. Sub
global DIDOutputSub="$Output DID_Sub.xls"

capture rm "$Results/$Output DID_Sub.xls"
capture rm "$Results/$Output DID_Sub.txt"


foreach g of global Sublist{
    foreach j of varlist $VarlistOutcome {
	reg `j' $VarX5 if `g', vce(cluster ID)
	outreg2 using "$Results/$DIDOutputSub",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Baseline, Sample, "`g'")
}

foreach j of varlist $VarlistOutcomeWin {	
	reg `j' $VarX5 if `g', vce(cluster ID)
	outreg2 using "$Results/$DIDOutputSub",excel append ///
	nocon keep( TreatPost ) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Winsorised, Sample, "`g'")
}
}
/*-----------------------------------------------------------*/


// E3. Sub Comparison (新增所有變數交乘某一個group dummy 代表兩組之間的差)
global DIDOutputSubC="$Output DID_SubCompare.xls"

capture rm "$Results/$Output DID_SubCompare.xls"
capture rm "$Results/$Output DID_SubCompare.txt"

gen GroupAux=0
gen TreatPostGroup=0

global VarXC="Treat#GroupAux i.Data_YM#GroupAux i.Age_I#GroupAux i.Gender#GroupAux edu_D1#GroupAux edu_D2#GroupAux edu_D4#GroupAux edu_D5#GroupAux edu_D6#GroupAux GroupAux"

foreach g of global SublistC{
	
	replace GroupAux=1 if `g'
	replace TreatPostGroup=TreatPost*GroupAux
	
    foreach j of varlist $VarlistOutcome {
	reg `j' TreatPostGroup $VarX5 $VarXC, vce(cluster ID)
	outreg2 using "$Results/$DIDOutputSubC",excel append ///
	nocon keep(TreatPostGroup) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Baseline, Group Dummy, "`g'")
}

foreach j of varlist $VarlistOutcomeWin {	
	reg `j' TreatPostGroup $VarX5 $VarXC, vce(cluster ID)
	outreg2 using "$Results/$DIDOutputSubC",excel append ///
	nocon keep(TreatPostGroup) ///
	addtext(YMFE, V, Age FE, V, Gender, V, Education FE, V, Outcome, Winsorised, Group Dummy, "`g'")
}
    replace GroupAux=0
}

/*-----------------------------------------------------------*/










