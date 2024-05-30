FROM alpine:latest
RUN apk update && apk add curl bash go jq
RUN curl https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-`uname -m`.tgz -o speedtest.tgz \
    && tar -xzf speedtest.tgz \
    && mv speedtest /usr/bin
RUN go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
RUN mv ~/go/bin/grpcurl /usr/bin
WORKDIR /app
COPY --chmod=550 starlinkstatus_client.sh .
ENTRYPOINT ./starlinkstatus_client.sh

