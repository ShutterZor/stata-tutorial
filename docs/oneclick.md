# `oneclick` 5.0 上手指南

## 0 `oneclick` 原理

我在这里要首先强调 `oneclick` 的原理。它的工作原理仅仅是排列组合控制变量，而不对样本数据造成任何改变，所以它不是万能的，只能在一定程度上帮我们减轻工作量。所以如果你使用了 `oneclick` 却没有得到显著的结果，不要灰心，试一试将变量缩尾、取对数、更换其他的回归方法，以及更换变量的衡量方式。

个人认为学术不端跟这个完全不沾边，人工选也是选，机器选也是选，后者效率更高。在机器学习中网格搜索的调参方法与 `oneclick` 是异曲同工的。

>  人工筛选控制变量并不比机器筛选来得更别具匠心！！！By 知乎用户

使用前请先安装更新命令，本版本不再依赖 `tuples`，并且兼容 Stata14.0 及以上版本，执行下列代码即可完成安装：

```stata
ssc install oneclick, replace
```

## 1 确定回归方法

由于 `oneclick` 使用过程中需要考虑是否添加 `z` 选项，所以在使用 `oneclick` 之前，我们需要先观察回归中用于判定显著性的统计量是否为 `z-value`。若是，则需要添加 `z` 选项，反之则不需要。

以 `auto.dta` 数据集为例，假设我们的被解释变量是 *price*，解释变量是 *length*。先用自己需要的回归观测该回归方法下的用于判定显著性的统计量，这里以 `reg` 为例。

```stata
*- 调用数据
sysuse auto.dta, clear

*- 使用回归
reg price length

*- 返回结果
      Source |       SS           df       MS      Number of obs   =        74
-------------+----------------------------------   F(1, 72)        =     16.50
       Model |   118425867         1   118425867   Prob > F        =    0.0001
    Residual |   516639529        72  7175549.01   R-squared       =    0.1865
-------------+----------------------------------   Adj R-squared   =    0.1752
       Total |   635065396        73  8699525.97   Root MSE        =    2678.7

------------------------------------------------------------------------------
       price |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      length |   57.20224   14.08047     4.06   0.000     29.13332    85.27115
       _cons |  -4584.899   2664.437    -1.72   0.090    -9896.357     726.559
------------------------------------------------------------------------------
```

根据下方表格，不难发现用于判断显著性的统计量是 `t-value`。

以 `auto.dta` 数据集为例，假设我们的被解释变量是 *foreign*，解释变量是 *length*。这个时候使用 `logit` 或者 `probit`，就会发现，用于判定显著性的统计量变为了 `z-value`。

```stata
*- logit 回归
logit foreign length

*- 返回结果
Iteration 0:   log likelihood =  -45.03321  
Iteration 1:   log likelihood = -32.059368  
Iteration 2:   log likelihood = -30.991928  
Iteration 3:   log likelihood =  -30.97462  
Iteration 4:   log likelihood = -30.974595  
Iteration 5:   log likelihood = -30.974595  

Logistic regression                             Number of obs     =         74
                                                LR chi2(1)        =      28.12
                                                Prob > chi2       =     0.0000
Log likelihood = -30.974595                     Pseudo R2         =     0.3122

------------------------------------------------------------------------------
     foreign |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      length |  -.0797353   .0194854    -4.09   0.000     -.117926   -.0415447
       _cons |   13.60634   3.457273     3.94   0.000     6.830209    20.38247
------------------------------------------------------------------------------

*- probit 回归
probit foreign length

*- 返回结果
Iteration 0:   log likelihood =  -45.03321  
Iteration 1:   log likelihood = -31.110985  
Iteration 2:   log likelihood =  -30.64599  
Iteration 3:   log likelihood = -30.644666  
Iteration 4:   log likelihood = -30.644666  

Probit regression                               Number of obs     =         74
                                                LR chi2(1)        =      28.78
                                                Prob > chi2       =     0.0000
Log likelihood = -30.644666                     Pseudo R2         =     0.3195

------------------------------------------------------------------------------
     foreign |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      length |  -.0474833   .0107435    -4.42   0.000    -.0685403   -.0264264
       _cons |   8.099108   1.917156     4.22   0.000     4.341551    11.85667
------------------------------------------------------------------------------
```

综上，我们通过因变量与自变量之间进行回归的方式，可以确定我们是否需要在 `oneclick` 的选项中加入 `z` 选项。对于常见的回归，我总结一份表格如下。

