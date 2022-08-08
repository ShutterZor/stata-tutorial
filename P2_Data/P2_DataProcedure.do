/*==================================================
project:       
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
              0：目录
==================================================*/


*	2.1  各类数据的导入导出
* 	2.2  变量转换技巧
* 	2.3  重复样本值的处理
*	2.4  缺漏值的处理
* 	2.5  离群值的处理    
* 	2.6  数据的合并和追加
* 	2.7  长宽数据转换
*   2.8  文字变量的处理
*   2.9	 类别变量的分析

*	CASE1	描述性统计与相关性分析的导出
*	CASE2	CFPS  数据清洗
*	CASE3	CSMAR 数据清洗
*	CASE4	WIND  数据清洗


/*==================================================
              2：Stata 数据管理与清洗 
==================================================*/


*----------2.1：数据的导入导出


	*- 数据以 csv 与 excel 格式为主，常见命令为 insheet 与 import
		// 其余格式数据如有需求建议手工导入
		
	*- Stata 自带的数据集可以使用如下命令查看 
		
		help dta_examples

	*- 数据保存，另存为 dta 文件通过 save xxx.dta, replace 实现
		// 保存为其他格式请使用面板操作

		
*----------2.2：变量转换技巧


	* Stata 的 _n 与 _N
	
/*
	_n 与 _N 是 Stata 自带的内容
	_n 可以理解为样本序列编号
	_N 则可以理解为存储样本最大值的变量
*/

	* _n 与 _N 的区别
		
		sysuse auto.dta, clear
		gen var1 = _n 
		gen var2 = _N 
		list price var1 var2 in 1/5
		
		sort price 
		gen var3 = _n 
		list var1 var3 in 1/5			// _n 随排序而发生变化
		
		dis _n
		dis _N							// 存在区别
		
		sum price 
		dis r(N)
		dis _N
		
	* _n 与 _N 的应用
		
		* 利用 _n 将截面数据变为面板数据
		
			import excel using TextileCode.xls, first clear
			
			expand 10
			sort code
			
			by code: gen temp = _n
			by code: gen year = 2009 + temp
		
			// 等价于
			import excel using TextileCode.xls, first clear
			expand 10
			bys code: gen year = 2009 + _n
		
		* 差分计算
			
			sysuse sp500.dta, clear
			gen Dclose1 = close[_n] - close[_n-1]
			
			tsset date
			gen Dclose2 = D.close
			
			list Dclose1 Dclose2 in 1/10			// 日期不连续问题
			
			// 此处差异在处理时间序列数据时需要着重考虑
		
		* 生成滞后或者提前项
			
			sysuse sp500.dta, clear
			tsset date
			
			* 滞后项
				
				gen Lclose1 = close[_n-1]
				gen Lclose2 = L.close 
				list Lclose* in 1/10
				
				gen L2close1 = close[_n-2]
				gen L2close2 = L2.close 
				list L2close* in 1/10
				
			* 提前项
				
				gen Fclose1 = close[_n+1]
				gen Fclose2 = F.close 
				list Fclose* in 1/10
		
/*
				对于时间序列数据而言，尤其是股价这种非连续时间的数据
			尽量通过 Stata 的 L、D、F 来分别生成滞后、差分、提前项，而
			避免手动生成所导致的偏差
 */
			
		* 计算增长率（三种方法，一二种等价）
		
			sysuse sp500.dta, clear
			tsset date
			
			gen Ratio1 = (close[_n]-close[_n-1])/close[_n-1]
			gen Ratio2 = D.close/L.close
			gen lnclose = ln(close)
			gen Ratio3 = D.lnclose
			
			list Ratio* in 1/10
			
			// 对数差分为什么可以替代增长率（等价无穷小）
			// 增长率 = (close2-close1)/close1 = (close2/close1)-1 
			//        ~ ln(close2/close1) = lnclose2 - lnclose1
			// 10% https://www.zhihu.com/question/31722222
			
		* 计算移动平均
			
			* 常规做法
				
				sysuse sp500.dta, clear
				tsset date 
				keep date close
				
				gen L1close = L.close 
				gen L2close = L2.close
				gen L3close = L3.close
				
				egen MA3close = rowmean(L1close-L3close)
				gen MA3close1 = F.MA3close
				replace MA3close1 = . if mod(_n,3) != 0			// 仅保留第三期
				
			* 利用 _n 简化（可能有问题）
				
				gen MA3close2 = (close[_n-1] + close[_n] + close[_n+1]) / 3
				gen MA3close3 = MA3close2[_n-1]
				replace MA3close3 = . if mod(_n,3) != 0
				
				list close L* MA3* in 1/10
				dis (1333.34+1347.56+1283.27)/3
				dis (1283.27+1347.56+1333.34)/3
			
			* 看看两种做法的差异
			
				ttest MA3close1 = MA3close3
			
	* 虚拟变量的产生与转换
	
