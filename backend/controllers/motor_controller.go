package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"

	"rental-backend/config"
	"rental-backend/models"
)

func GetMotors(w http.ResponseWriter, r *http.Request) {
	// Query untuk mengambil data dari tabel motors
	query := "SELECT id, name, brand, price_per_day, status FROM motors"

	rows, err := config.DB.Query(query)
	if err != nil {
		http.Error(w, fmt.Sprintf("Gagal mengambil data motors: %v", err), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var motors []models.Motor

	// Iterasi hasil query
	for rows.Next() {
		var motor models.Motor
		if err := rows.Scan(&motor.ID, &motor.Name, &motor.Brand, &motor.PricePerDay, &motor.Status); err != nil {
			http.Error(w, fmt.Sprintf("Gagal membaca data motor: %v", err), http.StatusInternalServerError)
			return
		}
		motors = append(motors, motor)
	}

	// Cek error setelah iterasi
	if err = rows.Err(); err != nil {
		http.Error(w, fmt.Sprintf("Terjadi kesalahan saat iterasi data motor: %v", err), http.StatusInternalServerError)
		return
	}

	// Set header dan encode ke JSON
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(motors)
}

func CreateMotor(w http.ResponseWriter, r *http.Request) {
	var motor models.Motor

	// Decode JSON request body ke struct Motor
	if err := json.NewDecoder(r.Body).Decode(&motor); err != nil {
		http.Error(w, "Gagal membaca data motor dari request", http.StatusBadRequest)
		return
	}

	// Query untuk menambahkan data motor baru
	query := "INSERT INTO motors (name, brand, price_per_day, status) VALUES (?, ?, ?, ?)"
	_, err := config.DB.Exec(query, motor.Name, motor.Brand, motor.PricePerDay, motor.Status)
	if err != nil {
		http.Error(w, fmt.Sprintf("Gagal menambahkan data motor: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"message": "Motor berhasil ditambahkan"})
}

func UpdateMotor(w http.ResponseWriter, r *http.Request) {
	var motor models.Motor

	// Decode JSON request body ke struct Motor
	if err := json.NewDecoder(r.Body).Decode(&motor); err != nil {
		http.Error(w, "Gagal membaca data motor dari request", http.StatusBadRequest)
		return
	}

	// Query untuk mengupdate data motor
	query := "UPDATE motors SET name = ?, brand = ?, price_per_day = ?, status = ? WHERE id = ?"
	_, err := config.DB.Exec(query, motor.Name, motor.Brand, motor.PricePerDay, motor.Status, motor.ID)
	if err != nil {
		http.Error(w, fmt.Sprintf("Gagal mengupdate data motor: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"message": "Motor berhasil diperbarui"})
}
