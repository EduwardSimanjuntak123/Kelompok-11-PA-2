CREATE DATABASE motorRent

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    `password` TEXT NOT NULL,  -- Menggunakan backticks karena "password" adalah reserved keyword
    phone VARCHAR(15),
    role ENUM('owner', 'customer') NOT NULL,  -- Menggunakan ENUM sebagai pengganti CHECK constraint
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE motors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT,
    NAME VARCHAR(100) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    price_per_day INT NOT NULL,
    STATUS ENUM('available', 'rented') NOT NULL DEFAULT 'available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);