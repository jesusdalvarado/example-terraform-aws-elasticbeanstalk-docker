docker build . -t redis-jesus:latest
cat ~/GH_PAT.txt | docker login ghcr.io -u jesusdalvarado --password-stdin
docker tag redis-jesus:latest ghcr.io/jesusdalvarado/redis-jesus:latest
docker push ghcr.io/jesusdalvarado/redis-jesus:latest