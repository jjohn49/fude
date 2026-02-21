package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"

	"github.com/hugh/fude-backend/internal/config"
	"github.com/hugh/fude-backend/internal/food"
	"github.com/hugh/fude-backend/internal/middleware"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("config error: %v", err)
	}

	usdaClient := food.NewUSDAClient(cfg.USDAAPIKey)
	foodHandler := food.NewHandler(usdaClient)

	r := chi.NewRouter()

	// Global middleware
	r.Use(chimiddleware.Logger)
	r.Use(chimiddleware.Recoverer)
	r.Use(chimiddleware.Timeout(15 * time.Second))
	r.Use(middleware.CORS())
	r.Use(middleware.RateLimit(60, time.Minute)) // 60 requests/min per IP

	// Health check
	r.Get("/health", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintln(w, `{"status":"ok"}`)
	})

	// Food routes
	r.Mount("/api/food", foodHandler.Routes())

	addr := ":" + cfg.Port
	log.Printf("fude-backend listening on %s", addr)
	if err := http.ListenAndServe(addr, r); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
