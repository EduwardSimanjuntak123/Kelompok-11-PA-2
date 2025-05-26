package dto

import "time"

type BookingInput struct {
	StartDate       time.Time `json:"start_date" form:"start_date" binding:"required"` // Format ISO8601, misal: 2025-03-02T05:00:00Z
	Duration        int       `json:"duration" form:"duration" binding:"required"`     // Durasi dalam hari
	PickupLocation  string    `json:"pickup_location" form:"pickup_location" binding:"required"`
	BookingPurpose  string    `json:"booking_purpose" form:"booking_purpose"`
	DropoffLocation string    `json:"dropoff_location" form:"dropoff_location"`
	MotorID         uint      `json:"motor_id" form:"motor_id" binding:"required"`
}
