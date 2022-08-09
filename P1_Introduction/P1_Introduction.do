/*==================================================
project:       Introduction section for Stata course
Author:        Shutter Zor 
E-email:       Shutter_Z@outlook.com
url:           shutterzor.github.io
Dependencies:  School of Accountancy, Wuhan Textile University
----------------------------------------------------
Creation Date:     4 Aug 2022 - 09:14:58
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/



/*==================================================
						目录
==================================================*/


*	1.1  Stata 概貌
* 	1.2  菜单操作
* 	1.3  命令与帮助文件
*	1.4  局域暂元与全局暂元
* 	1.5  条件循环语句及异常处理     
* 	1.6  数据标签
* 	1.7  变量创建、修改与基础运算


/*==================================================
              1：Stata 概貌
==================================================*/


*----------1.1：Stata 界面 


*----------1.1.1：初识 Stata

 	
	* Stata 初印象
	
		shellout Stata_Intro.pdf
	
	* Stata 界面由六个部分组成：五个窗口与两条导航栏
	
	* 一些偏好设定
	
		* 偏好设置方法：
			* 编辑-->首选项-->常规首选项 (中文版适用)
			* Edit-->Preference-->General Preference (For English Version)
		
	* Stata 有三种执行命令的方式	
		
		* （1）通过菜单导航栏直接进行相应操作
		* （2）在命令窗口输入命令进行操作
		* （3）编写 do 文件进行批量操作
		*	（3.1）在 do 文件中通过快捷键 Ctrl+D 或者点击导航栏操作
		*	（3.2）编写 ado 文件完成一些自动化操作
	
	* Case 1：一份 do 文件实例
	
		doedit case1.do			// 打开一份已有的 do 文件 
		
		doedit something.do		// 当当前路径不存在该文件时则创建
		
		do case1.do				// 运行这一份 do 文件	
		run case1.do			// 有区别
		
		help run

		
*----------1.2：菜单操作


	* 不推荐使用该方法
	
		* 难以重现且操作较为繁琐

		
*----------1.3：命令与帮助文件


	* 几个基础命令
	
		pwd						// 显示当前工作路径，与左下角一致
		cd E:\Stata16\ado   	// 进入指定文件夹
		sysdir					// 查看 Stata 相关路径
		ls						// 展示当前路径文件，与 linux 类似
		dir						// 效果同 ls

	* Stata 的帮助文件
		
		* 基本语法: help + command
		
			help reg
			help regress
			
			help sum
			help summarize

			
*----------1.4：局域暂元与全局暂元（local & global）


