FROM alpine:latest AS base

RUN apk --no-cache update && \ 
    apk --no-cache upgrade && \
    apk --no-cache add python3 py-pip && \
    pip3 install --ignore-installed distlib pipenv && \
    addgroup -g 1000 runner && \
    adduser -D -u 1000 -G runner runner && \
    mkdir /app && chown -R runner:runner /app

FROM base AS build-tools
RUN apk --no-cache add \
    build-base \
    python3-dev 

FROM build-tools as builder
USER runner
ADD . /app
WORKDIR /app
RUN pipenv install

FROM base AS hblink
COPY --from=builder /home/runner/.local /home/runner/.local
COPY . /app
USER runner
WORKDIR /app

EXPOSE 62030

ENTRYPOINT [ "/app/docker_entrypoint.sh" ]
