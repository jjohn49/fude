package food

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"
)

type Handler struct {
	client *USDAClient
}

func NewHandler(client *USDAClient) *Handler {
	return &Handler{client: client}
}

func (h *Handler) Routes() chi.Router {
	r := chi.NewRouter()
	r.Get("/search", h.search)
	r.Get("/{fdcId}", h.detail)
	return r
}

func (h *Handler) search(w http.ResponseWriter, r *http.Request) {
	q := strings.TrimSpace(r.URL.Query().Get("q"))
	if q == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "q parameter is required"})
		return
	}

	result, err := h.client.Search(q)
	if err != nil {
		writeJSON(w, http.StatusBadGateway, map[string]string{"error": "food search unavailable"})
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func (h *Handler) detail(w http.ResponseWriter, r *http.Request) {
	fdcID := chi.URLParam(r, "fdcId")

	item, err := h.client.Detail(fdcID)
	if err != nil {
		writeJSON(w, http.StatusBadGateway, map[string]string{"error": "food lookup unavailable"})
		return
	}
	if item == nil {
		writeJSON(w, http.StatusNotFound, map[string]string{"error": "food not found"})
		return
	}

	writeJSON(w, http.StatusOK, item)
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
