//此檔案是拿來比較房貸跟契稅能串到的ID，他們取得日期為當年的房貸數量跟契稅的數量差多少
clear all
global i= 110

use "I:\tachun\Houseloan\dta\房貸資料\houseloan_${i}_relation.dta"
gen hou_get_year = substr(hou_get_date,1,3)
destring hou_get_year, replace force
keep if hou_get_year==$i //只保留取得日期為當年的房貸
duplicates tag ID, gen(check)
bysort ID: gen n= _n==1
keep if n==1 //保留第一筆資料，這樣每個人就只會有一筆資料
drop n
merge 1:m ID using "I:\tachun\Houseloan\dta\契稅資料\chtt_${i}.dta"
keep if _merge==3
drop _merge
duplicates tag ID, gen(check2)
gen check3=check-check2
bysort ID: gen n= _n==1
keep if n==1
drop n
tab check3
