* Finalized on: 2026-02-02 by [Chun Yao]

*===============================================================================
* 專案名稱：[LTV2020]
* 檔案名稱：00_main.do
* 建立日期：2026-01-23
* 最後修改：2026-01-23
* 建立者：[Chun Yao]
* 目的：主控制台,環境設定
*===============================================================================

*================================================================================================================================================================================================*

/*******************************************************************************
   [層次結構說明]
   LEVEL 1: ########################## (大章節：環境、階段)
   LEVEL 2: ========================== (中節次：具體任務)
   LEVEL 3: -------------------------- (小項目：清洗、合併)
   LEVEL 4: * --- [Step] ---          (執行步驟)
   LEVEL 5: // 註解                    (行內代碼說明)
*******************************************************************************/

*================================================================================================================================================================================================*

// ################################################################################
//# 00. 環境清除與初始化 (ENVIRONMENT SETTINGS)
// ################################################################################

clear all             	// 清除記憶體中的舊資料
macro drop _all			// 刪除所有macros
capture log close     	// 關閉先前可能未正常關閉的 log 檔案
set more off          	// 讓輸出結果不間斷顯示
set mem 500m          	// (選用) 設定記憶體大小
version 17.0          	// 鎖定 Stata 版本，確保語法相容性
// adopath + "D:\stsdat\ado\plus" // 啟用套件

// =============================================================================
//## 0.1 設定路徑
// =============================================================================

**#### --- 設定本地路徑 (使用 Global 方便不同電腦切換) ---
global local_root "C:/Users/user/OneDrive/桌面/work/114/RA with Tzu-Ting/LTV_2020"
global raw_path "$local_root/data/rdata"
global work_path "$local_root/data/wdata"
global figures_path "${local_root}/figures"
global results_path "$local_root/results"
global temp "$local_root/temp" // 暫存檔 tempfile
capture mkdir "$temp"

cd "$root" // 設定工作檔案夾 

**#### --- 設定雲端路徑 (使用 Global 方便不同電腦切換) ---
global dropbox_root "C:/Users/user/Dropbox/LTV_財資版/data"
global dr_raw_path "$dropbox_root/data/rdata"
global dr_work_path "$dropbox_root/data/wdata"
global dr_figures_path "${dropbox_root}/figures"
global dr_results_path "$dropbox_root/results"

**#### --- 設定研究設計 (使用 Global 方便不同電腦切換) ---
global proj_ver = "S_Lag_M_TI_Tr_D3" // 研究版本
global my_vars "have_new_houseloan have_new_house buy_in_taipei but_in_six" // outcome變數
global build_date "2026-02-01" 
global ana "DID_practice" // 分析內容

global Input "$raw_path/${proj_ver}_Dynamic_DID_results.xlsx" // 原始資料


// capture mkdir "path" // Create folder if it doesn't exist

local sheets "新增房貸機率 購屋機率 購屋於台北 購屋於六都"

**#### --- log檔紀錄 ---
capture mkdir "$local_root/code/logs"
log using "$local_root/code/logs/00_main.log", replace



// ################################################################################
//# 01. Data cleaning 
// ################################################################################

// do "do/01_cleaning.do"



// ################################################################################
//# 02. ANALYSIS & VISUAL PHASE
// ################################################################################

do "do/01_analysis & visual.do"