/*
		虚拟变量指的是以分类变量取值的变量，例如：
	男性为 1 ，女性为 0 ，这里 1 > 0 是不成立的。
*/
		
		* 了解 Stata 中变量的三种常见形式：
		
		*	（1）黑色：数值型变量，可以直接加减乘除
		*	（2）红色：文本型变量，无法直接计算，但能进行字符串运算
		*	（3）蓝色：数值-文本变量，显示为文本，但值为数字
		*	（4）这些变量的颜色可以在偏好设置中调整
		
		* 通过 generate 与 replace 生成虚拟变量
			
			sysuse auto.dta, clear
			
			* 依据 headroom 划分汽车舒适度（不够严谨）
				// 对连续变量生成
			
				sum headroom, detail
				return list
				
				gen Comfort = 1 if headroom >= r(p50)
				replace Comfort = 0 if headroom < r(p50)
			
			* 根据 foreign 生成国产变量
				// 对虚拟变量生成虚拟变量
				
				gen Domestic = 1 if foreign == 0
				replace Domestic = 0 if foreign == 1
				
			* 给这些虚拟变量打上标签，由黑变蓝
				// 展示数据有用，但合并时会造成混乱（不推荐）
			
				label define Comfort_label 1 "舒适" 0 "不舒适"
				label define Domestic_label 1 "国产" 0 "非国产"
				label values Comfort Comfort_label
				label values Domestic Domestic_label
				
		* 利用 tab 生成虚拟变量（one hot - 独热编码）

/*
			使用one-hot编码，将离散特征的取值扩展到了欧式空间，
		离散特征的某个取值就对应欧式空间的某个点。独热编码解决
		了分类器不好处理属性数据的问题，在一定程度上也起到了扩
		充特征的作用。它的值只有0和1，不同的类型存储在垂直的空间。
*/
			
			sysuse auto.dta, clear
			tab foreign, gen(Dummy)
			
			pwcorr Dummy*					// 完全共线
			
			reg price length Dummy* 
			est store Model1
			reg price length i.foreign
			est store Model2
			reg price length Dummy1			// LSDV 法固定效应
			est store Model3
			
			esttab Model*, nogap compress
	
		* 其他转换函数
			
			* 将样本等分产生虚拟变量
			
				sysuse auto.dta, clear
				sort price
				gen Group = group(4)
				browse price Group
				tabstat price, stat(N) by(Group) f(%4.2f)
			
				// 按照分位数分组也可达到相似效果
				
				sum price, detail
				return list
				gen Group1 = 1 if price <= r(p25)
				replace Group1 = 2 if (price>r(p25)) & (price<=r(p50))
				replace Group1 = 3 if (price>r(p50)) & (price<=r(p75))
				replace Group1 = 4 if price>r(p75)
				tabstat price, stat(N) by(Group1) f(%4.2f)
			
			* 任意分界点产生
			
				// 按照任意分位数产生
				
				sysuse auto.dta, clear
				_pctile price, p(1 3 6 10 34 91)
				return list 
				// 6 个分位数都已列出，可以搭配 generate 与 replace 进行操作
				
				// 直接指定具体的值（方法同上，不再赘述）
				// recode
				
				help recode
				
				sum price
				recode price (min/4000 = 1) (4000/5000 = 2) 	///
							 (5000/max=3), gen(Group)
						
				// 注意三斜线换行以及 recode 的范围
				// recode 为左开右闭取值
				
				// 利用条件函数
				
				sysuse auto.dta, clear
				quietly sum price, detail
				dis "price的中位数为" r(p50)
				gen Dummy = cond(price<r(p50),1,0)
				list price Dummy in 1/5
			
			* 对文本进行虚拟变量划分（inlist）
				
				use MainlandChina.dta, clear
				
				gen Middle = inlist(province,"山西","河南",	///
							"安徽","湖北","江西","湖南")
				browse
				
				// inlist 也可以处理数字
				
				sum year
				gen Last5years = inlist(year,2020,2019,2018,2017,2016)
				browse
				
				// 同样地可以用 inrange 代替
				
				gen Last3years = inrange(year,2018,2020)
				browse
				
	* 通过 egen 产生一些指标
		
