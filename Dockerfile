FROM crystallang/crystal:0.34.0-alpine

RUN apk add ncurses-dev ncurses-static sqlite-dev sqlite-static
