本节内容翻译自 `Princeton University` 的 `Stata` 教程。当然，我做了适当的修改。原文地址：[DATA & STATISTICAL SERVICES](http://www.princeton.edu/~otorres/Stata/)。

当你的 `Stata` 中已经导入数据后，就可以通过如下命令来探索它们：`describe`、`list`、`summarize`，以及 `codebook`。

## 1 Describing the data-描述数据

`describe` 命令将为你提供当前数据集的相关信息（数据集名称等）和变量的格式（“显示格式”）。点击回车键或空格键可以看到其余的列表。输入 `help describe` 以获得更多的细节（如果“--更多--”的信息让你感到困扰，请输入 `set more off`）。

```stata
*- 调用自带的数据
sysuse auto.dta

*- 使用命令
describe

*- 返回结果
Contains data from E:\Stata16\ado\base/a/auto.dta
  obs:            74                          1978 Automobile Data
 vars:            12                          13 Apr 2018 17:45
                                              (_dta has notes)
--------------------------------------------------------------------------------
              storage   display    value
variable name   type    format     label      variable label
--------------------------------------------------------------------------------
make            str18   %-18s                 Make and Model
price           int     %8.0gc                Price
mpg             int     %8.0g                 Mileage (mpg)
rep78           int     %8.0g                 Repair Record 1978
headroom        float   %6.1f                 Headroom (in.)
trunk           int     %8.0g                 Trunk space (cu. ft.)
weight          int     %8.0gc                Weight (lbs.)
length          int     %8.0g                 Length (in.)
turn            int     %8.0g                 Turn Circle (ft.)
displacement    int     %8.0g                 Displacement (cu. in.)
gear_ratio      float   %6.2f                 Gear Ratio
foreign         byte    %8.0g      origin     Car type
--------------------------------------------------------------------------------
Sorted by: foreign
```

## 2 The list command-`list` 命令

`list` 命令将以表格的形式列出数据，如下所示。

```stata
*- 调用自带的数据
sysuse auto.dta

*- 使用命令
list price mpg in 1/5

*- 返回结果
     +-------------+
     | price   mpg |
     |-------------|
  1. | 4,099    22 |
  2. | 4,749    17 |
  3. | 3,799    22 |
  4. | 4,816    20 |
  5. | 7,827    15 |
     +-------------+
```

由于样本总数比较多，这里使用 `in 1/5` 来将显示在屏幕上的数据限制在前 5 个样本，去掉这个限制，即可显示所有样本。

## 3 The summarize command-`summarize` 命令

### 3.1 描述性统计之 `summarize`

`summarize` 命令为你提供了更多的数据信息，返回结果将会告诉你样本的数量，它们的平均值、标准差和最小、最大值。注意变量全为 “0”，可能意味着这些变量是文本（或字符串）格式，而不是数字格式。

```stata
*- 调用自带的数据
sysuse auto.dta

*- 使用命令
summarize

*- 返回结果
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
        make |          0
       price |         74    6165.257    2949.496       3291      15906
         mpg |         74     21.2973    5.785503         12         41
       rep78 |         69    3.405797    .9899323          1          5
    headroom |         74    2.993243    .8459948        1.5          5
-------------+---------------------------------------------------------
       trunk |         74    13.75676    4.277404          5         23
      weight |         74    3019.459    777.1936       1760       4840
      length |         74    187.9324    22.26634        142        233
        turn |         74    39.64865    4.399354         31         51
displacement |         74    197.2973    91.83722         79        425
-------------+---------------------------------------------------------
  gear_ratio |         74    3.014865    .4562871       2.19       3.89
     foreign |         74    .2972973    .4601885          0          1
```

返回结果中变量 `make` 的观测值为 0，点开数据则不难发现，该变量为文本型变量，所有不会参与描述性统计。

如果你需要获得某个变量的分位数或者其他统计量，可以在命令之后加上 `,detail`，如下。

```stata
*- 调用自带的数据
sysuse auto.dta

*- 使用命令
summarize price, detail

*- 返回结果
                            Price
-------------------------------------------------------------
      Percentiles      Smallest
 1%         3291           3291
 5%         3748           3299
10%         3895           3667       Obs                  74
25%         4195           3748       Sum of Wgt.          74

50%       5006.5                      Mean           6165.257
                        Largest       Std. Dev.      2949.496
75%         6342          13466
90%        11385          13594       Variance        8699526
95%        13466          14500       Skewness       1.653434
99%        15906          15906       Kurtosis       4.819188
```

此外，对于任意分位数，可以参考 `Chapter 2-变量处理` 中 `2.5 离群值的影响` 中产生分位数的方法。或者直接看如下命令。

```stata
*- 通过 summarize 产生分位数
	*- 调用自带的数据集
	sysuse auto.dta
	*- 使用 sum 与 detail 查看详细
	sum price, detail
	*- 查看命令返回值
	return list
	*- 将返回值中的 p90 分位数赋值给变量 pctile90
	gen pctile90=r(p90)

*- 通过 _pctile 产生分位数
	*- 调用自带的数据集
	sysuse auto.dta
	*- 使用 _pctile 命令估计变量 price 的 25 和 75 分位数
	_pctile price, p(25 75)
	*- 查看命令返回值
	return list
	*- 将返回值中的 p25 与 p75 的分位数赋值给变量 pctile25 与 pctile75
    gen pctile25=r(r1)
    gen pctile75=r(r2)
	*- 利用 sum 检查是否一致
	sum price, detail
	*- 浏览变量 price 以及它的 25 与 75 分位数
	browse price pctile25 pctile75
```

### 3.2 描述性统计之 `tabstat`

此外，`tabstat` 命令也可以实现描述性统计的操作，比如。

```stata
*- 调用自带的数据
sysuse auto.dta

*- 使用命令
tabstat price mpg rep78, s(count mean sd min max)

*- 返回结果
   stats |     price       mpg     rep78
---------+------------------------------
       N |        74        74        69
    mean |  6165.257   21.2973  3.405797
      sd |  2949.496  5.785503  .9899323
     min |      3291        12         1
     max |     15906        41         5
----------------------------------------
```

并且，`tabstat` 命令提供的统计量非常之多，通过 `help tabstat`，然后点击 `options👉statistics` 中的 `statname`，可以看到所有支持的统计量。此外，也可以联合 `by()` 选项，完成分组的描述性统计。

## 4 Getting a codebook-获得编码手册

这个标题可能比较抽象一点，但是如果你看过我前面提到的变量类型，在 `Chapter 2-变量处理` 中 `2.2.1` 小节所提到的，我提到过 `Stata` 中的变量有三种基本的颜色，其中有一种是蓝色，我们可以通过 `codebook` 命令很方便地查看蓝色变量的含义，比如。

```stata
*- 调用自带的数据
sysuse auto.dta

*- 使用命令
codebook foreign

*- 返回结果
--------------------------------------------------------------------------------
foreign                                                                 Car type
--------------------------------------------------------------------------------

                  type:  numeric (byte)
                 label:  origin

                 range:  [0,1]                        units:  1
         unique values:  2                        missing .:  0/74

            tabulation:  Freq.   Numeric  Label
                            52         0  Domestic
                            22         1  Foreign
```

`Stata` 自带的数据中，`foreign` 变量是蓝色的，我们可以通过 `codebook` 命令查看详情，上述结果意味着数字 0 表示国产车，数字 1 表示进口车（国外的车）。

## 5. Basic commands-其他基础命令

### 5.1 Frequencies (tab)-单变量样本频数

接上一个例子，比如我希望进一步了解国产车与进口车的频数，即在我的样本中到底有多少个国产车以及多少个进口车，那么可以使用 `tab` 命令进行查看。

```stata
*- 调用自带的数据
sysuse auto.dta

*- 使用命令
tab foreign

*- 返回结果
   Car type |      Freq.     Percent        Cum.
------------+-----------------------------------
   Domestic |         52       70.27       70.27
    Foreign |         22       29.73      100.00
------------+-----------------------------------
      Total |         74      100.00
```

另外，如果你想一次性查看多个变量的单变量频数，可以使用 `tab1` 命令，它会分表依次显示多个变量的具体频数分布。

```stata
tab1 make foreign
// 由于结果太长，这里就不展示了
```

### 5.2 Crosstabs (tab)-多变量交叉频数

多变量交叉频数指的是观察两个变量之间的频数关系，比如按人种类型（白、黑与其他）统计其婚姻情况，代码如下。

```stata
*- 调用自带的数据集
sysuse nlsw88.dta

*- 使用命令
tab race married

*- 返回结果
           |        married
      race |    single    married |     Total
-----------+----------------------+----------
     white |       487      1,150 |     1,637 
     black |       309        274 |       583 
     other |         8         18 |        26 
-----------+----------------------+----------
     Total |       804      1,442 |     2,246 
```

这样我们便可以很方便地观察不同人种之间的婚姻情况数据，比较适用于 `CFPS` 这样式的调查问卷。

同时，通过选择 `row` 或者 `column` 选项，可以观察按行或者按列计算的频率，比如。

```stata
*- 按行
tab race married, row

*- 返回结果
+----------------+
| Key            |
|----------------|
|   frequency    |
| row percentage |
+----------------+

           |        married
      race |    single    married |     Total
-----------+----------------------+----------
     white |       487      1,150 |     1,637 
           |     29.75      70.25 |    100.00 
-----------+----------------------+----------
     black |       309        274 |       583 
           |     53.00      47.00 |    100.00 
-----------+----------------------+----------
     other |         8         18 |        26 
           |     30.77      69.23 |    100.00 
-----------+----------------------+----------
     Total |       804      1,442 |     2,246 
           |     35.80      64.20 |    100.00 

*- 按列
tab race married, column

*- 返回结果
+-------------------+
| Key               |
|-------------------|
|     frequency     |
| column percentage |
+-------------------+

           |        married
      race |    single    married |     Total
-----------+----------------------+----------
     white |       487      1,150 |     1,637 
           |     60.57      79.75 |     72.89 
-----------+----------------------+----------
     black |       309        274 |       583 
           |     38.43      19.00 |     25.96 
-----------+----------------------+----------
     other |         8         18 |        26 
           |      1.00       1.25 |      1.16 
-----------+----------------------+----------
     Total |       804      1,442 |     2,246 
           |    100.00     100.00 |    100.00 
```

最后，也可以同时加入 `row` 与 `column` 的选项来一次返回按行或者按列计算的多种频率。

## 6 T-test T检验

主要用于比较两个组别之间的均值差异，比如，比较读大学和不读大学对工资收入的影响。

```stata
*- 调用数据
sysuse nlsw88.dta

*- 使用命令
ttest wage, by(collgrad)

*- 返回结果
Two-sample t test with equal variances
------------------------------------------------------------------------------
   Group |     Obs        Mean    Std. Err.   Std. Dev.   [95% Conf. Interval]
---------+--------------------------------------------------------------------
not coll |   1,714    6.910561    .1276104    5.283132    6.660273     7.16085
 college |     532    10.52606    .2742596    6.325833    9.987296    11.06483
---------+--------------------------------------------------------------------
combined |   2,246    7.766949    .1214451    5.755523    7.528793    8.005105
---------+--------------------------------------------------------------------
    diff |           -3.615502    .2753268               -4.155424    -3.07558
------------------------------------------------------------------------------
    diff = mean(not coll) - mean(college)                         t = -13.1317
Ho: diff = 0                                     degrees of freedom =     2244

    Ha: diff < 0                 Ha: diff != 0                 Ha: diff > 0
 Pr(T < t) = 0.0000         Pr(|T| > |t|) = 0.0000          Pr(T > t) = 1.0000
```

T 检验的的原假设为不存在显著差异，根据 `Ha: diff != 0, Pr(|T| > |t|) = 0.0000`，我们可以判断，显著拒绝原假设，即存在显著差异。所以是否读大学与工资之间的回归应当是显著的，请读者自行验证。

## 7 One-way ANOVA-单因素方差分析

> 该检验的目的是判断每个组的平均数是否相同，即可以视为一种组间差异检验。不同于 T-test 的两组之间的差异比较，One-way ANOVA 可以对多分类的某一个变量构成的不同组别进行均值差异检验。-- By Shutter Zor

```stata
*- 调用数据
sysuse nlsw88.dta

*- 使用命令
oneway wage race

*- 返回结果
                        Analysis of Variance
    Source              SS         df      MS            F     Prob > F
------------------------------------------------------------------------
Between groups      675.510282      2   337.755141     10.28     0.0000
 Within groups      73692.4571   2243   32.8544169
------------------------------------------------------------------------
    Total           74367.9674   2245   33.1260434

Bartlett's test for equal variances:  chi2(2) =  21.0482  Prob>chi2 = 0.000
```

结果意味着不同人种之间的工资具有显著的差异（Between groups，Prob>F 为 0.0000），同样地，这使得两者之间的回归结果也变得显著了，请读者自行验证。