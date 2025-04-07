package dto

type EditProfileRequest struct {
	Name    string `form:"name" json:"name"`
	Email   string `form:"email" json:"email"`
	Phone   string `form:"phone" json:"phone"`
	Address string `form:"address" json:"address"`
}

type UserResponse struct {
	Name         string `json:"name"`
	Email        string `json:"email"`
	Phone        string `json:"phone"`
	Address      string `json:"address"`
	ProfileImage string `json:"profile_image"`
}