/*
		egen 全称为 Extensions to generate，是对 generate 命令的扩充
*/
	
		* 求和的差异
		
			sysuse auto.dta, clear
			gen sumprice1 = sum(price)			// 累加
			egen sumprice2 = sum(price)			// 总和
			list price sumprice* in 1/10
			list price sumprice* in -1
		
		* 缺失值处理的差异
			
			// 生成数据
				
				clear
				set obs 10
				set seed 12345
				gen x1 = 10*runiform()
				gen x2 = 10*runiform()
			
			// 随机缺失值
				foreach v in x1 x2 {
					replace `v' =. if mod(ceil(`v'),2) == 0
				}
				
				list x*
			
			// 生成均值比较差异
				gen mean1 = (x1+x2)/2
				egen mean2 = rowmean(x1 x2)
				list x* mean*
				
		* 快速生成等差数列
			
			// 手动生成等差数列方式（初始项为1，公差为2）
			
				clear
				set obs 100
				set seed 12345
				gen X = 1 in 1
				forvalues i = 2/100{
					replace X = 1 + (`i' - 1) * 2 in `i'
				}
			
			// 尝试仿照上述方法编写等比数列计算代码
			
				gen Y = 1 in 1
				forvalues i = 2/100{
					replace Y = 1 * 2^((`i' - 1)) in `i'
				}
		
			// 利用 egen 简化
			
				egen Z1 = seq(), from(1)
				egen Z2 = seq(), from(1) to(199)	// seq() 无法改变公差
				
				egen A1 = fill(1 3)					// 可以制造任意等差
				egen A2 = fill(3 1)
				
				// fill 同样可以用来补足时间
				
				use MainlandChina.dta, clear
				drop year
				egen year = fill(2011 2012 2013 2014 2015 	///
								2016 2017 2018 2019 2020	///
								2011 2012 2013 2014 2015 	///
								2016 2017 2018 2019 2020)
		
		* 其余常用指标
		
			help egen
			
			// 均值、中位数、标准差、最小值、最大值
			
			sysuse auto.dta, clear
			egen Average = mean(price), by(foreign)
			egen Median = median(price), by(foreign)
			egen StdDev = sd(price), by(foreign)
			egen Min = min(price), by(foreign) 
			egen Max = max(price), by(foreign)
			browse
			
			// 这些命令均可以不通过分组而直接进行
		
			// 横向对比
				
			egen Difference = diff(Min Max)
			egen Mean = rowmean(Min Max)
		
		* 变量标准化（减去均值后除以标准差）
			
			// 手动实现
			
			sysuse auto.dta, clear
			sum price 
			gen STDprice1 = (price - r(mean))/r(sd)
			sum STDprice1
			list *price in 1/10
			
			// 通过 egen 简化实现步骤
			
			egen STDprice2 = std(price), mean(0) std(1)
			sum STDprice*
			list *price in 1/10
		
		* 移动平均
			
			sysuse sp500.dta, clear
			tsset date
			egen MA1 = ma(close) 				// 默认 3 期
			egen MA2 = ma(close), t(3)
			egen MA3 = ma(close), t(3) nomiss
			list close MA* in 1/10
			
			dis (1283.27+1347.56)/2				// 第一个值
			dis (1283.27+1347.56+1333.34)/3		// 第二个值
			dis (1347.56+1333.34+1298.35)/3		// 第三个值

			// 在加入nomiss的时候，不会存在缺失值，取而代之的是 n-1 期均值
			
				
*----------2.3：重复样本值的处理


	* 观察是否存在重复样本
		
		* 通过 isid 识别变量是否重复
		
			sysuse auto.dta, clear
			isid make
			isid foreign
		
		* 通过 distinct 判断变量不重复的组别
		
			distinct foreign
		
		* duplicates
			
			duplicates list foreign
	
			duplicates report foreign
	
			duplicates example foreign
	
	* 删除重复样本
		
		duplicates drop foreign, force
	
	* 对于面板数据而言
		
		duplicates drop stkcd year, force
	

*----------2.4：缺漏值的处理


	* Stata 的缺漏值种类
		
		help missing
		
	* 在 Stata 当中，“.” 大于任何的自然数
		
		sysuse auto.dta, clear
		replace price = . if price > 4000
		sum price if price > 3000
		count if price > 3000
		
		* 总结：
		* 有些命令会自动忽略缺漏值
		* 有些命令不会忽略 “." 
	
	* 查找是否存在缺漏值
	
		* 查找变量当中是否存在缺漏值（纵向搜索）
			
			sysuse auto.dta, clear
			sum
			dis _N					// 观测值不等于样本数，变量有缺失
			
			// 通过 misstable 查找
			
			misstable summarize       // 对所有变量
			misstable sum price-length   // 对指定变量
			
			// 该命令仅报告存在缺失的变量（不计算文本变量）
			
		* 查找样本中是否存在缺漏值（横向搜索）
			
			egen Rowmiss = rowmiss(price rep78 weight length)
			list price rep78 weight length if Rowmiss == 1
			
			// 一种逆向方法
			
			help reg
			reg price length weight rep78
			gen Missing = 1 if e(sample)
			
	* 对缺漏值的处理
		
		* 确定缺失比例
			
			sysuse auto.dta, clear
			sum
			dis "rep78变量缺失值比例=" (_N-69)/_N*100
			
			local Variables price mpg rep78 headroom trunk weight length
			foreach v in `Variables' {
				quietly summarize `v'
				dis _skip(10) "`v'的缺失比例为=" (_N-r(N))/_N*100
			}
		
		* 对连续变量可以通过均值填充
			
			egen rep78mean = mean(rep78)
			replace rep78 = rep78mean if rep78 == .
			drop rep78mean
			
			// 批量填充
			
			local Variables price mpg rep78
			foreach v in `Variables' {
				egen `v'mean = mean(`v')
				replace `v' = `v'mean if `v' == .
				drop `v'mean
			}
			
		* 对分类变量可以通过众数填充
		
			sysuse auto.dta, clear
			replace foreign = . in 3
			replace foreign = . in 70
			tab foreign
			labelbook
			replace foreign = 0 if foreign == .
			
		* 向前/向后填充（利用前后值进行填充）
			
			// 向后填充（上一期替代本期缺失）
			
			use WaitingFillData.dta, clear
			list
			replace X = X[_n-1] if X == .
			replace Y = Y[_n-1] if Y == ""
			list
			
			// 向前填充（下一期替代本期缺失）
			
			use WaitingFillData.dta, clear
			list
			replace X = X[_n+1] if X == .
			replace Y = Y[_n+1] if Y == ""
			list
		
			// 对面板数据而言，最好使用 L 与 F 
			
			use WaitingFillDataXT.dta, clear
			xtset Num Year
			list, sep(10)
			bys Num: replace Random = L.Random if mi(Random)
			list, sep(10)
			
			use WaitingFillDataXT.dta, clear
			xtset Num Year
			list, sep(10)
			bys Num: replace Random = F.Random if mi(Random)
			list, sep(10)
		
				// 在非连续时间样本中此时使用 [_n-1] 或者 [_n+1] 
				// 会使得数据填充过度
				
				use WaitingFillDataXT.dta, clear
				drop if Year == 2015			// 制造时间间隔
				xtset Num Year
				gen Random1 = Random
				bys Num: replace Random = L.Random if mi(Random)
				bys Num: replace Random1 = Random1[_n-1] if mi(Random1)
				list in -9/-1, sep(10)
					
		
*----------2.5：离群值的处理


	* 离群值是什么，会有什么影响？
		
/*
		离群值是脱离数据群体的值，极大极小值不一定为离群值
		数据群体指的是处于 (p25-1.5iqr, p75+1.5iqr) 之间的值
		四分位间距（interquartile range）：iqr = p75 - p25 
		p25、p75 分别指处于第 1 个四分位（第 25 个百分位）
		p25、p50、p75 分别叫第 1、2、3 个四分位
		p50 即中位数
 */
	
	* 离群值的影响（一个例子）
		
		sysuse auto.dta, clear
		_pctile price, p(25 75)
		dis "p25=" r(r1)
		dis "p75=" r(r2)
		
		local Lower r(r1)-1.5*(r(r2)-r(r1))
		local Upper r(r2)+1.5*(r(r2)-r(r1))

		gen tempVar = 1 if price>`Upper' | price<`Lower'
		sum tempVar
		
		reg price mpg rep78 
		est store Model1 
		reg price  mpg rep78 if tempVar != 1
		est store Model2 
		esttab Model1 Model2, nogap compress mtitle("Yes" "No")
		
		reg mpg rep78 price 
		est store Model1 
		reg mpg rep78 price if tempVar != 1
		est store Model2 
		esttab Model1 Model2, nogap compress mtitle("Yes" "No")
		
		// 离群值的存在会改变模型的解释
		
	* 查找离群值
		
		* 手动编写
		
			sysuse auto.dta, clear
			
			local Variables price mpg rep78 headroom trunk
			foreach v in `Variables' {
			
				_pctile `v', p(25 75)
				scalar Lower = r(r1)-1.5*(r(r2)-r(r1))		
				scalar Upper = r(r2)+1.5*(r(r2)-r(r1))		
				
				quietly sum `v'
				if (r(max)>Upper) | (r(min)<Lower) {
					dis _skip(15) "变量`v'存在离群值"
				}
				quietly gen Outlier`v'=1 if `v'>Upper | `v'<Lower
				quietly replace Outlier`v'=0 if Outlier`v'==.
			}
			
			// scalar 用于存储单值，可以增加代码美观度
			// scalar dir、scalar list、scalar drop
			
		* adjacent 命令
		
			// 展示距离上下边界最近的样本值
			
			sysuse auto.dta, clear
			
			sum price, detail
			dis "下界为" r(p25)-1.5*(r(p75)-r(p25))
			dis "上界为" r(p75)+1.5*(r(p75)-r(p25))
	
			adjacent price
			sort price
			
			// 同样可以保留非极端值
				
				gen tempVar = 1 if price > 8814 | price < 3291
				sum tempVar
			
		* 一种直观的做法，绘制箱型图
			
			graph box price
			graph hbox price
			graph box price, by(foreign)
		
	* 处理离群值
		
		* 直接删除（截尾）
			
			// 通过adjacent
			
			sysuse auto.dta, clear
			adjacent price 
			drop if price > 8814 | price < 3291
			
			// 通过 _pctile
			
			sysuse auto.dta, clear
			_pctile price, p(25 75)

			local Lower r(r1)-1.5*(r(r2)-r(r1))
			local Upper r(r2)+1.5*(r(r2)-r(r1))
			drop if price > `Upper' | price < `Lower'
			
		* 对数转换
			
			sysuse auto.dta, clear
			expand 2
			gen temp = 1 in 1/74
			replace temp = 0 if temp == .
			gen lnprice = ln(price) if temp == 0
			replace lnprice = price if temp == 1
			replace lnprice = lnprice/1000 if temp == 1
			
			graph box lnprice, by(temp)
			
			// 不难发现对数转换可以有效地缩小极端值，使数据更合理
			
		* 缩尾处理
			
			* 截尾是指将尾巴处样本直接删除或者转为缺漏值
			* 缩尾是指将尾巴末端处转为最后一个非极端值
			
			sysuse auto.dta, clear 
			
			// 判断是否需要缩尾的利器，直方图
			
			histogram price
			
			* 双边缩尾，对变量极大极小值同时缩尾
				
				winsor price, gen(price_W) p(0.05)
				
				twoway (histogram price, color(red))		///
					   (histogram price_W, color(blue)),	///
					   legend(label(1 "原始数据") label(2 "缩尾后"))
			
			* 仅对右侧缩尾
				
				graph box price			// 目测仅需对右侧缩尾
				
				dis 12/74
				winsor price, gen(price_HW) p(0.15) highonly
				graph box price_HW
				
				// 如果仅对左侧缩尾，则选择 lowonly 选项替换 highonly 
				
				twoway (histogram price, color(red))		///
					   (histogram price_HW, color(blue)),	///
					   legend(label(1 "原始数据") label(2 "右侧缩尾后"))
				
			* 任意点位缩尾
				
				// 通过 _pctile
				
				sysuse auto.dta, clear
				
				_pctile price, p(6 94)
				gen price_ = price
				replace price_ = r(r1) if price_ < r(r1)
				replace price_ = r(r2) if price_ > r(r2)
				
				twoway (histogram price, color(red))		///
					   (histogram price_, color(blue)),	///
					   legend(label(1 "原始数据") label(2 "任意缩尾后"))
		
		
