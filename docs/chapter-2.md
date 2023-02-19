## 2.1 数据的导入导出

### 2.1.1 导入-读入数据

常见的数据，这里以 `csv` 格式、`xls`，以及 `xlsx` 为主，介绍利用代码导入的方式。而对于其余格式的数据，可以通过菜单中的 `文件👉导入` 按操作实现。

- `csv` 格式数据

  ```stata
  *- 语法格式
  import delimited [using] filename [, import_delimited_options]
  *- 实例
  import delimited using "E:\data\csvfile.csv", clear
  ```

  一般常用的 `[, import_delimited_options]` 部分只有 `clear` 选项，该选项意味着清除 `Stata` 中的数据，并以新导入的数据覆盖原有的数据框。`注意：` 导入新数据前，务必将已有数据做好备份。

- `xls` 或者 `xlsx` 格式数据

  ```stata
  *- 语法格式
  import excel [using] filename [, import_excel_options]
  *- 实例
  import excel using "E:\data\xlsfile.xls", clear
  import excel using "E:\data\xlsxfile.xlsx", clear
  ```

### 2.1.2 导出-存储数据

一般来说我们选择以 `.dta` 格式的文件存储数据。因为后续的一些合并操作都需要先将数据转换为该格式，所以在读入数据并进行简单清洗操作后，我们需要将目前 `Stata` 数据框的文件另存为 `.dta` 文件，代码如下。

```stata
*- 语法格式
save [filename] [, save_options]
*- 实例
save data.dta, replace
```

注意 `replace` 选项的使用。第一次存储文件时，不需要使用 `replace`。当发现了该文件有一些错误，需要重新存储为该名字时，则需要加上 `replace` 选项，以替换先前的版本。`注意：` 为了养成良好的数据处理习惯，我建议大家多多备份数据。

### 2.1.3 使用 `Stata` 自带的数据

在一些特殊的情况下，比如你只想试验一下某条命令，但苦于懒得从其他平台下载数据或者导入数据，那你可以使用 `Stata` 自带的数据来帮你做一些初步的验证。

```stata
help dta_examples
```

通过该命令，你可以看到所有 `Stata` 自带的数据集。调用 `Stata` 自带的数据时，需要使用 `sysuse` 而不是 `use`，使用 `use` 则是默认调用 `.dta` 文件。

```stata
sysuse auto.dta // 调用 Stata 自带的 auto 数据集
use auto.dta // 调用当前路径下的 auto.dta 文件
```

## 2.2 变量生成

当导入数据后，在存储数据之前，我们一般会通过一些变量生成操作，或者说数据转换操作，来对导入的数据进行一些初步的处理。

### 2.2.1 `Stata` 中变量的三种颜色

你可能已经注意到，在 `Stata` 的数据框中，可能会存在三种颜色的数据。如果你一直维持默认的配色，那这三种颜色会是黑色、红色以及蓝色，它们分别对应不同类型的变量。

- 黑色：数值型变量，可以直接加减乘除
- 红色：文本型变量，可以进行文本字符运算
- 蓝色：数值-文本交叉型变量，以文本方式显示，但本质是数值型，可以直接运算

### 2.2.2 `_n` 与 `_N`

`_n` 与 `_N` 是 `Stata` 中较为特殊的存在，巧用它俩，能很好地帮助我们解决一些实际问题。

- `_n` 可以理解为样本的序列编号（1,2,...,n）
- `_N` 可以理解为样本序列编号的最大值（n）

请读者自行根据下列代码验证区别，获得更直观的理解。

```stata
* _n 与 _N 的区别
sysuse auto.dta, clear
gen var1 = _n 
gen var2 = _N 
list price var1 var2 in 1/5

sort price 
gen var3 = _n 
list var1 var3 in 1/5 // _n 随排序而发生变化

dis _n
dis _N

sum price 
dis r(N)
dis _N
```

在实际应用当中，我列举几个常用的例子，具体如下。

- 将截面数据转换为平衡面板

  ```stata
  // TextileCode 仅包括一个变量 code，具体内容为纺织行业上市公司代码
  // 因为作者本人本硕均就读于武汉纺织大学
  // 并且发表于 Journal of Cleaner Production 的论文就是纺织业数据
  // 所以这里用了纺织业的上市公司代码，但这里可以替换成任意不重复的某个行业的上市公司代码
  // 除上市公司外，该方法适用于生成任何平衡面板数据
  
  import excel using TextileCode.xls, first clear
  expand 10
  sort code
  
  by code: gen temp = _n
  by code: gen year = 2009 + temp
  
  // 等价于
  import excel using TextileCode.xls, first clear
  expand 10
  bys code: gen year = 2009 + _n
  ```

