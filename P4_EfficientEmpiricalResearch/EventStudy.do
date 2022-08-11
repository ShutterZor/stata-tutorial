/*==================================================
project:       Efficient Empirical Research in Stata
Author:        Shutter Zor 
E-email:       Shutter_Z@outlook.com
url:           shutterzor.github.io
Dependencies:  School of Accountancy, Wuhan Testile University
----------------------------------------------------
Creation Date:    11 Aug 2022 - 14:38:05
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
			事件研究法的 Stata 实现
==================================================*/


* 查看数据类型
	
	import excel using ESData.xlsx, first clear

* 确保日期为 日期型 数据，参考 P2_Data 中 1029 行

	
	
******************* 设置关键信息 *******************

global 	EstimationRange		90				// 设置估计窗口的前后时间
global 	EventRange 			5				// 设置时间窗口的前后时间

global	Stkcd				code			// 设置股票代码
global 	EstimationDate		date			// 设置表示交易日的变量
global	EventDate			event_date		// 设置事件发生日变量，归至最近交易日
global	Share				share_return	// 设置个股收益率变量
global	Market				market_return	// 设置市场收益率变量

global	FirmNum				11				// 设置公司数量 distinct code

******************* 以下不用修改 *******************

* 标记事件发生日
bys $Stkcd : gen date1 = _n
bys $Stkcd : gen Event_Window = date1 if $EstimationDate == $EventDate

* 标记事件窗口
sum Event_Window
global JudgeNum r(min)
replace Event_Window=date1 if date1-$JudgeNum>=-$EventRange & ///
							  date1-$JudgeNum<= $EventRange
replace Event_Window = 1 if Event_Window != .
replace Event_Window = 0 if Event_Window == .

* 标记估计窗口
drop if Event_Window == 0 & date1-$JudgeNum > $EventRange
gen Estimation_Window = 1 if Event_Window == 0
replace Estimation_Window = 0 if Estimation_Window == .

* 估计每一支股票的超额收益
egen FirmGroup = group($Stkcd)
gen Predict_Return = .
forvalues i = 1/$FirmNum {
	reg $Share $Market if Estimation_Window == 1 & FirmGroup == `i'
	predict PredictValue if FirmGroup == `i'
	replace Predict_Return = PredictValue if FirmGroup == `i'
	drop PredictValue
}
gen AR$EventRange = $Share - Predict_Return

* 计算累积超额收益
bys $Stkcd : egen CAR$EventRange = sum(AR)

* 导出超额收益与累积超额收益结果
preserve
	keep $Stkcd AR$EventRange CAR$EventRange
	export excel code AR CAR using "AR$EventRange&CAR$EventRange.xlsx", firstrow(variables) replace
restore


