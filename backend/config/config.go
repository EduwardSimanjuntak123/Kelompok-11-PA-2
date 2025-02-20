package config

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/go-sql-driver/mysql"
	"github.com/joho/godotenv"
)

var DB *sql.DB

func ConnectDB() {
	err := godotenv.Load("D:/semester 4/PA II/Kelompok-11-PA-2/backend/.env")
	if err != nil {
		fmt.Println("Gagal membaca file .env")
		panic(err)
	}

	// Debugging: Cek apakah variabel environment terbaca
	fmt.Println("DB_USER:", os.Getenv("DB_USER"))
	fmt.Println("DB_PASSWORD:", os.Getenv("DB_PASSWORD"))
	fmt.Println("DB_NAME:", os.Getenv("DB_NAME"))
	fmt.Println("DB_HOST:", os.Getenv("DB_HOST"))
	fmt.Println("DB_PORT:", os.Getenv("DB_PORT"))

	// Build DSN string
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s",
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_NAME"),
	)

	// Open connection to MySQL
	DB, err = sql.Open("mysql", dsn)
	if err != nil {
		fmt.Println("Gagal membuka koneksi ke database:", err)
		panic(err)
	}

	// Test database connection
	err = DB.Ping()
	if err != nil {
		fmt.Println("Gagal terhubung ke database:", err)
		panic(err)
	}

	fmt.Println("Database connected!")
}
