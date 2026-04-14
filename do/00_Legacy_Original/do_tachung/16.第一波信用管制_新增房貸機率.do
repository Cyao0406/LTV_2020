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
