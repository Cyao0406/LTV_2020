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