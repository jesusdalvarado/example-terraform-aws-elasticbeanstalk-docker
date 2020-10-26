FILES=./modules/*
GH_PAT=$1

echo "--- Pushing images from modules ---"

for f in $FILES
do
	echo "Processing module $f"
	sh "$f/publish_image.sh $GH_PAT"
done
