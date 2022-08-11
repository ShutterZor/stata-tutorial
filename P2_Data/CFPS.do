/*==================================================
project:       Data procedure in Stata
Author:        Shutter Zor 
E-email:       Shuttter_Z@outlook.com
url:           shutterzor.github.io
Dependencies:  School of Accountancy, Wuhan Textile University
----------------------------------------------------
Creation Date:     4 Aug 2022 - 15:15:44
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/


/*==================================================
			CASE2	CFPS 数据清洗
==================================================*/


view browse https://www.lianxh.cn/news/2916ae8363459.html
 
 
* CFPS 数据集合
/*
链接：https://pan.baidu.com/s/1DydoNSVpDIyJWcWVO0kfhg?pwd=kepn 
提取码：kepn 
*/



* 设置路径
	global root         = "/Applications/Stata/personal/CFPS"
	global cfps2018     = "$root/CFPS2018"
	global cfps2016     = "$root/CFPS2016"
	global dofiles      = "$root/Result_data/Dofiles"
	global logfiles     = "$root/Result_data/Logfiles"
	global working_data = "$root/Result_data/Working_data"
	global temp_data    = "$root/Result_data/Temp_data"

*- 提取家庭库变量
	use "$cfps2018/cfps2018famecon_202101.dta", clear
	keep fid18 fid16 provcd18 countyid18 cid18 urban18 resp1pid fk1l ft200 ///
		fincome1_per total_asset familysize18

	//查看变量标签
	label list urban18

	//缺失值替换为.
	for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

	//重新赋值
	recode fk1l  (1 = 1 "是")(5 = 0 "否"), gen(agri)
	recode ft200 (1 = 1 "是")(5 = 0 "否"), gen(finp)

	//存储家庭问卷清洗后的数据
	drop fk1l ft200
	save "$temp_data/family_2018.dta", replace 

*- 提取个人库变量
	use "$cfps2018/cfps2018person_202012.dta", clear
	keep pid fid18 fid16 provcd18 countyid18 cid18 urban18 gender age ///
		qa301 qea0 qp605_s_* cfps2018edu 

	for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)
	tab qa301
	tab qea0

	//重新赋值
	recode qa301 (1 = 1 "农业户口")(3 = 0 "非农户口")(5 79 =.), gen(hukou)
	recode qea0  (2 3 = 1 "有配偶")(1 4 5 = 0 "无配偶"), gen(spouse)
	recode cfps2018edu (1 = 0 "文盲/半文盲")(2 = 1 "小学")(3 = 2 "初中")(4 = 3 "高中") ///
		(5 6 7 8 = 4 "大学以以上"), gen(edu)

	//计算是否有医保及医保数量
	for var qp605_s_*: replace X =. if X == 78
	gen medsure_dum = 0
	gen medsure_xnh = 0
	gen medsure_num = 0
	for var qp605_s_*: replace medsure_dum = 1 if X !=.
	for var qp605_s_*: replace medsure_xnh = 1 if X == 5
	for var qp605_s_*: replace medsure_num = medsure_num + 1 if X !=.

	drop qa301 qea0 qp605_s_* cfps2018edu
	save "$temp_data/person_2018.dta", replace



*- 跨表合并
	//个人库merge家庭库
	use "$temp_data/person_2018.dta", clear
	merge m:1 fid18 using "$temp_data/family_2018.dta", ///
		keepusing(fincome1_per total_asset familysize18 agri finp) keep(1 3) nogen

	label var medsure_dum "是否购买医保"
	label var medsure_xnh "是否购买新农合"
	label var medsure_num "购买医保数量"
	rename (provcd18 countyid18 cid18 urban18 familysize18) ///
		(provcd countyid cid urban familysize)
	save "$temp_data/person2family2018.dta", replace

	//家庭库merge个人库
	use "$temp_data/family_2018.dta", clear
	rename resp1pid pid

	merge 1:1 fid18 pid using "$temp_data/person_2018.dta", ///
		keepusing(gender-medsure_num) keep(1 3) nogen

	label var medsure_dum "是否购买医保"
	label var medsure_xnh "是否购买新农合"
	label var medsure_num "购买医保数量"
	rename (provcd18 countyid18 cid18 urban18 familysize18) ///
		(provcd countyid cid urban familysize)
	save "$temp_data/family2person2018.dta", replace

*- 数据核查
	use "$temp_data/family2person2018.dta", clear

	//查看变量缺失情况
	egen miss = rowmiss(urban fincome1_per total_asset familysize agri finp gender age)
	tab miss
	keep if miss == 0

	//保留16-85岁的样本
	keep if inrange(age, 16, 85)
	save "$working_data/result_cfps2018.dta", replace

*- 跨年合并
	use "$cfps2016/cfps2016famecon_201807.dta", clear
	keep fid16 provcd16 countyid16 cid16 urban16 resp1pid fk1l ft200 ///
		fincome1_per total_asset familysize16

	//缺失值替换为.
	for var _all: replace X =. if inlist(X, -10, -9, -8, -2, -1)

	//重新赋值
	recode fk1l  (1 = 1 "是")(5 = 0 "否"), gen(agri)
	recode ft200 (1 = 1 "是")(5 = 0 "否"), gen(finp)

	//存储家庭变量
	drop fk1l ft200
	rename (provcd16 countyid16 cid16 urban16 familysize16) ///
		(provcd countyid cid urban familysize)
	gen year = 2016
	save "$temp_data/family_2016.dta", replace 

	//CFPS2018数据
	use "$temp_data/family_2018.dta", clear
	rename (provcd18 countyid18 cid18 urban18 familysize18) ///
		(provcd countyid cid urban familysize)
	gen year = 2018
	save "$temp_data/family_2018.dta", replace

	//合并数据
	use "$temp_data/family_2016.dta", clear
	append using "$temp_data/family_2018.dta"
	drop fid18
	order fid16 year
*xtset fid16 year

	//标记分家样本
	duplicates tag fid16 year, gen(num)
	tab num

	//删除全部分家样本
	keep if num == 0
	xtset fid16 year
	drop num

	//保留分家中的一家样本
	duplicates drop fid16 year, force
	xtset fid16 year

	//构建平衡面板
	bys fid16: egen num = count(fid16)
	tab num
	keep if num == 2
	drop num
	xtset fid16 year

	//构造社区均值
	bys cid year: egen cidnum = count(cid)
	bys cid year: egen finpnum = sum(finp)
	gen average = (finpnum - finp) / (cidnum -1)

	//构造对照组与处理组
	xtset fid16 year
	bys fid16: gen treat = finp[_n+1] - finp[_n]
	bys fid16: replace treat = treat[_n-1] if mi(treat)
	tab treat

	drop if treat == -1
	gen post = (year == 2018)
	save "$working_data/panel2016_2018.dta", replace
		
				