* Finalized on: 2026-01-31 by [Chun Yao]

*===============================================================================
* 專案名稱：LTV2020
* 檔案名稱：20260131_DID_results.do
* 建立日期：2026-01-31
* 最後修改：2026-01-31
* 建立者：[Chun Yao]
* 目的：重新畫最開始五種房貸計算方式的DID估計結果的趨勢圖 (S_Lag_M_T_D)
*===============================================================================


* ==========================================
* 1. 環境設定
* ==========================================
clear all
set more off

global version_ = "S_Lag_M_T_D"
local base_path "C:/Users/user/OneDrive/桌面/work/114/RA with Tzu-Ting/houseloan/2020/figures"
local my_vars "新增房貸機率 購屋機率 購屋於六都 購屋於台北"
local dropbox_path "C:/Users/user/Dropbox/LTV_財資版/攜出/figures"
local today "2026-01-31"
local ana "DID"

local excel_path "C:/Users/user/OneDrive/桌面/work/114/RA with Tzu-Ting/LTV_2020/data/rdata/S_Lag_M_T_Dynamic_DID_results.xlsx"
local out_dir    "C:/Users/user/OneDrive/桌面/work/114/RA with Tzu-Ting/LTV_2020/figures"

capture mkdir "`out_dir'"


* ==========================================
* 2. 開始執行各分頁循環
* ==========================================
foreach v in `my_vars' {

    import excel "`excel_path'", sheet("`v'") clear allstring
    rename (A B C D E F) (term m1 m2 m3 m4 m5)

    * 1. 識別哪些列是我們要的 interact 及其標準誤 (SE)
    gen interact_num = .
    replace interact_num = real(regexs(1)) if regexm(term, "interact([0-9]+)")
    
    * 標記該行是否為 interact 及其緊接在後的標準誤列
    gen to_keep = 0
    replace to_keep = 1 if !missing(interact_num)
    replace to_keep = 1 if _n > 1 & !missing(interact_num[_n-1]) // 這是為了抓到括號標準誤列
    
    * 只保留 1-3 與 5-8 (跳過 4，因為我們要手動補入基準期 -1)
    replace interact_num = interact_num[_n-1] if missing(interact_num) & to_keep == 1
    keep if inlist(interact_num, 1, 2, 3, 5, 6, 7, 8) & to_keep == 1

    * 2. 核心映射邏輯：將 1-8 轉換為 -4 到 3
    * 映射公式：event_time = interact_num - 5
    * 1-5=-4, 2-5=-3, 3-5=-2 / 5-5=0, 6-5=1, 7-5=2, 8-5=3
    gen event_time = interact_num - 5
    
    * 判斷是否為標準誤列 (根據原始 term 是否含括號)
    gen is_se = strpos(term, "(") > 0 | (term == "")

    * 3. 資料轉置與清洗
    gen row_id = _n
    reshape long m, i(row_id) j(model)
    destring m, replace ignore("*" "(" ")" ",")
    
    separate m, by(is_se)
    rename m0 estimate
    rename m1 se
    collapse (max) estimate se, by(event_time model)

    * 4. 手動補入基準期 t = -1 (DiD 標準作法)
    preserve
        clear
        set obs 5
        gen model = _n
        gen event_time = -1
        gen estimate = 0
        gen se = 0
        tempfile ref_point
        save `ref_point'
    restore
    append using `ref_point'
    sort model event_time

    * 5. 計算 95% 置信區間
    * 公式： $$Estimate \pm 1.96 \times SE$$
    gen ci_lo = estimate - 1.96 * se
    gen ci_hi = estimate + 1.96 * se

	* --- 自動對應資料夾名稱 ---
    if "`v'" == "新增房貸機率" {
        local folder_name "新增房貸"
    }
	else if "`v'" == "購屋機率"{
		local folder_name "購屋機率"
	}
    else if "`v'" == "購屋於台北" {
        local folder_name "購屋於台北"
    }
    else if "`v'" == "購屋於六都" {
        local folder_name "購屋於六都"
    }
	
	local final_dir "`out_dir'/`folder_name'/`today'"
    capture mkdir "`final_dir'"
	local dropbox_dir "`dropbox_path'/`folder_name'/`today'_`ana'"
    capture mkdir "`dropbox_dir'"
	
    * 6. 繪圖
    forval i = 1/5 {
        twoway ///
            (rcap ci_hi ci_lo event_time if model == `i', lcolor(maroon) sort) ///
            (connect estimate event_time if model == `i', lcolor(navy) msize(small) sort) ///
            , ///
			legend(off) ///
            yline(0, lp(solid) lc(black)) ///
            xline(-1, lp(dash) lc(gray)) /// 標示基準期
            xlabel(-4(1)3) ///
            title("Dynamic_DID - (`i')") ///
			subtitle("`v'") ///
            ytitle("DID Estimates") xtitle("Date") ///
            graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
            
//         graph export "`out_dir'/test/`v'_M`i'.png", replace // 測試
		graph export "`final_dir'/${version_}`i'_dynamic_DID.png", as(png) replace
		graph export "`dropbox_dir'/${version_}`i'_dynamic_DID.png", as(png)  replace
    }
}



