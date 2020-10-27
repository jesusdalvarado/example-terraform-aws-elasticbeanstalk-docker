GH_PAT=$1

docker build ./modules/webserver/ -t jesusdalvarado-example-image:latest
echo $GH_PAT | docker login ghcr.io -u jesusdalvarado --password-stdin
docker tag jesusdalvarado-example-image:latest ghcr.io/jesusdalvarado/jesus-image:latest
docker push ghcr.io/jesusdalvarado/jesus-image:latest