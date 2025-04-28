package models

type Kecamatan struct {
	ID   uint   `gorm:"primaryKey;column:id_kecamatan" json:"id_kecamatan"`            // Nama kolom GORM disesuaikan
	Nama string `json:"nama_kecamatan" gorm:"size:100;not null;column:nama_kecamatan"` // Nama kolom GORM disesuaikan

	LocationRecommendations []LocationRecommendation `gorm:"foreignKey:DistrictID;references:ID" json:"location_recommendations"`
}

func (Kecamatan) TableName() string {
	return "kecamatan" // Sesuaikan dengan nama tabel yang ada di DB
}
