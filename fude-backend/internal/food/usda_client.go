package food

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
)

const usdaBase = "https://api.nal.usda.gov/fdc/v1"

// --- USDA raw types (what the USDA API actually returns) ---

type usdaSearchResponse struct {
	Foods []usdaFoodItem `json:"foods"`
}

type usdaFoodItem struct {
	FdcID         int             `json:"fdcId"`
	Description   string          `json:"description"`
	BrandOwner    *string         `json:"brandOwner"`
	BrandName     *string         `json:"brandName"`
	FoodNutrients []usdaNutrient  `json:"foodNutrients"`
}

// Search result nutrients use "value"
type usdaNutrient struct {
	NutrientID int     `json:"nutrientId"`
	Value      float64 `json:"value"`
}

type usdaDetailResponse struct {
	FdcID         int                  `json:"fdcId"`
	Description   string               `json:"description"`
	BrandOwner    *string              `json:"brandOwner"`
	BrandName     *string              `json:"brandName"`
	FoodNutrients []usdaDetailNutrient `json:"foodNutrients"`
}

// Detail result nutrients have a nested "nutrient" object
type usdaDetailNutrient struct {
	Nutrient struct {
		ID int `json:"id"`
	} `json:"nutrient"`
	Amount float64 `json:"amount"`
}

// --- iOS-facing output types (what we return to the iOS app) ---

// SearchResponse is what we return for /api/food/search
type SearchResponse struct {
	Foods []OutputFoodItem `json:"foods"`
}

// OutputFoodItem matches what FoodProxyService.swift decodes
type OutputFoodItem struct {
	FdcID         int              `json:"fdcId"`
	Description   string           `json:"description"`
	BrandOwner    *string          `json:"brandOwner"`
	BrandName     *string          `json:"brandName"`
	FoodNutrients []OutputNutrient `json:"foodNutrients"`
}

// OutputNutrient uses "amount" to match iOS CodingKeys: value = "amount"
type OutputNutrient struct {
	NutrientID int     `json:"nutrientId"`
	Amount     float64 `json:"amount"`
}

// --- Client ---

type USDAClient struct {
	apiKey     string
	httpClient *http.Client
}

func NewUSDAClient(apiKey string) *USDAClient {
	return &USDAClient{
		apiKey:     apiKey,
		httpClient: &http.Client{},
	}
}

func (c *USDAClient) Search(query string) (*SearchResponse, error) {
	u := fmt.Sprintf("%s/foods/search", usdaBase)
	params := url.Values{}
	params.Set("query", query)
	params.Set("dataType", "Branded,Foundation,SR Legacy")
	params.Set("pageSize", "20")
	params.Set("api_key", c.apiKey)

	resp, err := c.httpClient.Get(u + "?" + params.Encode())
	if err != nil {
		return nil, fmt.Errorf("USDA search request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("USDA search returned status %d", resp.StatusCode)
	}

	var raw usdaSearchResponse
	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return nil, fmt.Errorf("USDA search decode failed: %w", err)
	}

	// Transform: rename "value" → "amount" for each nutrient
	out := &SearchResponse{Foods: make([]OutputFoodItem, 0, len(raw.Foods))}
	for _, f := range raw.Foods {
		item := OutputFoodItem{
			FdcID:         f.FdcID,
			Description:   f.Description,
			BrandOwner:    f.BrandOwner,
			BrandName:     f.BrandName,
			FoodNutrients: make([]OutputNutrient, 0, len(f.FoodNutrients)),
		}
		for _, n := range f.FoodNutrients {
			item.FoodNutrients = append(item.FoodNutrients, OutputNutrient{
				NutrientID: n.NutrientID,
				Amount:     n.Value, // USDA uses "value"; iOS expects "amount"
			})
		}
		out.Foods = append(out.Foods, item)
	}
	return out, nil
}

func (c *USDAClient) Detail(fdcID string) (*OutputFoodItem, error) {
	u := fmt.Sprintf("%s/food/%s?api_key=%s", usdaBase, fdcID, c.apiKey)

	resp, err := c.httpClient.Get(u)
	if err != nil {
		return nil, fmt.Errorf("USDA detail request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusNotFound {
		return nil, nil // caller will return 404
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("USDA detail returned status %d", resp.StatusCode)
	}

	var raw usdaDetailResponse
	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return nil, fmt.Errorf("USDA detail decode failed: %w", err)
	}

	// Transform: flatten nutrient.id → nutrientId, amount stays as amount
	item := &OutputFoodItem{
		FdcID:         raw.FdcID,
		Description:   raw.Description,
		BrandOwner:    raw.BrandOwner,
		BrandName:     raw.BrandName,
		FoodNutrients: make([]OutputNutrient, 0, len(raw.FoodNutrients)),
	}
	for _, n := range raw.FoodNutrients {
		item.FoodNutrients = append(item.FoodNutrients, OutputNutrient{
			NutrientID: n.Nutrient.ID,
			Amount:     n.Amount,
		})
	}
	return item, nil
}
