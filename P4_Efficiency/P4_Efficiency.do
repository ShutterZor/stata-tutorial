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
						目录
==================================================*/


*	4.1  一般事件研究法的初步实现
*	4.2  调节效应与中介效应进阶
*	4.3  配合 reghdfe 筛选最优控制变量组合
*	4.4  编写一键显著命令

*	CASE	论文重现


/*==================================================
              4：高效实证
==================================================*/


*----------4.1：一般事件研究法的初步实现


	* 什么是事件研究法
		
		shellout P4.pptx
	
	* 一般事件研究法的 Stata 实现
		
		doedit EventStudy.do


*----------4.2：调节效应与中介效应进阶
	
	* 调节效应 
		
		* 什么是调节效应
			
			shellout P4.pptx
			
			// 论文
			
			shellout MOPaper.pdf
			
/*
			连燕玲, 叶文平, 刘依琳. 
			行业竞争期望与组织战略背离——基于中国制造业上市公司的经验分析[J]. 
			管理世界, 2019, 35(008):155-172.
 */
			
		* 简单的调节效应示例
			
			use MOData.dta, clear
			
			reg invest kstock
			est store m1
			
			gen Interaction = mvalue * kstock
			
			reg invest mvalue kstock Interaction
			est store m2
			
			esttab m1 m2, compress nogap
			
			// 同号增强，异号减弱
		
		* 可以对交互项中心化，从而使得解释变量（主效应）显著
			
			center kstock mvalue
			
			gen Interaction1 = c_kstock * c_mvalue
			
			reg invest mvalue kstock Interaction1
			est store m3
			
			esttab m1 m2 m3, compress nogap
		
		* 中心化后改变解释变量（主效应）方向
			
			sysuse auto.dta, clear
			
			reg price mpg
			est store m1
			
			reg price mpg weight c.mpg#c.weight 
			est store m2 
			
			reg price c.mpg##c.weight
			est store m3
			
			esttab m1 m2 m3, compress nogap
			
			// 中心化后符号变回来
				
				center mpg weight
				
				reg price c.c_mpg##c.c_weight
				est store m4 
				
				esttab m1 m3 m4, compress nogap 	///
						mtitle("主效应" "中心化前" "中心化后")
			
		* 多调节变量调节效应模板
			
			doedit ModeratingEffect.do
	
	* 中介效应
		
		* 什么是中介效应
			
			shellout P4.pptx
	
		* 简单的示例
		
			sysuse auto.dta, clear
			
			reg price weight 
			est store m1
			
			reg mpg weight 
			est store m2
			
			reg price weight mpg
			est store m3
			
			esttab m1 m2 m3, compress nogap
			
			
			
	
	
	
	

*----------1.3:


*----------1.4:










exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><