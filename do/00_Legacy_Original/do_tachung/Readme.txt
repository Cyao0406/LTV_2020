==================================================
01. Datamerge
==================================================

using dta: 自用住宅/jhq_hou_count_`i'.dta

目的: 將經由 JHQ 算出的個人年度持有房屋筆數，與 IBR 房貸資料進行合併。
關鍵發現: 
	1. 串接方式： 使用「關係人 ID」進行比對可獲得較高的媒合率。 
	2. 邏輯修正： 原僅保留「同 ID 且同取得日期」的房貸資料，但考量實務上存在「單日購入多筆房產」之情形，後續分析將放寬此限制以符合現實。

saving dta: 
		1. how_many_houses_total.dta ：依 JHQ 計算之總房屋持有筆數。
		2. total_houseloan.dta ：依 IBR 計算之總房貸筆數。
		3. houseloan_and_houses_owned.dta ：房貸與持有房屋筆數之合併大資料。


==================================================
02. clean_chtt
==================================================

目的: 將完整原始契稅資料按「年度」分割存檔，並精簡保留必要變數。 
保留變數: 原所有權人id 新所有權人id hsn_cd hou_losn bl_ym 立契日期 申報日期 契約種類 

原始完整資料集_A: 99 ~ 110 年 chtt030
原始完整資料集_B: 110 ~ 113 年 chtt030_110-113

saving dta : 契稅資料/chtt_`i'.dta

==================================================
03. find_nthhouse
==================================================

using dta: 
		1. how_many_houses_total.dta
		

目的: 	此檔案嘗試去找每筆房貸是每人或每戶的第幾棟房子
	1. 個別使用關係人和列舉人算出每人或每戶的nth_house


saving dta: 
		1. houseloan_and_houses_owned.dta : 一個持有房貸及今年房屋數、去年房屋數的大檔案
		2. nth_house.dta : 計算購房順序(該房為某人第幾戶房子)

==================================================
04. count_houseloan_list
==================================================

using dta: ibrt400_2_`i' : 原始房貸資料 98年 ~111年

目的: 此檔案使用ibr房貸資料,並以列舉人(list_id_idn)為單位計算房貸數量
	
	1. 分別利用5種不同的計算方式計算房貸數量


saving dta: houseloab_`i'_list.dta


==================================================
05. count_houseloan_relation
==================================================

using dta: ibrt400_2_`i' : 原始房貸資料 98年 ~111年

目的: 此檔案使用ibr房貸資料,並以關係人(relation_id_idn)為單位計算房貸數量
	
	1. 分別利用5種不同的計算方式計算房貸數量


saving dta: houseloan_`i'_relation.dta



==================================================
06. compare_w_chtt
==================================================

using dta: 
		1. houseloan_${i}_relation.dta 
		2. chtt_${i}.dta

目的: 比較房貸與契稅串到的ID.他們取得日期為當年的房貸數量跟契稅的數量差多少。 p.s. 應該是測試檔 因為global i = 110




==================================================
07.find_different_houseloan_list
==================================================

using dta: houseloan_`i'_list.dta 原始資料: 98年 ~ 110年 來自ibr

目的: 計算 年度間 新增的房貸數量

資料處理過程
		1. 先將第一年有資料,第二年沒資料的人刪去(可能為繳完)
		2. 根據取得日判斷是否新增,若為無取得日則依筆數判斷是否為新增 ***可能要注意無取得日變多,會不會是原本有取得日變成無取得日的房貸
		3. 計算完無取得日的貸款數量後,暫存並合併到原資料。 *** 

問題: 
	此檔案的計算過程調整方向建議: 原本的計算方式,指保留第二年度比第一年度的無取得日房貸多的資。但是否有第一年未填寫取得日,但第二年卻填寫了,	所以資料上無取得日的數量會變少,但有取得日的會增加。


saving dta: new_houseloan`i'-`j'_list.dta


==================================================
08.find_different_houseloan_relation
==================================================

using dta: houseloan_`i'_relation.dta 原始資料: 98年 ~ 110年 來自ibr

目的: 同(7)find_different_houseloan_list, 只是ID改為realation(關係人) 計算


saving dta: new_houseloan`i'-`j'_relation.dta


==================================================
09.find_different_houseloan_110-111_list
==================================================

