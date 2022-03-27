FROM golang:1-alpine as builder

RUN apk --no-cache --no-progress add git ca-certificates tzdata make \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*

WORKDIR /go/whoami

# Download go modules
COPY go.mod .
COPY go.sum .
COPY healthcheck ./healthcheck

RUN GO111MODULE=on GOPROXY=https://proxy.golang.org go mod download
RUN CGO_ENABLED=0 go build -a -installsuffix cgo -o health-check "./healthcheck"

COPY . .

RUN make build

# Create a minimal container to run a Golang static binary
FROM scratch

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/whoami/whoami .
COPY --from=builder /go/whoami/health-check ./healthcheck

HEALTHCHECK --interval=1s --timeout=60s --start-period=15s --retries=3 CMD [ "/healthcheck" ]

ENV HEALTH_PORT_NUMBER=80

ENTRYPOINT ["/whoami"]
EXPOSE $HEALTH_PORT_NUMBER