- 差分计算

  ```stata
  sysuse sp500.dta, clear //  Stata 自带的数据
  gen Dclose1 = close[_n] - close[_n-1]
  
  tsset date
  gen Dclose2 = D.close
  
  list Dclose1 Dclose2 in 1/10 // 日期不连续问题
  
  // 此处差异在处理时间序列数据时需要着重考虑
  ```

- 滞后项或提前项

  ```stata
  sysuse sp500.dta, clear
  tsset date
  
  *- 生成滞后项
  gen Lclose1 = close[_n-1]
  gen Lclose2 = L.close 
  list Lclose* in 1/10
  
  gen L2close1 = close[_n-2]
  gen L2close2 = L2.close 
  list L2close* in 1/10
  
  *- 生成提前项
  gen Fclose1 = close[_n+1]
  gen Fclose2 = F.close 
  list Fclose* in 1/10
  ```

  `注意：` 对于时间序列数据而言，尤其是股价这种非连续时间的数据，尽量通过 `Stata` 的 `L.`、`D.`，以及 `F.`  等来分别生成滞后、差分、提前项，而避免手动生成所导致的偏差。

- 计算增长率

  ```stata
  sysuse sp500.dta, clear
  tsset date
  
  gen Ratio1 = (close[_n]-close[_n-1])/close[_n-1]
  gen Ratio2 = D.close/L.close
  gen lnclose = ln(close)
  gen Ratio3 = D.lnclose
  
  list Ratio* in 1/10
  ```

  注意，`Ratio1` 与 `Ratio2` 等价，即对数差分能替代增长率，这可能是一个[等价无穷小](https://baike.baidu.com/item/等价无穷小/7796020)的关系。也可以参考如下回答：[计量经济学中为什么要对变量取对数，差分以及对数差分？](https://www.zhihu.com/question/31722222)。

- 计算移动平均

  ```stata
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
  ```

### 2.2.3 虚拟变量

`虚拟变量` 指的是分类变量，用数字来代替一些不同的类别，它们之间并不构成严格的大小关系。例如：男性取 1， 女性取 0，男女平等，所以在这种情况下 1>0 是显然不成立的。

- 使用 `generate` 与 `replace` 生成虚拟变量，注意 `generate` 可以简写为 `gen`

  ```stata
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
  ```

- 利用 `tab` 生成虚拟变量

  ```stata
  *- 将上述代码简化为
  sysuse auto.dta, clear
  tab foreign, gen(Dummy)
  ```

  注意，这是一种[独热编码(one-hot)](https://baike.baidu.com/item/独热编码?fromModule=lemma_search-box)，生成的变量是完全共线的。`注意：` `tab` 与后面介绍的 `tabstat` 是不同的命令。

- 将样本等分并产生虚拟变量

  ```stata
  sysuse auto.dta, clear
  sort price
  gen Group = group(4)
  browse price Group
  tabstat price, stat(N) by(Group) f(%4.2f)
  
  // 按照分位数分组也可达到相似效果
  sum price, detail
  return list // 查看函数运行完之后的返回值
  gen Group1 = 1 if price <= r(p25)
  replace Group1 = 2 if (price>r(p25)) & (price<=r(p50))
  replace Group1 = 3 if (price>r(p50)) & (price<=r(p75))
  replace Group1 = 4 if price>r(p75)
  tabstat price, stat(N) by(Group1) f(%4.2f)
  ```

- 按任意分位点产生虚拟变量

  ```stata
  sysuse auto.dta, clear
  _pctile price, p(1 3 6 10 34 91)
  return list 
  ```

  上述代码是生成 1、3、6、10、34、91 等分位数的值，利用 `gen` 、`replace` 以及内置的 `if` 即可任意生成虚拟变量。

- 对文本生成虚拟变量

  ```stata
  *- 这是一份包含大陆地区 34 个主要省市区名称的 dta 文件
  use MainlandChina.dta, clear
  gen Middle = inlist(province,"山西","河南","安徽","湖北","江西","湖南")
  ```

  在这个例子中，我使用了 `inlist`，它的含义是，对于变量 `province` 如果里面出现了后面这些文本值，则取 1，反之取 0。

### 2.2.4 神奇的 `egen`

`egen` 的全称是 `extensions to generate`，不难看出，它是对 `generate` 的扩充，用于实现一些神奇的功能，可以通过 `help egen` 查看 `egen` 支持的所有运算函数，这里只介绍几个常用的。

- `egen` 与 `gen` 的求和差异

  ```stata
  sysuse auto.dta, clear
  gen sumprice1 = sum(price) // 累加
  egen sumprice2 = sum(price) // 总和
  list price sumprice* in 1/10
  list price sumprice* in -1
  ```

- `egen` 与 `gen` 生成均值时的差异

  ```stata
  *- 生成数据
  clear
  set obs 10
  set seed 12345
  gen x1 = 10*runiform()
  gen x2 = 10*runiform()
  
  *- 随机缺失值，随机生成一些缺失值
  foreach v in x1 x2 {
  	replace `v' =. if mod(ceil(`v'),2) == 0
  }
  list x*
  
  *- 生成均值比较差异
  gen mean1 = (x1+x2)/2
  egen mean2 = rowmean(x1 x2)
  list x* mean*
  ```

- 生成等差数列

  ```stata
  *- 手动生成等差数列方式（初始项为1，公差为2）
  clear
  set obs 100
  set seed 12345
  gen X = 1 in 1
  forvalues i = 2/100{
  	replace X = 1 + (`i' - 1) * 2 in `i'
  }
  
  *- 尝试仿照上述方法编写等比数列计算代码
  gen Y = 1 in 1
  forvalues i = 2/100{
  	replace Y = 1 * 2^((`i' - 1)) in `i'
  }
  
  *- 利用 egen 简化
  egen Z1 = seq(), from(1)
  egen Z2 = seq(), from(1) to(199) // seq() 无法改变公差
  
  egen A1 = fill(1 3) // 可以制造任意等差
  egen A2 = fill(3 1)
  ```

- `egen` 中最常见的指标计算

  ```stata
  *- 生成均值、中位数、标准差、最小值、最大值（纵向，按变量）
  sysuse auto.dta, clear
  egen Average = mean(price), by(foreign)
  egen Median = median(price), by(foreign)
  egen StdDev = sd(price), by(foreign)
  egen Min = min(price), by(foreign) 
  egen Max = max(price), by(foreign)
  browse
  
  *- 横向对比，按样本
  egen Difference = diff(Min Max)
  egen Mean = rowmean(Min Max)
  ```

* 利用 `egen` 简化变量标准化步骤

  ```stata
  *- 手动标准化
  sysuse auto.dta, clear
  sum price 
  gen STDprice1 = (price - r(mean))/r(sd)
  sum STDprice1
  list *price in 1/10
  
  *- 通过 egen 简化实现步骤
  egen STDprice2 = std(price), mean(0) std(1)
  sum STDprice*
  list *price in 1/10
  ```

* 利用 `egen` 计算移动平均

  ```stata
  sysuse sp500.dta, clear
  tsset date
  egen MA1 = ma(close) // 默认 3 期
  egen MA2 = ma(close), t(3)
  egen MA3 = ma(close), t(3) nomiss
  list close MA* in 1/10
  
  dis (1283.27+1347.56)/2 // 第一个值
  dis (1283.27+1347.56+1333.34)/3 // 第二个值
  dis (1347.56+1333.34+1298.35)/3	// 第三个值
  // 在加入nomiss的时候，不会存在缺失值，取而代之的是 n-1 期均值
  ```

## 2.3 重复样本处理

### 2.3.1 观测是否存在重复样本

- 通过 `isid` 识别

  ```stata
  sysuse auto.dta, clear
  isid make
  isid foreign
  ```

- 通过 `duplicates` 识别

  ```stata
  sysuse auto.dta, clear
  duplicates list foreign
  duplicates report foreign
  duplicates example foreign
  ```

### 2.3.2 删除重复样本

首先需要确认删除什么样的重复样本，以最常用的上市公司面板数据而言，对于每个公司，其每年的数据应当是唯一的，所以应当以上市公司代码 `stkcd` 以及年份变量 `year` 为准，删除重复值，代码如下。

```stata
duplicates drop stkcd year, force
```

## 2.4 缺失值处理

### 2.4.1 认识不同的缺失值

在 `Stata` 中，有一些不同的缺失值表示方式，最常见的就是以 `.` 来表示变量中的缺失。通过 `help missing`，我们可以得到如下一段描述。

```stata
Stata has 27 numeric missing values:
	., the default, which is called the "system missing value" or sysmiss
and
	.a, .b, .c, ..., .z, which are called the "extended missing values".
Numeric missing values are represented by large positive values.  The ordering is
	all nonmissing numbers < . < .a < .b < ... < .z
Thus, the expression age > 60 is true if variable age is greater than 60 or
missing.
To exclude missing values, ask whether the value is less than ".".  For instance,
	. list if age > 60 & age < .
To specify missing values, ask whether the value is greater than or equal to ".".
For instance,
	. list if age >=.
Stata has one string missing value, which is denoted by "" (blank).
```

这段话的大致意思就是 `Stata` 一共有 27 种数值型变量的缺失值，以及 1 种文本型变量的缺失值。在数值型缺失值中，`.` 是默认的，对于 `.` + 26 个小写英文字母所构成的扩展缺失值，依次有一个大小关，所以如果我们在处理一些类似于个体调查问卷的时候，如果需要保留大于 60 岁的样本，则需要让年龄变量 `age` 同时小于缺失值 `.`，不然缺失值不会被剔除，并且缺失值大于所有的自然数。

### 2.4.2 判断缺失值的存在性

`注意：` 这里需要先区分一个概念，样本与变量，在 `Stata` 中，横向的一般为样本，纵向的为变量。

- 查找变量中是否有缺失值（纵向）。确定一个变量中是否存在缺失值，最好的方式就是观测该变量中的数值个数是否与样本总数一致，具体代码如下。

  ```stata
  sysuse auto.dta, clear
  sum price rep78
  dis _N
  ```

  如果描述性统计之后，`price` 的观测值为 74，`rep78` 的观测值个数为 69，样本总数为 74，所以 `rep78` 存在 5 个缺失值。同样地，也可以通过 `misstable` 命令更好地观察缺失值。

  ```stata
  sysuse auto.dta, clear
  misstable summarize // 对所有变量
  misstable sum price-length // 对指定变量
  // 该命令仅报告存在缺失的变量（不计算文本变量）
  ```

- 查找样本中是否存在缺失值（横向）。确定一个样本是否存在缺失变量。

  ```stata
  sysuse auto.dta, clear
  egen Rowmiss = rowmiss(price rep78 weight length)
  list price rep78 weight length if Rowmiss == 1
  ```

  在样本中，但凡有一个变量是缺失值，就默认该样本为缺失，并且缺失样本不参与后续回归。

### 2.4.3 处理缺失值

注意我的做法，这里与其他 `Stata` 教程直接教你均值填充不同，我会教你优先判断缺失的比例。

- 判断缺失值的比例

  首先，我们可以通过一串建议的代码判断某一个缺失值的比例，比如。

  ```stata
  sysuse auto.dta, clear
  sum
  dis "rep78变量缺失值比例=" (_N-69)/_N*100
  ```

  这个 69 是我们运行描述性统计后，变量 `rep78` 中的观测值个数，我们用样本总数减去变量的观测值数再除以样本总数并乘以 100，就能够得到改变量的缺失比例。

  接下来，我们结合之前所学习到的局部宏与 `foreach` 循环，可以批量展示变量的缺失比例，具体代码如下。

  ```stata
  sysuse auto.dta, clear
  local Variables price mpg rep78 headroom trunk weight length
  foreach v in `Variables' {
      quietly summarize `v'
      dis _skip(10) "`v'的缺失比例为=" (_N-r(N))/_N*100
  }
  ```

- 对连续变量可采用均值填补策略

  如果在上面的缺失比例判断中，比例并不是很大，个人认为缺失比例小于 30% 的情况下可以直接填充，均值填充适用于连续型变量，填充代码如下。

  ```stata
  *- 填充单个变量
  sysuse auto.dta, clear
  egen rep78mean = mean(rep78)
  replace rep78 = rep78mean if rep78 == .
  drop rep78mean
  
  *- 批量填充
  local Variables price mpg rep78
  foreach v in `Variables' {
      egen `v'mean = mean(`v')
      replace `v' = `v'mean if `v' == .
      drop `v'mean
  }
  ```

- 对分类变量或者说虚拟变量，可以通过众数填充

  ```stata
  sysuse auto.dta, clear
  replace foreign = . in 3
  replace foreign = . in 70
  tab foreign // 查看不同类别的频次
  labelbook // 查看不同类别对应的数值
  replace foreign = 0 if foreign == .
  ```

- 向前/向后填充，利用前面或者后面的值进行邻接填充

  ```stata
  *- 向后填充（上一期替代本期缺失）
  replace X = X[_n-1] if X == .
  replace Y = Y[_n-1] if Y == ""
  
  *- 向前填充（下一期替代本期缺失）
  replace X = X[_n+1] if X == .
  replace Y = Y[_n+1] if Y == ""
  
  *- 对面板数据而言，最好使用 L 与 F 
  xtset Num Year
  bys Num: replace Random = L.Random if mi(Random)
  bys Num: replace Random = F.Random if mi(Random)
  ```

  需要注意的是，对于非连续时间样本，这里的时间指的是你 `xtset Num Year` 中的时间，如果不连续，比如样本时间跨度是 2010-2021，而一家公司的数据是 2010、2011、2015、2021，中间存在一些间隔时间，在这种情况下使用 `L.` 与 `F.` 是正确的，而使用 `[_n-1]` 或者 `[_n+1]` 将会使得数据被过度填充。

## 2.5 离群值处理

### 2.5.1 什么是离群值

离群值是脱离数据群体的值，极大极小值不一定为离群值。数据群体指的是处于 (p25-1.5iqr, p75+1.5iqr) 之间的值。四分位间距（interquartile range）：iqr = p75 - p25，p25、p75 分别指处于第 1 个四分位（第 25 个百分位），p25、p50、p75 分别叫第 1、2、3 个四分位，p50 即中位数。

### 2.5.2 离群值的影响

在下面的例子中，我构造了一个叫 `tempvar` 的变量来识别该样本的 `price`变量是否为离群值，然后分别以纳入该样本与不纳入该样本的方式进行两次回归，并比较两次回归的结果。

```stata
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
```

最后在 `Stata` 界面，我们可以发现，离群值的存在会改变模型的解释。

### 2.5.3 查找离群值

- 手动编写一条查找离群值的命令

  ```stata
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
  
  // quietly 表示静悄悄地运行代码，不展示过程
  // scalar 用于存储单值，可以增加代码美观度
  // scalar dir、scalar list、scalar drop
  ```

- `adjacent` 命令展示距离上下边界（合群阈值）最近的样本值

  ```stata
  sysuse auto.dta, clear
  
  sum price, detail
  dis "下界为" r(p25)-1.5*(r(p75)-r(p25))
  dis "上界为" r(p75)+1.5*(r(p75)-r(p25))
  
  adjacent price
  sort price
  
  // 同样可以保留非极端值
  gen tempVar = 1 if price > 8814 | price < 3291
  sum tempVar
  ```

### 2.5.4 处理离群值

处理离群值的方法有很多，常见的有截尾处理、缩尾处理以及对数转换。

- 截尾处理，截尾是指将尾巴处样本直接删除或者转为缺漏值

  ```stata
  *- 通过adjacent
  sysuse auto.dta, clear
  adjacent price 
  drop if price > 8814 | price < 3291
  
  *- 通过 _pctile
  sysuse auto.dta, clear
  _pctile price, p(25 75)
  
  local Lower r(r1)-1.5*(r(r2)-r(r1))
  local Upper r(r2)+1.5*(r(r2)-r(r1))
  drop if price > `Upper' | price < `Lower'
  ```

- 缩尾处理，缩尾是指将尾巴末端处转为最后一个非极端值

  ```stata
  sysuse auto.dta, clear 
  
  *- 判断是否需要缩尾的利器，直方图
  histogram price
  
  *- 双边缩尾，对变量极大极小值同时缩尾
  winsor price, gen(price_W) p(0.05)
  
  twoway (histogram price, color(red)) (histogram price_W, color(blue)),legend(label(1 "原始数据") label(2 "缩尾后"))
  
  *- 仅对右侧缩尾
  graph box price // 目测仅需对右侧缩尾
  
  dis 12/74
  winsor price, gen(price_HW) p(0.15) highonly
  graph box price_HW
  
  *- 如果仅对左侧缩尾，则选择 lowonly 选项替换 highonly 
  twoway (histogram price, color(red)) (histogram price_HW, color(blue)), legend(label(1 "原始数据") label(2 "右侧缩尾后"))
  
  *- 通过 _pctile 任意点位缩尾
  sysuse auto.dta, clear
  
  _pctile price, p(6 94)
  gen price_ = price
  replace price_ = r(r1) if price_ < r(r1)
  replace price_ = r(r2) if price_ > r(r2)
  
  twoway (histogram price, color(red)) (histogram price_, color(blue)), legend(label(1 "原始数据") label(2 "任意缩尾后"))
  ```

- 对数转换，使数据分布更加合理

  ```stata
  sysuse auto.dta, clear
  expand 2
  gen temp = 1 in 1/74
  replace temp = 0 if temp == .
  gen lnprice = ln(price) if temp == 0
  replace lnprice = price if temp == 1
  replace lnprice = lnprice/1000 if temp == 1
  
  graph box lnprice, by(temp)
  ```

## 2.6 数据的合并与追加

- 横向合并，即增加变量，相当于 `Excel` 的 `VLOOKUP`

  ```stata
  *- 一对一合并（1：1）
      *- Data1 
      * make var1
      * AA 2
      * BB 3
  
      *- Data2
      * make var2
      * AA 5
      * BB 6
  
      *- 观察 Data1 与 Data2 可知，两份数据中 make 都是唯一对应一条样本的，所以以 make 为关键词
      use Data1.dta, clear
      merge 1:1 make using Data2.dta
  
      *- 合并后
      * make var1 var2
      * AA 2 5
      * BB 3 6
  
      // 注意，该方法可应用于面板对面板的合并，比如以 stkcd 以及 year 为关键词分别对应唯一的样本
  
  *- 此时会新生成一个 _merge 变量，含义如下：
      *- _merge==1  observation appeared in master only                           
      *- _merge==2  observation appeared in using only               
      *- _merge==3  observation appeared in both
  
  * 多对一合并（m：1）
      *- 多见于面板数据，把财务面板数据与企业基本信息合并等
      *- Data3 为企业的面板数据，数据大致如下
      * stkcd year
      * 1	2001
      * 1 2002
      * 2 2001
      * 2 2002
  
      *- Data4 为企业的基本信息，数据大致如下
      * stkcd province
      * 1 湖北
      * 2 湖南
  
      *- Data3 中一个企业代码对应多个样本，Data4 中一个企业代码对应一条数据，所以是 m:1
      use Data3.dta, clear
      merge m:1 stkcd using Data4.dta
  
      *- 合并后
      * stkcd year province
      * 1	2001 湖北
      * 1 2002 湖北
      * 2 2001 湖南
      * 2 2002 湖南
  
  * 一对多合并（1：m）逆过程
      use Data4.dta, clear
      merge 1:m Num using Data3.dta
      
  *- 注意合并时一定要保证主表与被合并表的关键词名称相同
  ```

- 纵向合并，增加样本值，相当于在 `Excel` 后面追加数据

  ```stata
  *- Data1 
  * make var1
  * AA 2
  * BB 3
  
  *- Data2
  * make var2
  * AA 5
  * BB 6
  
  use Data1.dta, clear
  append using Data2.dta
  
  *- 追加后
  * make var1 var2
  * AA 2 .
  * BB 3 .
  * AA . 5
  * BB . 6
  ```

## 2.7 长宽数据转换

```stata
*- 宽数据转长数据
    *- 生成数据
    clear
    input id sex inc80 inc81 inc82 xx80 xx81 xx82
        1 0 5000 5500 6000 1 2 3
        2 1 2000 2200 3300 2 3 4
        3 0 3000 2000 1000 6 4 8
    end

    *- 转换数据
    reshape long inc xx, i(id) j(year)

*- 长数据转宽数据
    *- 生成数据
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
	*- 转换数据
	reshape wide inc xx, i(id) j(year)    
```

`注意：` `reshape` 命令宽转长仅仅适用于变量以 文字+数字 形式命名

## 2.8 文字变量的处理

### 2.8.1 文字变量数值化

在一些数据的导入过程中，数值型的变量有可能被识别为文本型变量。在这种情况下，就需要将其转换为数值型变量，以方便后续的运算，可以使用 `destring` 命令进行转换。

```stata
destring var, replace
```

意味着将被识别为文本型变量的 `var` 转换为数值型，并替代原来的值。

对于一些含有百分号的变量，也可以直接转换，比如。

```stata
*- 生成数据
clear 
input str6 Percent 
    "10%"
    "20%"
    "30%"
    "40%"
    "50%"
end
browse

*- 转换数据
destring Percent, gen(Num) percent
```

这样新生成的变量 `Num` 就是百分比的数值型变量了。

### 2.8.2 文字变量的拆分

通过 `split` 函数，可以有效地拆分有规律的变量，比如。

```stata
*- 生成变量
clear 
input str18 City 
    台湾省台北市
    台湾省高雄市
    湖北省潜江市
    湖北省武汉市
    湖南省长沙市
    四川省成都市
end

*- 从有规律的组合中拆分 省 与市区
split City, parse("省") 
replace City1 = City1 + "省"
rename City1 province 
rename City2 city
```

同样地，也可以通过 `substr()` 对文字变量进行截取，上述方法可以改写为如下。

```stata
gen province1 = substr(City,1,9)
gen city1 = substr(City,10,9)
// 注意，每一个汉字算 3 个占位
```

### 2.8.3 处理文字变量的其他函数

可以通过 `help string functions` 查看所有的文字处理函数，这里介绍几个常用的。

- 更改大小写

  ```stata
  dis lower("ASejksjdlwASD")
  dis upper("sadhASDkSss")
  ```

- 测量文本长度

  ```stata
  dis length("汉字") // 一个汉字长度为 3
  dis length("English ") // 一个字母长度为 1，且空格为 1
  ```

- 测量文字个数

  ```stata
  dis wordcount("汉字 English ") // 空格不作数
  ```

- 匹配文本是否出现

  ```stata
  dis strmatch("xxx出生在中国湖北省潜江市", "潜江")
  
  dis strmatch("xxx出生在中国台湾省台北市", "台北市*")
  dis strmatch("xxx出生在中国台湾省台北市", "*台北市*")
  
  dis strmatch("Stata", "s")
  dis strmatch("Stata", "s")
  dis strmatch("Stata", "S")
  dis strmatch("Stata", "S*")
  ```

  上述方法是区分大小写的，且匹配中文时需要在待匹配内容两侧加 * 。

- 去除文本中空格的几种方法

  ```stata
  dis " 我还 在漂泊  你是错 过的烟火 "
  
  *- 去除两端空格
  dis  strtrim(" 我还 在漂泊  你是错 过的烟火 ") 
  
  *- 去除左边空格
  dis  strltrim(" 我还 在漂泊  你是错 过的烟火 ") 
  
  *- 去除右边空格
  dis  strrtrim(" 我还 在漂泊  你是错 过的烟火 ") 
  
  *- 去掉中间空格
  dis  stritrim(" 我   还 在  漂泊  你  是错 过的烟火 ") 
  help stritrim() // 将中间若干空格压缩成一个空格
  
  *- 若要去掉所有空格
  dis subinstr(" 我   还 在  漂泊  你  是错 过的烟火 "," ","",.)
  help subinstr() // 点表示替换所有空格
  
  dis subinstr(" 我   还 在  漂泊  你  是错 过的烟火 "," ","",2)
  
  dis subinstr(" 我   还 在  漂泊  你  是错 过的烟火 "," ","",4)
  ```

注意，以上方法都能配合 `gen` 生成新的变量。

### 2.8.4 正则表达

`Stata` 支持正则表达，即通过特定的字符串规则提取文字变量中与规则对应的字符串。

- 生成文本数据

  ```stata
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
  ```

- 常用的操作有

  ```stata
  *- 提出所有数字
  gen Number = ustrregexs(0) if ustrregexm(String,"\d+")
  
  *- 提出所有小写字母
  gen LetterL = ustrregexs(0) if ustrregexm(String,"[a-z]+")
  
  *- 提出所有大写字母
  gen LetterU = ustrregexs(0) if ustrregexm(String,"[A-Z]+")
  
  *- 提出所有字母
  gen Letter = ustrregexs(0) if ustrregexm(String,"[a-zA-Z]+")
  
  *- 提出所有汉字
  gen Character = ustrregexs(0) if ustrregexm(String,"[\u4e00-\u9fa5]+")
  
  // 同时也可用于匹配身份证、邮政编码、网址、Email等
  ```

其余相关操作可以自行搜索发现，正则表达对文本的处理功能非常强大。
