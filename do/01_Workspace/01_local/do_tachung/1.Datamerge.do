//Datamerge.do
clear all
//將R程式碼算出來的每一年每個人有多少房屋，合併成一份大資料。
use "I:\tachun\Houseloan\dta\自用住宅\jhq_hou_count_97.dta" 
gen year=2008
forv i = 98(1)111{
	append using "I:\tachun\Houseloan\dta\自用住宅\jhq_hou_count_`i'.dta" 
	replace year=`i'+1911 if year==.
}
rename idn ID
sort ID year
duplicates tag ID year, gen(dup)
drop if dup !=0
drop dup
save "I:\tachun\Houseloan\dta\how_many_houses_total.dta", replace

clear all
//將所有房貸資料合併。ibrt400有很多種資料，2就是房貸資料。
use "D:\stsdat\ibr\dta\ibrt400_98.dta" 
drop if list_format_cd!="2"
forv i = 99(1)112{
	append using "D:\stsdat\ibr\dta\ibrt400_`i'.dta" 
	drop if list_format_cd!="2"
}
gen year=hou_get_year+1911
rename list_id_idn ID // 這邊是用list_id_idn作為ID，之後發現用relation_ID才能串到比較多。

save "E:\tachun\Houseloan\dta\total_houseloan.dta", replace


//這邊將每人每年有幾多少房屋跟房貸資料合併
use "I:\tachun\Houseloan\dta\how_many_houses_total.dta", clear
sort ID
bysort ID: gen houses_last_year= pers_n[_n-1]//新增變數紀錄這個人前一年有多少房屋
merge 1:m ID year using "I:\tachun\Houseloan\dta\total_houseloan.dta"//合併房貸，使用1:m是因為每個人一年只會有一筆資料記錄他有多少房屋，但一年可能有很多筆房貸繳款資料。
drop if _merge!=3 //保留串到的資料
sort list_unit_ban ID hou_get_date
bysort list_unit_ban ID hou_get_date: gen n=_n //找出同ID同取得日期的算成一筆
keep if n==1 //只保留同ID同取得日期的房貸資料，後續發現一個人一天可能買好幾棟房，所以這件事並不合理。
drop _merge n
save "I:\tachun\Houseloan\dta\houseloan_and_houses_owned.dta", replace