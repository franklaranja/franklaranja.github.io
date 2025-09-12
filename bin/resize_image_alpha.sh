#!/data/data/com.termux/files/usr/bin/bash
img_identify=($(identify $1))
basename=${img_identify[0]%.*}
short_name=${basename##*/}

declare -i width=${img_identify[2]%x*}
percent=${2:-100}

echo ${img_identify[2]}
echo $basename
echo $width $percent

declare -i NEW_WIDTH=$((width * percent / 100))
# AVIF
magick "${img_identify[0]}" -strip -alpha on -resize "$NEW_WIDTH"x -quality 60 -define heic:speed=2 -format avif "${basename}.avif"
echo "Generated ${basename}.avif"
AVIF="/images/${short_name}.avif"

# WebP
magick "${img_identify[0]}" -strip -alpha on -resize "$NEW_WIDTH"x -quality 80 -define webp:lossless=false -format webp "${basename}.webp"
echo "Generated ${basename}.webp"
WEBP="/images/${short_name}.webp"

magick "${img_identify[0]}" -strip -resize "$NEW_WIDTH"x -format png "${basename}.png"
echo "Generated ${basename}.png"
PNG="/images/${short_name}.png"

cat <<END
<picture>
   <source srcset="${AVIF}" type="image/avif">
   <source srcset="${WEBP}" type="image/webp">
   <img src="$PNG" alt="">
</picture>
END
