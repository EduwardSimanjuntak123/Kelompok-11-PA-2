package models

type LocationRecommendation struct {
	ID         uint   `gorm:"primaryKey;autoIncrement" json:"id"`
	DistrictID uint   `gorm:"column:district_id;not null" json:"district_id"`
	Place      string `gorm:"type:varchar(255);not null" json:"place"`
	Address    string `gorm:"type:text" json:"address"`

	Kecamatan Kecamatan `gorm:"foreignKey:DistrictID;references:ID" json:"kecamatan"`
}
