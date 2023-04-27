# `onetext` 上手指南
## 0 `onetext` 命令起源
`onetext` 是我自己独立编写的第二条 **Stata** 命令，它主要是对 **Python** 中 `jieba` 库里一些功能的搬运，目的是为了能够在 **Stata** 中直接进行简单的文本分析，避免调用 **Python** ，适当减轻工作负担。但总的来说，目前 `onetext` 的功能还不够完善，在我的设想当中，`onetext` 的终极形态应当是能够完全替代 `jieba` （先画个饼，下次一定）。不过很遗憾，以目前我的能力来看，完全版本的 `onetext` 还很难从技术层面实现。

就目前而言，`onetext` 能够统计：

- 特定词汇是否出现（exist）
- 特定词汇出现的频次（count）
- 计算向量间的余弦相似度（cosine similarity）
- 计算向量间的杰卡德相似度（jaccard similarity）

## 1 `onetext` 的 Stata 应用
首先，该包已成功上传至 **ssc**（The Statistical Software Components）。即，可以通过 **Stata** 中的 `ssc install onetext, replace` 进行下载。在上述命令当中，`ssc install onetext` 代表着从 **ssc** 中下载名为 `onetext` 的命令包，`replace` 选项代表着当 **Stata** 中存在该包时，会下载最新版本的来替代它。

具体来看，`onetext` 在 **Stata** 中的应用可以通过以下代码实现（PS：以下代码都已写入 `onetext` 的帮助文件，可以通过 `help onetext` 查看。）：

```Stata

*- 从数据当中寻找 “大数据” 三个字出现的次数
clear
set obs 4
gen text = "大数据" in 1
replace text = "大数据大数据" in 2
replace text = "数据小数据" in 3
replace text = "小数据" in 4
onetext text, k("大数据") m(count) g(count_text)

```

![图1：count选项](https://files.mdnice.com/user/34469/2a25bf3a-18b3-4699-aec5-94570c2827b7.png)

```Stata

*- 从数据当中判断 “大数据” 三个字是否出现
clear
set obs 4
gen text = "大数据" in 1
replace text = "大数据大数据" in 2
replace text = "数据小数据" in 3
replace text = "小数据" in 4
onetext text, k("大数据") m(exist) g(isExist)

```

![图2：exist选项](https://files.mdnice.com/user/34469/0136ce03-b576-4b20-8f61-ad690940b7e1.png)

```Stata

*- 计算向量间的相似度
clear
set obs 3
gen var1 = 1 in 1
replace var1 = 2 in 2
replace var1 = 3 in 3
gen var2 = 4 in 1
replace var2 = 2 in 2
replace var2 = 5 in 3
onetext var1 var2, m(cosine) g(cs)
onetext var1 var2, m(jaccard) g(js)

```

![图3：相似度计算](https://files.mdnice.com/user/34469/2a214fa8-92fd-4b8c-8425-57b92ab8f26b.png)

## 2 结语
就目前而言， `onetext` 仅仅实现了很小一部分文本分析的功能，希望在未来能够不断地完善它（画饼）。

更多应用参考：[Stata：计算文本语调-onetext](https://mp.weixin.qq.com/s/ZGIpFkYfwqTWU9LrZOg8Mw)、[遍历兆字节，约取千人面：OneText文本分析速览](https://mp.weixin.qq.com/s/tD06v9V25c8eqet48I_6cg)

