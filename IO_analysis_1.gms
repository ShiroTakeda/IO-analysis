$title GAMS による産業連関分析
display "@ GAMS による産業連関分析";
$ontext
Time-stamp:     <2021-05-04 13:51:23 st>
First-written:  <2021/05/02>

$offtext

*       excel -> gdx の変換をするときには 1 を設定。一度作成したら 0 にすればよい。
$setglobal fl_data_remake 1

*       部門数
$setglobal sec_num 4

$setglobal gdx_file sample_data_1
$setglobal temp_file temp_1
$setglobal inv_gdx_file inverse_data_1
$setglobal excel_range IO_ex_1!B4:H10

$eolcom #

display "@ 集合の定義";

set     i       部門のインデックス              / i1*i%sec_num% /
        v       付加価値部門のインデックス      / va /
        f       最終需要部門のインデックス      / fd /
;
alias (i,j), (i,ii);
display i;

display "@ IO表の読み込み";

parameter
    io(*,*)             産業連関表
    z(*,*)              投入額（内生部門）
    a(*,*)              投入係数行列
    imat(*,*)           単位行列
    imat_a(*,*)         "単位行列－投入係数行列（I-A）"
    v_fd(*,*)           最終需要額
    v_va(*,*)           付加価値額
    v_xr(*)             生産額（行和）
    v_xc(*)             生産額（列和）
;
*       まず、excel から gdx ファイルにデータを出力
$onecho > temp.txt
i=sample_IO_data.xlsx o=%gdx_file%.gdx
par=io rng=%excel_range%
$offecho

$if not %fl_data_remake%==0 $call '=gdxxrw @temp.txt'

*       gdx ファイルからデータの読み込み
$gdxin %gdx_file%.gdx
$load io

option io:0;
display io;

display "@ データの加工";

*       投入額（内生部門）
z(i,j) = io(i,j);
display z;

*       最終需要額
v_fd(i,f) = io(i,f);
v_fd(i,"sum") = sum(f, v_fd(i,f));
display v_fd;

*       付加価値額
v_va(v,j) = io(v,j);
v_va("sum",j) = sum(v, v_va(v,j));
display v_va;

*       生産額（行和）
v_xr(i) = sum(j, io(i,j)) + sum(f, io(i,f));
display v_xr;

*       生産額（列和）
v_xc(i) = sum(j, io(j,i)) + sum(v, io(v,i));
display v_xc;

*       投入係数行列
a(i,j) = z(i,j) / v_xr(j);
option a:6;
display a;

*       単位行列
imat(i,j) = 0;
imat(i,i) = 1;
display imat;

*       単位行列－投入係数行列（I-A）
imat_a(i,j) = imat(i,j) - a(i,j);
option imat_a:6;
display imat_a;

display "@ 逆行列の作成";
$ontext
+ 逆行列の計算には GAMS に付属の invert というプログラムを利用する。
+ invert について詳しくは以下のページ
  + https://www.gams.com/34/docs/T_INVERT.html

手順
+ imat_a 行列を gdx ファイルに出力
+ その gdx ファイルの行列を invert を使って逆行列に変換し、別の gdx ファイルに出力
+ 逆行列を gdx ファイルから読み込む

$offtext
parameter
    inv_imat_a(i,j)         "I-Aの逆行列"
;
*       imat_a & i を gdx ファイルに出力
execute_unload '%temp_file%.gdx', i, imat_a;

*       invert を実行
execute '=invert.exe %temp_file%.gdx i imat_a %inv_gdx_file%.gdx inv_imat_a';

*       inv_imat_a を gdx ファイルから読み込む
execute_load '%inv_gdx_file%.gdx', inv_imat_a;

option inv_imat_a:6;
display inv_imat_a;

$ontext
実際に逆行列が正しいかを (I-A)^(-1) * (I-A) を計算してチェック。

$offtext
parameter
    chk_mat     行列のチェック;

chk_mat(i,j) = sum(ii, inv_imat_a(i,ii)*imat_a(ii,j));
display chk_mat;

$ontext
(I-A)^(-1) * FD によって元の生産額が再現できるかチェックする。
$offtext

parameter
    chk_output
