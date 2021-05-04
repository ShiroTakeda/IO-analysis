##################################################
##
##  R を使って産業連関分析
##

## 部門数
sec_num = 4

## IOデータのファイル名
data_file = "sample_IO_data_1.txt"

## テキストファイルからIO表のデータを読み込む
io = matrix(scan(data_file,skip=1), nrow=sec_num+2, ncol=sec_num+2, byrow = TRUE)
io

## 投入額行列
z = matrix(0, nrow = sec_num, ncol = sec_num)
z

z = io[1:sec_num,1:sec_num]
z

## 最終需要額のベクトル
v_fd = numeric(sec_num)
v_fd

v_fd = io[1:sec_num,sec_num+1]
v_fd

## 単位行列の作成
imat = diag(sec_num)
imat

## 生産額ベクトルの作成

## まず、0 のベクトルを作成しておく
x = numeric(sec_num)
x

## 各行の行和を求めて生産額とする。
for (i in 1:sec_num)
{
    zz = z[i,]
    x[i] = sum(zz) + v_fd[i]
}
x

## 投入係数行列の作成。とりあえず 0 を入れる。
a = matrix(0, nrow = sec_num, ncol = sec_num)
a

## 投入係数の計算
for (i in 1:sec_num)
{
    a[,i] = z[,i] / x[i]
}
a

## (I - A) 行列の作成
imat_a = imat - a
imat_a

## (I - A) 行列の逆行列の作成
inv_imat_a = solve(imat_a)
inv_imat_a

## (I - A) * (I - A)^(-1) = I となるか確認
chk_imat = imat_a %*% inv_imat_a
chk_imat

## 元の最終需要額
chk_fd_org = v_fd
chk_fd_org

## 元の生産額
chk_x_org = x
chk_x_org

## (I - A)^(-1) * FD で元の生産額が再現できるかチェック
chk_x = inv_imat_a %*% chk_fd_org
chk_x

##################################################
## シミュレーション

chk_fd_new = matrix(0, nrow=sec_num, ncol = 2)
chk_fd_rate = matrix(0, nrow=sec_num, ncol = 2)
chk_x_new = matrix(0, nrow=sec_num, ncol = 2)
chk_x_rate = matrix(0, nrow=sec_num, ncol = 2)

### シナリオ1

## 新しい最終需要額
chk_fd_new[,1] = chk_fd_org * 1.1
chk_fd_new

## 新しい生産額の計算
chk_x_new[,1] = inv_imat_a %*% chk_fd_new[,1]
chk_x_new

### シナリオ2

## 新しい最終需要額
chk_fd_new[,2] = chk_fd_org
chk_fd_new[4,2] = chk_fd_org[4] + 500
chk_fd_new

## 新しい生産額の計算
chk_x_new[,2] = inv_imat_a %*% chk_fd_new[,2]
chk_x_new

### 計算まとめ

## 最終需要の変化率
colnames(chk_fd_rate) <- c("sce1","sce2")
chk_fd_rate = (chk_fd_new / chk_fd_org - 1) * 100
chk_fd_rate

## 生産額の変化率
colnames(chk_x_rate) <- c("sce1","sce2")
chk_x_rate = (chk_x_new / chk_x_org - 1) * 100
chk_x_rate


## --------------------
## Local Variables:
## fill-column: 80
## mode: ess-r-mode
## End:
