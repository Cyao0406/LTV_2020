
*===============================================================================
* 專案名稱：[LTV2020]
* 檔案名稱：01_analysis & visual.do
* 建立日期：2026-01-23
* 最後修改：2026-02-03
* 建立者：[Chun Yao]
* 目的：資料分析及可視化 (圖形分析) 
*===============================================================================


// ################################################################################
// ### (四) 分析階段 (ANALYSIS PHASE)
// ################################################################################

// =============================================================================
// 4.1 作圖分析 (Graphical Analysis)
// =============================================================================

* -----------------------------------------------------------------------------
* 4.1.1  Common Trend
* -----------------------------------------------------------------------------

preserve
    * --- 1. 數據彙整 ---
    contract year group
    bysort year: egen total = sum(_freq)
    gen share = (_freq / total) * 100
    
    * --- 2. 繪製趨勢圖 ---
    twoway (line share year if group == 1, lwidth(thick) lcolor(navy)) ///
           (line share year if group == 2, lwidth(thick) lcolor(maroon)), ///
           xline(2020, lpattern(dash) lcolor(black)) ///
           title("信用管制政策前後之佔比變化") ///
           ytitle("佔比 (%)") xtitle("年度") ///
           legend(order(1 "實驗組" 2 "控制組"))
           
    graph export "$figures/Common_Trend_Group12.png", replace
restore


// =============================================================================
// 4.2 迴歸分析 (Regression Analysis)
// =============================================================================

* -----------------------------------------------------------------------------
* 4.2.1 建構虛擬變數 (Dummy Variables)
* -----------------------------------------------------------------------------
gen post  = (year >= 2020)                   // 政策後時間虛擬變數
gen treat = (group == 1)                     // 實驗組虛擬變數
gen did   = treat * post                     // DID 交互項

* -----------------------------------------------------------------------------
* 4.2.2 Pre/ Post DID Model)
* -----------------------------------------------------------------------------
xtset id year

// 模型 1：基礎 OLS
reg loan_amount did i.year i.id, vce(cluster id)

// 模型 2：個體固定效應
xtreg loan_amount did i.year, fe vce(cluster id)
estimates store main_model

* -----------------------------------------------------------------------------
* 4.2.3 Dynamic DID Model
* -----------------------------------------------------------------------------


* -----------------------------------------------------------------------------
* 4.2.4 穩健性檢定 (Robustness Checks)
* -----------------------------------------------------------------------------

* (1) 樣本敏感性測試：排除 2020 當年 (避免緩衝期干擾)
xtreg loan_amount did i.year if year != 2020, fe vce(cluster id)
estimates store rob_no2020

* (2) 安慰劑檢定 (Placebo Test)：將政策時間假定在 2018 年
gen post_fake = (year >= 2018 & year < 2020)
gen did_fake  = treat * post_fake
xtreg loan_amount did_fake i.year, fe vce(cluster id)
estimates store placebo_test


// ################################################################################
// ### (五) 結果輸出與儲存 (OUTPUT & STORAGE)
// ################################################################################

* --- 匯出迴歸表格 ---
local out_options "cells(b(star fmt(3)) se(par fmt(3))) stats(N r2_a, labels(N Adj-R2))"
esttab main_model rob_no2020 placebo_test using "$output/Regression_Results.rtf", `out_options' replace

* --- 儲存最終分析用資料檔 ---
save "$data/Final_Analysis_Dataset.dta", replace

capture log close
exit


// ======= //
* 1. 基本設定
xtset id year

* 2. 計算每個 ID 總共「轉變」過幾次
* 只要這一期跟上一期不一樣，就記為一次轉變
gen change = (treat != L.treat) if L.treat != .
bysort id: egen total_changes = total(change)

* 3. 建立最終組別變數
gen group = .

* --- 優先判定第 5 組：多次轉變組 ---
* 如果一個 ID 在整個期間轉變次數 >= 2 (例如 0->1->0 或 1->0->1)
replace group = 5 if total_changes >= 2

* --- 剩餘的 ID (轉變 0 次或 1 次) 依照年度狀態判定 ---
* 情況 1：穩定實驗 (1 -> 1)
replace group = 1 if total_changes < 2 & treat == 1 & L.treat == 1

* 情況 2：穩定控制 (0 -> 0)
replace group = 2 if total_changes < 2 & treat == 0 & L.treat == 0

* 情況 3：控制變實驗 (0 -> 1) - Group 3
replace group = 3 if total_changes < 2 & treat == 1 & L.treat == 0

* 情況 4：實驗變控制 (1 -> 0) - Group 4
replace group = 4 if total_changes < 2 & treat == 0 & L.treat == 1

* 4. 加上標籤
label define group_lab 1 "Stable T" 2 "Stable C" 3 "C to T (G3)" 4 "T to C (G4)" 5 "Multiple Switches (G5)"
label values group group_lab

* 查看每一組的數量分佈
tab group

* 抽查特定的個體看歷程
list id year treat total_changes group if total_changes >= 1, sepby(id)

preserve
    * 1. 統計每年各組的人數
    contract year group, nomiss
    
    * 2. 計算每年總人數，進而算出百分比
    bysort year: egen total_n = sum(_freq)
    gen share = (_freq / total_n) * 100
    
    * 3. 繪製趨勢圖 (使用線條圖)
    xtset group year
    twoway (line share year if group == 1, lwidth(thick)) ///
           (line share year if group == 2, lwidth(thick)) ///
           (line share year if group == 3, yaxis(2) lwidth(thick)) ///
		   (line share year if group == 4, yaxis(2) lwidth(thick)) ///
           title("各組別佔樣本總數之比例 (年度趨勢)") ///
           ytitle("佔比 (%)") xtitle("年度") ///
           legend(order(1 "始終對照組" 2 "始終實驗組" 3 "狀態改變組")) ///
		   xlabel(2017(1)2023) ///
		   saving("@{figure_path}/@{version}4g_state_conv", replace)
		   
	graph export "@{figure_path}/@{version}4g_state_conv.png", replace
	
	twoway (line share year if group == 1, lwidth(thick)) ///
           (line share year if group == 2, lwidth(thick)) ///
           (line share year if group == 3, yaxis(2) lwidth(thick)) ///
		   (line share year if group == 4, yaxis(2) lwidth(thick)) ///
		   (line share year if group == 5, yaxis(2) lwidth(thick)), ///
           title("各組別佔樣本總數之比例 (年度趨勢)") ///
           ytitle("佔比 (%)") xtitle("年度") ///
           legend(order(1 "始終對照組" 2 "始終實驗組" 3 "狀態改變組")) ///
		   xlabel(2017(1)2023) ///
		   saving("@{figure_path}/@{version}5g_state_conv", replace)
		   
	graph export "@{figure_path}/@{version}5g_state_conv.png", replace
restore

