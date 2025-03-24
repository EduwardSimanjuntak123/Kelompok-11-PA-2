CREATE DATABASE rental_motor;
USE rental_motor;

CREATE TABLE USER (
    id_User INT PRIMARY KEY AUTO_INCREMENT,
    NAME VARCHAR(100) NOT NULL,
    alamat TEXT,
    no_telepon VARCHAR(20) UNIQUE,
    PASSWORD VARCHAR(255) NOT NULL,
    role ENUM('admin', 'vendor', 'customer') NOT NULL,
    DoB DATE,
    email VARCHAR(100) UNIQUE,
    image VARCHAR(255),
    tanggal_bergabung TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kecamatan (
    id_kecamatan INT PRIMARY KEY AUTO_INCREMENT,
    nama_kecamatan VARCHAR(100) NOT NULL
);

CREATE TABLE vendors (
    id_vendor INT PRIMARY KEY AUTO_INCREMENT,
    id_User INT UNIQUE,
    id_kecamatan INT,
    nama_vendor VARCHAR(100) NOT NULL,
    alamat TEXT,
    deskripsi TEXT,
    STATUS ENUM('aktif', 'nonaktif') DEFAULT 'aktif',
    FOREIGN KEY (id_User) REFERENCES USER(id_User) ON DELETE CASCADE,
    FOREIGN KEY (id_kecamatan) REFERENCES kecamatan(id_kecamatan) ON DELETE SET NULL
);


CREATE TABLE motor (
    id_motor INT PRIMARY KEY AUTO_INCREMENT,
    id_vendor INT,
    nama_motor VARCHAR(100) NOT NULL,
    merek VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    tahun_produksi YEAR NOT NULL,
    tipe_motor VARCHAR(50),
    rating FLOAT DEFAULT 0,
    harga_sewa DECIMAL(10,2) NOT NULL,
    warna VARCHAR(50),
    foto_motor VARCHAR(255),
    FOREIGN KEY (id_vendor) REFERENCES vendors(id_vendor) ON DELETE CASCADE
);
ALTER TABLE motor ADD COLUMN rating FLOAT DEFAULT 0;


CREATE TABLE status_booking (
    id_status INT PRIMARY KEY AUTO_INCREMENT,
    keterangan VARCHAR(50) NOT NULL
);


CREATE TABLE bookings (
    id_bookings INT PRIMARY KEY AUTO_INCREMENT,
    id_User INT,
    id_motor INT,
    id_vendor INT,
    tanggal_sewa DATE NOT NULL,
    tanggal_kembali DATE NOT NULL,
    titik_kembali TEXT NOT NULL,
    foto_diri VARCHAR(255),
    id_status INT,
    FOREIGN KEY (id_User) REFERENCES USER(id_User) ON DELETE CASCADE,
    FOREIGN KEY (id_motor) REFERENCES motor(id_motor) ON DELETE CASCADE,
    FOREIGN KEY (id_vendor) REFERENCES vendors(id_vendor) ON DELETE CASCADE,
    FOREIGN KEY (id_status) REFERENCES status_booking(id_status) ON DELETE SET NULL
);
ALTER TABLE bookings
ADD COLUMN total_hari INT;

UPDATE bookings
SET total_hari = DATEDIFF(end_date, start_date);




CREATE TABLE ulasan (
    id_ulasan INT PRIMARY KEY AUTO_INCREMENT,
    id_User INT,
    id_booking INT,
    id_motor INT,
    rating FLOAT CHECK (rating >= 0 AND rating <= 5),
    komentar TEXT,
    tanggal_ulasan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_User) REFERENCES USER(id_User) ON DELETE CASCADE,
    FOREIGN KEY (id_booking) REFERENCES bookings(id_bookings) ON DELETE CASCADE,
    FOREIGN KEY (id_motor) REFERENCES motor(id_motor) ON DELETE CASCADE
);


ALTER TABLE motor ADD COLUMN STATUS ENUM('tersedia', 'disewa', 'rusak') DEFAULT 'tersedia';

ALTER TABLE USER
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
ALTER TABLE USER ADD COLUMN deleted_at TIMESTAMP NULL;



ALTER TABLE vendors
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD COLUMN deleted_at TIMESTAMP NULL;


CREATE TABLE otp (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    CODE VARCHAR(10) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);