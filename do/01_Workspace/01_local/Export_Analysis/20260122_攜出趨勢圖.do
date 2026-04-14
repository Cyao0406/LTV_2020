* Finalized on: 2026-02-01 by [Chun Yao]

*===============================================================================
* 專案名稱：[LTV2020]
* 檔案名稱：20260122_攜出趨勢圖.do
* 建立日期：2026-01-22
* 最後修改：2026-02-01
* 建立者：[Chun Yao]
* 目的：
*	1. 利用攜出資料,畫出各Outcomes的實驗/對照組趨勢圖
*	2. 利用攜出資料,畫出各組轉變狀態趨勢圖 p.s. 實驗組對照組在政策其間的變化 (始終實驗組 / 始終對照組 / 狀態轉變組)
*===============================================================================

//===========================================================//
// 趨勢圖
//===========================================================//

clear all

cd "C:/Users/user/OneDrive/桌面/work/114/RA with Tzu-Ting/LTV_2020/data/rdata"

global proj_ver = "S_F2020_M_TI_Tr_D3"

*1. 先匯入資料（放在迴圈外，只需執行一次，節省時間）
import excel "S_F2020_M_TI_Tr_outcomes.xlsx", firstrow clear

* 2. 定義你要跑的變數清單
local base_path "C:/Users/user/OneDrive/桌面/work/114/RA with Tzu-Ting/LTV_2020/figures"
local my_vars "have_new_houseloan_cf have_new_house_cf buy_in_taipei_cf buy_in_six_cf"
local dropbox_path "C:/Users/user/Dropbox/LTV_財資版/data/figures"
local today "2026-02-01"
local ana "outcomes_trend"

* 3. 開始迴圈處理
foreach v in `my_vars' {
    
    * --- 自動對應資料夾名稱 ---
    if "`v'" == "have_new_houseloan_cf" {
        local folder_name "新增房貸"
    }
	else if "`v'" == "have_new_house_cf"{
		local folder_name "購屋機率"
	}
    else if "`v'" == "buy_in_taipei_cf" {
        local folder_name "購屋於台北"
    }
    else if "`v'" == "buy_in_six_cf" {
        local folder_name "購屋於六都"
    }
    
    * 建立完整路徑 (如果資料夾不存在，Stata 會報錯，所以建議先手動建立或使用 capture mkdir)
    local final_dir "`base_path'/`folder_name'/`today'_`ana'"
    capture mkdir "`final_dir'"
	local dropbox_dir "`dropbox_path'/`folder_name'/`today'_`ana'"
    capture mkdir "`dropbox_dir'"
	capture shell rd /s /q "`base_path'/`folder_name'/`today'"
	capture shell rd /s /q "`dropbox_path'/`folder_name'/`today'"
	
    preserve
        drop if treat == .
        keep `v' year treat
		replace year = year -2020        
        * 進行分析轉換
        reshape wide `v', i(year) j(treat)
        
        * 繪圖 (沿用您之前的設定)
        twoway (line `v'1 year, lcolor(maroon) sort) (line `v'0 year, lcolor(navy) lp(dash) sort), ///
				ytitle("%") xtitle("Date") ///
				graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
				legend(order(1 "實驗組" 2 "控制組")) ///
				xlabel(-3(1)3) ///
				xline(0, lpattern(dash) lcolor(gray)) ///
				graphregion(fcolor(white)) ///
				title("Common Trend: `folder_name'")
        
        * --- 匯出圖片到指定資料夾 ---
        * 使用雙引號包住路徑，避免路徑中的空格導致出錯
        graph export "`final_dir'//${proj_ver}_common_trend_0.png", as(png) replace
		graph export "`dropbox_dir'/${proj_ver}_common_trend_0.png", as(png) replace

        * 繪圖 (沿用您之前的設定)
        twoway (line `v'1 year, lcolor(maroon) sort) (line `v'0 year, lcolor(navy) lp(dash) sort), ///
				ytitle("%") xtitle("Date") ///
				graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
				legend(order(1 "實驗組" 2 "控制組")) ///
				xlabel(-3(1)3) ///
				xline(-1, lpattern(dash) lcolor(gray)) ///
				graphregion(fcolor(white)) ///
				title("Common Trend: `folder_name'")
        
        * --- 匯出圖片到指定資料夾 ---
        * 使用雙引號包住路徑，避免路徑中的空格導致出錯
        graph export "`final_dir'//${proj_ver}_common_trend_-1.png", as(png) replace
		graph export "`dropbox_dir'/${proj_ver}_common_trend_-1.png", as(png) replace
        
    restore
}


//===========================================================//
// 狀態轉變趨勢圖
//===========================================================//

clear all

cd "C:/Users/user/OneDrive/桌面/work/114/RA with Tzu-Ting/houseloan/攜出"

global proj_ver = "S_Lag_M_TI_Tr_D3"

*1. 先匯入資料（放在迴圈外，只需執行一次，節省時間）
import excel "S_F2020_M_TI_Tr_percents.xlsx", firstrow clear

* 2. 定義你要跑的變數清單
local base_path "C:/Users/user/OneDrive/桌面/work/114/RA with Tzu-Ting/houseloan/2020/figures"
local dropbox_path "C:/Users/user/Dropbox/LTV_財資版/攜出/figures"

destring group,replace

preserve
    * 2. 計算每年總人數，進而算出百分比
    bysort year: egen total_n = sum(_freq)
    gen share = (_freq / total_n) * 100
    
    * 3. 繪製趨勢圖 (使用線條圖)
    xtset group year
    twoway (line share year if group == 1, lwidth(thick)) ///
           (line share year if group == 2, lwidth(thick)) ///
           (line share year if group == 3, yaxis(2) lwidth(thick)), ///
           title("各組別佔樣本總數之比例 (年度趨勢)") ///
           ytitle("佔比 (%)") xtitle("年度") ///
           legend(order(1 "始終對照組" 2 "始終實驗組" 3 "狀態改變組")) ///
		   xlabel(2017(1)2023) ///
		   saving("`base_path'/${proj_ver}_share_conv",replace)
		   
	graph export "`base_path'/狀態轉換趨勢圖/${proj_ver}_share_conv.png", replace
	graph export "`dropbox_path'/狀態轉換趨勢圖/${proj_ver}_share_conv.png", replace
restore
