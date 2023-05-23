VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

format:
    gofmt -s -w ./

build:
    go build -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=v1.0.2