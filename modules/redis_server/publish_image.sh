GH_PAT=$1

docker build . -t redis-jesus:latest
echo $GH_PAT | docker login ghcr.io -u jesusdalvarado --password-stdin
docker tag redis-jesus:latest ghcr.io/jesusdalvarado/redis-jesus:latest
docker push ghcr.io/jesusdalvarado/redis-jesus:latest