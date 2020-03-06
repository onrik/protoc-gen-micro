FROM golang:1.14 as builder
WORKDIR /tmp/proto
ENV GOPATH=/tmp/proto

RUN apt-get update
RUN apt-get install -y unzip

# protoc
RUN curl https://github.com/protocolbuffers/protobuf/releases/download/v3.11.4/protoc-3.11.4-linux-x86_64.zip -L -o protoc.zip
RUN unzip protoc.zip

# protoc-gen-go
RUN go get -d -u github.com/golang/protobuf/protoc-gen-go
RUN git -C "$(go env GOPATH)"/src/github.com/golang/protobuf checkout v1.3.4
RUN go install github.com/golang/protobuf/protoc-gen-go

# protoc-gen-micro
RUN go get github.com/micro/protoc-gen-micro
RUN git -C "$(go env GOPATH)"/src/github.com/micro/protoc-gen-micro checkout v1.0.0
RUN go install github.com/micro/protoc-gen-micro

FROM busybox:1.31-glibc
COPY --from=builder /tmp/proto/bin/protoc /usr/local/bin/protoc
COPY --from=builder /tmp/proto/bin/protoc-gen-go /usr/local/bin/protoc-gen-go
COPY --from=builder /tmp/proto/bin/protoc-gen-micro /usr/local/bin/protoc-gen-micro