| 回归方法                              | 是否需要加入 `z` 选项 |
| ------------------------------------- | --------------------- |
| reg                                   | 不需要                |
| logit、ologit、probit、oprobit        | 需要                  |
| xtreg                                 | 需要                  |
| xtreg加re选项构成的随机效应           | 需要                  |
| xtreg加fe选项构成的固定效应           | 不需要                |
| 其他任意固定效应模型：reghdfe、areg等 | 不需要                |

## 2 保证 `oneclick` 的正确书写

首先我们先观察 `oneclick` 的命令构成情况。

```stata
*- 基本语法
oneclick y controls, method(regression) pvalue(p-value) fixvar(x and other FE) [
    options zvalue ]
```

- `y` 位置用来放置你的被解释变量
- `controls` 位置用来放置你的待选控制变量集合，可以是 `i.var` 形式，也可以是 `l.var` 或者 `f.var` 等
- `m()` 位置用来放置你的回归方法，可以是 `reg`、`logit`、`probit`等
- `p()`，在括号中输入你希望的显著性水平，一般是 0.1、0.05，以及0.01。
- `fix()`，在括号中输入你的主要解释变量以及需要每个回归中都出现的变量。比如在一些实证论文中，我们希望能够保留 *size*、*roa* 等其他常见变量，则可以写在解释变量后。**注意：** 第一个位置一定要放解释变量。
- `o()`，用来放置其他原属于回归方法的其他选项，比如 `xtreg y x, re` 中的 `re` 选项、`reghdfe y x, absorb(A B)` 中的 `absorb(A B)` 选项
- `z`，根据第一步中的判定方法考虑是否需要添加以 `z-value` 判别显著性的方法

## 3 以正确的姿势开始！

**我一定一定一定要着重着重着重地强调这一点！！！**

我从Bilibili、微信公众号等后台收到的提问内容发现，很多都是大伙儿粗心大意自己写错了，所以我得非常强调一定要自己看清楚代码，所以我这里提到了要用正确的姿势开始对变量的拷打。

**再三确认回归方法，切忌张冠李戴**

在使用 `oneclick` 前，一定要先问自己，自己需要怎样的回归。比如：

- 是否需要加 `robust` 选项，是的话则需要在 `oneclick` 后面加入 `o(robust)` 。具体而言，如果你的回归形式是 `reg y x, vce(robust)`，则对应的 `oneclick` 代码应该是 `oneclick y 待选控制变量集合, m(reg) fix(x) p(0.1) o(vce(robust))`，而不是`oneclick y 待选控制变量集合, m(reg) fix(x) p(0.1)`。一这样才称得上是一一对应。
- 使用 `xtreg` 时，则需要将你要使用的固定效应 `fe`，或者随机效应 `re`，以及其他选项同时添加到 `o()` 当中。
- 使用 `reghdfe` 时，比如固定个体效应、时间效应的同时需要聚类到行业，可以直接将 `absorb(stkcd year) cluster(industry)` 直接放入 `o()` 中。

## 4 查看运算结果

在 `oneclick` 运算后，屏幕上会呈现一个简单的运行过程与最后的结论摘要，并且会在当前工作路径下生成一份名为 `subset.dta` 的文件。

```stata
*- 调用数据
sysuse auto.dta, clear
(1978 Automobile Data)

*- 使用 oneclick
oneclick price mpg rep78, fix(weight) p(0.1) m(reg)

*- 返回结果
This will probably take you up to 1 minutes

The program is working:
----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5 
...
Time=.027S

A total of 3 significant groups: 3 positive, 0 negative
```

从结论摘要中，可以发现，一共有3个显著的组合，为什么是3呢？因为我放入了两个待选择的控制变量：*mpg* 与 *rep78*，它们的真子集（非空子集）个数是 2^n-1 = 2^2-1 = 4-1 = 3。所以 `oneclick` 分别将这三种组合带入了运算，并查看了主要解释变量 `weight` 是否在 10% 的显著水平下显著。

在这3个显著的组合中，有3种正向显著的情况，都可以使得在 `reg price weight 控制变量` 回归中，*weight* 对 *price* 正向显著。

最后，查看当前工作路径下的 `subset.dta` 文件。当前工作路径指的是你当前 Stata 窗口左下角所显示的路径。该文件中有两个变量，一个变量叫 *subset* 用来展示满足显著性要求的控制变量组合，一个变量叫 `positive` 用来展示显著的方向，1表示正向显著，0表示负向显著。