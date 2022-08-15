clear
use 数据-企业.dta

xtset id year
global deptvar labor
global firmvar wage size lev ser tax grow roa

sum $deptvar lccpost $firmvar 

reghdfe labor lccpost, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar, absorb(id year) vce(cluster id)

gen event = year - policy if G>0
tab event
replace event = -4 if event <= -4
replace event = 6 if event >= 6
replace event =. if G==0
tab event, gen(eventt)
forvalues i = 1/11{
	replace eventt`i' = 0 if eventt`i' == .
}
drop eventt1
reghdfe labor eventt* $firmvar, absorb(id year) vce(cluster id)
coefplot, baselevels keep(eventt*) vertical yline(0) ytitle("政策动态效应") xtitle("低碳城市试点政策实施的相对时间") addplot(line @b @at) ciopts(recast(rcap)) scheme(s1mono) levels(95)    coeflabels(eventt2 = "-3" eventt3 = "-2" eventt4 = "-1" eventt5 = "0" eventt6 = "1" eventt7  = "2" eventt8  = "3" eventt9  = "4" eventt10  = "5" eventt11  = ">=6")
graph export "平行趋势检验.png",as(png) replace width(800) height(600)

reghdfe labor lccpostfalse1 $firmvar, absorb(id year) vce(cluster id)
reghdfe labor lccpostfalse2 $firmvar, absorb(id year) vce(cluster id)
reghdfe labor lccpostfalse3 $firmvar, absorb(id year) vce(cluster id)
reghdfe labor lccpostfalse4 $firmvar, absorb(id year) vce(cluster id)

reghdfe labor_tr lccpost $firmvar, absorb(id year) vce(cluster id)
reghdfe labor_tr2 lccpost $firmvar, absorb(id year) vce(cluster id)

reghdfe labor lccpost $firmvar c.两控区#c.year, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar c.省会城市#c.year, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar c.经济特区城市#c.year, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar c.是否胡焕庸线以东#c.year, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar c.两控区#c.year c.省会城市#c.year c.经济特区城市#c.year c.是否胡焕庸线以东#c.year, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar 创新型城市试点did, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar 重点控制区did, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar 政策态度, absorb(id year) vce(cluster id)

reghdfe labor lccpost $firmvar 总量指数得分, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar 人均得分, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar 单位面积得分, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar 创新型城市试点did 重点控制区did 政策态度 总量指数得分, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar 创新型城市试点did 重点控制区did 政策态度 人均得分, absorb(id year) vce(cluster id)
reghdfe labor lccpost $firmvar 创新型城市试点did 重点控制区did 政策态度 单位面积得分, absorb(id year) vce(cluster id)

clear
use 企业数据.dta
xtset id year
global firmvar wage size lev ser tax grow roa
reghdfe 企业产出 lccpost $firmvar, absorb(id year) vce(cluster id)
reghdfe labor 企业产出 $firmvar, absorb(id year) vce(cluster id)
reghdfe ln高技能 企业产出 $firmvar, absorb(id year) vce(cluster id)
reghdfe ln低技能 企业产出 $firmvar, absorb(id year) vce(cluster id)

reghdfe 减排治理投资 lccpost $firmvar, absorb(id year) vce(cluster id)
reghdfe labor 减排治理投资 $firmvar, absorb(id year) vce(cluster id)
reghdfe ln高技能 减排治理投资 $firmvar, absorb(id year) vce(cluster id)
reghdfe ln低技能 减排治理投资 $firmvar, absorb(id year) vce(cluster id)

clear
use 企业数据.dta
xtset id year
global firmvar wage size lev ser tax grow roa
keep if 股权性质编码=="1"
reghdfe labor lccpost $firmvar, absorb(id year) vce(cluster id)

clear
use 企业数据.dta
xtset id year
global firmvar wage size lev ser tax grow roa
keep if 股权性质编码=="2"
reghdfe labor lccpost $firmvar, absorb(id year) vce(cluster id)

clear
use 企业数据.dta
xtset id year
global firmvar wage size lev ser tax grow roa
keep if 股权性质编码=="3"
reghdfe labor lccpost $firmvar, absorb(id year) vce(cluster id)


clear
use 企业数据.dta
xtset id year
global firmvar wage size lev ser tax grow roa
keep if 企业年龄>=16
reghdfe labor lccpost $firmvar, absorb(id year) vce(cluster id)

clear
use 企业数据.dta
xtset id year
global firmvar wage size lev ser tax grow roa
keep if 企业年龄<16
reghdfe labor lccpost $firmvar, absorb(id year) vce(cluster id)


clear
use 企业数据.dta
xtset id year
global firmvar wage size lev ser tax grow roa
keep if 产业==1
reghdfe labor lccpost $firmvar, absorb(id year) vce(cluster id)

clear
use 企业数据.dta
xtset id year
global firmvar wage size lev ser tax grow roa
keep if 产业==2
reghdfe labor lccpost $firmvar, absorb(id year) vce(cluster id)

clear
use 企业数据.dta
xtset id year
global firmvar wage size lev ser tax grow roa
keep if 产业==3
reghdfe labor lccpost $firmvar, absorb(id year) vce(cluster id)

clear
use 企业数据.dta
xtset id year
global firmvar wage size lev ser tax grow roa
keep if 高碳行业==1  
reghdfe labor lccpost $firmvar, absorb(id year) vce(cluster id)

clear
use 企业数据.dta
xtset id year
global firmvar wage size lev ser tax grow roa
keep if 高碳行业==0
reghdfe labor lccpost $firmvar, absorb(id year) vce(cluster id)

