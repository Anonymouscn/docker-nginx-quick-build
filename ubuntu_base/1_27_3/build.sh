#!/bin/bash
# 拷贝 welcome page
cp ../../index.html tmp
# 交叉编译构建镜像
docker buildx build --platform linux/amd64,linux/arm64 -t pgl888999/nginx-in-docker:1.27.3 --push .
# 清除临时产物
rm -rf tmp/*