adopath + "D:\stsdat\ado\plus"
clear all
use "E:\tachun\Houseloan\dta\契稅資料\chtt_105"
forv i=106(1)112{
	append using "E:\tachun\Houseloan\dta\契稅資料\chtt_`i'.dta"
}
keep if contrct_tp=="64" | contrct_tp=="HF" | contrct_tp=="73"
gen year= substr(flg_date,1,3)
destring year,replace
replace year=year+1911
bysort ID year: drop if _n!=1
merge 1:1 ID year using "E:\tachun\Houseloan\dta\房貸資料\houseloan_104-112_relation.dta"
gen have_new_house= _merge==3
drop if year==2015
drop if _merge==1
drop _merge

forv i=1(1)5{
preserve
collapse(mean) have_new_house, by(treat`i' year)
drop if treat`i'==.
reshape wide have_new_house, i(year) j(treat`i')
twoway(line have_new_house1 year,sort) (line have_new_house0 year, sort), xline(2020, lpattern(dash) lcolor(black)) legend(order(1 "實驗組" 2 "控制組")) xlabel(2016(1)2023) saving("E:\tachun\Houseloan\Figures\購屋機率\common_trend_`i'",replace) 
graph export "E:\tachun\Houseloan\Figures\購屋機率\common_trend_`i'.png", replace
restore
}

gen post= year>=2020


forv i=1(1)5{
ren treat`i' treat
reg have_new_house treat##post i.year
outreg2 using "E:\tachun\Houseloan\Results\購屋機率\DID_results.xlsx"
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
reg have_new_house treat pre_event_4-pre_event_2 post_event* interact1-interact3 interact5-interact8
est store model
outreg2 using "E:\tachun\Houseloan\Results\購屋機率\Dynamic_DID_results.xlsx"
ren treat treat`i'
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
saving("E:\tachun\Houseloan\Figures\購屋機率\dynamic_did_`i'",replace) 
graph export "E:\tachun\Houseloan\Figures\購屋機率\dynamic_did_`i'.png", replace
drop interact*
}