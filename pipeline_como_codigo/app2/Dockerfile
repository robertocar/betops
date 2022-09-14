#CARDENAS ROBERTO
#APP2 
FROM golang:1.15 as builder
EXPOSE 8080
WORKDIR /go/src/github.com/devops
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -v -o app

FROM alpine
RUN apk update && apk add --no-cache ca-certificates
COPY --from=builder /go/src/github.com/devops/app /app
CMD ["/app"]