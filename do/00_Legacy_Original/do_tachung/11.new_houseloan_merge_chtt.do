//此程式碼嘗試將每年新增房貸(以取得日期來分)串契稅看看
clear all
use "I:\tachun\Houseloan\dta\每年房貸新增資料\new_houseloan109-110_list.dta"

merge m:m ID date_yr using "I:\tachun\Houseloan\dta\契稅資料\chtt_110.dta"

clear all
use "I:\tachun\Houseloan\dta\每年房貸新增資料\new_houseloan109-110_relation.dta"

merge m:m ID date_yr using "I:\tachun\Houseloan\dta\契稅資料\chtt_110.dta"


clear all
use "I:\tachun\Houseloan\dta\每年房貸新增資料\new_houseloan108-109_relation.dta"

merge m:m ID date_yr using "I:\tachun\Houseloan\dta\契稅資料\chtt_109.dta"
keep if _merge==1 
drop _merge
merge m:m ID using "I:\tachun\Houseloan\dta\契稅資料\chtt_108.dta"