## 3.1 虚拟变量分析

对于虚拟变量，往往可以采用分组统计的方法来展示它的一些特征。

### 3.1.1 分组统计量

- 一维分组统计量

  ```stata
  *- 通过组合 by 与 sum 完成对数据的描述
  sysuse auto.dta, clear
  by foreign: sum price
  
  // 等价于
  sum price if foreign == 0
  sum price if foreign == 1
  
  *- 通过 tabstat
  tabstat price, by(foreign) stat(mean sd med min max)
  
  *- 通过 tabulate
  sysuse auto.dta, clear
  tabulate foreign
  
  sysuse nlsw88.dta, clear
  tab occupation
  tab occupation, sort
  tab occupation, summarize(wage)
  ```

* 二维和三维分组统计量

  ```stata
  sysuse nlsw88.dta, clear
  bysort race married: sum wage
  
  bysort race married: tabstat wage, by(union) s(n mean sd p50 min max)
  
  tabstat wage, by(race married union) s(n mean sd p50 min max) // 错误方式
  
  bysort race married: tab union, sum(wage)
  ```

- 四维分组统计量

  ```stata
  *- 利用 table
  sysuse nlsw88.dta, clear
  table race married union, by(collgrad) c(mean age) format(%4.2f)
  
  table union race married, by(collgrad) c(mean wage freq) format(%4.2f)	
  
  // 基本规律
  // by() 中的变量与 table 后的第一个变量联合为表的左上角
  // 表的第一列为 by() 中的变量分类与 table 后第一个变量的组合
  // 表的第一行中从第二列开始为 table 后的第二三个变量的分类组合
  ```

### 3.1.2 通过其他方式生成分组统计量

- `egen` 在分组统计时的表现

  ```stata
  sysuse nlsw88.dta, clear
  
  *- 计算不同人种的工资均值
  bys race: egen Meanwage = mean(wage)	
  
  *- 计算不同人种的工资中位数
  bys race: egen Midwage1 = median(wage)
  bys race: egen Midwage2 = pctile(wage), p(50)
  
  *- 计算不同人种的工资标准差
  bys race: egen SDwage = sd(wage)
  
  preserve
      duplicates drop race, force
      drop wage
      list race *wage*
  restore 
  ```

- 通过 `collapse` 命令

  需要注意的是，`collapse` 命令会改变数据框中的数据，使用前需要先备份当前数据。

  ```stata
  *- 计算国产车与非国产车价格均值与生产商个数
  sysuse auto.dta, clear
  collapse (mean) Meanprice=price (count) Nummake=make, by(foreign) // 错误用法，有文字
  
  
  sysuse auto.dta, clear
  encode make, gen(Make) // 将文字转为带标签的变量
  collapse (mean) price (count) Make, by(foreign)
  
  *- 自定义生成变量的名称
  sysuse auto.dta, clear
  encode make, gen(Make)
  collapse (mean) Meanprice=price (count) NumMake=Make, by(foreign)
  
  // 使用后需要重新导入一次数据
  // 如仅仅想作图，则可以配合 preserve 与 restore 使用
  // preserve 与 restore 可以不改变当前数据
  *- 例如
  sysuse auto.dta, clear 
  
  preserve
      encode make, gen(Make)
      collapse (mean) Meanprice=price (count) NumMake=Make, by(foreign)
      egen STDprice = std(Meanprice), mean(0) std(1)
      egen STDnum = std(NumMake), mean(0) std(1)
      twoway (scatter STDprice foreign, color(blue)) ///
             (scatter STDnum foreign, color(red))
  restore
  ```

### 3.1.3 图示分组统计量

- 绘制柱状图

  ```stata
  sysuse nlsw88.dta, clear
  graph bar (median) wage, over(race) over(married) over(collgrad)
  
  *- 改变柱状图方向（横向柱状图）
  graph hbar (median) wage, over(race) over(married) over(collgrad)
  graph hbar (median) wage, over(race) over(married)
  graph hbar (median) wage, over(race)
  graph hbar (median) wage, over(race) over(married) over(union)
  // 最多允许 3 个 over()
  ```

- 增加更多变量

  ```stata
  sysuse nlsw88.dta, clear
  graph hbar (mean) wage (median) age, over(race) over(married)
  graph hbar wage age, over(race) over(married) stack
  
  *- 改变图中的标签
  graph hbar wage age, over(race, relabel(1 "白人" 2 "黑人" 3 "其他")) ///
                       over(married, relabel(1 "单身" 2 "已婚")) ///
                       legend(label(1 "工资水平") label(2 "年龄")) 
  ```

- 绘制箱型图

  ```stata
  sysuse nlsw88.dta, clear
  
  graph box wage,  over(race)
  graph box age, over(race) over(married)
  graph box age, over(race) over(married) over(union)
  graph box age, over(race) over(married) over(union) nooutsides		
  ```

## 3.2 连续变量分析

### 3.2.1 描述性统计与结果导出-`sum2docx`

```stata
sysuse auto.dta, clear

rename price 		价格
rename headroom 	头顶空间
rename length 		车长
rename weight		车重

local Variables 价格 头顶空间 车长 车重
sum2docx `Variables' using 描述性统计表.docx,	///
         replace stats(N mean sd median p25 p75 min max) ///
         title("描述性统计表1") font("宋体",12,"black") ///
         pagesize(A4)

sum2docx `Variables' using 描述性统计表.docx,	///
         replace stats(N mean sd median p25 p75 min max) ///
         landscape title("描述性统计表2") font("宋体",12,"black") ///
         pagesize(A4)

// landscape - 设置横向页面
```

### 3.2.2 相关性分析与结果导出-`corr2docx`

```stata
sysuse auto.dta, clear

rename price 		价格
rename headroom 	头顶空间
rename length 		车长
rename weight		车重

local Variables 价格 头顶空间 车长 车重
corr2docx `Variables' using 相关系数矩阵.docx, ///  
          replace fmt(%9.3f) title("相关系数矩阵") ///
          font("宋体",12,"black") star pagesize(A4) landscape ///    
          note("注：*** p<0.01, ** p<0.05, * p<0.1") 

// 左下角为 Pearson 相关系数，右上角为 Spearman 相关系数
```
