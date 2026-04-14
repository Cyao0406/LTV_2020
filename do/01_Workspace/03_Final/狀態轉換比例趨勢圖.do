* 劃分狀態變化趨勢圖
* 匯出outcomes

* 假設您的變數名稱如下：
* id: 個人編號
* year: 年度
* mort_t1: 前一期房貸筆數 (1 或 2)
* buy: 是否新增購房/房貸 (0 或 1)

* 1. 找出每個人在觀察期間內房貸筆數的 最小值 與 最大值
bysort id: egen min_status = min(mort_t1)
bysort id: egen max_status = max(mort_t1)

* 2. 根據極值定義三種類型
gen group = .
replace group = 1 if min_status == 1 & max_status == 1  // 始終為 1 筆 (對照組)
replace group = 2 if min_status == 2 & max_status == 2  // 始終為 2 筆 (實驗組)
replace group = 3 if min_status != max_status           // 狀態曾發生變動 (轉換組)

* 3. 設定標籤以便繪圖美觀
label define group_lbl 1 "Always treated" 2 "Always Control" 3 "Switchers"
label values group group_lbl

preserve
    * 計算各組、各年度的購房機率平均值
    collapse (mean) buy, by(year group)

    * 繪製三條折線
    twoway (line buy year if group == 1, lcolor(gs8) lpattern(dash) msize(small)) ///
           (line buy year if group == 2, lcolor(red) lwidth(thick)) ///
           (line buy year if group == 3, lcolor(blue) lpattern(shortdash)), ///
           xline(2021, lcolor(black) lpattern(dot)) ///  <-- 假設政策在 2021 年
           title("房貸筆數背景與購房機率趨勢") ///
           ytitle("新增購房/房貸平均機率") ///
           xtitle("年度") ///
           legend(order(1 "始終 1 筆 (對照)" 2 "始終 2 筆 (實驗)" 3 "狀態轉換組")) ///
           xlabel(2017(1)2023) ///
           scheme(s1color) // 使用較簡潔的配色主題
restore


* 使用線性機率模型 (LPM) 進行估計
reg buy i.year##i.group, vce(cluster id)

* 計算各組別在各年度的預測機率
margins group#year

* 繪圖
marginsplot, noci ///  <-- 若覺得線條太亂可加 noci 暫時隱藏信心區間
    title("各組別購房機率預測值") ///
    xlabel(2018(1)2024) ///
    plotopts(msize(small)) ///
    legend(rows(1))
	
tab group  // 確認每一條線背後代表的人數

***** 我是分界線 *****

* 查看各年度三組的人數比例
graph bar (count), over(group) over(year) asyvars stack

***** 我是分界線 *****

* 繪製各年度三組人數的百分比堆疊圖
graph bar (count), over(group) over(year) ///
    stack asyvars percent ///
    title("各年度組別比例變化圖") ///
    ytitle("百分比 (%)") ///
    legend(title("組別") order(1 "始終實驗組" 2 "始終對照組" 3 "狀態改變組"))
	
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
           (line share year if group == 3, lwidth(thick)), ///
           title("各組別佔樣本總數之比例 (年度趨勢)") ///
           ytitle("佔比 (%)") xtitle("年度") ///
           legend(order(1 "始終實驗組" 2 "始終對照組" 3 "狀態改變組"))
restore

***** 我是分界線 *****

* 統整&匯出outcomes v.1

* --- 前半部：資料整理 ---
use "large_transaction_data.dta", clear
// ... 雜亂資料的處理 ...

preserve
    collapse (mean) outcome1, by(year treatment)
    * 重點：不要存成 excel，存成 Stata 格式的暫存結果
    save "collapsed_outcome1.dta", replace 
restore

* --- 後半部：統計分析 ---
* 這裡的回歸會繼續執行，但你已經把上面 collapse 的結果「備份」出去了
reg outcome1 treatment i.year, cluster(id)
...

* 1. 以房貸主資料作為基準
use "collapsed_mortgage.dta", clear

* 2. 依序合併其他 Outcome
merge 1:1 year treatment using "collapsed_outcome1.dta", nogenerate
merge 1:1 year treatment using "collapsed_outcome2.dta", nogenerate
merge 1:1 year treatment using "collapsed_outcome3.dta", nogenerate

* 3. 最後才統一輸出成 Excel
export excel using "實驗組合併報表_日期.xlsx", firstrow(variables) replace

***** 我是分界線 *****

* 統整&匯出outcomes v.2
* --- 前半部：資料整理 ---
use "raw_data_1.dta", clear
// ... 進行一系列複雜的清洗 ...

preserve
    collapse (mean) outcome1, by(year treatment)
    * 儲存成中繼檔，建議加上日期或版本號
    save "temp_outcome1.dta", replace 
restore

* --- 後半部：回歸分析 (這部分很耗時，但現在你只需要跑一次) ---
reghdfe outcome1 treatment, absorb(id year) cluster(id)
// ... 其他統計指令 ...

* 1. 讀取基準資料 (例如：年新增房貸)
use "temp_mortgage.dta", clear

* 2. 橫向合併 (Merge)
* 注意：這裡使用的是 1:1 合併，因為每個年份+組別只有一筆平均值
foreach x in outcome1 outcome2 outcome3 {
    merge 1:1 year treatment using "temp_`x'.dta", keep(master match) nogenerate
}

* 3. 整理變數標籤 (讓 Excel 看起來更專業)
label variable outcome1 "平均房貸金額"
label variable outcome2 "平均違約率"

* 4. 匯出最終結果
export excel using "Final_Analysis_Report.xlsx", firstrow(variables) replace