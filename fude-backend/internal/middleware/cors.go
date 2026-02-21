package middleware

import (
	"github.com/go-chi/cors"
	"net/http"
)

// CORS returns middleware that allows all origins.
// iOS URLSession requests have no Origin header, so AllowedOrigins: ["*"] is safe.
func CORS() func(http.Handler) http.Handler {
	return cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Content-Type"},
		AllowCredentials: false,
		MaxAge:           300,
	})
}