using dta: 
		1. houseloan_110_list.dta 原始資料: 110年 ~ 111年 來自ibr
		2. chtt030.dta

目的: 
	1. 利用不同算法計算新增房貸
	2. 第一種算法 同(7)find_different_houseloan_list, 只是年度改為110~111 計算
	3. 第二種算法
		3-1. 一樣先將第一年有資料,第二年沒資料的人刪去(可能為繳完)
		3-2. 先比總繳款筆數後再做一樣的事(第一種算法)。
	4. merge by chtt030.dta


saving dta: 
		1. new_houseloan110-111_relation.dta
		2. new_houseloan110-111_second.dta


==================================================
10.find_different_houseloan_110-111_relation
==================================================

using dta: houseloan_110_relation.dta 原始資料: 110年 ~ 111年 來自ibr

目的: 
	1. 利用不同算法計算新增房貸
	2. 第一種算法 同(7)find_different_houseloan_list, 只是ID改為realation(關係人) 及 年度改為110~111 計算
	3. 第二種算法
		3-1. 一樣先將第一年有資料,第二年沒資料的人刪去(可能為繳完)
		3-2. 先比總繳款筆數後再做一樣的事(第一種算法)。



saving dta: new_houseloan110-111_relation.dta


==================================================
11.new_houseloan_merge_chtt
==================================================

using dta: 
		1. new_houseloan109-110_list.dta
		2. chtt_110.dta
		3. new_houseloan109-110_relation.dta
		4. new_houseloan108-109_relation.dta
		5. chtt_109.dta
		6. chtt_108.dta

目的: 此程式碼嘗試將每年新增房貸(以取得日期來分)串契稅看看



==================================================
12.What_if_all_new_are_nodate
==================================================

using dta: 
		1. houseloan_108_relation.dta
		2. houseloan_107_relation.dta
		3. chtt_108.dta


目的: 此do檔案是為了看若除了取得日期為當年的房貸，剩下的全為無取得日期的話，能串到多少契稅資料。

	1. 一樣先把第一年有資料,第二年沒資料的人刪掉
	2. 分類,暫存取得日期為當年的房貸,再將其他 取得日非當年 的房貸視為無取得日,一筆繳款資料算成一筆
	3. 比較107年和108年的總繳款筆數(不包含房屋取得日108年度的)多寡,計算新增房貸的數量
	4. 將房屋取得日較新的及無取得日的資料算為新房貸
	5. 將新增的房貸為無取得日的找出來,並經過處理後,算出 非當年度取得日 的新增房貸資料有多少筆。
	6. 計算 非當年度取得日 (不包含無取得日) 的ID有多少人
	7. 合併取得日為該年的資料回去 (tempfile houseloan_marked)

	8. 使用契稅資料(chtt), 合併前面的計算資料(houseloan_marked)
	9. 計算合併資料共有多少人


saving dta: 


==================================================
13.find_different_houseloan_v2
==================================================

using dta: 
		1. houseloan_99_relation.dta
		2. houseloan_98_relation.dta

目的:
	1. 一樣前面先把第一年有資料，第二年沒資料的人刪掉。
	2. 分類,暫存取得日期為當年的房貸,再將其他 取得日非當年 的房貸視為無取得日,一筆繳款資料算成一筆
	3. 比較98年和99年的總繳款筆數(不包含房屋取得日99年度的)多寡,計算新增房貸的數量 
	4. 將原本資料跟剛剛算出來的ID做合併
	5. 將房屋取得日較新的及無取得日的資料算為新房貸
	6. 最後合併一開始保留的，取得日期為當年的房貸資料
	7. 做法相當於同(12)


saving dta: new_houseloan98-99_relation.dta


==================================================
14.契稅合併前一年12月
==================================================

using dta: 
		1. 契稅資料/chtt_`i'.dta 原始資料年度: 98年 ~ 110年
		2. chtt_total.dta
		3. new_houseloan`j'-`i'.dta 原始資料年度: 98年 ~ 110年

