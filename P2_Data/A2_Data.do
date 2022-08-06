          *     ----------------------------------------
          *     ------- Stata 编程与效率实证分析 -------
          *     ----------------------------------------

          *         =========================
          *           第二讲  Stata 基础操作
          *         =========================



*----------------
*    本讲目录
*----------------
*	2.1  各类数据的导入导出
* 	2.2  变量转换技巧
* 	2.3  重复样本值的处理
*	2.4  缺漏值的处理
* 	2.5  离群值的处理    
* 	2.6  数据的合并和追加
* 	2.7  长宽数据转换
*   2.8  文字变量的处理
*   2.9  类别变量的分析



*------------------------
*-2.1 各类数据的导入导出
*------------------------

*-	数据以 csv 与 excel 格式为主，常见命令为 insheet 与 import
	// 其余格式数据如有需求建议手工导入

*-	数据保存，另存为 dta 文件通过 save xxx.dta, replace 实现
	// 保存为其他格式请使用面板操作



*------------------
*-2.2 变量转换技巧 
*------------------

  *     ==本节目录==
		  
  *     2.1.1 _n 和 _N
  *         2.1.1.1  _n 与 _N
  *         2.1.1.2  _n 与 _N 的应用
  *     2.1.2 虚拟变量的产生  
  *         2.1.2.1 基本方式
  *         2.1.2.2 基于类别变量生成虚拟变量: -tab-命令 	 
  *         2.1.2.3 在回归中设置对照组
  *         2.1.2.4 将连续变量转换为类别变量
  *         2.1.2.5 利用条件函数产生虚拟变量 
  *     2.1.3  -egen- 命令  
  *         2.1.3.1 egen 与 gen 的区别
  *         2.1.3.2  产生等差数列: seq() 函数
  *         2.1.3.3  填充数据：fill() 函数
  *         2.1.3.4  产生组内均值和中位数
  *         2.1.3.5  跨变量的比较和统计
  *         2.1.3.6  变量的标准化
  *         2.1.3.7  变量的平滑化（Moving Average）
  


*___________________
*-2.1.1  _n 和 _N

  *-2.1.1.1  _n 和 _N 的含义
     
    *-定义： 
      * _n "样本序号变量"，是一个变量，内容为 1,2,3,...,n
      * _N "样本数指标",   是一个单值，内容为 样本数

    *-说明：
      * _n 是一个永远存在，但却不能 list 出来的特殊变量
      * _n 的取值会随样本排序的变化而变化
      
      sysuse nlsw88.dta, clear
      list age wage in 1/10      // 最左边的1,2,...就是 _n 中的内容
      list _n                    // 错误

      sort hours
      gen nid_1 = _n             // 第一个 _n 的内容 
      list nid_1 hours race in  1/10 
      sort wage
      gen nid_2 = _n             // 第二个 _n 的内容         
      list nid_1 nid_2 hours race in 1/10

      dis _N                     // _N 是一个单值
      scalar obs = _N			 // scalar 用来存储单值
      quietly sum wage
      dis r(mean)*_N
      dis r(mean)*obs	

	  
  *-2.1.1.2  _n 和 _N 的应用
  
      sysuse sp500.dta, clear
      sort open
      sum open
      dis r(max)
      gen o_max   = open[_N]             // 最大值
      gen o_diff  = open[_n] - open[_N]  // 与最大值的差
      gen b_diff = open[_N] - open[1]    // range
      list open o_max o_diff b_diff in 1/20
      
      *-差分
        sort date
        gen d_open = open[_n] - open[_n-1]
        
      *-对数差分
        gen dln_open = ln(open[_n]) - ln(open[_n-1])
        
      *-移动平均
        gen mv3_open = (open[_n-1] + open[_n] + open[_n+1]) / 3
        list open o_max o_diff dln_open mv3_open in 1/10

      *-滞后项、前推项、差分
        tsset date  /*声明数据为时间序列*/
        gen open_lag  = L.open
        gen open_lag2 = L2.open
        gen open_forward  = F.open
        gen open_diff  = D.open
        gen open_diff2 = D2.open
        list open* in 1/10
        reg close L(1/3).(close open)
        
      *-增长率
        qui tsset date
        gen r1 = D.close/L.close
        gen lnclose = ln(close)
        gen r2 = D.lnclose        // 第二种计算方法
        list date r1 r2 in 1/10
        
		ttest r1 = r2
		// 等价无穷小
		// 增长率 = (close2-close1)/close1 = (close2/close1)-1 
		//        ~ ln(close2/close1) = lnclose2 - lnclose1
		// 10% https://www.zhihu.com/question/31722222
		
      *-分组进行
        sysuse nlsw88.dta, clear
        bysort industry: gen gid = _n
        list gid industry in 1/50, sepby(industry)
  

  
