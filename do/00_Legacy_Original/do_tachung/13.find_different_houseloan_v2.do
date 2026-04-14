clear all
forv i=99(1)99{
global i= `i'
global j= $i -1
display $i
display $j
use "E:\tachun\Houseloan\dta\房貸資料\houseloan_${i}_relation.dta"
append using "E:\tachun\Houseloan\dta\房貸資料\houseloan_${j}_relation.dta"

// -----------------------------------------------------------------------------------------
gen hou_get_year = substr(hou_get_date,1,3)
destring hou_get_year, replace force

// 先把第一年有資料，第二年沒資料的人刪掉。
bysort ID date_yr: gen year_first_one = _n==1 //每一年第一筆資料做標記
bysort ID : gen num_year= sum(year_first_one) 
bysort ID : replace num_year= num_year[_N] //將每個人總共有幾年資料算出來
drop if num_year==1 & date_yr == $j //把只有一年資料的且年份為前一年的人找出來
drop year_first_one num_year

//保留取得日期為當年的資料
preserve
drop if hou_get_year!=$i
tempfile have_date_new
save `have_date_new'
restore


//將剛剛保留的資料去掉，將一筆繳款資料算成一筆房貸，算每人有幾筆非當年的房貸
keep if hou_get_year!=$i
sort ID date_yr
duplicates tag ID date_yr, gen(loan_left)
replace loan_left=loan_left+1

//跟前一年相比，只保留保留總筆數較大的人
preserve
bysort ID date_yr: keep if _n==1
keep ID date_yr loan_left
reshape wide loan_left, i(ID) j(date_yr)
keep if loan_left$i>loan_left$j
gen new_no_date = loan_left$i - loan_left$j //保留筆數較大的人後，算說到底有幾筆新增
keep ID new_no_date
tempfile more_house_loan
save `more_house_loan'
restore

//將原本資料跟剛剛算出來的ID做合併
merge m:1 ID using `more_house_loan'
keep if _merge==3
drop _merge
drop if date_yr==$j


gen is_new = 0
gsort ID -hou_get_date
bysort ID: replace is_new=1 if _N-_n < new_no_date //照房屋取得日期排列，將新增的房貸由下而上指認為新房貸
drop if is_new == 0
drop is_new

append using `have_date_new' //最後合併一開始保留的，取得日期為當年的房貸資料

gsort ID -hou_get_date 
bysort ID: gen mark =_n  //照房屋取得日期排列後，給予其編號n辨認為第n筆資料，讓契稅在合併時可以以1對1合併
tempfile houseloan_marked
save `houseloan_marked'
save  "E:\tachun\Houseloan\dta\每年房貸新增資料_2\new_houseloan${j}-${i}_relation.dta",replace
}

// 以下為嘗試合併契稅資料。
// use "I:\tachun\Houseloan\dta\契稅資料\chtt_110.dta", clear
// gsort ID -flg_date
// bysort ID: gen mark = _n
// merge 1:1 ID mark using `houseloan_marked'
//
// keep if _merge==3
// 算合併成功的資料，他們取得日期與申報日期差多少天
// gen int date1 = mdy(real(substr(hou_get_date,4,2)),real(substr(hou_get_date,6,2)),real(substr(hou_get_date,1,3))+1911)
// gen int date2 = mdy(real(substr(flg_date,4,2)),real(substr(flg_date,6,2)),real(substr(flg_date,1,3))+1911)
// gen date_diff=date1-date2
