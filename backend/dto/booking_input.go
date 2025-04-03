package dto

import "time"

type BookingInput struct {
    MotorID        uint      `form:"motor_id" binding:"required"`
    StartDate      time.Time `form:"start_date" binding:"required"`
    EndDate        time.Time `form:"end_date" binding:"required"`
    PickupLocation string    `form:"pickup_location" binding:"required"`
}