/*
	Marco：宏、变量，可理解为 Python 中的 “变量”，
		   为了同回归模型中的变量区分，这里叫它
		   暂元
*/

	* 常见的暂元（local & global）
		
		* 两者区别在于:
		* 	local	使用一次便消失，需要同命令一起选中运行
		*	global	可以一直使用，直到关闭 Stata
	
	* 暂元的基本功能
		
		* 存放数字并进行运算
		
			local num1 3
			dis `num1'

			local num2 `num1' + 5
			dis `num2'
			
			* 双引号的存在对 local 展示结果有影响
			
				local num3 2+2
				dis `num3'
				dis "`num3'"
		
		* 存储字符串
		
			local str1 Stata16
			dis "`str1'"
			  
			local str2 编程与效率实证分析
			dis "`str2'"
			  
			local str3 `str1'`str2'
			dis "`str3'"
		
		* 存放数据中的变量进行运算
		
			sysuse auto.dta, clear
			
			local myVar price mpg rep78
			sum `myVar'
			sum price mpg rep78				// 与上面等价
			
			local myVar price mpg rep78
			pwcorr `myVar'
			pwcorr price mpg rep78			// 与上面等价
			
			* 是否增加双引号对 local 的展示结果有影响
			
				local myVar price mpg rep78
				dis `myVar'
				dis "myVar"
		
		* 单双引号混排造成的错误（不重要，一般用不到）
		
			local temp Bob's "cat"
			dis "`temp'"              		// 错误方式 
			local temp Bob's "cat"
			dis "John's " car ""
			
			local temp Bob's "cat"  		// 正确方式 
			dis `" `temp'"'  
			
		* 暂元套娃行为鉴赏（写批量导出模板时很好用）
			
			local num1 			2
			local str1 			"var"			// 此处双引号可要可不要
			local num2 			2*`num1'
			local X 			`num`num1''
			
			local `str1'`num1'  2*`num2'
			
			dis `num1'
			dis "`str1'"
			dis `num2'
			dis `X'
			dis "`X'"
			dis "`str1'`num1'"
			dis ``str1'`num1''					// 注意写法
			dis `var2'

	* 暂元的进阶操作
	
/*
	help mathematical functions
	查看 Stata 支持的所有运算函数
 */
	
		* 数据运算
		
			sysuse auto.dta, clear
			local num ceil(sqrt(log(100)))
			dis `num'
			dis make[3]
			dis make[`num']	
			dis make[`=ceil(sqrt(log(100)))']
		
		* 逻辑运算
			
			local Yes 1
			sum foreign if `Yes'
			
		* 一个可能有用的实例之一（横向求和）
		
			clear
		    set obs 10
		    set seed 12345
		    gen var1 = int(10*runiform())
		    gen var2 = int(10*runiform())
		    gen var3 = int(10*runiform())
		    gen var4 = 0
		  
		    local i = 1
		    while `i' <= 3 {
				replace var4 = var4 + var`i'
				local i = `i' + 1
		    }
		
		  // 等价于：
		    egen var5 = rowtotal(var1 - var3)
			
		* 一个可能有用的实例之一（横向求积） // 暂未了解到现成的替代函数
			
			clear
		    set obs 10
		    set seed 12345
		    gen var1 = int(10*runiform())
		    gen var2 = int(10*runiform())
		    gen var3 = int(10*runiform())
		    gen var4 = 1
		  
		    local i = 1
		    while `i' <= 3 {
				replace var4 = var4 * var`i'
				local i = `i' + 1
		    }

	* 全局暂元
	
		* global 使用方法同 local，但引用方式有区别
		
		* 存储数字与运算
			
			global num1 5
			global num2 $num1 + 10
			global str1 编程与效率实证分析
			global str11 "编程与效率实证分析"
			global str2 编程与   效率实证分析
			global str22 "编程与   效率实证分析"
			
			/// 定义时引号可有可无
			
			dis $num1 
			dis $num2
			dis "$str1"
			dis "$str11"
			dis "$str2"
			dis "$str22"
			dis $str22
			
			/// 引用时对文本信息而言必须要有引号
		
		* 常见使用方法（在回归中定义控制变量）
			
			sysuse auto.dta, clear
			
			global control mpg headroom weight length turn
			
			reg price $control
			
		* 进阶用法（借助循环依次纳入不同的控制变量）
		
			// 此法可用于批量回归与对应的结果导出
		
			foreach variable in $control {
				reg price `variable'
				est store M`variable'
			}
			
			esttab Mmpg Mheadroom Mweight Mlength Mturn, nogap compress
			
	* 暂元管理（作用不大）
		
		help macro
		
		macro list			// 列示所有暂元（global）
		macro drop str*		// 删掉 str22 str2 str11 str1，* 为通配符
		macro list str1		// 检查是否完成删除
			
			
*----------1.5：条件语句与异常排查			
	
	
/*	
	    与绝大多数编程语言相同，Stata 同样也具备例如 while、if、else 等
	的循环语句，善用循环语句可以在一定程度上减少我们很多的工作量。
*/
		
	* while、if、else
		
		* while 循环（到达边界前一直执行）
		
			* 向上探索边界
			
				local boundary 0
				while (`boundary'<=3) {
					dis _skip(20) `boundary'
					local boundary = `boundary' + 1
				}
				
				* 类似于 Python ，上述代码可以简化为
					
					local boundary 0
					while (`boundary'<=3) {
						dis _skip(20) `boundary++'
					}
			
			* 向下探索边界
			
				local boundary 0
				while (`boundary'>=-3) {
					dis _skip(20) `boundary'
					local boundary = `boundary' - 1
				}
				
				* 类似于 Python ，上述代码可以简化为
					
					local boundary 0
					while (`boundary'>=-3) {
						dis _skip(20) `boundary--'
					}
			
		* if 循环（是否满足边界条件）
			
			* if 可以单独使用，但在 Stata 的命令当中，大多会有内置的 if 选项
			
				sysuse auto.dta, clear
				sum price if foreign == 1
				local max1 r(max)
			
			* 外置的 if 可以同 else 连用，比如
				
				local num 11
				if (mod(`num',2)==0) {
					dis "`num'""是偶数"
				}
					else {
						dis "`num'" "是奇数"
					}
			
			* if 可以与 else 在一起无限套娃
			
				local score 90
				if (`score'<0)|(`score'>100){
					dis "您输入了错误的成绩，请重新输入"
					exit
				}
					if (`score'<=30){
						dis "您的成绩为C"
					}
					if (`score'>30)&(`score'<=60){
						dis "您的成绩为B"
					}
					else {
						dis "您的成绩为A"
					}
	
			* 实战：编写猜拳游戏
			* 要求：通过连用 if 与 else 编写猜拳游戏
			* 规则：布＞石头，石头＞剪刀，剪刀＞布
			* 提示：可用 runiform() 函数生成随机数
			
				do case2.do
				doedit case2.do
			
	* forvalues 循环（针对数字或含数字变量进行的循环）
		
		help forvalues
			
		* 生成 100 个均匀分布的变量 var1, var2....., var100
			
			clear
			set obs 10
			set seed 12345
			forvalues i = 1(1)100 {
				gen var`i' = runiform()
			}
		
		* 实际运用
			
			* 对规则命名的文件进行处理
			
				* 观察文件格式
				
					type usbirth2007.txt
					type usbirth2008.txt
					type usbirth2009.txt
				
				* 导入并另存为 dta 文件
					
					forvalues i = 2007/2009{
						insheet using usbirth`i'.txt, clear
						rename v1 region
						rename v2 county
						rename v3 year
						rename v4 nbirth
						rename v5 mage
						
						label var region "US census region"
						label var county "US countty"
						label var year   "data year"
						label var nbirth "number of births"
						label var mage   "average age of mother"
						save usbirth`i'.dta, replace
					}
	* foreach 循环（对变量、暂元、文件等的循环）	
	
		* 替代 forvalues 重现上述合并
			local fileName usbirth2007 usbirth2008 usbirth2009
			foreach v in `fileName' {
				insheet using `v'.txt, clear
				rename v1 region
				rename v2 county
				rename v3 year
				rename v4 nbirth
				rename v5 mage
				
				label var region "US census region"
				label var county "US countty"
				label var year   "data year"
				label var nbirth "number of births"
				label var mage   "average age of mother"
				save `v'.dta
			}
		
		* 变量的批量转换（取对数与缩尾等操作）
		
			* 批量进行对数转换
				
				sysuse auto.dta, clear
				
				local varName price mpg weight length
				foreach v in `varName' {
					gen ln`v' = ln(`v')
					gen log`v' = log(`v')
					label var ln`v' "ln(`v') for `v'"
					label var log`v' "log(`v') for `v'"
				}
				
				list lnprice logprice in 1/10
				
				// ln() 与 log() 为等价函数，10 为底用 log10()
				// 其余需求通过换底公式实现
				// log_{a}(b) = log(b) / log(a)
				
			* 批量进行变量缩尾
				
				sysuse auto.dta, clear
			
				local varName price mpg weight length
				foreach v in `varName' {
					winsor `v', gen(new_`v') p(0.1)
				}
				
				histogram price
				histogram new_price


				
				

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><