FROM alpine:latest
RUN apk update && apk add curl bash go
RUN curl https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-linux-x86_64.tgz -o speedtest.tgz && tar -xzf speedtest.tgz && mv speedtest /usr/bin
RUN go get github.com/fullstorydev/grpcurl/... && go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
RUN ls -la && pwd
RUN mv ~/go/bin/grpcurl /usr/bin
RUN curl https://raw.githubusercontent.com/Tysonpower/starlinkstatus/main/windowsinstall/starlinkstatus_client.sh -o /usr/bin/starlinkstatus_client.sh && chmod +x /usr/bin/starlinkstatus_client.sh
RUN speedtest --accept-license --accept-gdpr
ENTRYPOINT watch -n 900 starlinkstatus_client.sh -k $APIKEY -s -d

