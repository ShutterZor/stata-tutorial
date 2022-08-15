/*==================================================
project:       Efficient Empirical Research in Stata
Author:        Shutter Zor 
E-email:       Shutter_Z@outlook.com
url:           shutterzor.github.io
Dependencies:  School of Accountancy, Wuhan Testile University
----------------------------------------------------
Creation Date:    11 Aug 2022 - 14:38:05
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
			一键显著 oneclick 编写
==================================================*/



* 导入数据
	
	sysuse auto.dta, clear
	
	
******************* 设置关键信息 *******************

global 	P	0.1							// 设置显著性水平			
global	Y	price						// 设置被解释变量
global	X	weight						// 设置解释变量
global	CV	length mpg headroom trunk	// 设置控制变量			


****************** 以下直接运行 ********************

gen rsq 	= .
gen ctrlV 	= ""
gen modelT 	= .
gen realT  	= .

tuples $CV
forvalues i = 1/`ntuples' {

	reg $Y $X `tuple`i''
	
	replace rsq = e(r2) in `i'
	replace ctrlV = "`tuple`i''" in `i'
	replace modelT = _b["$X"]/_se["$X"]	in `i'
	replace realT = invttail(e(df_r),$P /2) in `i'
}
gen Num = wordcount(ctrlV) if ctrlV != ""

preserve
	keep rsq ctrlV modelT realT Num
	keep if modelT > realT
	sort rsq Num 
	list 
restore

reg $Y $X length mpg headroom trunk


****************** 更便捷的方法 ********************

ssc install oneclick

sysuse auto.dta, clear
oneclick length mpg headroom trunk, dep(price) ind(weight) s(0.1) m(reg)

use subSet.dta, clear
list in 15

sysuse auto.dta, clear
reg price weight length mpg headroom trunk