*----------2.6：数据的合并与追加
			

	* 横向合并（增加变量，相当于 Excel 的 VLOOKUP）
		
		* 一对一合并（1：1）
		
			* 找寻合并识别变量
				
				use MergeData1.dta, clear
				browse
				use MergeData2.dta, clear
				browse
				
				// 发现 make 可以唯一对应一条样本，所以以 make 为关键词
				
				use MergeData1.dta, clear
				
				merge 1:1 make using MergeData2.dta
			
			* 新生成的 _merge 变量的含义：
			* _merge==1  observation appeared in master only                           
			* _merge==2  observation appeared in using only               
			* _merge==3  observation appeared in both
		
		* 多对一合并（m：1）
			
			// 多见于面板数据，把财务面板数据与企业基本信息合并等
			
			use MergeData3.dta, clear
			browse
			use MergeData4.dta, clear
			browse
		
			use MergeData3.dta, clear
			
			merge m:1 Num using MergeData4.dta
		
		* 一对多合并（1：m）逆过程
			
			use MergeData4.dta, clear
			
			merge 1:m Num using MergeData3.dta
		
			// 注意合并时一定要保证主表与被合并表的关键词名称相同
		
		
		* 测试，尝试合并 Test1 文件夹中的不同数据
		* FirmProvince 	为企业所在省市区
		* RD			为企业的研发支出情况
		* Patent		为企业的绿色专利情况
		
		
	* 纵向合并（增加样本值，相当于在 Excel 后面追加数据）
		
		* 查看数据与追加
		
			use MergeData1.dta, clear
			browse
			use MergeData2.dta, clear
			browse
			
			use MergeData1.dta, clear
			append using MergeData2.dta
			browse
			
			use MergeData1.dta, clear
			append using MergeData2.dta, gen(_append)
			browse
		
			// 注意变量名问题
			// Stata 区分大小写，Stata 与 stata 是不同的名称
			// 需要保证两个数据 dta 文件中相同变量名称相同
			// 需要保证两个数据 dta 文件中相同变量格式相同
			
			
