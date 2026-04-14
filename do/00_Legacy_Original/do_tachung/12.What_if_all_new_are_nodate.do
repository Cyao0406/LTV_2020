//此do檔案是為了看若除了取得日期為當年的房貸，剩下的全為無取得日期的話，能串到多少契稅資料。
clear all
global i= 108
global j= $i -1

use "I:\tachun\Houseloan\dta\房貸資料\houseloan_${i}_relation.dta"
append using "I:\tachun\Houseloan\dta\房貸資料\houseloan_${j}_relation.dta"

// -----------------------------------------------------------------------------------------
gen hou_get_year = substr(hou_get_date,1,3)
destring hou_get_year, replace force

// 先把第一年有資料，第二年沒資料的人刪掉。
bysort ID date_yr: gen year_first_one = _n==1
bysort ID : gen num_year= sum(year_first_one)
bysort ID : replace num_year= num_year[_N]
drop if num_year==1 & date_yr == $j
drop year_first_one num_year

//存取得日期為當年的房貸
preserve
drop if hou_get_year!=$i
gen date_new=1
tempfile have_date_new
save `have_date_new'
restore


//把取得日期非當年的留下來，一筆繳款資料算成一筆房貸
keep if hou_get_year!=$i
sort ID date_yr
duplicates tag ID date_yr, gen(loan_left)
replace loan_left=loan_left+1

//只保留非該年取得的總筆數，比前一年大的人，且算出筆數多出多少
preserve
bysort ID date_yr: keep if _n==1
keep ID date_yr loan_left
reshape wide loan_left, i(ID) j(date_yr)
keep if loan_left$i>loan_left$j
gen new_no_date = loan_left$i - loan_left$j
keep ID new_no_date
tempfile more_house_loan
save `more_house_loan'
restore

merge m:1 ID using `more_house_loan'
keep if _merge==3
drop _merge
drop if date_yr==$j

//根據繳款筆數多出多少，將取得日期較新或是無房屋取得日期的資料算為新房貸
gen is_new = 0
gsort ID -hou_get_date
bysort ID: replace is_new=1 if (_N-_n < new_no_date)
drop if is_new == 0
drop is_new
//將所有新增的皆為無取得日期的找出來
gen n=1 if hou_get_date!=""
bysort ID: egen check=sum(n)
drop if check!=0
drop n check
gen date_new=0
count
//算有多少人
bysort ID: gen n=_n==1
count if n==1
drop n 

//合併取得日期為該年的資料回去
append using `have_date_new'
gsort ID -hou_get_date
bysort ID: gen mark =_n
tempfile houseloan_marked
save `houseloan_marked'


use "I:\tachun\Houseloan\dta\契稅資料\chtt_${i}.dta", clear
gsort ID -flg_date
bysort ID: gen mark = _n
merge 1:1 ID mark using `houseloan_marked'
drop if date_new==1
count if _merge==3
//算有多少人
preserve
keep if _merge==3
bysort ID: gen n=_n==1
count if n==1
drop n 
restore
