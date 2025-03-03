package helpers

import (
	"fmt"
	"net/smtp"
	"os"
	"log"
)

// SendOTPEmail mengirim OTP ke alamat email yang diberikan menggunakan SMTP.
func SendOTPEmail(toEmail string, otp string) error {
	// Ambil konfigurasi SMTP dari environment variables.
	smtpHost := os.Getenv("SMTP_HOST") // Contoh: "smtp.gmail.com"
	smtpPort := os.Getenv("SMTP_PORT") // Contoh: "587"
	smtpUser := os.Getenv("SMTP_USER") // Misalnya: "youremail@gmail.com"
	smtpPass := os.Getenv("SMTP_PASS") // Password atau App Password untuk email tersebut

	// Buat autentikasi SMTP.
	auth := smtp.PlainAuth("", smtpUser, smtpPass, smtpHost)

	// Format subject dan body email.
	subject := "Subject: OTP Verification Code\n"
	body := fmt.Sprintf("Your OTP code is: %s\n", otp)
	message := []byte(subject + "\n" + body)

	// Buat alamat server SMTP, misalnya "smtp.gmail.com:587".
	addr := fmt.Sprintf("%s:%s", smtpHost, smtpPort)

	// Kirim email menggunakan smtp.SendMail.
	err := smtp.SendMail(addr, auth, smtpUser, []string{toEmail}, message)
if err != nil {
    log.Println("Error saat mengirim OTP:", err)
    return err
}

	return nil
}
