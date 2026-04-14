/*此檔案以關係人為單位計算房貸數量，若無關係人則以列舉人。*/
clear all

forv i=112(1)112{
use "D:\stsdat\ibr\dta\依列舉內容切檔\ibrt400_2_`i'.dta"
ren relation_idn ID
replace ID=list_id_idn if ID==""
sort ID
bysort ID: gen n=_n
count if n==1
count
count if hou_get_date==""
duplicates tag ID, gen(num_of_loan1)
replace num_of_loan1=num_of_loan1+1
tab num_of_loan1 if n==1
label variable num_of_loan1 "累積房貸_繳款一次就算一筆"

preserve
drop if hou_get_date==""
bysort ID: gen n2=_n
count if n2==1
duplicates tag ID, gen(num_of_loan2)
replace num_of_loan2=num_of_loan2+1
tab num_of_loan2 if n2==1
drop if n2!=1
keep ID num_of_loan2
tempname temp1
save `temp1',replace 
restore

merge m:1 ID using `temp1'
drop _merge
replace num_of_loan2=0 if num_of_loan2==.
label variable num_of_loan2 "num_of_loan1扣掉無取得日期"

preserve
egen house_group= group(hou_get_date)
bysort ID house_group: gen num_of_loan3 = _n==1

gen num_of_loan4 = num_of_loan3
bysort ID house_group: replace num_of_loan4= 0 if house_group==.

gen num_of_loan5 = num_of_loan3
bysort ID house_group: replace num_of_loan5= 1 if house_group==.

bysort ID: replace num_of_loan3= sum(num_of_loan3)
bysort ID: replace num_of_loan3= num_of_loan3[_N]
bysort ID: replace num_of_loan4= sum(num_of_loan4)
bysort ID: replace num_of_loan4= num_of_loan4[_N]
bysort ID: replace num_of_loan5= sum(num_of_loan5)
bysort ID: replace num_of_loan5= num_of_loan5[_N]
drop if n!=1
keep ID num_of_loan3 num_of_loan4 num_of_loan5
tempname temp2
save `temp2', replace 
restore

merge m:1 ID using `temp2'
drop _merge
label variable num_of_loan3 "累積房貸_同一個取得日期算同一筆"
label variable num_of_loan4 "num_of_loan3扣掉無取得日期"
label variable num_of_loan5 "num_of_loan3無取得日期一次就算一筆"

drop n

save "E:\tachun\Houseloan\dta\房貸資料\houseloan_`i'_relation.dta", replace
}