目的: 	這個do檔將原本每一年的契稅資料，改為當年1-11月加上前一年12月的契稅資料，因為申報日期可能實際上跟房貸撥款的日期有差異。
	附註:註解掉的這邊是將所有契稅合併在一起，因為申報日期有時候會跨到後一年，這樣在切每一年資料的時候才不會漏切。
	
	1. 先利用契稅資料(chtt)合併成所有契稅的大資料集(chtt_total.dta)
	2. 再將該合併大資料重新切割成不同年度的契稅資料集,差異在於新資料集為前一年度12月及當年度1~12月的資料
	3. 切割完,串當年度房貸(new_houseloan`j'-`i'.dta )資料


saving dta: 
		1. 契稅資料_合併前一年12月/chtt_total.dta
		2. 契稅資料_合併前一年12月/chtt_`j'.dta  新資料年度: 98年 ~ 110年


==================================================
15.新房貸資料合併新版本契稅
==================================================

using dta: 
		1. 契稅資料_合併前一年12月/chtt_108.dta
		3. 契稅資料/chtt_108.dta
		2. new_houseloan107-108_relation.dta

目的: 	拿"契稅合併前一年12月.do"儲存的dta來合併房貸新增資料，應該只能多串到4000-5000筆資料。
	=> 表示有沒有考慮隔年繳款的資料差異不大。



==================================================
16.第一波信用管制_新增房貸機率
==================================================

using dta: 
		1. houseloan_`i'_relation.dta 原始資料年度: 104 ~ 112年
		2. new_houseloan$j-`i'_relation.dta 原始資料年度: 104 ~ 112年

目的: 	估計政策效果-新增房貸機率(outcome)
	1. 先進行分組 (實驗組 和 對照組)
	2. 分組完匯出後面分析需要用到的workdata (house_104-112_relation.dta)
	3. 合併"有新增房貸資料的資料集"(new_houseloan$j-`i'_relation)
	4. 畫對照組及實驗組初始outcome 趨勢圖
	5. Pre/Post DID 分析
	6. Dynamic DID 分析

	
saving dta: houseloan_104-112_relation.dta

export file: 
		1. common_trend_`i'.png
		2. DID_reults.xlsx
		3. Dynamic_DID_results.xlsx
		4. dynamic_did_`i'.png


==================================================
17.第一波信用管制_購屋機率
==================================================

using dta: 
		1. chtt_`i'.dta 原始資料年度: 105 ~ 112年
		2. houseloan_104 -112_relation.dta

目的: 	估計政策效果-購屋機率(outcome)
	1. 匯入契稅資料 ( chtt ), 合併前面整理的"房貸數量"和"新增房貸"資料(houseloan_104-112)
	2. 畫對照組及實驗組初始outcome 趨勢圖
	3. Pre/Post DID 分析
	4. Dynamic DID 分析

	
saving dta: house_104-112_relation.dta

export file: 
		1. common_trend_`i'.png
		2. DID_reults.xlsx
		3. Dynamic_DID_results.xlsx
		4. dynamic_did_`i'.png



==================================================
18.第一波信用管制_是否購屋於六都
==================================================

using dta: 
		1. chtt_`i'.dta 原始資料年度: 105 ~ 112年
		2. houseloan_104 -112_relation.dta

目的: 	估計政策效果-購屋於六都(outcome)
	1. 匯入契稅資料 ( chtt ), 合併前面整理的"房貸數量"和"新增房貸"資料(houseloan_104-112)
	2. 畫對照組及實驗組初始outcome 趨勢圖
	3. Pre/Post DID 分析
	4. Dynamic DID 分析

	
saving dta: house_104-112_relation.dta

export file: 
		1. common_trend_`i'.png
		2. DID_reults.xlsx
		3. Dynamic_DID_results.xlsx
		4. dynamic_did_`i'.png 


==================================================
19.第一波信用管制_是否購屋於台北
==================================================

using dta: 
		1. chtt_`i'.dta 原始資料年度: 105 ~ 112年
		2. houseloan_104 -112_relation.dta

目的: 	估計政策效果-購屋於台北(outcome)
	1. 匯入契稅資料 ( chtt ), 合併前面整理的"房貸數量"和"新增房貸"資料(houseloan_104-112)
	2. 畫對照組及實驗組初始outcome 趨勢圖
	3. Pre/Post DID 分析
	4. Dynamic DID 分析

	
saving dta: house_104-112_relation.dta

export file: 
		1. common_trend_`i'.png
		2. DID_reults.xlsx
		3. Dynamic_DID_results.xlsx
		4. dynamic_did_`i'.png


