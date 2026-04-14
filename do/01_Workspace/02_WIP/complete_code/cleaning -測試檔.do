




"jhq -> how_many_houses_total"
"ibr -> total_houseloan "
"jhq & ibr -> houseloan_and_houses_owned"


"chtt -> chtt_`i"

"how_many_houses_total & total_houseloan -> houseloan_and_houses_owned"
"houseloan_and_houses_owned -> nth_house "
"how_many_houses_total & total_houseloan2 -> houseloan_and_houses_owned2"

"ibr -> houseloan_`i'_list"

"ibr -> houseloan_`i'_relation"





** ################################################################################
**# ibr 整理
** ################################################################################

** =============================================================================
**## 整理新增房貸數量資料
** =============================================================================


forv i = 98(1)112{
	local j = `i' + 1
	use "D:\stsdat\ibr\dta\依列舉內容切檔\ibrt400_2_`i'.dta", clear 
	append using "D:\stsdat\ibr\dta\依列舉內容切檔\ibrt400_2_`j'.dta"	
	bysort ID: gen is_new = 1 if hou_get_year = `j'
	preserve
	drop if hou_get_year == `j'

	restore
	
	save "${rdta_path}/新增房貸/new_houseloan`i'-`j'_relation.dta"
	}

** =============================================================================
**## 比較不同算法的房貸數量變化與新增房貸數量
** =============================================================================

