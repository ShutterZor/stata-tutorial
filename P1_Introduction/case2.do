/*==================================================
project:       Introduction section for Stata course
Author:        Shutter Zor 
E-email:       Shutter_Z@outlook.com
url:           shutterzor.github.io
Dependencies:  School of Accountancy, Wuhan Textile University
----------------------------------------------------
Creation Date:     4 Aug 2022 - 09:14:58
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/



/*
	Rock、Paper and Scissors
*/
				
				
				
local Player "布"
local Random = 10*runiform()	

if "`Player'" != "石头" & "`Player'" != "剪刀" & "`Player'" != "布" {
	dis as error "只能输入石头、剪刀和布"
	exit
}

if (`Random'<=3) {
	local Stata "石头"
	if "`Player'" == "石头" {
		dis "Stata本轮出" "`Stata'" "你出的是" "`Player'"
		dis "本次是平局"
	}
	if "`Player'" == "剪刀" {
		dis "Stata本轮出" "`Stata'" "你出的是" "`Player'"
		dis "很遗憾你输了-_-"
	}
	if "`Player'" == "布" {
		dis "Stata本轮出" "`Stata'" "你出的是" "`Player'"
		dis "恭喜你胜利^_^"
	}
}
if (`Random'>3) & (`Random'<=6) {
	local Stata "剪刀"
	if "`Player'" == "石头" {
		dis "Stata本轮出" "`Stata'" "你出的是" "`Player'"
		dis "恭喜你胜利^_^"
	}
	if "`Player'" == "剪刀" {
		dis "Stata本轮出" "`Stata'" "你出的是" "`Player'"
		dis "本次是平局"
	}
	if "`Player'" == "布" {
		dis "Stata本轮出" "`Stata'" "你出的是" "`Player'"
		dis "很遗憾你输了-_-"
	}
}
if (`Random'>6) {
	local Stata "布"
	if "`Player'" == "石头" {
		dis "Stata本轮出" "`Stata'" "你出的是" "`Player'"
		dis "很遗憾你输了-_-"
	}
	else if "`Player'" == "剪刀" {
		dis "Stata本轮出" "`Stata'" "你出的是" "`Player'"
		dis "恭喜你胜利^_^"
	}
	else if "`Player'" == "布" {
		dis "Stata本轮出" "`Stata'" "你出的是" "`Player'"
		dis "本次是平局"
	}
}






