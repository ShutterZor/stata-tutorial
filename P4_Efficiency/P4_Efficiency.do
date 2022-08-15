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
			
		* 多中介变量中介效应模板
			
			doedit MediatingEffect.do
			
	
*----------4.3：配合 reghdfe 筛选最优控制变量组合


	* 如何判断你的控制变量能否使得回归结果更好？ 
		
		// 依据数据选择最合适的控制变量（gsreg）
		
			sysuse auto.dta, clear
			
			gsreg price mpg length weight headroom	// (2^4)-1 次回归
		
			reg price mpg length
			
			reg price mpg length weight headroom
			
			// gsreg 默认报告调整 R方 最高的结果
			
		* 自定义待选控制变量个数（保留至少 m ，至多 n 个控制变量）
		
			gsreg price mpg length weight headroom, ncomb(2,4) replace
		
			dis comb(4,2)+comb(4,3)+comb(4,4)
		
		* 自定义必须保留的变量
			
			gsreg price mpg length weight headroom trunk, ncomb(2,4) replace
			
			gsreg price mpg length weight headroom, 	///
					ncomb(2,4) fixvar(trunk) replace
					
		* 配合 reghdfe 使用
			
			gsreg price mpg length weight headroom, 				///
					cmdest(reghdfe) cmdoptions(absorb(foreign))		///
					ncomb(2,4) fixvar(trunk) replace
		
		* 对于我们实证过程当中的一般回归而言
			
		* 1. 广泛阅读文献，收集所有可能的控制变量
		* 2. 通过 gsreg 筛选特定条件下模型拟合最好的


*----------4.4：编写一键显著命令


	* 一键显著的原理
		
/*
	将控制变量的排列组合个数依次加入回归，找出使得主要解释变量显著的结果。
	gsreg 通过拟合度筛选控制变量，一键显著则是通过主要解释变量显著性进行筛选。
*/
		

	* 需要的命令 tuples （对控制变量排列组合）
	
		* tuples 简单示例
			
			tuples a b c, display
		
		* 通过 tuples 实现半个 gsreg 的效果
		
			sysuse auto.dta, clear
			
			gen rsq = .
			gen predictors = ""
			
			tuples headroom trunk length displacement
			qui forvalues i = 1/`ntuples' {
				reg mpg `tuple`i''
				replace rsq = e(r2) in `i'
				replace predictors = "`tuple`i''" in `i'
			}
			
			gen p = wordcount(predictors) if predictors != ""
			sort p rsq
			list predictors rsq in 1/`ntuples'

		* 按照主要解释变量显著性进行筛选

			reg price weight length 
			dis _b[weight]/_se[weight]			// weight 的 t 值
			
			* 经验准则下
			* t<1.64 		不显著
			* 1.64<t<1.96 	一颗星（10% 显著，人为规定）
			* 1.96<t<2.58 	两颗星（5%  显著，人为规定）
			* t>2.58		三颗星（1%	显著，人为规定）
			
		* 用于判断显著性的 t 值与样本自由度有关
			
			* 不同自由度下的 10% 显著水平的 t 值
				
				dis invttail(10, 0.05)		// 双尾所以除 2
				dis invttail(100, 0.05)
				dis invttail(300, 0.05)
				dis invttail(500, 0.05)
			
/*
			
		结论：我们只需要比较模型中主要解释变量的 t 值，与对应自由度下
			  使得变量显著的 t 值大小关系（临界条件），就能筛选模型。
		
 */
		
		* 示例
			
			reg price weight length 
			ereturn list
			local modelT 	_b[weight]/_se[weight]
			local realT		invttail(e(df_r), 0.05)
			
			if `modelT'>`realT'{
				dis "这些控制变量能够使得自变量在10%显著水平下显著"
			}
			else {
				dis "这些控制变量无法使得自变量在10%显著水平下显著"
			}
		
	
	* 正式编写
		
		* 思路
		
/*	
		首先我们已经能够判断单个方程中的控制变量能够使得解释变量显著
	接下来只需要借助 tuples 命令，进行循环，对每个方程都执行示例中的
	操作，即可达到目的。
 */
			
		doedit oneclick.do	
			
			
/*==================================================
						CASE
==================================================*/


*	CASE	低碳转型冲击就业吗	



exit
/* End of do-file */