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
			CASE4	CSMAR 数据清洗
==================================================*/


* 本案例主要介绍一种方便读入 CSMAR 数据的命令 

	ssc install labone

* 导入数据
	
	import excel using CsmarData.xlsx, first clear

	// 直接删除 1、2 行？
	// 可以，但不赞同
	
* 数据标签处理
	
	labone, nrow(1 2) concat("_")
	drop in 1/2

* 处理年份
	
	gen Year = real(substr(Reptdt,1,4))
	
	// 注意， CSMAR 中对年份的描述变量名可能不同，合并前需更名
	// 比如财报中就可能叫 Accper 而不是 Reptdt