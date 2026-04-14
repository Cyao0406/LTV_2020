clear all

cd "E:/cy/housloan2020/dta"
global version = "S_Lag_M_TI_Tr_D3_"
global figure_path = "E:/cy/Housloan2020/figures"
global result_path = "E:/cy/Housloan2020/results"


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


