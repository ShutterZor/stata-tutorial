/*==================================================
project:       Graph procedure in Stata
Author:        Shutter Zor 
E-email:       Shutter_Z@outlook.com
url:           shutterzor.github.io
Dependencies:  School of Accountancy, Wuhan Textile University
----------------------------------------------------
Creation Date:     9 Aug 2022 - 11:12:25
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/



/*==================================================
						目录
==================================================*/


*	3.1  常见图形的绘制
* 	3.2  图形选项设置
* 	3.3  图形合并与导出
*	3.4  更改绘图模板

*	CASE1	事件研究法绘图
*	CASE2	绘制中国地图



/*==================================================
              3：Stata 数据可视化
==================================================*/


*----------3.1：常见图形的绘制 


	* Stata 常见图形 
		
		help graph
		
		sysuse auto.dta, clear
		
		collapse (mean) price, by(length)
		
		* 散点图
			
			twoway scatter price length
			
		* 折线图
			
			twoway line price length
		
		* 连线图（带样本点的折线图）
			
			twoway connected price length
		
		* 柱状图
			
			twoway bar price length			// 描述两个变量之间的关系
				
			graph bar price length			// 自动取均值后比较
		
		* 直方图
			
			histogram price					// 面积和为 1
		
		* 密度函数图
			
			kdensity price
			
			kdensity price, normal
			
		
*----------3.2：图形选项设置


		* 任意函数的图形
			
			help twoway function
			
			twoway (function y=x^2, range(-5 20) lw(*1.5) color(red))  		///
				   (function y=x^3, range(-5 20) lw(*2.0) color(blue))		///
				   (function y=ln(x), range(-5 20) lw(*2.5) color(green)), 	///
				   ylabel(, angle(-45))           							///
				   yline(0, lcolor(black*0.5) lpattern(dash))   			///
				   xlabel(, angle(0))										///
				   xline(0, lcolor(black*0.5) lpattern(dash))				///
				   legend(label(1 "y=x^2") label(2 "y=x^3") label(3 "y=ln(x)"))	///
				   scheme(s1mono)
		
		* U 型曲线
			
			sysuse auto.dta, clear
			
			reg price c.length#c.length
			
			twoway function y=0.1642153*x^2, range(0 233)			///
					ytitle("汽车价格") xtitle("汽车长度")			///
					title("价格与长度的二次曲线")
		
			// 补全负值
			
			twoway (function y=0.1642153*x^2, range(0 233))			///
				   (function y=0.1642153*x^2, range(-233 0) lpattern(dash)), ///
					ytitle("汽车价格") xtitle("汽车长度")			///
					title("价格与长度的二次曲线")					

					
*----------3.3：图形合并与导出


	* 保存绘制好的图片
			
		sysuse auto.dta, clear
			
		twoway scatter price length			
		
		graph save FirstFigure.gph, replace		// 保持绘图窗口不关闭时才能保存
		
	* 重新调用
		
		graph use FirstFigure.gph
		
		// 调用时可换用不同的图片风格
			
			graph use FirstFigure.gph, scheme(s1mono)
			graph use FirstFigure.gph, scheme(s2mono)
			
	* 推荐使用手动保存方式
		
		sysuse auto.dta, clear
			
		twoway scatter price length	
		
	* 将图形导出为其他格式
		
		help graph export
		
		sysuse auto.dta, clear
			
		twoway scatter price length	
		
		graph export FirstFigure.png, replace
		shellout FirstFigure.png
		
		// 除 png 格式外，还有 .ps .eps .wmf .emf .pict .tif 等图片格式
	
	* 调整输出图片的分辨率
		
		collapse (mean) price, by(length)
		twoway connected price length	
		
		graph export SecondFigure.png, width(1280) height(960) replace
		shellout SecondFigure.png
		
	* 图形的合并（Stata 只能合并 gph 格式图片）
		
		graph combine FirstFigure.gph SecondFigure.gph
		
		graph combine FirstFigure.gph SecondFigure.gph, cols(1)

	* 删除图形 
		
		graph dir
		erase FirstFigure.gph


