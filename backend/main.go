package main

import (
	"fmt"
	"log"
	"net/http"
	"rental-backend/config"
	"github.com/gorilla/mux"
	handlers "rental-backend/controllers"
)

func main() {
	config.ConnectDB()

	r := mux.NewRouter()

	// Menambahkan rute
	r.HandleFunc("/motors", handlers.GetMotors).Methods("GET") // Mendapatkan daftar motor
	r.HandleFunc("/motors", handlers.CreateMotor).Methods("POST") // Mendapatkan detail motor
	r.HandleFunc("/motors", handlers.UpdateMotor).Methods("PUT")

	//r.HandleFunc("/motors", controllers.CreateMotor).Methods("POST") // Menambahkan motor
	// r.HandleFunc("/bookings", controllers.CreateBooking).Methods("POST") // Membuat booking
	// r.HandleFunc("/bookings", controllers.GetBookings).Methods("GET") // Melihat daftar booking

	// Menjalankan server
	fmt.Println("Server running on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}
 
