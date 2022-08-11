/*==================================================
project:       Graph procedure in Stata
Author:        Shutter Zor 
E-email:       Shutter_Z@outlook.com
url:           shutterzor.github.io
Dependencies:  School of Accountancy, Wuhan Textile University
----------------------------------------------------
Creation Date:     9 Aug 2022 - 11:12:25
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/



/*==================================================
				不同的绘图模板
==================================================*/


local scheme "s2color"
set scheme `scheme'
twoway (function y=x^2, range(-5 20) lw(*1.5))  				///
		(function y=x^3, range(-5 20) lw(*2.0))					///
		(function y=ln(x), range(-5 20) lw(*2.5)), 				///
		ylabel(, angle(-45))           							///
		yline(0, lcolor(black*0.5) lpattern(dash))   			///
		xlabel(, angle(0))										///
		xline(0, lcolor(black*0.5) lpattern(dash))				///
		legend(label(1 "y=x^2") label(2 "y=x^3") label(3 "y=ln(x)"))	///
		scheme(`scheme') saving("F1", replace) nodraw

local scheme "s2mono"
set scheme `scheme'
twoway (function y=x^2, range(-5 20) lw(*1.5))  				///
		(function y=x^3, range(-5 20) lw(*2.0))					///
		(function y=ln(x), range(-5 20) lw(*2.5)), 				///
		ylabel(, angle(-45))           							///
		yline(0, lcolor(black*0.5) lpattern(dash))   			///
		xlabel(, angle(0))										///
		xline(0, lcolor(black*0.5) lpattern(dash))				///
		legend(label(1 "y=x^2") label(2 "y=x^3") label(3 "y=ln(x)"))	///
		scheme(`scheme') saving("F2", replace) nodraw
  

local sch "s1color"
set scheme `scheme'
twoway (function y=x^2, range(-5 20) lw(*1.5))  				///
		(function y=x^3, range(-5 20) lw(*2.0))					///
		(function y=ln(x), range(-5 20) lw(*2.5)), 				///
		ylabel(, angle(-45))           							///
		yline(0, lcolor(black*0.5) lpattern(dash))   			///
		xlabel(, angle(0))										///
		xline(0, lcolor(black*0.5) lpattern(dash))				///
		legend(label(1 "y=x^2") label(2 "y=x^3") label(3 "y=ln(x)"))	///
		scheme(`scheme') saving("F3", replace) nodraw


local sch "s1mono"
set scheme `scheme'
twoway (function y=x^2, range(-5 20) lw(*1.5))  				///
		(function y=x^3, range(-5 20) lw(*2.0))					///
		(function y=ln(x), range(-5 20) lw(*2.5)), 				///
		ylabel(, angle(-45))           							///
		yline(0, lcolor(black*0.5) lpattern(dash))   			///
		xlabel(, angle(0))										///
		xline(0, lcolor(black*0.5) lpattern(dash))				///
		legend(label(1 "y=x^2") label(2 "y=x^3") label(3 "y=ln(x)"))	///
		scheme(`scheme') saving("F4", replace) nodraw


local sch "economist"
set scheme `scheme'
twoway (function y=x^2, range(-5 20) lw(*1.5))  				///
		(function y=x^3, range(-5 20) lw(*2.0))					///
		(function y=ln(x), range(-5 20) lw(*2.5)), 				///
		ylabel(, angle(-45))           							///
		yline(0, lcolor(black*0.5) lpattern(dash))   			///
		xlabel(, angle(0))										///
		xline(0, lcolor(black*0.5) lpattern(dash))				///
		legend(label(1 "y=x^2") label(2 "y=x^3") label(3 "y=ln(x)"))	///
		scheme(`scheme') saving("F5", replace) nodraw


local sch "sj"
set scheme `scheme'
twoway (function y=x^2, range(-5 20) lw(*1.5))  				///
		(function y=x^3, range(-5 20) lw(*2.0))					///
		(function y=ln(x), range(-5 20) lw(*2.5)), 				///
		ylabel(, angle(-45))           							///
		yline(0, lcolor(black*0.5) lpattern(dash))   			///
		xlabel(, angle(0))										///
		xline(0, lcolor(black*0.5) lpattern(dash))				///
		legend(label(1 "y=x^2") label(2 "y=x^3") label(3 "y=ln(x)"))	///
		scheme(`scheme') saving("F6", replace) nodraw


graph combine "F1" "F2" "F3" "F4" "F5" "F6", rows(3) saving(DifferentScheme, replace)