*----------3.4：更改绘图模板
	
	
	* Stata 自带的绘图模板
		
		help schemes 
		
	* 不同模板的区别
		
		doedit DifferentScheme.do
		
		do DifferentScheme.do
	
		// 存在细微的差别，但总的来说 Stata 自带的模板绘图美观感不足
		
	* 其他外部模板
		
		* 解压 schemes.zip 
		net install tsg_schemes, from("您的文件夹路径\schemes") replace
		
		sysuse auto.dta, clear
		collapse (mean)price, by(length)
		
		set scheme white_tableau
		twoway line price length
		
		use SchemeData.dta, clear
		
		* 散点图 
		
		set scheme black_cividis
		twoway ///
			(scatter var2 date if group==1) ///
			(scatter var2 date if group==2) ///
			(scatter var2 date if group==3) ///
			(scatter var2 date if group==4) ///
			(scatter var2 date if group==5) ///
			(scatter var2 date if group==6) ///
			(scatter var2 date if group==7) ///
			(scatter var2 date if group==8) ///
			(scatter var2 date if group==9) ///
			(scatter var2 date if group==10) ///
			(scatter var2 date if group==11) ///
			(scatter var2 date if group==12)， ///
			legend(order(1 "group1" 2 "group2" 3 "group3" 	    ///
			4 "group4" 5 "group5" 6	"group6" 7 "group7" 		///
			8 "group8" 9 "group9" 10 "group10" 11 "group11" 12	///
			"group12")) title("Scatter plot")
			
		graph save scatter1, replace
		
		set scheme neon
		twoway ///
			(scatter var2 date if group==1) ///
			(scatter var2 date if group==2) ///
			(scatter var2 date if group==3) ///
			(scatter var2 date if group==4) ///
			(scatter var2 date if group==5) ///
			(scatter var2 date if group==6) ///
			(scatter var2 date if group==7) ///
			(scatter var2 date if group==8) ///
			(scatter var2 date if group==9) ///
			(scatter var2 date if group==10) ///
			(scatter var2 date if group==11) ///
			(scatter var2 date if group==12)， ///
			legend(order(1 "group1" 2 "group2" 3 "group3" 		///
			4 "group4" 5 "group5" 6	"group6" 7 "group7" 		///
			8 "group8" 9 "group9" 10 "group10" 11 "group11" 12	///
			"group12")) title("Scatter plot")
			
		graph save scatter2, replace
		
		graph combine scatter1.gph scatter2.gph

		* 箱型图
		
			set scheme black_cividis
			graph box var*, title("Box plot")
			graph save box1, replace

			set scheme neon
			graph box var*, title("Box plot") 
			graph save box2, replace

			graph combine box1.gph box2.gph	
		

/*==================================================
						CASE
==================================================*/


*	CASE1	事件研究法绘图 


/*
	参考文献：石大千, 丁海, 卫平, 刘建江. 智慧城市建设能否降低环境污染[J]. 
			  中国工业经济, 2018(06): 117-135.
 */


	* 查看数据
		
		use aqiData.dta, clear
		
	*- 事件分析（动态效应检验）
		gen dum = 1
		
		bys cityname: gen timeseries = _n
		
		gen current = 13.timeseries*dum
		
		forvalues i = 12(-1)1{
			gen before`i' = (timeseries == 13 - `i')*dum
		}

		forvalues k = 1/11{
			gen after`k' = (timeseries == 13 + `k')*dum
		}

		drop before12

		gen lnpm2_5 = ln(pm2_5)
		
		reghdfe lnpm2_5  before2 before1 current after*	///
				, absorb(citycode year) cluster(citycode)
				
		coefplot,                                                                  	///
			  keep(before* current after*)                                          ///
			  vertical                                                              ///
			  scheme(s1mono)                                     	                ///
			  coeflabels(before3 = -3                                               ///
						 before2 = -2                                               ///
						 before1 = -1                                               ///
						 current =  0                                               ///
						 after1  =  1                                               ///
						 after2  =  2                                               ///
						 after3  =  3                                               ///
						 after4  =  4												///
						 after5  =  5												///
						 after6  =  6												///
						 after7  =  7												///
						 after8  =  8												///
						 after9  =  9												///
						 after10 =  10												///
						 after11 =  11)												///		 
			  msymbol(O) msize(small) mcolor(black)                                 ///
			  addplot(line @b @at,    lcolor(black) lwidth(thin) lpattern(solid))   ///
			  ciopts(recast(rcap)     lcolor(black) lwidth(thin))                   ///
			  yline(0, lpattern(dash) lcolor(black) lwidth(thin))                   ///
			  ytitle("PM2.5", size(medlarge) orientation(h))      					///
			  xtitle("{stSans:期数}", size(medlarge))                 			    ///
			  xlabel(, labsize(medlarge))                                           ///
			  ylabel(, labsize(medlarge) format(%02.1f))                            ///
			  saving(EventFirgure, replace) levels(95)
	

*	CASE2	绘制中国地图
	
	* 打开阿里云地图选择器
		
		view browse http://datav.aliyun.com/portal/school/atlas/area_selector
	
		* 选择想要区域后点击 其他类型中的第一个下载按钮
		// 下载 中华人民共和国.json 文件
	
	* 将 JSON 文件转换为 shp 文件
		
		view browse http://datav.aliyun.com/portal/school/atlas/area_selector
	
	
	
		spshape2dta "ChinaMap/中华人民共和国.shp"		
		
		* 中华人民共和国.dta 用来存储画图指标
		
			use 中华人民共和国.dta, clear
			keep _ID _CX _CY name 
			
			gen GDP = int(10*runiform())
			save Indicator.dta, replace
		
		* 中华人民共和国_shp.dta 用来存储画图背景
			
			use 中华人民共和国_shp.dta
			twoway scatter _Y _X, msize(vtiny) 
		
		* 先导入指标数据，然后在 中华人民共和国_shp.dta 上画图
		
			use Indicator.dta, clear
			
			spmap GDP using "中华人民共和国_shp.dta", id(_ID) 
			
			// 美化	
			
			spmap GDP using "中华人民共和国_shp.dta", id(_ID) 	///
					 label(label(GDP) xcoord(_CX) ycoord(_CY) 	///
				     size(*0.6) color(blue))					///
					 title("GDP Growth for China")				///
					 subtitle("Virtual Data")
		
			spmap GDP using "中华人民共和国_shp.dta", id(_ID) 	///
					 clnumber(5) fcolor(Reds2)					///
					 title("GDP Growth for China")				///
					 subtitle("Virtual Data")
			
			help spmap 		// 查看更多选项设定

		
		
		
		
		
		


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><