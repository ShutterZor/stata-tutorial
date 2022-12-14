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
			调节效应的 Stata 实现（模板）
==================================================*/



* 导入数据

	sysuse auto.dta, clear

	
******************* 设置关键信息 *******************

global 	Y		price						// 定义因变量
global	X		length						// 定义自变量
global	ME		weight 	turn headroom		// 定义中介变量
global	CV		rep78						// 定义控制变量


************ 批量导出多个调节效应结果 **************

reg $Y $X $CV
est store main

foreach v in $ME {

	reg `v' $X $CV
	est store `v'2
	
	reg $Y $X `v' $CV
	est store `v'3
	
}

foreach v in $ME {

	reg2docx main `v'2 `v'3 using ME`v'.docx, 						///
		scalars(N r2(%9.3f) r2_a(%9.2f)) 				///
		star(* 0.1  ** 0.05  *** 0.01)					///
		b(%9.3f) t(%7.2f) replace						///
		order($X $MO $CV)

}



************ 拆分上述模板 **************




		