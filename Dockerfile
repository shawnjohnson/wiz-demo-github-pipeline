FROM golang:1.21-alpine AS builder
RUN apk add --no-cache --update build-base
RUN which gcc
CMD ["sleep", "infinity"]