//此檔案嘗試去找每筆房貸是每人或每戶的第幾棟房子

use "I:\tachun\Houseloan\dta\how_many_houses_total.dta", clear
sort ID year
bysort ID: gen houses_last_year_family= all_house_count[_n-1] //每戶前一年有幾棟
bysort ID: gen houses_last_year= pers_n[_n-1] //每人前一年有幾棟
duplicates tag ID year ,gen(dup)
drop if dup!=0
drop dup
merge 1:m ID year using "I:\tachun\Houseloan\dta\total_houseloan.dta" //與房貸資料合併
drop if _merge!=3
sort ID hou_get_date //依據房貸的房屋取得日期排列
bysort ID hou_get_date: gen n=_n keep if n==1
drop _merge n
//扣掉同一ID且同一房屋取得日期的資料，這是初期做法，之後應該是要保留。
drop list_t_amt
save "I:\tachun\Houseloan\dta\houseloan_and_houses_owned.dta", replace //存成一個持有房貸及今年房屋數、去年房屋數的大檔案

clear all
use "I:\tachun\Houseloan\dta\houseloan_and_houses_owned.dta"
sort ID year
bysort ID year: gen houses_that_year= _n //算出每個人每筆房貸是那年第幾個房貸
ren houses_last_year houses_last_year_pers
gen nth_house=houses_last_year_pers+houses_that_year //將那年第幾棟房子與去年底有幾棟房子做相加，就會得到這是這個人第幾棟房子
save "I:\tachun\Houseloan\dta\nth_house.dta", replace

//下面帶有2的版本則是使用關係人relation_idn來做一模一樣的步驟
use "I:\tachun\Houseloan\dta\total_houseloan.dta", clear
replace ID=relation_idn if relation_idn !="" 
save "I:\tachun\Houseloan\dta\total_houseloan2.dta", replace

use "I:\tachun\Houseloan\dta\how_many_houses_total.dta", clear
sort ID
bysort ID: gen houses_last_year_family= all_house_count[_n-1]
bysort ID: gen houses_last_year_pers= pers_n[_n-1]
merge 1:m ID year using "I:\tachun\Houseloan\dta\total_houseloan2.dta"
drop if _merge!=3
sort list_unit_ban ID hou_get_date
bysort list_unit_ban ID hou_get_date: gen n=_n
keep if n==1
drop _merge n
save "I:\tachun\Houseloan\dta\houseloan_and_houses_owned2.dta", replace

clear all
use "I:\tachun\Houseloan\dta\houseloan_and_houses_owned2.dta"
bysort ID year: gen houses_that_year= _n
gen nth_house=houses_last_year_pers+houses_that_year-1
gen nth_house2=houses_last_year_family+houses_that_year-1
tab nth_house
tab nth_house2 