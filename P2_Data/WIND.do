


/*
		CASE4	WIND 数据清洗
*/


* 本案例主要介绍一种方便读入 WIND 数据的命令

* readwind

	ssc install readwind


* 导入数据查看
	
	import excel using WindData.xlsx, first clear
	browse
	clear

* 读取该数据并转换面板

	readwind A B, key(WindData) timeType(y) t0(2020) tn(2022) 

* 另存为 dta 文件
	
	save WindData.dta, replace