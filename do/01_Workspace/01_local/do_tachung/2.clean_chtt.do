//此檔案將契稅檔案chtt整理，只保留要的變數。
clear all

forv i=99(1)110{

use "D:\stsdat\cht\dta\chtt030.dta", clear

keep o_holder_idn_ban n_holder_idn_ban hsn_cd hou_losn bl_ym contrct_date flg_date contrct_tp 

gen date_yr=substr(contrct_date,1,3)
destring date_yr, force replace

ren n_holder_idn_ban  ID

count if date_yr==`i'
keep if date_yr==`i'

save "I:\tachun\Houseloan\dta\契稅資料\chtt_`i'.dta", replace


}

//此檔案將契稅檔案chtt整理，只保留要的變數。
clear all

forv i=110(1)113{

use "D:\stsdat\cht\dta\chtt030_110-113.dta", clear

keep o_holder_idn_ban n_holder_idn_ban hsn_cd hou_losn bl_ym contrct_date flg_date contrct_tp 

gen date_yr=substr(contrct_date,1,3)
destring date_yr, force replace

ren n_holder_idn_ban  ID

count if date_yr==`i'
keep if date_yr==`i'

save "E:\tachun\Houseloan\dta\契稅資料\chtt_`i'.dta", replace


}