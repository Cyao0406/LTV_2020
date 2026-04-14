clear all
use "I:\tachun\Houseloan\dta\房貸資料\houseloan_110_list.dta"
append using "I:\tachun\Houseloan\dta\房貸資料\houseloan_111_list.dta"

// 資料裡面的num_of_loan5代表110年跟111年一個ID有幾筆房貸(無取得日期都算獨立一筆，相同取得日期則計算為相同)
// -----------------------------------------------------------------------------------------
gen hou_get_year = substr(hou_get_date,1,3)
destring hou_get_year, replace force

// 先把第一年有資料，第二年沒資料的人刪掉。
bysort ID date_yr: gen year_first_one = _n==1
bysort ID : gen num_year= sum(year_first_one)
bysort ID : replace num_year= num_year[_N]
drop if num_year==1 & date_yr == 110

// 第一種算法: 取得日期在2022年則視為新增，無取得日期則依筆數來判斷是否為新增。

// 先算每年有多少沒有取得日期的繳款資料
bysort ID hou_get_date date_yr: gen num_no_date=_n if hou_get_date==""
bysort ID date_yr: egen max_no_date = max(num_no_date)
replace max_no_date = 0 if max_no_date == .

// 製作一個tempfile 計算111年無繳款資料比110年繳款資料多多少筆(比較少則在下一步驟計為0)
preserve
bysort ID date_yr: keep if _n==1
keep ID date_yr max_no_date
reshape wide max_no_date, i(ID) j(date_yr)
keep if max_no_date111>max_no_date110
gen new_no_date= max_no_date111 - max_no_date110
tab new_no_date
keep ID new_no_date
tempfile more_no_date
save `more_no_date'
restore

// 將原本資料與tempfile合併
merge m:1 ID using `more_no_date'
drop if date_yr==110

replace new_no_date=0 if new_no_date==.
// 將"房屋取得日期在111年"的資料標記為新的房貸
gen is_new = hou_get_year==111
// 再將"無房屋取得日期"的，依照比110年多的筆數，從後往前數標記為新的房貸
bysort ID hou_get_date date_yr: replace is_new=1 if (hou_get_date=="") & (_N-_n < new_no_date)

drop if is_new==0

save "I:\tachun\Houseloan\dta\每年房貸新增資料\new_houseloan110-111_list.dta"

// 第二種算法: 先比筆數，再做一模一樣的事

// 先算前一年筆數，若是前一年筆數比較多的則移除
preserve
bysort ID date_yr: keep if _n==1
keep ID date_yr num_of_loan5
reshape wide num_of_loan5, i(ID) j(date_yr)
keep if num_of_loan5111>num_of_loan5110
keep ID 
tempfile more_house_loan
save `more_house_loan'
restore

merge m:1 ID using `more_house_loan'
replace _merge=0 if _merge!=3
replace _merge=1 if _merge==3
ren _merge more_house_loan
tab more_house_loan

bysort ID hou_get_date date_yr: gen num_no_date=_n if hou_get_date==""
bysort ID date_yr: egen max_no_date = max(num_no_date)
replace max_no_date = 0 if max_no_date == .

preserve
bysort ID date_yr: keep if _n==1
keep ID date_yr max_no_date
reshape wide max_no_date, i(ID) j(date_yr)
keep if max_no_date111>max_no_date110
gen new_no_date= max_no_date111 - max_no_date110
tab new_no_date
keep ID new_no_date
tempfile more_no_date
save `more_no_date'
restore

merge m:1 ID using `more_no_date'
drop if date_yr==110

gen is_new = hou_get_year==111
replace new_no_date=0 if new_no_date==.
drop if is_new == 0 & more_house_loan ==0 
sort ID hou_get_date
bysort ID hou_get_date date_yr: replace is_new=1 if (hou_get_date=="") & (_N-_n < new_no_date)


drop if is_new==0
save "I:\tachun\Houseloan\dta\房貸資料\new_houseloan110-111_second.dta"

merge m:m n_holder_idn_ban using "D:\stsdat\cht\dta\chtt030.dta" 
