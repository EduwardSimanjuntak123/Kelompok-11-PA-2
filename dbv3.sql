CREATE DATABASE rental2
USE rental2
DROP DATABASE rental2

	CREATE TABLE users (
	    id INT PRIMARY KEY AUTO_INCREMENT,
	    NAME VARCHAR(100) NOT NULL,
	    email VARCHAR(100) UNIQUE NOT NULL,
	    PASSWORD VARCHAR(255) NOT NULL,
	    role ENUM('admin', 'vendor', 'customer') NOT NULL,
	    phone VARCHAR(20) UNIQUE NOT NULL,
	    address TEXT NULL,
	    profile_image VARCHAR(255) NULL,
	    ktp_image VARCHAR(255) NULL,
	    STATUS ENUM('active', 'inactive') DEFAULT 'active',
	    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
	);

	CREATE TABLE kecamatan (
	    id_kecamatan INT PRIMARY KEY AUTO_INCREMENT,
	    nama_kecamatan VARCHAR(100) NOT NULL
	);

	CREATE TABLE vendors (
	    id INT PRIMARY KEY AUTO_INCREMENT,
	    user_id INT UNIQUE NOT NULL,
	    id_kecamatan INT NULL,
	    shop_name VARCHAR(100) NOT NULL,
	    shop_address TEXT NOT NULL,
	    shop_description TEXT NULL,
	    STATUS ENUM('active', 'inactive') DEFAULT 'active',
	    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	    FOREIGN KEY (id_kecamatan) REFERENCES kecamatan(id_kecamatan) ON DELETE SET NULL ON UPDATE CASCADE
	);

	ALTER TABLE vendors
	ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;



	CREATE TABLE motor (
	    id INT PRIMARY KEY AUTO_INCREMENT,
	    vendor_id INT NOT NULL,
	    NAME VARCHAR(100) NOT NULL,
	    brand VARCHAR(50) NOT NULL,
	    model VARCHAR(50) NOT NULL,
	    YEAR YEAR NOT NULL,
	    price DECIMAL(10,2) NOT NULL,
	    color VARCHAR(50),
	    STATUS ENUM('available', 'booked', 'unavailable') DEFAULT 'available',
	    image VARCHAR(255),
	    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE
	);
	ALTER TABLE motor
	ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;




CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    vendor_id INT NOT NULL,
    motor_id INT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pickup_location TEXT NOT NULL,
    STATUS ENUM('pending', 'confirmed', 'canceled', 'completed') DEFAULT 'pending',
    photo_id VARCHAR(255) NOT NULL,
    ktp_id VARCHAR(255) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
    FOREIGN KEY (motor_id) REFERENCES motor(id) ON DELETE CASCADE
);

ALTER TABLE bookings
MODIFY COLUMN STATUS ENUM('pending', 'confirmed', 'canceled', 'completed', 'rejected') DEFAULT 'pending';

ALTER TABLE bookings
	ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;




CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NULL, -- NULL jika transaksi manual
    vendor_id INT NOT NULL,
    customer_id INT NULL, -- NULL jika transaksi manual
    motor_id INT NOT NULL,
    TYPE ENUM('online', 'manual') NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pickup_location TEXT NOT NULL,
    STATUS ENUM('completed', 'disputed') DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (motor_id) REFERENCES motor(id) ON DELETE CASCADE
);


CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    STATUS ENUM('unread', 'read') DEFAULT 'unread',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


SELECT id, email,PASSWORD PASSWORD FROM users WHERE email = 'user@gmail.com';
SELECT * FROM users WHERE email = 'user@gmail.com' AND role = 'customer';


