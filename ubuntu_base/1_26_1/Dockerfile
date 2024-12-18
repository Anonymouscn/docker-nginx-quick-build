########## nginx builder container ##########
FROM ubuntu:latest AS builder
WORKDIR /build
RUN apt-get update && \
    apt-get install build-essential ca-certificates tar curl cmake ninja-build mercurial pkg-config libunwind-dev libpcre3 libpcre3-dev openssl libssl-dev zlib1g-dev git wget software-properties-common -y && \
    add-apt-repository ppa:longsleep/golang-backports -y && \
    apt-get update && \
    apt-get install golang-go -y && \
    git clone --depth=1 https://github.com/google/boringssl.git && \
    cd boringssl && mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make V=s -j $(nproc) && cd ../.. && \
    git clone --recurse-submodules -j$(nproc) https://github.com/google/ngx_brotli && cd ngx_brotli/deps/brotli && \
    mkdir out && cd out && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed .. && cmake --build . --config Release --target brotlienc && \
    cmake --build . --config Release --target brotlienc && \
    cd ../../../.. && \
    wget https://nginx.org/download/nginx-1.26.1.tar.gz && \
    tar -zxvf nginx-1.26.1.tar.gz && \
    cd nginx-1.26.1 && ./configure  --prefix=/usr/local/nginx \
        --with-debug \
        --with-http_v3_module \
        --with-http_v2_module \
        --with-stream \
        --with-cc=c++ \
        --add-module=../ngx_brotli \
        --with-cc-opt="-I../boringssl/include -x c" \
        --with-ld-opt="-L../boringssl/build/ssl -L../boringssl/build/crypto" \
        --with-http_gzip_static_module && \
    make V=s -j $(nproc) && make install

########## base container ##########
FROM ubuntu:latest
# copy nginx product
COPY --from=builder /usr/local/nginx  /usr/local/nginx
# copy nginx config
## COPY nginx.conf /usr/local/nginx/conf/nginx.conf
# copy static files
## COPY dist/ /usr/local/nginx/html/platform
## COPY robots.txt /usr/local/nginx/html
# copy welcome page
COPY ./tmp/index.html /usr/local/nginx/html
# install necessary libraries
RUN apt-get update -y && \
    apt-get install libpcre3 libpcre3-dev libssl-dev -y
# expose ports and run container
EXPOSE 80 80/udp 443 443/udp
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]