*----------2.7：长宽数据转换		
	
	
	* 通过 reshape 命令转换
		
		* 宽转长生成数据
			
			clear
			input id sex inc80 inc81 inc82 xx80 xx81 xx82
				1 0 5000 5500 6000 1 2 3
				2 1 2000 2200 3300 2 3 4
				3 0 3000 2000 1000 6 4 8
			end
		
			reshape long inc xx, i(id) j(year)
			
			// 修正年份
				
				replace year = real("18"+string(year))
	
		* 长转宽生成数据
			
			clear
			input id	year	sex	inc	xx
				1	1880	0	5000	1
				1	1881	0	5500	2
				1	1882	0	6000	3
				2	1880	1	2000	2
				2	1881	1	2200	3
				2	1882	1	3300	4
				3	1880	0	3000	6
				3	1881	0	2000	4
				3	1882	0	1000	8		
			end
		
			reshape wide inc xx, i(id) j(year)
		
		// 注意 reshape 命令宽转长仅仅适用于变量以 文字+数字 形式命名
	
	* gather 与 spread
		
		ssc install tidy
		
		* 宽转长 gather
			
			sysuse educ99gdp.dta, clear
			browse
			
			gather public private
			
			sysuse educ99gdp.dta, clear
			gather public private, variable(Indicator) value(Ratio)
			
	
		* 长转宽 spread
			
			spread Indicator Ratio
	
		* 缺点
			
			clear
			input id sex inc80 inc81 inc82 xx80 xx81 xx82
				1 0 5000 5500 6000 1 2 3
				2 1 2000 2200 3300 2 3 4
				3 0 3000 2000 1000 6 4 8
			end
			
			gather inc* xx*
	
			// gather 仅能操作 “一批” 变量
			
	* 一种其他办法，从底层实现
		
		// 分析 gather
		
			clear
				input id sex inc80 inc81 inc82 xx80 xx81 xx82
					1 0 5000 5500 6000 1 2 3
					2 1 2000 2200 3300 2 3 4
					3 0 3000 2000 1000 6 4 8
				end
				
			gather inc*
		
		// 循环拆分，拆成样本年份与指标的对应格式
		
			forvalues a = 1/3 {
				foreach b in inc xx {
					preserve
						use ReshapeData.dta, clear
						keep if id == `a'
						keep id sex `b'*
						gather `b'*, variable(year) value(`b')
						replace year = substr(year,-2,2)
						destring year, replace
						save `a'`b'.dta, replace
					restore 
					
				}		
			}
		
		// 合并单个样本的其余变量
		
			use 1inc.dta, clear
			browse
			merge 1:1 id year using 1xx.dta
			
			forvalues i = 1/3 {
				use `i'inc.dta, clear
				merge 1:1 id year using `i'xx.dta
				drop _merge
				save `i'.dta, replace
			}
		
		// 追加其余样本时间序列数据，形成面板数据
		
			use 1.dta, clear
			browse
			forvalues i = 2/3 {
				append using `i'.dta
			}
			
			save LongShapeData.dta, replace
		
		// 清理中间过程文件
		
			forvalues a = 1/3 {
				erase `a'.dta
				foreach b in inc xx {
					erase `a'`b'.dta
				}
			}
		

