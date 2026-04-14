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
