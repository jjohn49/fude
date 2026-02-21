# syntax=docker/dockerfile:1

# --- Build stage ---
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o fude-backend .

# --- Runtime stage ---
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/fude-backend /fude-backend
EXPOSE 8080
ENTRYPOINT ["/fude-backend"]
