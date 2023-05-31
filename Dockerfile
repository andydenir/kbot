FROM golang:1.20 as build

WORKDIR /go/src/app
COPY . .
RUN make build

FROM scratch
WORKDIR /
COPY --from=build /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]