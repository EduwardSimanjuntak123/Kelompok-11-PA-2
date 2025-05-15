-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 12 Bulan Mei 2025 pada 04.49
-- Versi server: 10.4.28-MariaDB
-- Versi PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rental2`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `customer_name` varchar(100) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `motor_id` int(11) DEFAULT NULL,
  `booking_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `pickup_location` text NOT NULL,
  `status` enum('pending','confirmed','canceled','completed','rejected','in transit','in use','awaiting return') DEFAULT 'pending',
  `photo_id` varchar(255) NOT NULL,
  `ktp_id` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `dropoff_location` text DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `bookings`
--

INSERT INTO `bookings` (`id`, `customer_id`, `customer_name`, `vendor_id`, `motor_id`, `booking_date`, `start_date`, `end_date`, `pickup_location`, `status`, `photo_id`, `ktp_id`, `created_at`, `updated_at`, `dropoff_location`, `is_read`) VALUES
(115, 25, 'Eduward Simanjuntak', 1, 9, '2025-05-06 03:26:06', '2025-05-10 06:00:00', '2025-05-14 23:59:59', 'sitoluama', 'completed', '/fileserver/booking/20250505_115705.jpg', '/fileserver/booking/20250506_102606.jpg', '2025-05-06 03:26:06', '2025-05-12 02:21:29', 'bulbul', 0),
(116, 25, 'Eduward Simanjuntak', 1, 9, '2025-05-06 03:26:10', '2025-05-04 06:00:00', '2025-05-06 06:00:00', 'sitoluama', 'completed', '/fileserver/booking/20250506_102610.jpg', '/fileserver/booking/20250506_102610.jpg', '2025-05-06 03:26:10', '2025-05-10 06:57:04', 'bulbul', 0);

-- --------------------------------------------------------

--
-- Struktur dari tabel `booking_extensions`
--

CREATE TABLE `booking_extensions` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `requested_end_date` datetime NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `approved_at` timestamp NULL DEFAULT NULL,
  `additional_price` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `booking_extensions`
--

INSERT INTO `booking_extensions` (`id`, `booking_id`, `requested_end_date`, `status`, `requested_at`, `approved_at`, `additional_price`) VALUES
(26, 115, '2025-05-14 23:59:59', 'pending', '2025-05-07 11:30:16', NULL, 300000);

-- --------------------------------------------------------

--
-- Struktur dari tabel `chat_rooms`
--

