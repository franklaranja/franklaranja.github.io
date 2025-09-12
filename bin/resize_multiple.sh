#!/data/data/com.termux/files/usr/bin/bash
img_identify=($(identify $1))
basename=${img_identify[0]%.*}
short_name=${basename##*/}

declare -i width=${img_identify[2]%x*}
percent=${2:-100}

echo ${img_identify[2]}
echo $basename
echo $width $percent
declare -a SIZES="480 960 1920"
for SIZE in $SIZES; do
  [[ $SIZE -lt $width ]] && NEW_SIZE=$SIZE || NEW_SIZE=$width
  declare -i NEW_WIDTH=$((NEW_SIZE * percent / 100))

  echo doing $SIZE to $NEW_SIZE ${percent}% $NEW_WIDTH

  magick "${img_identify[0]}" -strip -resize "$NEW_WIDTH"x -quality 60 -define heic:speed=2 -format avif "${basename}-${NEW_WIDTH}.avif"
  echo "Generated ${basename}-${NEW_WIDTH}.avif"
  AVIF="${AVIF}/images/${short_name}-${NEW_WIDTH}.avif ${NEW_WIDTH}w, "

  magick "${img_identify[0]}" -strip -resize "$NEW_WIDTH"x -quality 80 -define webp:lossless=false -format webp "${basename}-${NEW_WIDTH}.webp"
  echo "Generated ${basename}-${NEW_WIDTH}.webp"
  WEBP="${WEBP}/images/${short_name}-${NEW_WIDTH}.webp ${NEW_WIDTH}w, "

  SET_SIZES="${SET_SIZES}(max-width: ${SIZE}px) ${NEW_WIDTH}px, "
done

# # AVIF
# magick "${img_identify[0]}" -strip -resize "$NEW_WIDTH"x -quality 60 -define heic:speed=2 -format avif "${basename}.avif"
# echo "Generated ${basename}.avif"
# AVIF="/images/${short_name}.avif"
#
# # WebP
# magick "${img_identify[0]}" -strip -resize "$NEW_WIDTH"x -quality 80 -define webp:lossless=false -format webp "${basename}.webp"
# echo "Generated ${basename}.webp"
# WEBP="/images/${short_name}.webp"
#
# # JPEG
magick "${img_identify[0]}" -strip -resize "$NEW_WIDTH"x -quality 85 -format jpg "${basename}.jpg"
echo "Generated ${basename}.jpg"
JPG="/images/${short_name}.jpg"

AVIF=${AVIF%,*}
SET_SIZES=${SET_SIZES%,*}
SET_SIZES=${SET_SIZES%,*}
SET_SIZES="${SET_SIZES}, $NEW_WIDTH"
cat <<END
<picture>
   <source srcset="${AVIF}" sizes="$SET_SIZES" type="image/avif">
   <source srcset="${WEBP}" sizes="$SET_SIZES" type="image/webp">
   <img src="$JPG" alt="">
</picture>
END
