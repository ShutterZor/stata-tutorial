
clear
use 数据-城市.dta

gen city=1 if 省份=="广东省" & 年度 >= 2010
replace city=1 if 省份=="辽宁省" & 年度 >= 2010
replace city=1 if 省份=="湖北省" & 年度 >= 2010
replace city=1 if 省份=="陕西省" & 年度 >= 2010
replace city=1 if 省份=="云南省" & 年度 >= 2010
replace city=1 if 城市=="天津市" & 年度 >= 2010
replace city=1 if 城市=="重庆市" & 年度 >= 2010
replace city=1 if 城市=="深圳市" & 年度 >= 2010
replace city=1 if 城市=="厦门市" & 年度 >= 2010
replace city=1 if 城市=="杭州市" & 年度 >= 2010
replace city=1 if 城市=="南昌市" & 年度 >= 2010
replace city=1 if 城市=="贵阳市" & 年度 >= 2010
replace city=1 if 城市=="保定市" & 年度 >= 2010
gen policy=2010 if 省份=="广东省"
replace policy=2010 if 省份=="辽宁省"
replace policy=2010 if 省份=="湖北省"
replace policy=2010 if 省份=="陕西省"
replace policy=2010 if 省份=="云南省"
replace policy=2010 if 城市=="天津市"
replace policy=2010 if 城市=="重庆市"
replace policy=2010 if 城市=="深圳市"
replace policy=2010 if 城市=="厦门市"
replace policy=2010 if 城市=="杭州市"
replace policy=2010 if 城市=="南昌市"
replace policy=2010 if 城市=="贵阳市"
replace policy=2010 if 城市=="保定市"

replace city=1 if 省份=="海南省" & 年度 >= 2013
replace city=1 if 城市=="北京市" & 年度 >= 2013
replace city=1 if 城市=="上海市" & 年度 >= 2013
replace city=1 if 城市=="石家庄市" & 年度 >= 2013
replace city=1 if 城市=="秦皇岛市" & 年度 >= 2013
replace city=1 if 城市=="晋城市" & 年度 >= 2013
replace city=1 if 城市=="呼伦贝尔市" & 年度 >= 2013
replace city=1 if 城市=="吉林市" & 年度 >= 2013
replace city=1 if 城市=="苏州市" & 年度 >= 2013
replace city=1 if 城市=="淮安市" & 年度 >= 2013
replace city=1 if 城市=="镇江市" & 年度 >= 2013
replace city=1 if 城市=="宁波市" & 年度 >= 2013
replace city=1 if 城市=="温州市" & 年度 >= 2013
replace city=1 if 城市=="池州市" & 年度 >= 2013
replace city=1 if 城市=="南平市" & 年度 >= 2013
replace city=1 if 城市=="景德镇市" & 年度 >= 2013
replace city=1 if 城市=="赣州市" & 年度 >= 2013
replace city=1 if 城市=="青岛市" & 年度 >= 2013
replace city=1 if 城市=="济源市" & 年度 >= 2013
replace city=1 if 城市=="广元市" & 年度 >= 2013
replace city=1 if 城市=="遵义市" & 年度 >= 2013
replace city=1 if 城市=="金昌市" & 年度 >= 2013
replace city=1 if 城市=="乌鲁木齐市" & 年度 >= 2013
replace policy=2013 if 省份=="海南省"
replace policy=2013 if 城市=="北京市"
replace policy=2013 if 城市=="上海市"
replace policy=2013 if 城市=="石家庄市"
replace policy=2013 if 城市=="秦皇岛市"
replace policy=2013 if 城市=="晋城市"
replace policy=2013 if 城市=="呼伦贝尔市"
replace policy=2013 if 城市=="吉林市"
replace policy=2013 if 城市=="苏州市"
replace policy=2013 if 城市=="淮安市"
replace policy=2013 if 城市=="镇江市"
replace policy=2013 if 城市=="宁波市"
replace policy=2013 if 城市=="温州市"
replace policy=2013 if 城市=="池州市"
replace policy=2013 if 城市=="南平市"
replace policy=2013 if 城市=="景德镇市"
replace policy=2013 if 城市=="赣州市"
replace policy=2013 if 城市=="青岛市"
replace policy=2013 if 城市=="济源市"
replace policy=2013 if 城市=="广元市"
replace policy=2013 if 城市=="遵义市"
replace policy=2013 if 城市=="金昌市"
replace policy=2013 if 城市=="乌鲁木齐市"

