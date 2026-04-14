* 第一波信用管制_新增房貸機率_v0.2
adopath + "D:\stsdat\ado\plus"
clear all
use "E:\cy\Houseloan\dta\房貸資料\houseloan_104_relation"
forv i=105(1)112{
	append using "E:\cy\Houseloan\dta\房貸資料\houseloan_`i'_relation.dta"
}

sort date_yr
bysort ID date_yr: drop if _n!=1
gen year=date_yr+1911

* 第一步：建立一個空變數，預設為缺失值 (.)
gen status_2020 = .

* 第二步：定義 2020 年符合條件的 ID
replace status_2020 = 1 if date_yr == 2020 & num_of_loan3 == 2  // 實驗組
replace status_2020 = 0 if date_yr == 2020 & num_of_loan3 == 1  // 控制組

* 第三步：將 2020 年的狀態擴散到該 ID 的所有年度
bysort ID: egen treat = max(status_2020)

drop status_2020

save "E:\cy\Houseloan\dta\房貸資料\houseloan_104-112_relation.dta", replace

gen have_new_houseloan=0
gen mark=1

forv i=104(1)112{
global j= `i'-1
merge 1:1 ID date_yr mark using "E:\cy\Houseloan\dta\每年房貸新增資料_2\new_houseloan$j-`i'_relation"
drop if _merge==2
replace have_new_houseloan=1 if _merge==3
drop _merge
}
drop mark hou_get_year loan_left new_no_date


preserve
collapse(mean) have_new_houseloan, by(treat year)
drop if treat==.
reshape wide have_new_houseloan, i(year) j(treat)
twoway(line have_new_houseloan1 year,sort) (line have_new_houseloan0 year, sort), xline(2020, lpattern(dash) lcolor(black)) legend(order(1 "實驗組" 2 "控制組")) xlabel(2016(1)2023) saving("E:\cy\Houseloan\Figures\新增房貸機率\common_trend",replace)
graph export "E:\cy\Houseloan\Figures\新增房貸機率\common_trend.png", replace
restore


gen post= year>=2020

reg have_new_houseloan treat##post i.year
outreg2 using "E:\cy\Houseloan\Results\新增房貸機率\DID_results.xlsx"

gen pre_event_4 = year==2016
gen pre_event_3 = year==2017
gen pre_event_2 = year==2018
gen pre_event_1 = year ==2019
gen post_event_0 = year==2020
gen post_event_1 = year==2021
gen post_event_2 = year==2022
gen post_event_3 = year==2023


gen interact1= pre_event_4*treat
gen interact2= pre_event_3*treat
gen interact3= pre_event_2*treat
gen interact4= pre_event_1*treat
gen interact5= post_event_0*treat
gen interact6= post_event_1*treat
gen interact7= post_event_2*treat
gen interact8= post_event_3*treat
reg have_new_houseloan treat pre_event_4-pre_event_2 post_event* interact1-interact3 interact5-interact8
est store model
outreg2 using "E:\cy\Houseloan\Results\新增房貸機率\Dynamic_DID_results.xlsx"
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
saving("E:\cy\Houseloan\Figures\新增房貸機率\dynamic_did",replace)
graph export "E:\cy\Houseloan\Figures\新增房貸機率\dynamic_did.png", replace
drop interact*
}