*_______________________
*-2.1.2  虚拟变量的产生

  *-2.1.2.1 基本方式
    
    *-使用-generate-和-replace-产生虚拟变量
      sysuse nlsw88.dta, clear
	  
	  codebook race
      gen dum_race2=0
        replace dum_race2=1 if race==2
      gen dum_race3 = 0
        replace dum_race3=1 if race==3
		
      list race dum_race* in 1/100, sepby(race)


  *-2.1.2.2 基于类别变量生成虚拟变量: -tab-命令
  
      sysuse nlsw88.dta, clear
      tab race, gen(dum_r)
      list race dum_r1-dum_r3 in 1/100, sepby(race)
	       
	  
  *-2.1.2.3 在回归中设定特定变量对照组
	   
	   sysuse nlsw88.dta, clear
	 
	 *- 虚拟变量设置
	   *-选择 race=other 作为对照组
	     label list racelbl   // race=1(Min) 是stata默认的对照组
		 reg wage ib3.race
		 
	   *-选择 race=other, married=1 作为对照组	
	     label list marlbl 
		 reg wage  ib3.race ib1.married 
		 reg wage  ib3.race##ib1.married  // 加入交乘项

		
     *- 连续变量的设定
	   help fvvarlist 
	   reg wage  i.married hours i.married#c.hours
	   reg wage  i.married##c.hours      // 等价于上述命令
	   
	   reg wage  i.married##c.hours  /// // 婚否
	             i.union##c.hours    /// // 是否工会成员 
				 i.collgrad##c.hours     // 是否大学毕业
		 
	   reg wage  hours c.hours#c.hours	 // 增加平方项 
	   reg wage  c.hours##c.hours	     // 等价于上述命令
	   
	   reg wage  c.hours##c.hours##c.hours	// 增加三次方
	   reg wage  c.hours c.hours#c.hours c.hours#c.hours#c.hours  //等价
	   
            
  *-2.1.2.4 将连续变量转换为类别变量

    *- 等分样本              -group()-
       sysuse nlsw88.dta, clear
       sort wage                  // 这一步很重要
       gen  g_wage = group(5)     // 等分为五组
       tab g_wage
       tabstat wage, stat(N mean med min max) by(g_wage) f(%4.2f)

    *- 指定分界点的转换方式  -recode-
       sum age
       recode age (min/39 = 1) (39/42 = 2) (42/max = 3), gen(g_age) 
       * 1  if  age<=39         右封闭区间
       * 2  if  39<age<=42
       * 3  if  age>42
       list  age g_age  in 1/50, sepby(g_age)

       *-Q：如果希望将 39 岁女员工归入第 2 类，该如何下达命令？
            recode age (39/42 = 2) (min/39 = 4) (42/max = 3), gen(g1_age) 
           

  *-2.1.2.5 利用条件函数产生虚拟变量
  
    *- cond() 函数
      
      * 基本语法：cond(s,a,b)  |   cond(s,a,b,c)
      * 取值：
        * a    if 表达式 s 为真；
        * b    if 表达式 s 为假；
        * c    if 表达式 s 为缺漏值
      * 示例：
	    sysuse nlsw88, clear
        gen dum1 = cond(hours>40, 1, 0, .)
          list hours dum1 in 1/20
		gen dum2 = cond(hours>40&hours!=., 1, 0, .)
          list hours dum1 dum2 in 1/20  // 注意此处的区别
		  
        gen dum_ratio = cond(wage/hours>0.5, 1, 0)
          list wage hours dum_ratio in 1/20
     
	 
    *- inlist() 函数
      
      * 基本语法：inlist(x, a,b,c,...) 
      * 取值：
        * 1    if x = a,b,c,...中的任何一个
        * 0    otherwise
      * 规则：
        * 若x为实数，则后续取值必须介于2-255
        * 若x为字符，则后续填项的个数必须介于2-10
      *
      * 示例 1：
        label list occlbl
        gen dum_occu = inlist(occupation, 1,2,7,12)  
        list occu dum_occu in 1/20
        * 等价于
          gen dum_occu1 = (occ==1|occ==2|occ==7|occ==12)
      *   
      * 示例 2：
        use gdp_China.dta, clear		
		
		*- 解决乱码（Stata不同版本之间dta文件切换可以使用如下方法转码）
		clear
		unicode encoding set gb18030  		//将文本编码设置为中文
		unicode analyze gdp_China.dta		//分析需要转码的文档
		unicode translate gdp_China.dta
		
		use gdp_China.dta, clear
        sort Y
        list in 1/10     // 如何产生地区虚拟变量？
        *egen pvname = msub(prov), f(" ") //去掉省名中的空格
        gen east = inlist(prov,"北京","福建","广东","江苏", ///
                         "辽宁","山东","上海","天津","浙江") 
        sort east prov
        browse if year ==2003
     
	 
   *- inrange() 函数
   
     * 基本语法： inrange(x, a,b)
     * 取值：
       * 1    if  a<= x <= b；
       * 0    otherwise
	   
     * 示例：
	   sysuse nlsw88, clear
       gen dum_h2  = inrange(hours, 30,40)
	   
       * 等价于
         gen dum_h3 = (hours>=30 & hours<=40) 
         list hours dum_h2 dum_h3 in 1/20
     
	 
   *- clip() 函数 
 
     * 基本语法： clip(x, a,b)
     * 取值：
       * a    if x<=a;   // 缩尾
       * x    if a<x<b;  // 原始值
       * b    if x>=b    // 缩尾
	   
         gen g_h4 = clip(hours, 30, 40)
         list hours g_h4 in 1/100
		 
       *-以此为基础，可进一步产生虚拟变量
 


