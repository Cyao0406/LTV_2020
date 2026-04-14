//===========================================================//
// 檔案更名程式碼 (非完整,需修改)
//===========================================================//

clear all

// 1. 設定工作路徑 (請填入您圖中檔案所在的資料夾)
cd "C:\您的檔案路徑"

// 2. 抓取目前目錄下所有的 .xlsx 檔案列表並存入 local macro
local fileList : dir . files "*.xlsx"

// 3. 遍歷每一個檔案執行邏輯判斷與改名
foreach oldName in `fileList' {
    
    // 檢查檔名中是否包含 "Dynamics" (注意大小寫需與圖片中的 Dynamics 一致)
    if strpos("`oldName'", "Dynamics") > 0 {
        
        // 規則 1：有 Dynamics 的檔案，在 _Dynamics 前加上 D3
        // 我們將 "_Dynamics" 替換為 "_D3_Dynamics" (保留底線以維持格式一致)
        local newName = subinstr("`oldName'", "_Dynamics", "_D3_Dynamics", 1)
    }
    else {
        
        // 規則 2：沒有 Dynamics 的檔案，在 _DID 前加上 D3
        // 我們將 "_DID" 替換為 "_D3_DID"
        local newName = subinstr("`oldName'", "_DID", "_D3_DID", 1)
    }
    
    // 4. 執行改名操作
    // 使用 copy 先複製出一份新名字的檔案
    // replace 選項確保如果新檔名已存在則覆蓋
    copy "`oldName'" "`newName'", replace
    
    // 確認複製成功後，刪除原本的舊檔案
    erase "`oldName'"
    
    // 在視窗顯示處理進度
    display "已將 {text:`oldName'} 改名為 {result:`newName'}"
}