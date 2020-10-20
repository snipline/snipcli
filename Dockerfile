FROM crystallang/crystal:0.35.1-alpine
RUN apk add --update --no-cache --force-overwrite \
openssl-libs-static openssl-dev g++ gc-dev \
libc-dev libevent-dev libevent-static libxml2-dev llvm llvm-dev \
llvm-static make pcre-dev readline-dev readline-static \
yaml-dev zlib-dev zlib-static ncurses-static sqlite-dev sqlite-static openssl-dev
#ncurses-libs ncurses-dev

