FILES=./modules/*
GH_PAT=$1

echo "--- Pushing images from modules ---"

for f in $FILES
do
	echo "Processing module $f"
	echo "---111 $f/publish_image.sh $GH_PAT"
	sh "$f/publish_image.sh $GH_PAT"
done