*______________________
*-2.1.3  -egen- 命令

  * extended generate 的缩写
    help egen

  *-2.1.3.1 egen 与 gen 的区别
  
    *-基本差异
	  sysuse sp500, clear
      gen  sum_close0 = sum(close)  // 累加
      egen sum_close1 = sum(close)  // 总体加总
      list close sum_close0 sum_close1 in 1/10
	  list close sum_close0 sum_close1 in -1
	  
    *-对于缺漏值的处理也有差异
      clear
      input v1  v2
            1   5
            2   .
            .   3
            2   4
            4   . 
            .   6
      end
      gen mean       = (v1+v2)/2
      egen mean_egen = rmean(v1 v2)
      list


  *-2.1.3.2  产生等差数列: seq() 函数
    clear
	set obs 100
    egen x1 = seq(), from(-1)
      list x1 in 1/10
    egen year = seq(), from(2000) to(2004)
      list year in 1/20
    egen code = seq(), from(1) block(5)
      list code in 1/20
      list code year in 1/20
	
	*- 手动等差(初始项为1，公差为2)
	clear
	set obs 100
	gen X = 1 in 1
	forvalues i = 2/100{
		replace X = 1 + (`i' - 1) * 2 in `i'
	}

  *-2.1.3.3  填充数据：fill() 函数
  
    egen r2 = fill(2 4)      // 间隔 2  的递增数列
    egen r3 = fill(6 3)      // 间隔 -3 的递减数列
    egen r4 = fill(1990 1991 1992 1990 1991 1992) // 分块重复数列
     list r2-r4 in 1/20


  *-2.1.3.4  产生组内均值和中位数
    
    sysuse nlsw88.dta, clear
    egen avg_w_r = mean(wage), by(race)
    egen med_w   = median(wage), by(race)
    list wage race avg_w_r med_w in 1/20 
    
    use xtcs.dta, clear              // 中国上市公司资本结构数据
    egen msize = mean(size),by(code) // 这样可以保证每家公司的组别一致
    sort msize
    gen gsize  = group(3)                   // 根据公司规模分组
    bysort gsize year: egen mtl = mean(tl)  // 注意 -bysort- 的使用方法
    sort gsize year
    list code year gsize tl mtl in 1/40, sep(0)
    list code year gsize tl mtl in 2500/2540, sep(0)
	
	*-应用举例
	  xtreg tl size fr ndts tobin tang, fe
	    est store full
	  xtreg tl size fr ndts tobin tang if gsize==1, fe
	    est store small
	  xtreg tl size fr ndts tobin tang if gsize==2, fe
	    est store mid
	  xtreg tl size fr ndts tobin tang if gsize==3, fe
	    est store large
	  local m "full small mid large"
	  esttab `m', mtitle(`m') s(N r2) b(%6.3f) ///
	            nogap compress
    
	*- 少一步，结果会变化！
	use xtcs.dta, clear              
    gen gsize  = group(3)                 
    bysort gsize year: egen mtl = mean(tl)  
    sort gsize year
	
	  xtreg tl size fr ndts tobin tang if gsize==1, fe
	    est store small1
	  xtreg tl size fr ndts tobin tang if gsize==2, fe
	    est store mid1
	  xtreg tl size fr ndts tobin tang if gsize==3, fe
	    est store large1
	  local m "full small mid large small1 mid1 large1"
	  esttab `m', mtitle(`m') s(N r2) b(%6.3f) ///
	            nogap compress
	
    *-说明：利用 egen 提供的函数，尚可计算组内s.d., Max, Min 等指标
   
 
  *-2.1.3.5  跨变量的比较和统计
    
    sysuse sp500.dta, clear
	
    egen avg_price = rowmean(open close)
      list open avg_price close in 1/10
      
	  replace open = int(open)
      replace close= int(close)
	egen diff = diff(open close)
      sort diff
      list open diff close in 1/10
     

  *-2.1.3.6  变量的标准化
  
    *-定义：x_s = (x - x_m) / x_sd
      *-x_s 的均值将为 0； 标准差将为 1
      *-线性转换，并不改变变量间的相对大小
	  
	sysuse sp500.dta, clear  
    egen s_change1 = std(change)
    egen s_change2 = std(change), mean(20) std(3)
    sum change s_change*


  *-2.1.3.7  变量的平滑化（Moving Average）     
      
    sysuse sp500, clear
    tsset date
      egen mv3_open        = ma(open)
      egen mv5_open        = ma(open), t(5)
      egen mv5_open_nomiss = ma(open), t(5) nomiss
    list *open* in 1/10
    dis (1320.28+1283.27+1347.56)/3  // 第一个观察值
    dis (1320.28+1283.27+1347.56+1333.34)/4  // 第二个观察值
    dis (1320.28+1283.27+1347.56+1333.34+1298.35)/5  // 第三个观察值
   


*----------------------
*-2.3 重复样本值的处理
*----------------------

  *-类别变量中样本的重复非常普遍，也具有特殊的含义
  *-连续变量中的重复样本往往因为资料谬误所致
  
  
       *     ==本节目录==  
       
	   *     2.3.1 检查重复的样本组
	   *     2.3.2 标记和删除重复的样本组合
  


*___________________________
*-2.3.1 检查重复的样本组合

    sysuse nlsw88.dta, clear
    
  *-isid- 命令   学号和姓名
    isid race age
    isid idcode
	
  *-duplicates list- 命令
    duplicates list race married in 1/20

  *-duplicates report- 命令
    duplicates report race
    duplicates report race married
    duplicates report race married occupation

  *-duplicates example- 命令
    duplicates example race married
    tab race married

  *- distinct 报告非重复组别个数
    distinct race married
	
*_________________________________
*-2.3.2 标记和删除重复的样本组合

  *-标记重复的样本组合   
    
    *-使用 group() 函数
	
      sysuse nlsw88.dta, clear
	  
      egen rm = group(race married)
       tab rm, gen(dum_rm)  // 可以进一步用此变量创造虚拟变量
	   
      egen rm_lb = group(race married), label
       label list rm_lb
       list rm rm_lb in 1/10
       browse race married rm_lb rm
       
    *-使用 tag() 函数，第一个非重复样本为1，其他为零
	
      egen rm_tag = tag(race married) 
       list rm* in 1/20
       
    *-使用 -duplicates tag- 命令
	
      duplicates tag race married, gen(rm_dtag) //重复值的个数
       list rm* in 1/20
       
       
  *-删除重复的样本组合     
    
    duplicates drop race married, force

  *- 对于常见的面板数据，可以通过 duplicates drop stkcd yaer, force 删除重复



*------------------
*-2.4 缺漏值的处理 
*------------------
  
  *     ==本节目录== 
  
  *     2.4.1 缺漏值简介 
  *     2.4.2 缺漏值的标记
  *     2.4.3 查找/删除缺漏值
  *         2.4.3.1 缺漏值的形态
  *         2.4.3.2 删除缺漏值	
  *     2.4.4 填补空缺(gap) 
  
  
*__________________  
*-2.4.1 缺漏值简介 
  
  help missing
  
  *- "." 大于任何自然数 
  
  sysuse auto, clear
    sort rep78
    list rep78
  sum rep78 if rep78>4   // obs=11
  count if rep78>4       // obs=16, why?
  keep  if rep78>4
  list rep78
  
  *-说明：
    *-有些命令，如 sum, regress, generate 等，会自动忽略缺漏值；
    *-有些命令，如 count, keep 等，则会将 "." 视为一个无穷大的数值
    *-使用过程重要特别注意
  

*_____________________  
*-2.4.2 缺漏值的标记

  *-数值型缺漏值
    shellout d_miss.txt
    insheet using d_miss.txt, clear
	sum
    mvdecode x1, mv(-97)  // 重新定义某个变量的缺漏值
	list
	sum
	insheet using d_miss.txt, clear
	mvdecode _all, mv(-97 -999)
    sum
	
     
  *-文字型缺漏值
    type d201.txt
    insheet using d201.txt, clear
    replace x1 = .   if x1== "N/A"  // 错误方式
    replace x1 ="."  if x1== "N/A"
	des
    gen x1_new = real(x1)


*________________________  
*-2.4.3 查找/删除缺漏值       -misstable-  stata11新增功能
 
  *-2.4.3.1 缺漏值的形态
 
    *-最简单的命令: -summarize-
      sysuse nlsw88.dta, clear
      sum
 
    *-misstable summarize-命令：缺漏值的基本统计
      sysuse nlsw88.dta, clear
	  misstable summarize       // 所有变量
      misstable sum age-union   // 指定变量
	
	*-缺失值比例
	  misstable tree age
	  misstable tree union
	  sum age union
	  dis "union变量缺失值比例=" (_N-1878)/_N
      
  *-2.4.3.2 删除缺漏值	
	
    *-rmiss()函数 
	  sysuse nlsw88.dta, clear
      egen miss = rmiss(wage industry occupation)		// 2101
      list wage industry occupation miss if mis!=0  
      drop if miss!=0
 
    *-missing()函数 
      sysuse nlsw88.dta, clear
      sum
      drop if missing(grade,indus,occup,union,hours,tenure)
      sum
	  
    *-另一种巧妙的方法 -regress- 命令
	
      sysuse nlsw88.dta, clear
      sum
	  
      reg wage industry occup tenure hours

      sum wage industry occup tenure hours if e(sample)
	  keep if e(sample)
      
  

*_____________________  
*-2.4.4 填补空缺(gap)

  * 对于Panel Data或一些特殊的资料，可采用前向或后向非缺漏值填补
  * http://www.stata.com/support/faqs/data/missing.html
  
  * case1: 单一缺漏值之填补
    use d_miss01.dta, clear
    list
    sort t
    replace x = x[_n-1] if x==. 
    list
    
    use d_miss01.dta, clear
    list
    sort t
    replace x = x[_n+1] if missing(x)  // help missing()
    list
 
  * case2: 多个缺漏值之填补
    use d_miss02.dta, clear
    list
    sort t
    replace x = x[_n-1] if mi(x)  
    list
      
  * case3: Panel Data缺漏值之填补
    use d_miss03.dta, clear
    list , sep(4)    
    xtset id year
    by id: replace x = L.x if mi(x)	  // L.x 等价于 x[_n-1]
    list, sep(4)    
    
    
*-进一步阅读的资料：
  *
  *[1] How can I drop spells of missing values at 
  *    the beginning and end of panel data? 
   view browse http://www.stata.com/support/faqs/data/dropmiss.html
  *[2] How can I replace missing values with previous or 
  *    following nonmissing values or within sequences?
   view browse http://www.stata.com/support/faqs/data/missing.html




*------------------
*-2.5 离群值的处理  
*------------------
  
  *     ==本节目录== 
  
  *     2.5.1 离群值的影响
  *     2.5.2 查找离群值
  *     2.5.3 离群值的处理
  *         2.5.3.1 删除
  *         2.5.3.2 对数转换
  *         2.5.3.3 缩尾处理
  *         2.5.3.4 截尾处理  

 
*_____________________
*-2.5.1 离群值的影响
    
    *-例：离群值对回归结果的影响
	
      sysuse auto, clear
      histogram price
      count if price>13000

      reg price weight length foreign
       est store r1
      reg price weight length foreign if price<13000
       est store r2
	   
      esttab r1 r2, mtitle("with" "without")
	  
    *-结论：虽然离群值只有4个，但对回归结果的影响却很大


*___________________
*-2.5.2 查找离群值
  
    *                  -------------    
    *                     基本概念
    *                  -------------
	*
    * 第25、50、75百分位上的数值分别称为第1、2、3四分位
    * 四分位间距(interquartile range): iqr = p75-p25
    * 上界(upper adjacent) = p75 + 1.5*iqr
    * 下界(lower adjacent) = p25 - 1.5*iqr
    *------------------------------------------------
    
    *-adjacent- 命令
      sysuse auto, clear
      adjacent price
      adjacent price, by(foreign)

	  
    *-箱形图
      help graph box
      graph box price
      graph box price, by(foreign)
      graph box weight, by(foreign)


	  
*_____________________
*-2.5.3 离群值的处理

    *-2.5.3.1 删除
	
      sysuse auto, clear
      adjacent price, by(foreign) 
      drop if (price>8814&foreign==0) | (price>9735&foreign==1)
	  
  
    *-2.5.3.2 对数转换
	
      sysuse nlsw88, clear
      gen ln_wage = ln(wage)
	  
      twoway (histogram wage,color(green))      ///
             (histogram ln_wage,color(yellow))
			 
      sum wage ln_wage, d
	  
      graph box wage
      graph box ln_wage
	  

    *-2.5.3.3 缩尾处理
	
      sysuse nlsw88.dta, clear
      histogram wage
	  
      *-双边缩尾
        winsor wage, gen(wage_w2) p(0.025)
		
		*-图示
        twoway (histogram wage,color(green))      ///
               (histogram wage_w2,color(yellow)), ///
               legend(label(1 "wage") label(2 "wage_winsor2")) 
			   
      *-单边缩尾
        winsor wage, gen(wage_h) p(0.025) highonly
		*-图示
        twoway (histogram wage,color(green))      ///
               (histogram wage_h,color(yellow)),  ///
               legend(label(1 "wage") label(2 "wage_winsorH"))
		
		
      *-更自由的缩尾方式：
	    
		_pctile wage, percentile(5 10)
		replace wage = r(r1) if wage < r(r1)
		replace wage = r(r2) if wage > r(r2)
		// winsor 也同样可以实现，但较为麻烦
       
	
    *-2.5.3.4 截尾处理
	
      sysuse nlsw88, clear
      _pctile wage, percentile(1 99)
      return list
      drop if wage<r(r1)  // 删除小于第1百分位的样本
      drop if wage>r(r2)  // 删除大于第99百分位的样本
      
      *-说明：
      * (1) 可以先绘制直方图，进而根据分布情况选择左截尾、
	  *     右截尾还是双边截尾
      * (2) 相比于ln()处理和winsor处理，该处理会损失样本
      *     但对于大样本而言，该方法比较“干净”



*----------------------
*-2.6 数据的合并和追加           
*----------------------
  
  *     ==本节目录== 
  
  *     2.6.1 横向合并：增加变量   
  *         2.6.1.1 一对一合并 
  *         2.6.1.2 多对一合并 
  *         2.6.1.3 一对多合并 
  *         2.6.1.4 自我检测	
  *     2.6.2 纵向合并：追加样本  	
  *     2.6.4 大型数据的处理



*____________________________ 
*-2.6.1 横向合并：增加变量        -merge-

  *-2.6.1.1 一对一合并  [ 1:1 ]
  
    *-待合并的数据
      use merge_u.dta, clear
      browse
      use merge_m.dta, clear
      browse
	  
	*-合并方法：
	  use merge_m.dta, clear
	  merge 1:1 date using merge_u
      
    *- _merge 变量的含义：
    *
    *  _merge==1  obs. from master data                            
    *  _merge==2  obs. from only one using dataset                 
    *  _merge==3  obs. from at least two datasets, master or using
	
	*-其它选项
	
	   help merge
	   
	   *-keepusing(varlist) 选项 (仅合并部分数据)
	     use merge_m.dta, clear
		 merge 1:1 date using merge_u, keepusing(close)
	   
	   *-generate() 选项 v.s. nogenerate 选项
	     use merge_m.dta, clear
		 merge 1:1 date using merge_u, gen(m1)
		 
	   *-nolabel, nonotes 选项 (不拷贝被合并数据的"数字-文字对应表")
		 
	   *-update 选项 (更新主数据集中的缺漏值)
	     *-问题
		 use merge_u.dta, clear
           browse
		 use merge_m.dta, clear
		   gen close = . // merge_u.dta 中也有该变量，但取值不同
		   browse
		 *-合并方法  
	     merge 1:1 date using merge_u, update
		   browse
		   
	   *-replace 选项 ()
	     use merge_m.dta, clear
		   gen close = 0 // 注意，此例中 close=0
		   browse
	     merge 1:1 date using merge_u, update  
		   browse	     // close=0 并未发生变化
		 
		   drop _merge
		 merge 1:1 date using merge_u, update replace // 正确做法
		   browse

		   
  *-2.6.1.2 多对一合并  [ m:1 ]
	
	*-数据形态
	  use GTA_FS.dta,clear     // 上市公司财务资料
          browse 
      use GTA_basic.dta,clear  // 上市公司基本资料,只有 id 没有 year
          browse 
	
	*-合并方法
	  use GTA_FS.dta, clear
	  merge m:1 id using GTA_basic.dta, nogen
	  
		   
  *-2.6.1.3 一对多合并  [ 1:m ] 
  
     // 其实就是 m:1 的逆向操作
	
	*-数据形态
	  use GTA_FS.dta,clear     // 上市公司财务资料
          browse 
      use GTA_basic.dta,clear  // 上市公司基本资料,只有 id 没有 year
          browse 
	
	*-合并方法
	  use GTA_basic.dta, clear
	  merge 1:m id using GTA_FS.dta, nogen
	  
	  
  *-2.6.1.4 自我检测
  
    *-数据形态：
	
      use GTA_FS.dta,clear     // 上市公司财务资料
          browse 
      use GTA_GC.dta,clear     // 上市公司治理结构信息
          browse 
      use GTA_div.dta,clear    // 上市公司股利分配、增发配股
          browse 
      use GTA_basic.dta,clear  // 上市公司基本资料,只有 id 没有 year
          browse
      
    *-合并上述数据
    
      *-基本思路：
      * (1) 先根据 id year 把前三个数据一次性合并起来；[1:1]
      * (2) 再根据 id      把GTA_basic数据合并进来     [m:1]
	  
      use GTA_FS.dta, clear
      merge 1:1 id year using GTA_GC.dta , nogen
	  merge 1:1 id year using GTA_div.dta, nogen
      merge m:1 id      using GTA_basic, nogen   

      tsset id year   
      save GTA_merge.dta, replace    // 保存合并后的数据 

       
    
*__________________________ 
*-2.6.2 纵向合并：追加样本      -append-
   
   *-两个数据库中的"同名变量"会自动对应累叠
   
   *-数据形态
     use append_m.dta, clear
         browse
		 tsset date
     use append_u.dta, clear
         browse
		 tsset date
 
     use append_m.dta, clear
     append using append_u.dta
         browse
		 tsset date
		 
   *-generate() 选项
     use append_m.dta, clear
     append using append_u.dta, gen(append_id)
	     browse
		 
   *-nolabel, nonotes 选项
     
   *- 几个注意事项：
   *  (1) 两个数据库中的变量名称要相同
   *      PRICE 和 price 是不同的变量
   *  (2) 两个数据库中的同名变量要具有相同的存储类型
   *      同为文字变量或同为数值变量		
	
	

*------------------
*-2.7 长宽数据转换
*------------------
  
  *     ==本节目录== 
  
  *     2.7.1 数据的长宽转换 

*_______________________
*-2.7.1 数据的长宽转换      -reshape-

  *- 问题描述
     shellout reshape0.txt  // -xpose- 命令不奏效
     
  *- wide --> long
     use reshape1.dta, clear
     list
     reshape long inc ue, i(id) j(year) // sex 不发生变化，无需转换
                                        // j() 选项中填写新的变量名称
     list, sepby(id)
     replace year = real("19" + string(year))
     list, sepby(id)
     
  *- long --> wide
     reshape wide inc ue, i(id) j(year)
        
*-示例：
*-World Development Indicator 转换
 view browse ///
    http://dss.princeton.edu/online_help/analysis/reshape_wdi.htm
 
*-进一步的参考资料
 view browse ///
    http://www.stata.com/support/faqs/data/reshape3.html#



*--------------------
*-2.8 文字变量的处理
*--------------------
  
  *     ==本节目录== 
  
  *     2.8.1 将文字转换为数字
  *         2.8.1.1 以文字类型存储的数字之转换 
  *         2.8.1.2 纯文字类别变量之转换 
  *     2.8.2 将数字转换成文字
  *     2.8.3 文字样本值的分解
  *     2.8.4 处理文字的函数
  *         2.8.4.1 文字函数简介
  *         2.8.4.2 例-1-：上市公司日期、行业代码和所在地的处理
  *         2.8.4.3 例-2-：处理不规则的日期


*__________________________
*-2.8.1  将文字转换为数字

  *-2.8.1.1 以文字类型存储的数字之转换      -destring-

    *- 说明：
    *-   从 .txt 文档中读入数值变量之所以会以文字值方式存储，
    *-   主要原因是变量中可能包含了如下特殊符号：
    *-   金额`$'、逗号`,'、斜线`/'、百分比`%'、破折号`-'
  
    use d202.dta, replace
    des
    sum

    *-说明：虽然 code 变量由数字组成，但其类型为 str7,即为文字型变量
    *       leverage, size, date 都存在类似的问题
	
    use d202.dta, clear
    destring code,  gen(code1) ignore(" ")  
    destring leverage, gen(lev) percent
    destring year date size lev, replace ignore("-/,%")
    

  *-2.8.1.2 纯文字类别变量之转换       -encode-, -rdecode-
  
    use d202.dta, clear
    encode gov, gen(gov1)
    labelbook
	
    *-说明：
	*
    *- encode 命令会自动根据文字类别编号，
	*         并设定相应的[数字-文字对应表]
	*
    *  [数字-文字对应表] 按“字母顺序排列” 
                 sysuse auto, clear
                 encode make, gen(make_num)
                 order make make_num
                 labelbook
				 
    *_Q: 如何根据出现的先后顺序设定[数字-文字对应表]? [-sdecode-]  
	
    *- 缺陷：
	*  (1) 没有 -replace- 选项                        [-rdecode-]
    *  (2) 每次只能转换一个变量，无法实现批量转换     [-rdecodeall-]
    *  (3) 可以借助 foreach 循环实现批量            
    
	
    *-encode 命令与 -destring- 的区别
    *
    *-(1) 若数字“误存”为文字型变量，使用-destring-命令或 real() 函数
	*
    *-(2) 若观察值均为“文字值”，则需使用-encode-命令，
    *     这些命令会自动产生【数字-文字对应表】
 
 
*_________________________
*-2.8.2 将数字转换成文字

  *-某些情况下，先把数字转换成文字，
  *-然后利用处理文字的函数进行处理比较方便
        
  *-eg01：年月日的组合
  
    use tostring.dta, clear
    tostring year day, replace
    gen date = year + "-" + month + "-" + day
    gen edate = date(date, "YMD")
    format edate %td
    browse
   
   
  *-eg02：年月日的分离
  
    use tostring2.dta, clear
    browse
    tostring date_pub, gen(date1)
    gen year  = substr(date1, 1, 4)
    gen month = substr(date1, 5, 2)
    gen day   = substr(date1, 7, 2)
    browse
    destring year month day, replace
    browse   
  
 
*_________________________
*-2.8.3  文字样本值的分解

    use d202.dta,clear
    list
    
  *-从 year 变量中提取年份   -split-
    split year, parse(-)
    order year year1 year2
    list
    browse
    gen year3 = real(year1)   // year1中全为数值，但以文字型存储
	
    * destring year1, replace // 另一种方式

  *-从 date 变量中提取年份、月度和日期,并转化为数值
    split date,parse(/) destring ignore("/") 
    order date date*
    

*_________________________
*-2.8.4  处理文字的函数

    help string functions

  *-2.8.4.1 文字函数简介
  
    dis lower("AbCDef")
    dis length("price  weight length   mpg") 
    dis wordcount("price  weight length   mpg") //统计变量的个数
    dis proper("mR. joHn a. sMitH")   // 规整人名
    dis strmatch("C51", "C")
    dis strmatch("C51", "C*")         // 寻找制造业公司
    dis  trim(" I love    STATA  ")   // 去掉两端的空格
    dis ltrim(" I love    STATA  ")   // 去掉左边的空格 
    dis rtrim(" I love    STATA  ")   // 去掉右边的空格       
    dis itrim(" I love    STATA  ")   // 去掉中间的空格             
    dis itrim("内  蒙   古 自治区")   // 去掉中间的空格，不奏效？
	help itrim()
    dis subinstr("内    蒙 古 自治区", " ", "", .)
   *-释义：
   *  subinstr(s, s1, s2, n)
   *  s   原始字符串
   *  s1 “将被替换”的字符串
   *  s2 “替换成”的字符串
   *  n   前n个出现的目标字符，若为“.”则表示全部替换
    dis subinstr("内 蒙 古 自治区", " ", "", 1)
	dis subinstr("内 蒙 古 自治区", " ", "", 2)
   
   *-说明：上述函数都可以用于 -generate- 命令来生成新的变量
       
 
  *-2.8.4.2 例-1-：上市公司日期、行业代码和所在地的处理
  
    *-a 待处理的数据
      use d203.dta, clear
	  browse

    *-b 从date中分离出年、月、日
	  tostring date, replace
      gen year  = real(substr(date,1,4))
      gen month = real(substr(date,5,2))
      gen day   = real(substr(date,7,2))
      browse
   
      *-更为简洁的命令
        use d203.dta, clear
		gen sdate1 = string(date)
        gen sdate2 = string(date,"%10.0g")  // help string()
        gen year  = real(substr(string(date,"%10.0g"), 1, 4))
        gen month = real(substr(string(date,"%10.0g"), 5, 2))
        gen day   = real(substr(string(date,"%10.0g"), 7, 2))
        browse
        drop sdate*

    *-c 从行业大类sic中分离出行业门类
      gen sic_men0 = substr(sic,1,1)
      encode sic_men0, gen(sic_men)
      tab sic_men
      label list sic_men

    *-d 从地点中分离出省份和城市
      use d203.dta,clear
      list
      gen province1 = substr(location, 1,2)
      gen city1     = substr(location, 4,4)
      list location province1 city1
      gen province2 = word(location, 1)
      gen city2     = word(location, 2)
      list location province1 city1 province2 city2    

  
  *-2.8.4.3 例-2-：处理不规则的日期
  
    *- regexm(), regexs(), regexr() 函数  
  
    help regexm()
  
    *-示例：处理不规则的日期
      clear
      input str18 date
          20jan2007 
          16June06
          06sept1985
          21june04
          4july90
          9jan1999
          6aug99
          19august2003
      end
	  
    *-如何规整之？
      gen day   = regexs(0) if regexm(date, "^[0-9]*")
      gen month = regexs(0) if regexm(date, "[a-zA-Z]+")
      gen year  = regexs(0) if regexm(date, "[0-9]*$")
      browse
      replace year = "20"+regexs(0) if regexm(year, "^[0][0-9]$")
      replace year = "19"+regexs(0) if regexm(year, "^[1-9][0-9]$")
      gen date2 = day+month+year
      browse
	  
    *-释义：
    * (1) "^[0-9]+"  
    *      ^ 表示字符串的开头部分
    *      [0-9] 表示属于自然数0-9的任何一个
    *      + 表示有至少一个对象符合匹配条件(*任何一个；?只有一个)
    * (2) "[a-zA-Z]+"
    *     [a-zA-Z] 表示阿拉伯字母中的a-z或A-Z
    * (3) "[0-9]*$"
    *     $ 表示字符串的结尾部分
  
 * 符号含义
   view browse https://blog.csdn.net/weixin_44411569/article/details/98959198
   
 *-更多示例：(1) 如何从地址中提取“邮编”？
 *           (2) 如何规整人名？
   view browse http://www.ats.ucla.edu/stat/stata/faq/regex.htm  
   view browse http://www.stata.com/support/faqs/data/regex.html



*---------------------
*-2.9 类别变量的分析
*---------------------
  
  *     ==本节目录== 
  
  *     2.9.1 类别数的统计
  *     2.9.2 分组统计量
  *         2.9.2.1 单层分组统计量 
  *         2.9.2.2 二层次和三层次分组统计量
  *         2.9.2.3 多层次分组统计量
  *     2.9.3 计算分组统计量的其它方法
  *         2.9.3.1 -egen-命令
  *         2.9.3.2 转换原资料为分组统计量：-collapse-命令
  *     2.9.4 图示分组统计量
  *         2.9.4.1 柱状图
  *         2.9.4.2 箱形图


*______________________
*-2.9.1  类别数的统计
  
  *-简单方法：-tab- 命令
  
    sysuse nlsw88, clear
    tab race
    tab occupation  // 局限：无法直接看到类别数目
    
	
  *-统计非重复值的个数
  
    distinct occupation
    ret list
    distinct married race
    distinct married race, joint  // 组合个数
    distinct married race occupation, joint
  
    
*__________________
*-2.9.2 分组统计量
  
  *-2.9.2.1  单层分组统计量 
    
    *-bysort,sum
      sysuse nlsw88.dta,clear
      bysort race: sum wage

    *-tabstat 命令
      tabstat wage, by(race) stat(mean sd med min max) 
            
    *-tabulate 命令
      tabulate industry
      tab industry, sort    // 可简写为 -tab-
      tab industry, summarize(wage) 


  *-2.9.2.2  二层次和三层次分组统计量
    
    bysort race married: sum wage
    bysort race married: tabstat wage,   ///
           by(union) s(n mean sd p50 min max)
    tabstat wage, by(race married union)  ///
           s(n mean sd p50 min max) // 错误方式
    bysort race married: tab union, sum(wage)


  *-2.9.2.3  多层次分组统计量
    
    *-基本架构：table var1 var2 var3, by(var4) contents(...)
    
    table race married union,       ///
          by(collgrad) c(mean wage) format(%4.2f)
    table race married union,       ///
          by(collgrad) c(mean wage freq) format(%4.2f)


*_________________________________
*-2.9.3  计算分组统计量的其它方法

  *-2.9.3.1 egen 命令
  
    bysort industry: egen wage_ind = mean(wage)
	bysort industry: egen wage_mid = median(wage)
    bysort industry: egen wage_p50 = pctile(wage), p(50)
    list wage indust wage_ind wage_p50 wage_mid in 1/30

	
  *-2.9.3.2 转换原资料为分组统计量：collapse 命令
  
    help collapse
    
    *-语法：collapse (统计量1) 新变量名=原变量名 (统计量2) ...
    
    sysuse nlsw88.dta,clear
    collapse (mean)  wage hours          ///
	         (count) n_w=wage n_h=hours, ///
	          by(industry)
    browse
    
    sysuse nlsw88.dta,clear
    collapse (mean)  wage hours          ///
	         (count) n_w=wage n_h=hours, ///
	          by(industry race) 
    browse
    
    * 几点说明：
    *   (1) 经常保存do文档，但不要轻易选择保存数据文件
    *   (2) by() 选项是必填选项，不可省略
    
    * collapse 后，原始变量的标签会丢失，处理方法如下：
      view browse ///
	  "http://www.stata.com/support/faqs/data/variables.html#"


	  
*________________________
*-2.9.4  图示分组统计量

  *-2.9.4.1 柱状图
  
    *-纵向柱状图
      sysuse nlsw88.dta, clear
      graph bar (mean) wage, over(smsa) over(married) over(collgrad)
	  *- 说明：over() 选项的呈现顺序是从内到外

    *-横向柱状图
      graph hbar (mean) hours, over(union) over(industry)
      *-note：over() 选项的顺序决定了分组的层次关系，
      graph hbar (mean) hours, over(union) over(industry) asyvars 
	                 //asyvars-把第一个over()选项中的变量放入图中
      graph hbar (mean) hours, over(union) over(married)  ///
                               over(race) percent asyvars
						   
    *-多变量柱状图
      graph bar wage hours, over(race) over(married)
      graph bar wage hours, over(race) over(married) stack
	  
      *-over() 选项的子选项
        graph bar wage hours, stack                       ///
          over(race, relabel(1 "白人" 2 "黑人" 3 "其他")) ///
          over(married, relabel(1 "单身" 2 "已婚"))       ///
          legend(label(1 "工资水平") label(2 "工作时数")) 


  *-2.9.4.2  箱形图

    *-箱形图能较清晰的呈现各组样本值的分布情况              
    
	  sysuse nlsw88, clear
      
	  graph box wage,  over(race)
      graph box hours, over(race) over(married)
      graph box hours, over(race) over(married) nooutsides






