*----------2.8：文字变量的处理


	* 变量的部分文字不影响变量，可直接 destring
		
		import excel using CharacterData.xls, first clear
		browse 
		clonevar var4 = var3
		
		destring var2, gen(var2N)
		destring var3, replace 
		destring var3, replace force
		destring var4, gen(var4N) 
		destring var4, gen(var4N) force
	
	* 含有 % 的变量也可以直接转换
		
		clear 
		input str6 Percent 
			"10%"
			"20%"
			"30%"
			"40%"
			"50%"
		end
		browse
		
		destring Percent, gen(Num) percent
		
		
	* 需要保留的文字变量，若需参与后续回归，则可以转换为类别变量
		
		use MainlandChina.dta, clear
		browse 
		
		encode province, gen(Province)
		
		// 或者
			
			egen Province1 = group(province), label lname(province)
		
		// 查看编码
			
			labelbook
	
	* 时间变量转换（非必要）
		
		* 时间日期变量是一种较为特殊的变量，有单独的存储格式
		* 在这里不够严谨地将其划分为文字变量
		
		* 生成数据 
			
			clear 
			input str6 Year str6 Month str6 Day
				"2020" "Jan" "3"
				"2021" "Feb" "6"
				"2022" "Mar" "9"
			end
			browse
		
			gen Date = Year + "/" + Month + "/" + Day
		
			gen SDate = date(Date, "YMD")
			format SDate %td
			
			tsset Date
			tsset SDate
		
		* 分离年月日（比较常用）
			
			clear 
			input str8 Date
				20200103
				20210103
				20220103
			end
			browse
			
			gen Year = real(substr(Date,1,4))
			gen Month = real(substr(Date,5,2))
			gen Day = real(substr(Date,-2,2))
			
			tsset Year
		
		* 更多时间变量转换相关见如下网页
		
			view browse https://www.bilibili.com/read/cv12026231
	
	* 文字变量拆分 split
		
		clear 
		input str18 City 
			台湾省台北市
			台湾省高雄市
			湖北省潜江市
			湖北省武汉市
			湖南省长沙市
			四川省成都市
		end
		
		// 从有规律的组合中拆分 省 与市区
	
			split City, parse("省") 
			replace City1 = City1 + "省"
			
			rename City1 province 
			rename City2 city
	
