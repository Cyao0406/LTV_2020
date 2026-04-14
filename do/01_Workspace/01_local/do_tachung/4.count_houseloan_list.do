/*此檔案以列舉人(list_id_idn)為單位計算房貸數量*/
clear all

forv i=98(1)111{
use "D:\stsdat\ibr\dta\依列舉內容切檔\ibrt400_2_`i'.dta"
ren list_id_idn ID
sort ID
bysort ID: gen n=_n
count if n==1 // 算出不重複ID資料筆數
count // 算出總資料筆數
count if hou_get_date=="" // 算出無取得日資料筆數
duplicates tag ID, gen(num_of_loan1)
replace num_of_loan1=num_of_loan1+1
tab num_of_loan1 if n==1 // 計算貸款數量_1 的分布
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
tempname temp1 // 設置暫存名稱
save `temp1',replace 
restore

merge m:1 ID using `temp1'
drop _merge
replace num_of_loan2=0 if num_of_loan2==. // 個體或家戶的房貸皆為無取得日,以算法2 房貸數量將為0
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

save "I:\tachun\Houseloan\dta\房貸資料\houseloan_`i'_list.dta"
}
