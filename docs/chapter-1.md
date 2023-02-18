## 1.1 `Stata` 概述

> Stata is a complete, integrated software package that provides all your data science needs—data manipulation, visualization, statistics, and automated reporting. 
>
> By Statistical software for data science

`Stata` 与其他软件的对比如下。

<center>
    <img src="https://github.com/ShutterZor/stata-tutorial/blob/main/images/intro.png">
</center>

## 1.2 菜单操作

需要说明的是，在一般情况下，我们很少通过菜单操作的方式来进行操作，并且长时间不用容易遗忘繁琐的点击步骤，所以不对此进行过多介绍。

## 1.3 命令与帮助文件

### 1.3.1 基础命令

在 `Stata` 中，可以通过在命令窗口输入一行命令后按回车的方式执行命令，也可以将命令写入 `.do` 文件后，运行整个脚本文件或者一行行地运行。请读者自行运行以下命令。

```stata
pwd					// 显示当前工作路径，与左下角一致
cd E:\Stata16\ado	  // 进入指定文件夹
sysdir 				// 查看 Stata 相关路径
ls 					// 展示当前路径文件，与 linux 类似
dir 				   // 效果同 ls
```

### 1.3.2 认识帮助文件

`Stata` 的开发者，包括官方开发者与第三方开发者，都会为自己开发的命令文档书写一份帮助文档。在使用过程中如果遇到对命令不熟悉或者其他不清晰的地方，调用帮助文档并自行阅读是最好的学习方法。在 `Stata` 中调用帮助文档的命令为 `help 命令`。比如。

```stata
help reg
help regress
```

注意，可以缩写的命令，如 `regress`、`summarize` 等，可以通过 `help 命令缩写` 的方式调用帮助文档。当你不清楚命令是否能缩写时，输入命令的全称是最好的方法。

## 1.4 局部宏与全局宏 (`local` & `global`)

`local` 与 `global` 是 `Stata` 的 `Macro function` 的其中两种常用宏，两者的区别在于。

- `local` 使用一次便消失，需要同命令一起选中运行
- `global` 可以一直使用，直到关闭 Stata

### 1.4.1 `local` 

需要注意的是，`local` 在引用时左右符号的区别，右边是单引号，而局部宏左边并非单引号，而是英文输入法下 `Esc` 下方的符号。

- 存放数字并进行运算

  ```stata
  local num1 3
  dis `num1'
  
  local num2 `num1' + 5
  dis `num2'
  
  *- 使用双引号时会对展示结果产生影响
  local num3 2+2
  dis `num3'
  dis "`num3'"
  ```

- 存储字符串

  ```stata
  local str1 Shutter
  dis "`str1'"
  
  local str2 Zor
  dis "`str2'"
  
  local str3 `str1'`str2'
  dis "`str3'"
  ```

- 存储变量，可以增加代码可读性

  ```stata
  sysuse auto.dta, clear
  
  local myVar price mpg rep78
  sum `myVar'
  *- 等价于
  sum price mpg rep78
  
  local myVar price mpg rep78
  pwcorr `myVar'
  *- 等价于
  pwcorr price mpg rep78
  
  *- 增加双引号会影响展示结果
  local myVar price mpg rep78
  dis `myVar'
  dis "`myVar'"
  ```

* 简单的数据运算

  ```stata
  *- 利用 help mathematical functions 查看Stata支持的所有运算函数
  sysuse auto.dta, clear
  local num ceil(sqrt(log(100)))
  dis `num'
  dis make[3]
  dis make[`num']	
  dis make[`=ceil(sqrt(log(100)))']
  ```

* 逻辑运算

  ```stata
  sysuse auto.dta, clear
  local Yes 1
  sum foreign if `Yes'
  *- 等价于
  sum foreign
  ```

### 1.4.2 `global`

用法基本与 `local` 一致，但引用方式有区别。

* 存储数字与运算

  ```stata
  global num1 5
  global num2 $num1 + 10
  global str1 Stata代码
  global str11 "Stata代码"
  global str2 Stata   代码
  global str22 "Stata   代码"
  
  *- 定义时引号可有可无，但引用时对文本信息而言必须加引号，请自行比较
  dis $num1 
  dis $num2
  dis "$str1"
  dis "$str11"
  dis "$str2"
  dis "$str22"
  dis $str22
  ```

- 常见使用方法

  定义回归中的控制变量，以简化代码。

  ```stata
  sysuse auto.dta, clear
  global control mpg headroom weight length turn
  reg price $control
  ```

  

  

## 1.5 条件循环语句及异常处理

### 1.5.1 `while` 循环

当满足条件时，则执行后续代码。

```stata
*- 向上
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
```

```stata
* 向下
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
```

注意，这些缩进是不必要的，这里只是为了看起来美观。

### 1.5.2 `if` 循环

- `if` 会被很多函数内置

  ```stata
  sysuse auto.dta, clear
  sum price if foreign == 1
  ```

- 可以与 `else` 连用

  ```stata
  local num 11
  if (mod(`num',2)==0) {
  	dis "`num'""是偶数"
  }
  else {
  	dis "`num'" "是奇数"
  }
  ```

- `if` 与 `else` 套娃使用

  ```stata
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
  ```

### 1.5.3 `forvalues` 循环

`forvalues` 循环是针对数字部分进行的循环，含有规律数字，则可以使用。

- 生成 30 个均匀分布的变量 `var1-var30`

  ```stata
  clear
  set obs 10 // 设定十个观测值，或者说样本
  set seed 12345	// 设置随机数种子，以确保结果不是胡乱随机的
  forvalues i = 1(1)30 {
  	gen var`i' = runiform()
  }
  ```

### 1.5.4 `foreach` 循环

`foreach` 可以对任意非数字的内容进行循环。

- 批量的对数转换

  ```stata
  sysuse auto.dta, clear
  local varName price mpg weight length
  foreach v in `varName' {
      gen ln`v' = ln(`v')
      gen log`v' = log(`v')
      label var ln`v' "ln(`v') for `v'"
      label var log`v' "log(`v') for `v'"
  }
  list lnprice logprice in 1/10
  ```

  注意，`Stata` 中的 `ln()` 与 `log()` 是等价的，10 为底数，则需要使用 `log10()`，而对于其他的底数，则需要使用[换底公式](https://baike.baidu.com/item/换底公式/6731201)。

- 批量进行变量缩尾

  ```stata
  sysuse auto.dta, clear
  local varName price mpg weight length
  foreach v in `varName' {
  	winsor `v', gen(new_`v') p(0.1)
  }
  histogram price
  histogram new_price
  ```
