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