/*
		由于我国幅员辽阔，地大物博，省级行政单位并不完全是以省结尾，
	市级行政单位也非都以市结尾。省级单位特殊情况诸如 新疆维吾尔自治区；
	市级单位特殊情况诸如内蒙古自治区锡林郭勒盟；此外还应当考虑四个直辖市
	。所以通过 split 进行分割的情况仅仅适用于整齐规律的值，后续将介绍通
	过正则表达的方式提取 CEO 籍贯信息的操作
 */
	
		* 通过截取的方式提取（同样适用于整齐规则的变量）
		
			gen province1 = substr(City,1,9)
			gen city1 = substr(City,10,9)
		
			// 注意，每一个汉字算 3 个占位
		
	
	* 可以处理文字变量的其他函数
		
		help string functions
	
		* 更改大小写
		
			dis lower("ASejksjdlwASD")
			dis upper("sadhASDkSss")
			
		* 测量文本长度
			
			dis length("汉字")			// 一个汉字长度为 3
			dis length("English ")		// 一个字母长度为 1，且空格为 1
		
		* 测量文本个数
			
			dis wordcount("汉字 English ")		// 空格不作数
		
		* 匹配文本是否出现
			
			dis strmatch("xxx出生在中国湖北省潜江市", "潜江")
			
			dis strmatch("xxx出生在中国台湾省台北市", "台北市*")
			dis strmatch("xxx出生在中国台湾省台北市", "*台北市*")

			dis strmatch("Stata", "s")
			dis strmatch("Stata", "s")
			dis strmatch("Stata", "S")
			dis strmatch("Stata", "S*")
			
			// 区分大小写，且匹配中文时需要在待匹配内容两侧加 *
		
		* 去除空格的几种方法
			
			dis " 我还 在漂泊  你是错 过的烟火 "
			
			// 去除两端空格
			dis  strtrim(" 我还 在漂泊  你是错 过的烟火 ") 
		
			// 去除左边空格
			dis  strltrim(" 我还 在漂泊  你是错 过的烟火 ") 
			
			// 去除右边空格
			dis  strrtrim(" 我还 在漂泊  你是错 过的烟火 ") 
			
			// 去掉中间空格
			dis  stritrim(" 我   还 在  漂泊  你  是错 过的烟火 ") 
			help stritrim()		// 将中间若干空格压缩成一个空格
			
			// 若要去掉所有空格
			dis subinstr(" 我   还 在  漂泊  你  是错 过的烟火 "," ","",.)
			help subinstr()		// 点表示替换所有空格
			
			dis subinstr(" 我   还 在  漂泊  你  是错 过的烟火 "," ","",2)
			
			dis subinstr(" 我   还 在  漂泊  你  是错 过的烟火 "," ","",4)
			
		* 以上 dis 部分内容都可以配合 gen 生成新的变量
		
	* 正则表达（regular expression）
	  
		* 正则表达教程
	
			view browse https://www.runoob.com/regexp/regexp-tutorial.html
	
		* 正则表达初印象（主要：ustrregexm、ustrregexs）
		
			clear
			input str10 String 
				"abc"
				"ab"
				"aa"
				"abcd"
				"aad"
				"aab123"
				"cdf12345"
				"123"
				"Abc"
			end
			
			gen Number1 = ustrregexs(0) if ustrregexm(String,"[0-9]")
			gen Number2 = ustrregexs(0) if ustrregexm(String,"[0-9]+")
			gen Number3 = ustrregexs(0) if ustrregexm(String,"[0-9]*")
			gen Number4 = ustrregexs(0) if ustrregexm(String,"[0-9]?")
			
			gen Number5 = ustrregexs(0) if ustrregexm(String,"[0-9]$")
			gen Number6 = ustrregexs(0) if ustrregexm(String,"[0-9]+$")
			gen Number7 = ustrregexs(0) if ustrregexm(String,"[0-9]*$")
			gen Number8 = ustrregexs(0) if ustrregexm(String,"[0-9]?$")
			
			gen Number9 = ustrregexs(0) if ustrregexm(String,"^[0-9]")
			gen Number10 = ustrregexs(0) if ustrregexm(String,"^[0-9]+")
			gen Number11 = ustrregexs(0) if ustrregexm(String,"^[0-9]*")
			gen Number12 = ustrregexs(0) if ustrregexm(String,"^[0-9]?")
			
		
		* 正则表达常用操作
		
			clear
			input str16 String 
				"ab"
				"AA"
				"ABcd"
				"aab123"
				"AA133"
				"Cdf12345"
				"123"
				"错过的烟火"
				"红颜如霜123"
			end
			
			// 提出所有数字
			
			gen Number = ustrregexs(0) if ustrregexm(String,"\d+")
			
			// 提出所有小写字母
			
			gen LetterL = ustrregexs(0) if ustrregexm(String,"[a-z]+")
			
			// 提出所有大写字母
			
			gen LetterU = ustrregexs(0) if ustrregexm(String,"[A-Z]+")
			
			// 提出所有字母
			
			gen Letter = ustrregexs(0) if ustrregexm(String,"[a-zA-Z]+")
			
			// 提出所有汉字
			
			gen Character = ustrregexs(0) if ustrregexm(String,"[\u4e00-\u9fa5]+")

			// 其余有用示例
			
			view browse https://blog.csdn.net/wangjia55/article/details/7877915
			
			// 可用于匹配身份证、邮政编码、网址、Email等
		
		* 一个例子：通过正则表达提取上市公司 CEO 的籍贯信息
			
			use CEONativePlace.dta, clear
			compress
			
			// 提取省份
			
gen Province=ustrregexs(0) if ustrregexm(NativePlace,".*省|.*自治区|.*市|.*特别行政区")
			
			// 提取所在地级市
			
gen City = ustrregexs(2) if ustrregexm(NativePlace,"(.*省|.*自治区)?(.*市|.*自治州|.*地区|.*盟)")

gen Province1 = ustrregexs(1) if ustrregexm(NativePlace,"(.*省|.*自治区)?(.*市|.*自治州|.*地区|.*盟)")	

			browse NativePlace Province1
			help ustrregexs()


