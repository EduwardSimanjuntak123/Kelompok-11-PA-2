package models

type Motor struct {
	ID          int     `json:"id"`
	Name        string  `json:"name"`
	Brand       string  `json:"brand"`
	PricePerDay float64 `json:"price_per_day"`
	Status      string  `json:"status"`
}