replace city=1 if 城市=="乌海市" & 年度 >= 2017
replace city=1 if 城市=="南京市" & 年度 >= 2017
replace city=1 if 城市=="常州市" & 年度 >= 2017
replace city=1 if 城市=="嘉兴市" & 年度 >= 2017
replace city=1 if 城市=="金华市" & 年度 >= 2017
replace city=1 if 城市=="衢州市" & 年度 >= 2017
replace city=1 if 城市=="合肥市" & 年度 >= 2017
replace city=1 if 城市=="淮北市" & 年度 >= 2017
replace city=1 if 城市=="黄山市" & 年度 >= 2017
replace city=1 if 城市=="六安市" & 年度 >= 2017
replace city=1 if 城市=="宣城市" & 年度 >= 2017
replace city=1 if 城市=="三明市" & 年度 >= 2017
replace city=1 if 城市=="共青城市" & 年度 >= 2017
replace city=1 if 城市=="吉安市" & 年度 >= 2017
replace city=1 if 城市=="抚州市" & 年度 >= 2017
replace city=1 if 城市=="济南市" & 年度 >= 2017
replace city=1 if 城市=="烟台市" & 年度 >= 2017
replace city=1 if 城市=="潍坊市" & 年度 >= 2017
replace city=1 if 城市=="长沙市" & 年度 >= 2017
replace city=1 if 城市=="株洲市" & 年度 >= 2017
replace city=1 if 城市=="湘潭市" & 年度 >= 2017
replace city=1 if 城市=="郴州市" & 年度 >= 2017
replace city=1 if 城市=="成都市" & 年度 >= 2017
replace city=1 if 城市=="普洱市" & 年度 >= 2017
replace city=1 if 城市=="拉萨市" & 年度 >= 2017
replace city=1 if 城市=="兰州市" & 年度 >= 2017
replace city=1 if 城市=="敦煌市" & 年度 >= 2017
replace city=1 if 城市=="西宁市" & 年度 >= 2017
replace city=1 if 城市=="银川市" & 年度 >= 2017
replace city=1 if 城市=="吴忠市" & 年度 >= 2017
replace city=1 if 城市=="昌吉市" & 年度 >= 2017
replace city=1 if 城市=="伊宁市" & 年度 >= 2017
replace city=1 if 城市=="和田市" & 年度 >= 2017
replace city=1 if 城市=="第一师阿拉尔市" & 年度 >= 2017
replace city=0 if city==.
replace policy=2017 if 城市=="乌海市"
replace policy=2017 if 城市=="南京市"
replace policy=2017 if 城市=="常州市"
replace policy=2017 if 城市=="嘉兴市"
replace policy=2017 if 城市=="金华市"
replace policy=2017 if 城市=="衢州市"
replace policy=2017 if 城市=="合肥市"
replace policy=2017 if 城市=="淮北市"
replace policy=2017 if 城市=="黄山市"
replace policy=2017 if 城市=="六安市"
replace policy=2017 if 城市=="宣城市"
replace policy=2017 if 城市=="三明市"
replace policy=2017 if 城市=="共青城市"
replace policy=2017 if 城市=="吉安市"
replace policy=2017 if 城市=="抚州市"
replace policy=2017 if 城市=="济南市"
replace policy=2017 if 城市=="烟台市"
replace policy=2017 if 城市=="潍坊市"
replace policy=2017 if 城市=="长沙市"
replace policy=2017 if 城市=="株洲市"
replace policy=2017 if 城市=="湘潭市"
replace policy=2017 if 城市=="郴州市"
replace policy=2017 if 城市=="成都市"
replace policy=2017 if 城市=="普洱市"
replace policy=2017 if 城市=="拉萨市"
replace policy=2017 if 城市=="兰州市"
replace policy=2017 if 城市=="敦煌市"
replace policy=2017 if 城市=="西宁市"
replace policy=2017 if 城市=="银川市"
replace policy=2017 if 城市=="吴忠市"
replace policy=2017 if 城市=="昌吉市"
replace policy=2017 if 城市=="伊宁市"
replace policy=2017 if 城市=="和田市"
replace policy=2017 if 城市=="第一师阿拉尔市"
replace policy=2050 if policy==.


xtset 城市编号 年度
rename city citylccpost
global firmvar1 pgdp pop ind urb es
global firmvar2 citywage pop pgdp rsc
sum co2 citylabor citylccpost pgdp pop ind urb es citywage rsc
reghdfe co2 citylccpost $firmvar1, absorb(城市 年度) vce(cluster 城市)
reghdfe citylabor citylccpost $firmvar2, absorb(城市 年度) vce(cluster 城市)


