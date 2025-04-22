#multistage builds as implemented to reduce the size 
FROM golang:1.22.5  AS base

WORKDIR /app

COPY go.mod .

RUN go mod download

COPY . .

RUN go build -o main .

FROM alpine:latest 

WORKDIR /app

COPY --from=base /app/main .

COPY --from=base /app/static ./static

EXPOSE 8080
 
CMD ["./main"]







