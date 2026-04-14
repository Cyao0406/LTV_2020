
*===============================================================================
* 專案名稱：[LTV2020]
* 檔案名稱：20260115 drop_no_hou_get_date.do
* 建立日期：2026-01-15
* 最後修改：2026-02-01
* 建立者：[Chun Yao]
*-------------------------------------------------------------------------------
* [專案目的]
*	1. 刪除「無房屋取得日期」之樣本
*	2. 統計各類房貸數量 (1 與 3 型態) -> ( 2 與 4型態)
*	3. 趨勢分析：繪製 Outcome 趨勢圖及狀態轉變比例變化
*	4. 實證模型：估計 Pre/Post DID 與 Dynamic DID (事件研究法)
*-------------------------------------------------------------------------------
* [環境與路徑設定 (Directory & Input Tracking)]
* B. Input Files (攜入檔/原始來源)：
* - 來源檔案 1：D:\stsdat\ibr\dta\依列舉內容切檔\ibrt400_*.dta
* - 來源檔案 2：[填入其他關聯資料表名稱]
*===============================================================================

** ################################################################################
**# 01. 整理原始 ibr 資料 - 整理出貸款資料 (每年度)
** ################################################################################
* 重新生成新增貸款資料
clear all

forv i=98(1)112{
use "D:\stsdat\ibr\dta\依列舉內容切檔\ibrt400_2_`i'.dta"

gen no_date = (hou_get_date == "")
bysort ID: egen no_date_count = max(no_date) 
drop if no_date_count == 1

gen get_yr = substr(hou_get_date,1,3)
destring get_yr,replace force
keep if inrange(get_yr,50,113)

preserve
egen house_group1 = group(hou_get_date)
egen house_group2 = group(hou_get_date list_unit_ban)
bysort ID house_group1: gen num_of_loan3 = _n==1
bysort ID house_group2: gen num_of_loan6 = _n==1

bysort ID: replace num_of_loan3= sum(num_of_loan3)
bysort ID: replace num_of_loan3= num_of_loan3[_N]
bysort ID: replace num_of_loan6 = sum(num_of_loan6)
bysort ID: replace num_of_loan6 = num_of_loan6[_N]
bysort ID: gen cnt =_n

drop if cnt != 1
keep ID num_of_loan3 num_of_loan6
tempname temp2
save `temp1', replace 
restore

merge m:1 ID using `temp1'
drop _merge
label variable num_of_loan3 "累積房貸_同取得日"
label variable num_of_loan6 "累積房貸_同取得日且同列舉單位"

* preserve
* sample 20, count
* list in 1/20, sepby(id)
* restore


save "E:/cy/LTV2020/LTV2020_eli_nodate/rdta/ibr/依年度/houseloan_`i'_relation_nodate.dta", replace
}

** ################################################################################
**# 02. 彙整期間貸款資料 (98 - 113)
** ################################################################################
use  "E:/cy/LTV2020/LTV2020_eli_nodate/rdta/ibr/依年度/houseloan_98_relation_nodate.dta",clear
forv i = 99(1)113{
	append using "E:/cy/LTV2020/LTV2020_eli_nodate/rdta/ibr/依年度/houseloan_`i'_relation_nodate.dta"
}
save "E:/cy/LTV2020/LTV2020_eli_nodate/rdta/ibr/依年度/houseloan_98-113_relation_nodate.dta",replace


** =============================================================================
**## 2.1 Data Check 
** =============================================================================

tab num_of_loan3 num_of_loan6
gen diff_num = num_of_loan6 - num_of_loan3
tab diff_num


** --- snapshot 用法 ---
snapshot save, label("原先資料")
drop if diff_num > 3

snapshot restore 1
snapshot list // 查看快照編號
snapshot erase 2

Stata
forv i = 1/10 {
    cap snapshot erase `i'
}


** --- frame 用法 ---
frame copy default backup1
drop if diff_num >3

frame copy backup1 default,replace 
frame copy default backup2

frame dir // 查看有哪些頁面
frame rename backup1 original_raw
frame drop backup2





** ################################################################################
**# 03. 計算新增房貸
** ################################################################################



