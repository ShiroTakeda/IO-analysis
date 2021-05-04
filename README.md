<!--
Filename:       README.md
Author:         Shiro Takeda
e-mail          <shiro.takeda@gmail.com>
First-written:	<2021/05/03>
Time-stamp:	<2021-05-04 21:25:24 st>
-->

GAMS, R, Excel による産業連関分析
==============================

## ファイル

| ファイル                                   | 説明                                                           |
| :----------------------------------------- | :------------------------------------------------------------- |
| `IO_analysis.xlsx`                         | Excel で産業連関分析をしたファイル                                               |
| `IO_analysis_1.gms`                        | GAMS で産業連関分析をしたファイル (1)                                             |
| `IO_analysis_2.gms`                        | GAMS で産業連関分析をしたファイル (2)                                             |
| `IO_analysis_3.gms`                        | GAMS で産業連関分析をしたファイル (3)                                             |
| `sample_IO_data.xlsx`                      | これは GAMS で利用しているデータが入ったファイル                                |
| `IO_analysis_1.r`                        | R で産業連関分析をしたファイル (1)                                             |
| `IO_analysis_2.r`                        | R で産業連関分析をしたファイル (2)                                             |
| `IO_analysis_3.r`                        | R で産業連関分析をしたファイル (3)                                             |
| `sample_IO_data_1.txt`                     | `IO_analysis_1.r` で利用しているデータ                          |
| `sample_IO_data_2.txt`                     | `IO_analysis_2.r` で利用しているデータ                          |
| `sample_IO_data_3.txt`                     | `IO_analysis_3.r` で利用しているデータ                          |
| `README.md`                                | このファイルです。                                             |


## データの説明

+ 3つのデータを利用している。
  + 架空の 4 部門の連関表データ
  + 日本の2011年の13部門表（単位は10億円）  
  + 日本の2015年の185部門表（単位は10億円）  


## シミュレーションの説明

+ どれも同じようなシミュレーションをおこなっている。
  + シミュレーション1: 全ての財に対する最終需要額を 1.1 倍にする。    
  + シミュレーション2: 建設業に対する最終需要額を 5000 億円増やす。


<!--
--------------------
Local Variables:
mode: markdown
fill-column: 80
coding: utf-8-dos
End:
-->
