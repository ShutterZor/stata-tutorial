## 4.1 常见图形绘制

通过 `help graph` 可以查看 `Stata` 中自带的可视化函数。a

```stata
*- 让数据满足绘图要求，二维图形中 (x,y) 需要一一对应
sysuse auto.dta, clear
collapse (mean) price, by(length)

*- 散点图
twoway scatter price length

*- 折线图
twoway line price length

*- 连线图（带样本点的折线图）
twoway connected price length

*- 柱状图
twoway bar price length // 描述两个变量之间的关系
graph bar price length // 自动取均值后比较

*- 直方图
histogram price // 面积和为 1

*- 密度函数图
kdensity price
kdensity price, normal
```

## 4.2 图形选项设置

### 4.2.1 常见图形绘制

最常见的图形选项设置是分别给 x 轴以及 y 轴加上名称，以及加上图例。

- 绘制任意函数图像并加上图例与设置角度以及线段颜色、粗细

  ```stata
  help twoway function
  
  twoway (function y=x^2, range(-5 20) lw(*1.5) color(red)) ///
         (function y=x^3, range(-5 20) lw(*2.0) color(blue)) ///
         (function y=ln(x), range(-5 20) lw(*2.5) color(green)), ///
         ylabel(, angle(-45)) ///
         yline(0, lcolor(black*0.5) lpattern(dash)) ///
         xlabel(, angle(0)) ///
         xline(0, lcolor(black*0.5) lpattern(dash)) ///
         legend(label(1 "y=x^2") label(2 "y=x^3") label(3 "y=ln(x)")) ///
         scheme(s1mono)
  ```

- 绘制 U 型曲线并加上图形标题

  ```stata
  sysuse auto.dta, clear
  
  reg price c.length#c.length
  
  twoway function y=0.1642153*x^2, range(0 233) ///
         ytitle("汽车价格") xtitle("汽车长度") ///
         title("价格与长度的二次曲线")
  
  // 补全负值
  twoway (function y=0.1642153*x^2, range(0 233)) ///
         (function y=0.1642153*x^2, range(-233 0) lpattern(dash)), ///
         ytitle("汽车价格") xtitle("汽车长度") ///
         title("价格与长度的二次曲线")	
  ```

此外，关于手动绘制调节效应图形的方法，请参考我的公众号推文[「Stata-手动绘制调节效应图」](https://mp.weixin.qq.com/s/HZ4wZB-0lizPPZKeSeD4ow)。

### 4.2.2 图形合并于导出

```stata
*- 保存绘制好的图片
sysuse auto.dta, clear
twoway scatter price length			
graph save FirstFigure.gph, replace // 保持绘图窗口不关闭时才能保存

*- 重新调用
graph use FirstFigure.gph

*- 调用时可换用不同的图片风格
    graph use FirstFigure.gph, scheme(s1mono)
    graph use FirstFigure.gph, scheme(s2mono)

*- 推荐使用手动保存方式
sysuse auto.dta, clear
twoway scatter price length	

*- 将图形导出为其他格式
help graph export
sysuse auto.dta, clear
twoway scatter price length	

graph export FirstFigure.png, replace
shellout FirstFigure.png

// 除 png 格式外，还有 .ps .eps .wmf .emf .pict .tif 等图片格式

*- 调整输出图片的分辨率
collapse (mean) price, by(length)
twoway connected price length	

graph export SecondFigure.png, width(1280) height(960) replace
shellout SecondFigure.png

*- 图形的合并（Stata 只能合并 gph 格式图片）
graph combine FirstFigure.gph SecondFigure.gph
graph combine FirstFigure.gph SecondFigure.gph, cols(1)

*- 删除图形 
graph dir
erase FirstFigure.gph
```

### 4.2.3 更改绘图模板

使用更优雅的绘图模板请参考我的推文：[「Stata绘图：用 Stata 绘制一打精美图片-schemes」](https://mp.weixin.qq.com/s/NAVd85dXuPNvYJXwIjzd2A)。

下载完模板后，放置于相应路径，下次绘图时直接更改图形选项中的 `scheme()` 即可，这里我推荐 `white_tableau`，图形效果见我的其他推文：[Stata-我的一些绘图代码](https://mp.weixin.qq.com/s/VGlhPCb65j8uD8bTRXiOWw)。

### 4.2.4 其他有用的图形

- 事件研究法绘图

  参考颖宝的推文：[「双重差分法之平行趋势检验」](https://zhuanlan.zhihu.com/p/387732407)。

- 中国地图绘制

  参考我的推文：[「Stata：空间计量之用-spmap-绘制地图 」](https://mp.weixin.qq.com/s/aQFtLhzlTjBvGbYXmHagIg)。