;
*       元のFD（合計）
chk_output(i,"org") = v_xr(i);
*       生産額を再現
chk_output(i,"chk") = sum(ii, inv_imat_a(i,ii)*v_fd(ii,"sum"));
*       両者の差を計算
chk_output(i,"org-chk") = chk_output(i,"org") - chk_output(i,"chk");
chk_output(i,"org-chk") = round(chk_output(i,"org-chk"), 6);

display chk_output;

*       ------------------------------------------------------------
display "@ シミュレーション";

parameter
    v_fd_org    元の最終需要額
    v_fd_new    新しい最終需要額
    v_x_new     新しい生産額
;
v_fd_org(i) = v_fd(i,"sum");
display v_fd_org;

set     sce     シナリオ /
        sce1    "全ての財の最終需要額を10%ずつ増加"
        sce2    "建設業（i4）に対する最終需要額が5000億円増加"
        /;

parameter
    chk_x               "生産額のチェック"
    chk_fd              "最終需要額のチェック"
    chk_x_diff          "生産額の変化のチェック"
    chk_x_rate          "生産額の変化率（%）のチェック"
    chk_fd_diff         "最終需要額の変化額のチェック"
    chk_fd_rate         "最終需要額の変化率（%）のチェック"
;

*       元の値
chk_x(i,"org") = v_xr(i);
chk_x("sum","org") = sum(i, chk_x(i,"org"));
chk_fd(i,"org") = v_fd_org(i);
chk_fd("sum","org") = sum(i, chk_fd(i,"org"));

$macro chk_result(sce) \
     chk_x(i,sce) = v_x_new(i); \
    chk_x("sum",sce) = sum(i, chk_x(i,sce)); \
    chk_fd(i,sce) = v_fd_new(i); \
    chk_fd("sum",sce) = sum(i, chk_fd(i,sce));


display "@@ シナリオ1: 最終需要額の変化の影響";
$ontext
全ての財に対する最終需要を 10 %ずつ増加させる。

$offtext
*       最終需要の額を10%増加
v_fd_new(i) = v_fd_org(i) * 1.1;

*       新しい生産額の計算
v_x_new(i) = sum(ii, inv_imat_a(i,ii)*v_fd_new(ii));

*       結果の代入
chk_result("sce1");


display "@@ シナリオ2: ";
$ontext
建設業（i4）に対する最終需要額が5000億円増加

$offtext
*       最終需要の額
v_fd_new(i) = v_fd_org(i);
v_fd_new("i4") = v_fd_org("i4") + 500;

*       新しい生産額の計算
v_x_new(i) = sum(ii, inv_imat_a(i,ii)*v_fd_new(ii));

*       結果の代入
chk_result("sce2");

display "@@ まとめ ";

*       最終需要額の変化額のチェック
chk_fd_diff(i,sce) = chk_fd(i,sce) - chk_fd(i,"org");
chk_fd_diff("sum",sce) = sum(i, chk_fd_diff(i,sce));

*       最終需要額の変化率のチェック
chk_fd_rate(i,sce)$chk_fd(i,"org")
    = 100 * (chk_fd(i,sce) / chk_fd(i,"org") - 1);
chk_fd_rate("sum",sce)$chk_fd("sum","org")
    = 100 * (chk_fd("sum",sce) / chk_fd("sum","org") - 1);

*       生産額の変化のチェック
chk_x_diff(i,sce) = chk_x(i,sce) - chk_x(i,"org");
chk_x_diff("sum",sce) = sum(i, chk_x_diff(i,sce));

*       生産額の変化率のチェック
chk_x_rate(i,sce)$chk_x(i,"org")
    = 100 * (chk_x(i,sce) / chk_x(i,"org") - 1);
chk_x_rate("sum",sce)$chk_x("sum","org")
    = 100 * (chk_x("sum",sce) / chk_x("sum","org") - 1);

*       結果のチェック
option chk_x_rate:5; # 小数点以下の桁数を 5 桁とする。

display chk_fd, chk_fd_diff, chk_fd_rate, chk_x, chk_x_diff, chk_x_rate;

*       ファイルの削除
execute 'del temp.txt';
execute 'del %temp_file%.gdx';
execute 'del %inv_gdx_file%.gdx';

* --------------------
* Local Variables:
* mode: gams
* fill-column: 80
* End:
