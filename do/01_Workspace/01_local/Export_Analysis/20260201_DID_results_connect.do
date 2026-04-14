* Finalized on: 2026-02-01 by [Chun Yao]

*===============================================================================
* 專案名稱：LTV2020
* 檔案名稱：20260201_DID_results_connect.do
* 建立日期：2026-02-01
* 最後修改：2026-02-01
* 建立者：[Chun Yao]
* 目的：畫其他攜出之DID估計結果趨勢圖 
* version: 	S_F2020_M_TI_D3
*			S_F2020_M_TI_Tr_D3
*			S_Lag_M_TI_Tr_D3
*===============================================================================		 



* ==========================================
* 1. 環境設定
* ==========================================

clear all
set more off

global proj_ver = "S_Lag_M_TI_Tr_D3"
global local_path "C:/Users/user/OneDrive/桌面/work/114/RA with Tzu-Ting/LTV_2020/figures"
global my_vars "have_new_houseloan have_new_house buy_in_taipei but_in_six"
global dropbox_path "C:/Users/user/Dropbox/LTV_財資版/data/figures"
global build_date "2026-02-01"
global ana "DID_practice"

global excel_path "C:/Users/user/OneDrive/桌面/work/114/RA with Tzu-Ting/LTV_2020/data/rdata/${proj_ver}_Dynamic_DID_results.xlsx"

capture mkdir "${local_path}"

local sheets "新增房貸機率 購屋機率 購屋於台北 購屋於六都"
* ==========================================
* 2. 開始執行各分頁循環
* ==========================================
foreach sh in `sheets' {

    import excel "${excel_path}", sheet("`sh'") clear allstring
    rename (A B) (term m1)
	
    * 1. 識別哪些列是我們要的 interact 及其標準誤 (SE)
    gen interact_num = .
    replace interact_num = -real(regexs(1)) if regexm(term, "interact_pre_event_([0-9]+)")
    replace interact_num = real(regexs(1)) if regexm(term, "interact_post_event_([0-9]+)")

    * 標記該行是否為 interact 及其緊接在後的標準誤列
    gen to_keep = 0
    replace to_keep = 1 if !missing(interact_num)
    replace to_keep = 1 if _n > 1 & !missing(interact_num[_n-1]) // 這是為了抓到括號標準誤列
    
    * 只保留 1-3 與 5-8 (跳過 4，因為我們要手動補入基準期 -1)
    replace interact_num = interact_num[_n-1] if missing(interact_num) & to_keep == 1
    keep if inlist(interact_num, -3, -2, -1, 1, 2, 3) & to_keep == 1

    * 2. 核心映射邏輯：將 1-8 轉換為 -4 到 3
    * 映射公式：event_time = interact_num - 5
    * 1-5=-4, 2-5=-3, 3-5=-2 / 5-5=0, 6-5=1, 7-5=2, 8-5=3
    gen event_time = interact_num 

    * 判斷是否為標準誤列 (根據原始 term 是否含括號)
    gen is_se = strpos(term, "(") > 0 | (term == "")

	 * 去掉星號、括號、逗號，將 m1 轉為純數字
	destring m1, replace ignore("*" "(" ")" ",")

	* --- 2. 結構轉置 (從上下行變成左右欄) ---
	* 建立一個標籤來區分 estimate 與 se
	gen type = cond(is_se == 1, "se", "estimate")

	* 只保留核心欄位，以便進行 reshape
	keep event_time m1 type

	* 使用 reshape wide，將資料依照時間點 (event_time) 展開
	* 執行後會生成 m1estimate 與 m1se 兩個變數
	reshape wide m1, i(event_time) j(type) string

	* 重新命名欄位方便繪圖
	rename m1estimate estimate
	rename m1se se
	
	* --- 3. 補入基準期資料 ---
	local new_obs = _N + 1
	set obs `new_obs'

	* 在最後一行填入基準期數值 (假設基準期為 -1)
	replace event_time = 0 in L
	replace estimate = 0 in L
	replace se = 0 in L

	* 重新排序確保連線正確
	sort event_time

    * 5. 計算 95% 置信區間
    * 公式： $$Estimate \pm 1.96 \times SE$$
    gen ci_lo = estimate - 1.96 * se
    gen ci_hi = estimate + 1.96 * se

	* --- 自動對應資料夾名稱 ---
    if "`sh'" == "新增房貸機率" {
        local folder_name "新增房貸"
    }
	else if "`sh'" == "購屋機率"{
		local folder_name "購屋機率"
	}
    else if "`sh'" == "購屋於台北" {
        local folder_name "購屋於台北"
    }
    else if "`sh'" == "購屋於六都" {
        local folder_name "購屋於六都"
    }
	
	local final_dir "${local_path}/`folder_name'/${build_date}_${ana}"
    capture mkdir "`final_dir'"
	local dropbox_dir "${dropbox_path}/`folder_name'/${build_date}_${ana}"
    capture mkdir "`dropbox_dir'"
	
    * 6. 繪圖
        twoway ///
            (rcap ci_hi ci_lo event_time, lcolor(maroon) sort) ///
            (connect estimate event_time, lcolor(navy) msize(small) sort) ///
            , ///
			legend(off) ///
            yline(0, lp(solid) lc(black)) ///
            xline(0, lp(dash) lc(gray)) /// 標示基準期
            xlabel(-3(1)3) ///
            title("Dynamic_DID ") ///
			subtitle("`sh'") ///
            ytitle("DID Estimates") xtitle("Date") ///
            graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
            
        graph export "${local_path}/test/`sh'.png", replace // 測試
		graph export "`final_dir'/${proj_ver}_dynamic_DID.png", as(png) replace
		graph export "`dropbox_dir'/${proj_ver}_dynamic_DID.png", as(png)  replace
    }
}