forv i = 98(1)112{
	use "${rdta_path}/ibr/依年度/houseloan_`i'_relation.dta", clear
	append using "${rdta_path}/ibr/依年度/houseloan_`j'_relation.dta"
	forv k=1(1)5{
		reshape wide num_of_loan`k', i(ID) j(date_yr)
		gen num_diff_loan`k' = num_of_loan`j' - num_of_loan`i'
	}
	tempfile diff_loan`i'-`j'
	save `diff_loan`i'-`j''
}

use `diff_loan`98'-`99'',clear
forv i = 99(1)112{
	append using `diff_loan`i'-`j''
}

merge m:1 using "${rdta_path}/新增房貸/new_houseloan`i'-`j'_relation.dta"



** ################################################################################
**# chtt 整理
** ################################################################################

** =============================================================================
**## chtt 切割檔案
** =============================================================================






** ################################################################################
**# 合併資料
** ################################################################################

** =============================================================================
**## 檢查房貸和契稅合併後資料數量
** =============================================================================






** ################################################################################
**# 7.find_different_houseloan_list
** ################################################################################

clear all
forv i=98(1)110{
	local j = `i'+ 1
	use "I:\tachun\Houseloan\dta\房貸資料\houseloan_`i'_list.dta"
	append using "I:\tachun\Houseloan\dta\房貸資料\houseloan_`j'_list.dta"

	// -----------------------------------------------------------------------------------------//
	gen hou_get_year = substr(hou_get_date,1,3)
	destring hou_get_year, replace force

	//先把第一年有資料，第二年沒資料的人刪掉。
	bysort ID date_yr: gen year_first_one = _n==1
	bysort ID : gen num_year= sum(year_first_one)
	bysort ID : replace num_year= num_year[_N]
	drop if num_year==1 & date_yr == `i'

	//第一種算法: 取得日期在j年則視為j年新增，無取得日期則依筆數來判斷是否為新增。

	//先算每年有多少沒有取得日期的繳款資料
	bysort ID hou_get_date date_yr: gen num_no_date=_n if hou_get_date==""
	bysort ID date_yr: egen max_no_date = max(num_no_date)
	replace max_no_date = 0 if max_no_date == .

	//製作一個tempfile 計算j年無繳款資料比i年繳款資料多多少筆(比較少則在下一步驟計為0)
	preserve
	bysort ID date_yr: keep if _n==1
	keep ID date_yr max_no_date
	reshape wide max_no_date, i(ID) j(date_yr)
	keep if max_no_date`j'>max_no_date`i'
	gen new_no_date= max_no_date`j' - max_no_date`i'
	tab new_no_date
	keep ID new_no_date
	tempfile more_no_date
	save `more_no_date'
	restore

	//將原本資料與tempfile合併
	merge m:1 ID using `more_no_date'
	drop if date_yr==`i'

	replace new_no_date=0 if new_no_date==.
	//將"房屋取得日期在j年"的資料標記為新的房貸
	gen is_new = hou_get_year==`j'
	//再將"無房屋取得日期"的，依照比i年多的筆數，從後往前數標記為新的房貸
	bysort ID hou_get_date date_yr: replace is_new=1 if (hou_get_date=="") & (_N-_n < new_no_date)

	drop if is_new==0
	drop year_first_one is_new _merge num_year num_no_date max_no_date new_no_date
	save "I:\tachun\Houseloan\dta\每年房貸新增資料\new_houseloan`i'-`j'_list.dta", replace
}

** ################################################################################
**# 8.find_different_houseloan_relation
** ################################################################################

clear all
forv i=98(1)110{
	local j = `i'+ 1
	use "I:\tachun\Houseloan\dta\房貸資料\houseloan_`i'_relation.dta"
	append using "I:\tachun\Houseloan\dta\房貸資料\houseloan_`j'_relation.dta"

	// -----------------------------------------------------------------------------------------//
	gen hou_get_year = substr(hou_get_date,1,3)
	destring hou_get_year, replace force

	//先把第一年有資料，第二年沒資料的人刪掉。
	bysort ID date_yr: gen year_first_one = _n==1
	bysort ID : gen num_year= sum(year_first_one)
	bysort ID : replace num_year= num_year[_N]
	drop if num_year==1 & date_yr == `i'

	//第一種算法: 取得日期在j年則視為j年新增，無取得日期則依筆數來判斷是否為新增。

	//先算每年有多少沒有取得日期的繳款資料
	bysort ID hou_get_date date_yr: gen num_no_date=_n if hou_get_date==""
	bysort ID date_yr: egen max_no_date = max(num_no_date)
	replace max_no_date = 0 if max_no_date == .

	//製作一個tempfile 計算j年無繳款資料比i年繳款資料多多少筆(比較少則在下一步驟計為0)
	preserve
	bysort ID date_yr: keep if _n==1
	keep ID date_yr max_no_date
	reshape wide max_no_date, i(ID) j(date_yr)
	keep if max_no_date`j'>max_no_date`i'
	gen new_no_date= max_no_date`j' - max_no_date`i'
	tab new_no_date
	keep ID new_no_date
	tempfile more_no_date
	save `more_no_date'
	restore

	//將原本資料與tempfile合併
	merge m:1 ID using `more_no_date'
	drop if date_yr==`i'

	replace new_no_date=0 if new_no_date==.
	//將"房屋取得日期在j年"的資料標記為新的房貸
	gen is_new = hou_get_year==`j'
	//再將"無房屋取得日期"的，依照比i年多的筆數，從後往前數標記為新的房貸
	bysort ID hou_get_date date_yr: replace is_new=1 if (hou_get_date=="") & (_N-_n < new_no_date)

	drop if is_new==0
	drop year_first_one is_new _merge num_year num_no_date max_no_date new_no_date
	save "I:\tachun\Houseloan\dta\每年房貸新增資料\new_houseloan`i'-`j'_relation.dta", replace
}

** ################################################################################
**# 9.find_different_houseloan_110-111_list
** ################################################################################

clear all
use "I:\tachun\Houseloan\dta\房貸資料\houseloan_110_list.dta"
append using "I:\tachun\Houseloan\dta\房貸資料\houseloan_111_list.dta"

// 資料裡面的num_of_loan5代表110年跟111年一個ID有幾筆房貸(無取得日期都算獨立一筆，相同取得日期則視為同筆)
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

// 檢查此算法算完後的資料分布
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


** ################################################################################
**# 10.find_different_houseloan_110-111_relation
** ################################################################################
clear all
use "I:\tachun\Houseloan\dta\房貸資料\houseloan_110_relation.dta"
append using "I:\tachun\Houseloan\dta\房貸資料\houseloan_111_relation.dta"

// 資料裡面的num_of_loan5代表110年跟111年一個ID有幾筆房貸(無取得日期都算獨立一筆，相同取得日期則計算為相同)
// -----------------------------------------------------------------------------------------//
gen hou_get_year = substr(hou_get_date,1,3)
destring hou_get_year, replace force

//先把第一年有資料，第二年沒資料的人刪掉。
bysort ID date_yr: gen year_first_one = _n==1
bysort ID : gen num_year= sum(year_first_one)
bysort ID : replace num_year= num_year[_N]
drop if num_year==1 & date_yr == 110

//第一種算法: 取得日期在2022年則視為新增，無取得日期則依筆數來判斷是否為新增。

//先算每年有多少沒有取得日期的繳款資料
bysort ID hou_get_date date_yr: gen num_no_date=_n if hou_get_date==""
bysort ID date_yr: egen max_no_date = max(num_no_date)
replace max_no_date = 0 if max_no_date == .

//製作一個tempfile 計算111年無繳款資料比110年繳款資料多多少筆(比較少則在下一步驟計為0)
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

//將原本資料與tempfile合併
merge m:1 ID using `more_no_date'
drop if date_yr==110

replace new_no_date=0 if new_no_date==.
//將"房屋取得日期在111年"的資料標記為新的房貸
gen is_new = hou_get_year==111
//再將"無房屋取得日期"的，依照比110年多的筆數，從後往前數標記為新的房貸
bysort ID hou_get_date date_yr: replace is_new=1 if (hou_get_date=="") & (_N-_n < new_no_date)

drop if is_new==0


//第二種算法: 先比筆數，再做一模一樣的事

//先算前一年筆數，若是前一年筆數比較多的則移除
preserve
bysort ID date_yr: keep if _n==1
keep ID date_yr num_of_loan5
reshape wide num_of_loan5, i(ID) j(date_yr)
keep if num_of_loan5111>=num_of_loan5110
keep ID 
tempfile more_house_loan
save `more_house_loan'
restore

merge m:1 ID using `more_house_loan'
keep if _merge==3
drop _merge

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

replace new_no_date=0 if new_no_date==.
gen is_new = hou_get_year==111
bysort ID hou_get_date date_yr: replace is_new=1 if (hou_get_date=="") & (_N-_n < new_no_date)

drop if is_new==0

** ################################################################################
**# 13.find_different_houseloan_v2
** ################################################################################
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


** ################################################################################
**# 11.new_houseloan_merge_chtt
** ################################################################################

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

** ################################################################################
**# 12.What_if_all_new_are_nodate
** ################################################################################

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


** ################################################################################
**# 14.契稅合併前一年12月
** ################################################################################

//這個do檔將原本每一年的契稅資料，改為當年1-11月加上前一年12月的契稅資料，因為申報日期可能實際上跟房貸撥款的日期有差異。

// 註解掉的這邊是將所有契稅合併在一起，因為申報日期有時候會跨到後一年，這樣在切每一年資料的時候才不會漏切。
// clear all
// use "I:\tachun\Houseloan\dta\契稅資料\chtt_98.dta", clear
// forv i=99(1)110{
// 	append using "I:\tachun\Houseloan\dta\契稅資料\chtt_`i'.dta"
// }
// gen flg_year = substr(flg_date,1,3)
// gen flg_month = substr(flg_date,4,2)
// destring flg_year,replace force
// destring flg_month,replace force
// save "I:\tachun\Houseloan\dta\契稅資料_合併前一年12月\chtt_total.dta",replace


forv i=110(-1)99{
global i= `i'
global j= $i -1
use "I:\tachun\Houseloan\dta\契稅資料_合併前一年12月\chtt_total.dta", clear
preserve
keep if (flg_year==${i}) | (flg_year==${j} & flg_month==12) //保留當年1-11月或前一年12月資料
gsort ID -flg_date
bysort ID: gen mark = _n 
merge 1:1 ID mark using "I:\tachun\Houseloan\dta\每年房貸新增資料_2\new_houseloan${j}-${i}_relation.dta"  //串當年房貸看看。
keep if _merge==1 & date_yr==${j} //保留前一年12月，且串不到的契稅資料
tempfile chtt_last_year_left
save `chtt_last_year_left'
restore
keep if (flg_year==${j} & flg_month!=12)//將前一年契稅1-11月的資料保留
append using `chtt_last_year_left'//append剛剛串不到的12月資料
keep o_holder_idn_ban hsn_cd ID hou_losn bl_ym contrct_date flg_date contrct_tp date_yr flg_year flg_month 
save "I:\tachun\Houseloan\dta\契稅資料_合併前一年12月\chtt_${j}.dta", replace
}



** ################################################################################
**# 15.新房貸資料合併新版本契稅
** ################################################################################

//拿"契稅合併前一年12月.do"儲存的dta來合併房貸新增資料，應該只能多串到4000-5000筆資料。
clear all
global i=108
global j=$i -1
global k=$i +1
use "I:\tachun\Houseloan\dta\契稅資料_合併前一年12月\chtt_${i}.dta",clear
gsort ID -flg_date
bysort ID: gen mark = _n
merge 1:1 ID mark using "I:\tachun\Houseloan\dta\每年房貸新增資料_2\new_houseloan${j}-${i}_relation.dta"
//算合到有多少人
// keep if _merge==3
// bysort ID: gen n=_n==1
// count if n==1

//以下為用原本的契稅資料串房貸資料，我寫在一起方便比較兩個串到的筆數差多少。
use "I:\tachun\Houseloan\dta\契稅資料\chtt_${i}.dta",clear
gsort ID -flg_date
bysort ID: gen mark = _n
merge 1:1 ID mark using "I:\tachun\Houseloan\dta\每年房貸新增資料_2\new_houseloan${j}-${i}_relation.dta"
keep if _merge==3
bysort ID: gen n= _n==1 
count if n==1


** ################################################################################
**# 16.第一波信用管制_新增房貸機率
** ################################################################################
adopath + "D:\stsdat\ado\plus"
clear all
use "E:\tachun\Houseloan\dta\房貸資料\houseloan_104_relation"
forv i=105(1)112{
	append using "E:\tachun\Houseloan\dta\房貸資料\houseloan_`i'_relation.dta"
}

sort date_yr
bysort ID date_yr: drop if _n!=1
gen year=date_yr+1911

bysort ID : gen treat1 =1 if num_of_loan1[_n-1]==2
bysort ID : replace treat1 =0 if num_of_loan1[_n-1]==1

bysort ID : gen treat2 =1 if num_of_loan2[_n-1]==2
bysort ID : replace treat2 =0 if num_of_loan2[_n-1]==1

bysort ID : gen treat3 =1 if num_of_loan3[_n-1]==2
bysort ID : replace treat3 =0 if num_of_loan3[_n-1]==1

bysort ID : gen treat4 =1 if num_of_loan4[_n-1]==2
bysort ID : replace treat4 =0 if num_of_loan4[_n-1]==1

bysort ID : gen treat5 =1 if num_of_loan5[_n-1]==2
bysort ID : replace treat5 =0 if num_of_loan5[_n-1]==1
save "E:\tachun\Houseloan\dta\房貸資料\houseloan_104-112_relation.dta", replace

gen have_new_houseloan=0
gen mark=1

forv i=104(1)112{
global j= `i'-1
merge 1:1 ID date_yr mark using "E:\tachun\Houseloan\dta\每年房貸新增資料_2\new_houseloan$j-`i'_relation"
drop if _merge==2
replace have_new_houseloan=1 if _merge==3
drop _merge
}
drop mark hou_get_year loan_left new_no_date

forv i=1(1)5{
preserve
collapse(mean) have_new_houseloan, by(treat`i' year)
drop if treat`i'==.
reshape wide have_new_houseloan, i(year) j(treat`i')
twoway(line have_new_houseloan1 year,sort) (line have_new_houseloan0 year, sort), xline(2020, lpattern(dash) lcolor(black)) legend(order(1 "實驗組" 2 "控制組")) xlabel(2016(1)2023) saving("E:\tachun\Houseloan\Figures\新增房貸機率\common_trend_`i'",replace)
graph export "E:\tachun\Houseloan\Figures\新增房貸機率\common_trend_`i'.png", replace
restore
}

gen post= year>=2020

forv i=1(1)5{
ren treat`i' treat
reg have_new_houseloan treat##post i.year
outreg2 using "E:\tachun\Houseloan\Results\新增房貸機率\DID_results.xlsx"
ren treat treat`i'
}

gen pre_event_4 = year==2016
gen pre_event_3 = year==2017
gen pre_event_2 = year==2018
gen pre_event_1 = year ==2019
gen post_event_0 = year==2020
gen post_event_1 = year==2021
gen post_event_2 = year==2022
gen post_event_3 = year==2023

forv i=1(1)5{
gen interact1= pre_event_4*treat`i'
gen interact2= pre_event_3*treat`i'
gen interact3= pre_event_2*treat`i'
gen interact4= pre_event_1*treat`i'
gen interact5= post_event_0*treat`i'
gen interact6= post_event_1*treat`i'
gen interact7= post_event_2*treat`i'
gen interact8= post_event_3*treat`i'
ren treat`i' treat
reg have_new_houseloan treat pre_event_4-pre_event_2 post_event* interact1-interact3 interact5-interact8
ren treat treat`i'
est store model
outreg2 using "E:\tachun\Houseloan\Results\新增房貸機率\Dynamic_DID_results.xlsx"
nlcom(interact4: 0) ,post
est store base
coefplot model base, l(95) vertical ///
keep(interact*) ///
order(interact1 interact2 interact3 interact4 interact5 interact6 interact7 interact8) ///
coeflabel(interact1 ="-4" interact2="-3" interact3="-2" interact4="-1" interact5="0" interact6="1" interact7="2" interact8="3") ///
nooffset ///
yline(0) ///
xline(5, lpattern(dash) lcolor(gray)) ///
addplot(line @b @at, color(black)) ///
ciopts(recast(rcap)) ///
saving("E:\tachun\Houseloan\Figures\新增房貸機率\dynamic_did_`i'",replace)
graph export "E:\tachun\Houseloan\Figures\新增房貸機率\dynamic_did_`i'.png", replace
drop interact*
}





