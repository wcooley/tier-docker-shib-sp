docker buildx create --use --name multiarch
docker buildx inspect --bootstrap

# git clone -b 3.3.0_09152022-rocky8-multi-arch-test https://github.internet2.edu/docker/shib-sp.git


#docker buildx build --platform linux/amd64,linux/arm64 --pull . 
docker buildx build --platform linux/amd64 -t shib-sp  .
docker buildx build --platform linux/arm64 -t shib-sp:arm64 .

#docker buildx build --push --platform linux/arm64 -t i2incommon/shib-sp:3.3.0_09152022-rocky8-multi-arch-test .
docker buildx build --push --platform linux/arm64,linux/amd64 -t i2incommon/shib-sp:3.3.0_09152022-rocky8-multi-arch-test .
 




# works for both docker buildx build --platform linux/amd64,linux/arm64 -t local/grouper:latest --output=type=docker --push --pull . 
# output to local dir:
#docker buildx build --platform linux/amd64,linux/arm64 -t local/grouper:latest --output=type=local,dest=foo --pull . 

# works docker buildx build --platform linux/amd64 --pull --tag=itap/grouper:latest . \
#docker buildx build --platform linux/arm64/v8 --pull --tag=itap/grouper:latest . \

if [[ "$OSTYPE" == "darwin"* ]]; then
  say build complete
fi
