#CARDENAS ROBERTO
#APP1
FROM golang:1.15 as builder
WORKDIR /go/src/github.com/devops
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -v -o app
##esta linea es requerida para que funcione

FROM alpine
RUN apk update && apk add --no-cache ca-certificates
COPY --from=builder /go/src/github.com/devops/app /app
CMD ["/app"]