CREATE TABLE `chat_rooms` (
  `id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `chat_rooms`
--

INSERT INTO `chat_rooms` (`id`, `vendor_id`, `customer_id`, `created_at`, `updated_at`) VALUES
(23, 4, 25, '2025-05-09 01:04:49', '2025-05-09 01:04:49');

-- --------------------------------------------------------

--
-- Struktur dari tabel `kecamatan`
--

CREATE TABLE `kecamatan` (
  `id_kecamatan` int(11) NOT NULL,
  `nama_kecamatan` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kecamatan`
--

INSERT INTO `kecamatan` (`id_kecamatan`, `nama_kecamatan`) VALUES
(1, 'llaguboti'),
(2, 'Ajibatabemo'),
(3, 'Uluan'),
(4, 'Balige'),
(8, 'sopo'),
(11, 'test'),
(12, 'ok');

-- --------------------------------------------------------

--
-- Struktur dari tabel `location_recommendations`
--

CREATE TABLE `location_recommendations` (
  `id` int(11) NOT NULL,
  `district_id` int(11) NOT NULL,
  `place` varchar(255) NOT NULL,
  `address` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `location_recommendations`
--

INSERT INTO `location_recommendations` (`id`, `district_id`, `place`, `address`) VALUES
(7, 1, 'Terminal Kota', 'Jl. Raya No.1, Kecamatan A'),
(12, 4, 'toko antony baru', 'jl sitoluama baru'),
(13, 4, 'Taman Kota', 'JL. Sisingamangaraja'),
(19, 4, 'toko antony', 'jl sitoluama,Sitoluama'),
(20, 4, 'toko antony', 'jl sitoluama,Sitoluama');

-- --------------------------------------------------------

--
-- Struktur dari tabel `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL,
  `chat_room_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_read` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `messages`
--

INSERT INTO `messages` (`id`, `chat_room_id`, `sender_id`, `message`, `sent_at`, `is_read`) VALUES
(118, 23, 25, 'halo boss', '2025-05-09 01:04:53', 0);

-- --------------------------------------------------------

--
-- Struktur dari tabel `motor`
--

CREATE TABLE `motor` (
  `id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `brand` varchar(50) NOT NULL,
  `year` year(4) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `color` varchar(50) DEFAULT NULL,
  `status` enum('available','booked','unavailable') DEFAULT 'available',
  `image` varchar(255) DEFAULT NULL,
  `rating` float DEFAULT 0 CHECK (`rating` >= 0 and `rating` <= 5),
  `type` enum('Matic','Manual','Kopling','Vespa') NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `platmotor` varchar(50) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `motor`
--

INSERT INTO `motor` (`id`, `vendor_id`, `name`, `brand`, `year`, `price`, `color`, `status`, `image`, `rating`, `type`, `description`, `created_at`, `updated_at`, `platmotor`, `deleted_at`) VALUES
(9, 1, 'Mario', 'Honda', '2006', 100000.00, 'Hitam', 'available', '/fileserver/motor/20250509_104649.jpg', 4, 'Manual', 'csa', '2025-04-04 13:24:01', '2025-05-12 02:48:50', '100000', '2025-05-12 09:48:50'),
(12, 1, 'supraa', 'Honda', '2010', 100000.00, 'Hitam', 'available', '/fileserver/motor/20250509_104752.jpg', 0, 'Manual', 'sdcsd', '2025-04-25 08:34:31', '2025-05-09 03:47:52', NULL, NULL),
(16, 1, 'sdcdssqq', 'dcdsdsc', '2005', 100000.00, 'dsvd', 'available', '/fileserver/motor/20250507_085029.png', 0, 'Manual', 'ascswza,als', '2025-05-07 01:50:29', '2025-05-07 04:14:42', 'b 7890 k', NULL),
(17, 1, 'sds', 'sds', '2006', 100000.00, 'sds', 'available', '/fileserver/motor/20250509_104710.jpg', 0, 'Matic', 'dvfd', '2025-05-08 03:33:53', '2025-05-09 03:47:10', 'dfvd', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `status` enum('unread','read') DEFAULT 'unread',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `booking_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `message`, `status`, `created_at`, `booking_id`) VALUES
(197, 4, 'Ada booking baru dari Eduward Simanjuntak untuk motor supra ray pada tanggal 09 May 2025', 'unread', '2025-05-06 03:26:06', 115),
(198, 4, 'Ada booking baru dari Eduward Simanjuntak untuk motor supra ray pada tanggal 09 May 2025', 'unread', '2025-05-06 03:26:10', 116),
(199, 4, 'Ada booking baru dari Eduward Simanjuntak untuk motor Viar pada tanggal 07 May 2025', 'unread', '2025-05-06 07:12:37', 117),
(235, 25, 'Perpanjangan booking #115 ditolak oleh vendor.', 'unread', '2025-05-12 02:21:06', 115),
(236, 25, 'Perpanjangan booking #115 disetujui. Tanggal selesai baru: 14 May 2025', 'unread', '2025-05-12 02:21:29', 115);

-- --------------------------------------------------------

--
-- Struktur dari tabel `otp_requests`
--

CREATE TABLE `otp_requests` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `otp` varchar(6) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` datetime NOT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `otp_requests`
--

INSERT INTO `otp_requests` (`id`, `email`, `otp`, `created_at`, `expires_at`, `updated_at`, `deleted_at`) VALUES
(1, 'user@gmail.com', '389315', '2025-04-01 07:35:19', '2025-04-01 14:45:19', '2025-04-01 07:35:19', NULL),
(2, 'eduwardgrace436@gmail.com', '130499', '2025-04-01 07:36:18', '2025-04-01 14:46:18', '2025-05-06 03:09:14', '2025-05-06 03:09:14'),
(3, 'eduwardgrace436@gmail.com', '901298', '2025-04-01 07:37:34', '2025-04-01 14:47:34', '2025-05-06 03:09:14', '2025-05-06 03:09:14'),
(4, 'eduwardgrace436@gmail.com', '660002', '2025-04-01 07:40:57', '2025-04-01 14:50:57', '2025-05-06 03:09:14', '2025-05-06 03:09:14'),
(5, 'eduwardgrace436@gmail.com', '880061', '2025-04-01 07:51:38', '2025-04-01 15:01:38', '2025-05-06 03:09:14', '2025-05-06 03:09:14'),
(6, 'eduwardgrace436@gmail.com', '164004', '2025-04-01 07:53:30', '2025-04-01 15:03:30', '2025-05-06 03:09:14', '2025-05-06 03:09:14'),
(7, 'eduwardsimanjuntak02@gmail.com', '731193', '2025-04-01 08:00:18', '2025-04-01 15:10:18', '2025-04-01 08:00:18', NULL),
(8, 'eduwardgrace436@gmail.com', '117014', '2025-04-01 08:03:51', '2025-04-01 15:13:50', '2025-04-01 08:07:51', '2025-04-01 08:07:51'),
(9, 'eduwardgrace436@example.com', '479918', '2025-04-01 08:51:48', '2025-04-01 16:01:48', '2025-04-01 08:51:48', NULL),
(10, 'eduwardgrace436@gmail.com', '983719', '2025-04-01 08:53:12', '2025-04-01 16:03:12', '2025-04-01 08:58:12', '2025-04-01 08:58:12'),
(11, 'frengkysirait1234@gmail.com', '131397', '2025-04-01 09:10:15', '2025-04-01 16:18:15', '2025-04-01 09:17:23', '2025-04-01 09:17:23'),
(12, 'eduwardgrace436@gmail.com', '309181', '2025-04-01 09:15:37', '2025-04-01 16:25:37', '2025-04-01 09:16:09', '2025-04-01 09:16:09'),
(13, 'boasrayhanturnip@gmail.com', '514000', '2025-04-01 10:13:37', '2025-04-01 17:23:37', '2025-04-01 10:15:23', '2025-04-01 10:15:23'),
(14, 'boasrayhanturnip@gmail.com', '526825', '2025-04-01 10:25:38', '2025-04-01 17:35:38', '2025-04-01 10:25:38', NULL),
(15, 'boasrayhanturnip@gmail.com', '332417', '2025-04-01 10:26:34', '2025-04-01 17:36:34', '2025-04-01 10:26:34', NULL),
(16, 'boasrayhanturnip@gmail.com', '207195', '2025-04-01 10:27:03', '2025-04-01 17:37:03', '2025-04-01 10:27:03', NULL),
(17, 'boasrayhanturnip@gmail.com', '483711', '2025-04-01 10:28:55', '2025-04-01 17:38:55', '2025-04-01 10:30:16', '2025-04-01 10:30:16'),
(18, 'boasrayhanturnip@gmail.com', '534329', '2025-04-01 10:37:30', '2025-04-01 17:47:30', '2025-04-01 10:37:30', NULL),
(19, 'boasrayhanturnip@gmail.com', '417253', '2025-04-01 10:44:36', '2025-04-01 17:54:36', '2025-04-01 10:44:36', NULL),
(20, 'boasrayhanturnip@gmail.com', '123900', '2025-04-01 10:48:52', '2025-04-01 17:58:52', '2025-04-01 10:49:58', '2025-04-01 10:49:58'),
(21, 'boasrayhanturnip@gmail.com', '602230', '2025-04-01 11:00:09', '2025-04-01 18:10:09', '2025-04-01 11:00:35', '2025-04-01 11:00:35'),
(22, 'fernandesjunta6@gmail.com', '942964', '2025-04-03 10:38:25', '2025-04-03 17:48:25', '2025-04-03 10:38:25', NULL),
(23, 'fernandesjuntak6@gmail.com', '936371', '2025-04-03 10:40:06', '2025-04-03 17:50:06', '2025-04-03 10:40:46', '2025-04-03 10:40:46'),
(24, 'boasrayhanturnip@gmail.co', '402242', '2025-04-06 05:36:16', '2025-04-06 12:46:16', '2025-04-06 05:36:16', NULL),
(25, 'graceyosephine63@gmail.com', '862624', '2025-04-10 23:55:11', '2025-04-11 07:05:11', '2025-04-10 23:56:55', '2025-04-10 23:56:55'),
(26, 'graceyosephine63@gmail.com', '736078', '2025-04-22 04:14:10', '2025-04-22 11:24:10', '2025-04-22 04:14:10', NULL),
(27, 'graceyosephine63@gmail.com', '453540', '2025-04-22 04:25:08', '2025-04-22 11:35:08', '2025-04-22 04:25:57', '2025-04-22 04:25:57'),
(28, 'graceyosephine63@gmail.com', '203418', '2025-04-22 04:33:41', '2025-04-22 11:43:41', '2025-04-22 04:34:12', '2025-04-22 04:34:12'),
(29, 'graceyosephine63@gmail.com', '874015', '2025-04-22 04:58:01', '2025-04-22 12:08:01', '2025-04-22 04:58:01', NULL),
(30, 'rentaledo@email.com', '240733', '2025-04-22 11:29:14', '2025-04-22 18:39:14', '2025-04-22 11:29:14', NULL),
(31, 'rentaledo@email.com', '135231', '2025-05-04 16:27:16', '2025-05-04 23:37:16', '2025-05-04 16:27:16', NULL),
(32, 'graceyosephine63@gmail.com', '659958', '2025-05-06 01:59:09', '2025-05-06 09:09:09', '2025-05-06 01:59:09', NULL),
(33, 'eduwardgrace436@gmail.com', '786033', '2025-05-06 02:14:54', '2025-05-06 09:24:54', '2025-05-06 03:09:14', '2025-05-06 03:09:14'),
(34, 'eduwardgrace436@gmail.com', '448388', '2025-05-06 02:24:14', '2025-05-06 09:34:14', '2025-05-06 02:25:08', '2025-05-06 02:25:08'),
(35, 'eduwardsimanjuntak02@gmail.com', '682841', '2025-05-06 02:29:19', '2025-05-06 09:39:19', '2025-05-06 02:29:53', '2025-05-06 02:29:53'),
(36, 'leon123@gmail.com', '700588', '2025-05-06 02:35:52', '2025-05-06 09:45:52', '2025-05-06 02:35:52', NULL),
(37, 'leonisibuea135@gmail.com', '710109', '2025-05-06 02:37:23', '2025-05-06 09:47:23', '2025-05-06 02:37:23', NULL),
(38, 'leonisibuea25@gmail.com', '898482', '2025-05-06 02:39:22', '2025-05-06 09:49:22', '2025-05-06 02:40:20', '2025-05-06 02:40:20'),
(39, 'leonisibuea25@gmail.com', '665440', '2025-05-06 02:56:33', '2025-05-06 10:06:33', '2025-05-06 02:59:23', '2025-05-06 02:59:23'),
(40, 'eduwardgrace436@gmail.com', '655249', '2025-05-06 03:08:52', '2025-05-06 10:18:52', '2025-05-06 03:09:14', '2025-05-06 03:09:14'),
(41, 'eduwardgrace436@gmail.com', '692813', '2025-05-06 03:12:57', '2025-05-06 10:22:57', '2025-05-06 03:14:37', '2025-05-06 03:14:37'),
(42, 'eduwardgrace436@gmail.com', '177904', '2025-05-06 03:16:39', '2025-05-06 10:26:39', '2025-05-06 03:17:27', '2025-05-06 03:17:27'),
(43, 'boasrayhanturnip@gmail.com', '833898', '2025-05-09 01:02:19', '2025-05-09 08:12:19', '2025-05-09 01:02:19', NULL),
(44, 'boasrayhanturnip@gmail.com', '905616', '2025-05-10 04:46:04', '2025-05-10 11:56:04', '2025-05-10 04:46:04', NULL),
(45, 'boasrayhanturnip@gmail.com', '669127', '2025-05-10 04:48:59', '2025-05-10 11:58:59', '2025-05-10 04:48:59', NULL),
(46, 'boasrayhanturnip@gmail.com', '581505', '2025-05-10 04:50:26', '2025-05-10 12:00:26', '2025-05-10 04:50:26', NULL),
(47, 'boasrayhanturnip@gmail.com', '670506', '2025-05-10 04:52:36', '2025-05-10 12:02:36', '2025-05-10 04:52:36', NULL),
(48, 'eduwardgrace436@gmail.com', '936738', '2025-05-10 04:56:51', '2025-05-10 12:06:51', '2025-05-10 04:57:16', '2025-05-10 04:57:16'),
(49, 'eduwardgrace436@gmail.com', '503819', '2025-05-10 05:22:42', '2025-05-10 12:32:42', '2025-05-10 05:23:31', '2025-05-10 05:23:31'),
(50, 'eduwardgrace436@gmail.com', '271167', '2025-05-10 06:27:49', '2025-05-10 13:37:49', '2025-05-10 06:29:14', '2025-05-10 06:29:14'),
(51, 'eduwardgrace436@gmail.com', '828205', '2025-05-10 06:29:30', '2025-05-10 13:39:30', '2025-05-10 06:31:38', '2025-05-10 06:31:38'),
(52, 'eduwardgrace436@gmail.com', '334812', '2025-05-10 06:31:09', '2025-05-10 13:41:09', '2025-05-10 06:31:38', '2025-05-10 06:31:38'),
(53, 'eduwardgrace436@gmail.com', '215519', '2025-05-10 06:32:36', '2025-05-10 13:42:36', '2025-05-10 06:33:30', '2025-05-10 06:33:30');

-- --------------------------------------------------------

--
-- Struktur dari tabel `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `motor_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `rating` int(11) NOT NULL CHECK (`rating` between 1 and 5),
  `review` text DEFAULT NULL,
  `vendor_reply` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `reviews`
--

INSERT INTO `reviews` (`id`, `booking_id`, `customer_id`, `motor_id`, `vendor_id`, `rating`, `review`, `vendor_reply`, `created_at`) VALUES
(11, 116, 25, 9, 1, 4, 'Motor sangat nyaman digunakan!', 'Motor sangat nyaman digunakan', '2025-05-08 06:22:06');

-- --------------------------------------------------------

--
-- Struktur dari tabel `transactions`
--

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `motor_id` int(11) NOT NULL,
  `type` enum('online','manual') NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `pickup_location` text NOT NULL,
  `status` enum('completed','disputed') DEFAULT 'completed',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `transactions`
--

INSERT INTO `transactions` (`id`, `booking_id`, `vendor_id`, `customer_id`, `motor_id`, `type`, `total_price`, `start_date`, `end_date`, `pickup_location`, `status`, `created_at`, `updated_at`) VALUES
(35, 116, 1, 25, 9, 'online', 100000.00, '2025-05-10', '2025-05-11', 'sitoluama', 'completed', '2025-05-06 07:18:22', '2025-05-06 07:18:22'),
(37, 116, 1, 25, 9, 'online', 200000.00, '2025-05-04', '2025-05-06', 'sitoluama', 'completed', '2025-05-10 06:57:04', '2025-05-10 06:57:04');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `birth_date` date DEFAULT NULL,
  `PASSWORD` varchar(255) NOT NULL,
  `role` enum('admin','vendor','customer') NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` text DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `birth_date`, `PASSWORD`, `role`, `phone`, `address`, `profile_image`, `status`, `created_at`, `updated_at`) VALUES
(3, 'admin baru', 'admin1@gmail.com', NULL, '$2a$10$1SOHcZCIQbsn5XtuFQCaEOcO38toRMRtoPHWWpwxgYsQD07BByBO2', 'admin', '08133456711', 'Jl. Example No. 123, Jakarta', '/fileserver/admin/20250329_185742.jpg', 'active', '2025-03-24 06:27:37', '2025-05-09 04:20:01'),
(4, 'nama vendor baru', 'rentaledo@email.com', NULL, '$2a$10$hwNv0oPoRaMIs6Nj5uSuO.BpOkdHzazeq1BtK2iLddvry805LyNO6', 'vendor', '081218076543', 'IT Del, Istitute Teknologi Del', '/fileserver/vendor/20250509_104626.jpg', 'active', '2025-03-24 06:32:38', '2025-05-09 09:08:54'),
(25, 'Eduward Simanjuntak', 'boasrayhanturnip@gmail.com', '1995-06-15', '$2a$10$//rB8vYNCh0fMam6lcQIVeeYIALN6xf0FtorSbAF35QWz.ROBRb9.', 'customer', '08976543214', 'JL. Hutabulu, Balige', '/fileserver/users/1746752515_1000186293.jpg', 'active', '2025-04-01 11:00:13', '2025-05-09 01:01:55'),
(39, 'iwiwue', 'eduwardgrace36@gmail.com', NULL, '$2a$10$zTS.KPyw4aJ7e2V3ndlrKO9QTjRUKKep3oSyuElBsdwmgTwxGqqti', 'customer', '085264913452', 'isush', '/fileserver/users/1746501177_1000191086.jpg', 'active', '2025-05-06 03:13:02', '2025-05-10 04:55:09'),
(45, 'Leoni Sibuea', 'eduwardgrace436@gmail.com', '2005-05-10', '$2a$10$3eM4GlWocsD88xFHWbvhC.oxnr7EFDUh/rfIGHVep3uuzNZOIKtSq', 'vendor', '082163766715', 'zjsjjs', '/fileserver/users/1746858756_1000193118.jpg', 'active', '2025-05-10 06:32:39', '2025-05-10 06:33:30');

-- --------------------------------------------------------

--
-- Struktur dari tabel `vendors`
--

CREATE TABLE `vendors` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `id_kecamatan` int(11) DEFAULT NULL,
  `shop_name` varchar(100) NOT NULL,
  `shop_address` text NOT NULL,
  `shop_description` text DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `rating` float DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `vendors`
--

INSERT INTO `vendors` (`id`, `user_id`, `id_kecamatan`, `shop_name`, `shop_address`, `shop_description`, `status`, `created_at`, `updated_at`, `rating`) VALUES
(1, 4, 1, 'horas rental', 'IT Del, Istitute Teknologi Del', 'saasad', 'active', '2025-03-24 08:08:23', '2025-05-09 09:08:54', 4),
(17, 45, 4, 'isisu', 'zjsjjs', 'sisus', 'active', '2025-05-10 06:32:39', '2025-05-10 06:32:39', 0);

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `vendor_id` (`vendor_id`),
  ADD KEY `motor_id` (`motor_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indeks untuk tabel `booking_extensions`
--
ALTER TABLE `booking_extensions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indeks untuk tabel `chat_rooms`
--
ALTER TABLE `chat_rooms`
  ADD PRIMARY KEY (`id`),
  ADD KEY `vendor_id` (`vendor_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indeks untuk tabel `kecamatan`
--
ALTER TABLE `kecamatan`
  ADD PRIMARY KEY (`id_kecamatan`);

--
-- Indeks untuk tabel `location_recommendations`
--
ALTER TABLE `location_recommendations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `district_id` (`district_id`);

--
-- Indeks untuk tabel `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `chat_room_id` (`chat_room_id`),
  ADD KEY `sender_id` (`sender_id`);

--
-- Indeks untuk tabel `motor`
--
ALTER TABLE `motor`
  ADD PRIMARY KEY (`id`),
  ADD KEY `vendor_id` (`vendor_id`);

--
-- Indeks untuk tabel `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indeks untuk tabel `otp_requests`
--
ALTER TABLE `otp_requests`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `motor_id` (`motor_id`),
  ADD KEY `vendor_id` (`vendor_id`);

--
-- Indeks untuk tabel `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `vendor_id` (`vendor_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `motor_id` (`motor_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone` (`phone`);

--
-- Indeks untuk tabel `vendors`
--
ALTER TABLE `vendors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `id_kecamatan` (`id_kecamatan`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT untuk tabel `booking_extensions`
--
ALTER TABLE `booking_extensions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT untuk tabel `chat_rooms`
--
ALTER TABLE `chat_rooms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT untuk tabel `kecamatan`
--
ALTER TABLE `kecamatan`
  MODIFY `id_kecamatan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT untuk tabel `location_recommendations`
--
ALTER TABLE `location_recommendations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT untuk tabel `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=119;

--
-- AUTO_INCREMENT untuk tabel `motor`
--
ALTER TABLE `motor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT untuk tabel `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=237;

--
-- AUTO_INCREMENT untuk tabel `otp_requests`
--
ALTER TABLE `otp_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT untuk tabel `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT untuk tabel `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT untuk tabel `vendors`
--
ALTER TABLE `vendors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`motor_id`) REFERENCES `motor` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `booking_extensions`
--
ALTER TABLE `booking_extensions`
  ADD CONSTRAINT `booking_extensions_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`);

--
-- Ketidakleluasaan untuk tabel `chat_rooms`
--
ALTER TABLE `chat_rooms`
  ADD CONSTRAINT `chat_rooms_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chat_rooms_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `location_recommendations`
--
ALTER TABLE `location_recommendations`
  ADD CONSTRAINT `location_recommendations_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `kecamatan` (`id_kecamatan`);

--
-- Ketidakleluasaan untuk tabel `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`chat_room_id`) REFERENCES `chat_rooms` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `motor`
--
ALTER TABLE `motor`
  ADD CONSTRAINT `motor_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_3` FOREIGN KEY (`motor_id`) REFERENCES `motor` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_4` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `transactions_ibfk_3` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `transactions_ibfk_4` FOREIGN KEY (`motor_id`) REFERENCES `motor` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `vendors`
--
ALTER TABLE `vendors`
  ADD CONSTRAINT `vendors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vendors_ibfk_2` FOREIGN KEY (`id_kecamatan`) REFERENCES `kecamatan` (`id_kecamatan`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
