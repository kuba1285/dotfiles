#!/bin/sh
######################################################## 
# Every photo should be the archlinux wallpaper.
#
# 適当にarchlinuxの壁紙を作る
#  要 imagemagick
#  要 bc
#  要 archlinux logo
########################################################

#######################################################
# 一時ファイル管理ディレクトリ
#######################################################
temp_dir=$(mktemp -d)
trap 'rm -rf ${temp_dir}' EXIT


#######################################################
# オプション処理
#######################################################

usage_exit() {
        echo "Usage: $0 [-b] [-p position] imagefile" 1>&2
        exit 1
}

while getopts p:bh OPT
do
    case $OPT in
        p)  trimpos=$OPTARG
            TRIM_FLAG="TRUE"
            ;;
        b)  BG_FLAG="TRUE"
            ;;
        h)  usage_exit
            ;;
        \?) usage_exit
            ;;
    esac
done

shift $((OPTIND - 1))

#######################################################
# 出力ファイル名を決定
#######################################################

# 入力された画像
input_image=${1}
i_dir=$(dirname ${input_image})
i_file=$(basename ${input_image})

# 出力ファイル名プレフィックス
pre_name="nekowp_"

# jpgファイルで出力する
result_file=${i_dir}/${pre_name}${i_file%.*}.jpg

# 大きさ調整された一時画像
scaled_image=${temp_dir}/scaled_image.png

# ロゴファイル
# aur/archlinux-artwork
# パッケージのインストールが必要
logo_svg="/usr/share/archlinux/logos/archlinux-grad1-light.svg"

# 影付きロゴ
shadowed_logo=${temp_dir}/shadowed_logo.png


#######################################################
# 基準点の変更
#######################################################
crop_pos="center"

if [ "$TRIM_FLAG" = "TRUE" ]; then
  case ${trimpos} in
    center) crop_pos="center"
      ;;
    north) crop_pos="north"
      ;;
    top) crop_pos="north"
      ;;
    south) crop_pos="south"
      ;;
    bottom) crop_pos="south"
      ;;
    east) crop_pos="east"
      ;;
    right) crop_pos="east"
      ;;
    west) crop_pos="west"
      ;;
    left) crop_pos="west"
      ;;
    *) crop_pos="center"
      ;;
  esac
fi

echo "crop_pos=${crop_pos}"

#######################################################
# 1920x1080サイズの画像
# 好きなモニタサイズに調整する
# bcコマンドが無いときは要インストール
#######################################################
mon_w=1920
mon_h=1080

iiw=`identify -format "%w" ${input_image}`
iih=`identify -format "%h" ${input_image}`

# check_ratio $1 $2 $3 $4
# 縦と横とどちらにあわせて縮小するかを自動で決める
#
# $1 input image width
# $2 input image height
# $3 monitor width
# $4 monitor height
# モニタの高さより大きいとき 1
# モニタの高さより小さいとき 0

function check_ratio(){
  echo $(echo "scale=5; ($2 / $1) > ($4 / $3)" | bc)
}

# 場合わけ付き縮小して切り取り処理
if [ `check_ratio ${iiw} ${iih} ${mon_w} ${mon_h}` -eq 1 ]; then
  convert ${input_image} -resize "${mon_w}x" - |
    convert - -gravity ${crop_pos} -crop "${mon_w}x${mon_h}"+0+0 \
    ${scaled_image}
else
  convert ${input_image} -resize "x${mon_h}" - |
    convert - -gravity ${crop_pos} -crop "${mon_w}x${mon_h}"+0+0 \
    ${scaled_image}
fi


#######################################################
# ロゴに影付け
#######################################################
convert -background none -density 96  ${logo_svg} \
  \( +clone -background "#000000" -shadow 100x5+5+5 \) \
  +swap -background none -layers merge +repage ${shadowed_logo}


#######################################################
# ロゴ合成
#######################################################
convert ${scaled_image} ${shadowed_logo} \
-gravity southwest -geometry +50+50 \
-composite \
${result_file}
