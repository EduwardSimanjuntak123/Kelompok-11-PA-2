package routes

import (
	"github.com/gorilla/mux"
	handlers "rental-backend/controllers"
)

func SetupRoutes() *mux.Router {
	r := mux.NewRouter()

	// Endpoint untuk motor
	r.HandleFunc("/motors", handlers.GetMotors).Methods("GET")

	return r
}
