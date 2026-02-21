package config

import (
	"fmt"
	"os"
)

type Config struct {
	USDAAPIKey string
	Port       string
}

func Load() (*Config, error) {
	key := os.Getenv("USDA_API_KEY")
	if key == "" {
		return nil, fmt.Errorf("USDA_API_KEY environment variable is required")
	}
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	return &Config{
		USDAAPIKey: key,
		Port:       port,
	}, nil
}