*----------2.9：类别变量的分析

	
	* 类别数目简单统计
	
		* 简单了解类别变量分布情况 tabulate
			
			sysuse auto.dta, clear
			tabulate foreign
		
		* 统计非重复值的个数
			
			distinct foreign
			distinct, max(10)
			distinct make-headroom
			distinct make-headroom, missing abbrev(6)
			distinct foreign rep78, joint
			distinct foreign rep78, joint missing
		
	* 分组统计量
		
		* 一维分组统计量
			
			* 简要组合 by 与 sum 进行描述
			
				sysuse auto.dta, clear
				by foreign: sum price
			
			// 等价于
				
				sum price if foreign == 0
				sum price if foreign == 1
				
			* tabstat 命令
				
				tabstat price, by(foreign) stat(mean sd med min max)
				
			* tabulate 命令
			
				sysuse auto.dta, clear
				tabulate foreign
				
				sysuse nlsw88.dta, clear
				tab occupation
				tab occupation, sort
				tab occupation, summarize(wage)
				
		* 二维和三维分组统计量
			
			sysuse nlsw88.dta, clear
			bysort race married: sum wage
			
			bysort race married: tabstat wage,   ///
				   by(union) s(n mean sd p50 min max)
				   
			tabstat wage, by(race married union)  ///
				   s(n mean sd p50 min max) // 错误方式
				   
			bysort race married: tab union, sum(wage)
				
				
		* 四维分组统计量
			
			* 可以在 table
				
				table race married union,       ///
						by(collgrad) c(mean age) format(%4.2f)
					
				table union race married,       ///
						by(collgrad) c(mean wage freq) format(%4.2f)	
			
				// 基本规律
				// by() 中的变量与 table 后的第一个变量联合为表的左上角
				// 表的第一列为 by() 中的变量分类与 table 后第一个变量的组合
				// 表的第一行中从第二列开始为 table 后的第二三个变量的分类组合
		
	* 计算分组统计量的其他办法（常用且自由度更高）
			
		* egen 命令 
			
			sysuse nlsw88.dta, clear
			
			// 计算不同人种的工资均值
			
				bys race: egen Meanwage = mean(wage)	
			
			// 计算不同人种的工资中位数
			
				bys race: egen Midwage1 = median(wage)
				bys race: egen Midwage2 = pctile(wage), p(50)
			
			// 计算不同人种的工资标准差
				
				bys race: egen SDwage = sd(wage)
		
				preserve
					duplicates drop race, force
					drop wage
					list race *wage*
				restore 
			
		* collapse 命令（会改变原始数据）
			
			* 计算国产车与非国产车价格均值与生产商个数
			
				sysuse auto.dta, clear
				collapse (mean) Meanprice=price 	///
						 (count) Nummake=make, 		///
						 by(foreign)				// 错误用法，有文字
			
				
				sysuse auto.dta, clear
				encode make, gen(Make)				// 将文字转为带标签的变量
				collapse (mean) price 	///
						 (count) Make, 		///
						 by(foreign)
				
				// 自定义生成变量的名称
				
					sysuse auto.dta, clear
					encode make, gen(Make)
					collapse (mean) Meanprice=price 	///
							 (count) NumMake=Make, 		///
							 by(foreign)
			
			// 使用后需要重新导入一次数据
			// 如仅仅想作图，则可以配合 preserve 与 restore 使用
			// preserve 与 restore 可以不改变当前数据
			
				sysuse auto.dta, clear 

				preserve
					encode make, gen(Make)
					collapse (mean) Meanprice=price 	///
							 (count) NumMake=Make, 		///
							 by(foreign)
					egen STDprice = std(Meanprice), mean(0) std(1)
					egen STDnum = std(NumMake), mean(0) std(1)
					twoway (scatter STDprice foreign, color(blue)) ///
						   (scatter STDnum foreign, color(red))
				restore
			
	* 图示分组统计量
		
		* 通过柱状图进行绘制
			
			sysuse nlsw88.dta, clear
			graph bar (median) wage, over(race) over(married) over(collgrad)
		
			* 改变柱状图方向（横向柱状图）
			
				graph hbar (median) wage, over(race) over(married) over(collgrad)
				
				graph hbar (median) wage, over(race) over(married)
				
				graph hbar (median) wage, over(race)
				
				graph hbar (median) wage, over(race) over(married) over(union)
				
				// 最多允许 3 个 over()
			
			* 增加更多地变量
				
				graph hbar (mean) wage (median) age, over(race) over(married)
				
				graph hbar wage age, over(race) over(married) stack
				
				* 改变图形标签
				
					graph hbar wage age,                      			  ///
						over(race, relabel(1 "白人" 2 "黑人" 3 "其他"))   ///
						over(married, relabel(1 "单身" 2 "已婚"))         ///
						legend(label(1 "工资水平") label(2 "年龄")) 
				
					shellout WordFile.docx
					
					// Stata 默认字体不够美观，在图形界面复制粘贴到 Word
					// 会发现自动更改为 宋体
		
		* 通过箱型图描述变量分布情况
			
			sysuse nlsw88.dta, clear
			
			graph box wage,  over(race)
			graph box age, over(race) over(married)
			graph box age, over(race) over(married) over(union)
			graph box age, over(race) over(married) over(union) nooutsides		
				
		
/*==================================================
						CASE
==================================================*/


*	CASE1	描述性统计与相关性分析的结果导出
	
	* 描述性统计导出 sum2docx
	
		sysuse auto.dta, clear
		
		rename price 		价格
		rename headroom 	头顶空间
		rename length 		车长
		rename weight		车重
		
		local Variables 价格 头顶空间 车长 车重
		sum2docx `Variables' using 描述性统计表.docx,	///
			replace stats(N mean sd median p25 p75 min max)			///
			title("描述性统计表1") font("宋体",12,"black") ///
			pagesize(A4)
			
		sum2docx `Variables' using 描述性统计表.docx,	///
			replace stats(N mean sd median p25 p75 min max)			///
			landscape title("描述性统计表2") font("宋体",12,"black") ///
			pagesize(A4)	
		// landscape - 设置横向页面
	
	* 相关性分析结果导出 corr2docx
		
		sysuse auto.dta, clear
		
		rename price 		价格
		rename headroom 	头顶空间
		rename length 		车长
		rename weight		车重
		
		local Variables 价格 头顶空间 车长 车重
		corr2docx `Variables' using 相关系数矩阵.docx, 		///  
			replace fmt(%9.3f) title("相关系数矩阵") 			///
			font("宋体",12,"black") star pagesize(A4) landscape 	///    
			note("注：*** p<0.01, ** p<0.05, * p<0.1") 

		// 左下角为 Pearson 相关系数，右上角为 Spearman 相关系数
		

*	CASE2	CFPS  数据清洗
	
	// 见 CFPS.do 

*	CASE3	CSMAR 数据清洗
	
	// 见 CSMAR.do

*	CASE4	WIND  数据清洗

	// 见 WIND.do






exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><