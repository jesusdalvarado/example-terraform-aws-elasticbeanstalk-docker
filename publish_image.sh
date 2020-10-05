docker build . -t jesusdalvarado-example-image:latest
cat ~/GH_PAT.txt | docker login ghcr.io -u jesusdalvarado --password-stdin
docker tag jesusdalvarado-example-image:latest ghcr.io/jesusdalvarado/jesus-image:latest
docker push ghcr.io/jesusdalvarado/jesus-image:latest