-- =========================================================
-- Finclub Loan Application Database Schema
-- DBMS: MySQL 8.0+
-- =========================================================

CREATE DATABASE IF NOT EXISTS `finclub_db` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `finclub_db`;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `avatar_url` VARCHAR(500) DEFAULT NULL,
  `has_accepted_terms` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Loans Table (Fixed 7 Days Loan)
CREATE TABLE IF NOT EXISTS `loans` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `principal` DECIMAL(10, 2) NOT NULL,
  `interest_per_day` DECIMAL(10, 2) NOT NULL,
  `total_interest` DECIMAL(10, 2) NOT NULL,
  `revenue_fee` DECIMAL(10, 2) NOT NULL COMMENT 'ค่าดำเนินการหรือ enue',
  `total_amount` DECIMAL(10, 2) NOT NULL,
  `tenure_days` INT NOT NULL DEFAULT 7,
  `status` ENUM('pending', 'approved', 'paid', 'rejected') NOT NULL DEFAULT 'approved',
  `due_date` DATE NOT NULL,
  `applied_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_loans_user_id` (`user_id`),
  CONSTRAINT `fk_loans_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Saved Plans Table (User's Saved 7-Day Loan Simulations)
CREATE TABLE IF NOT EXISTS `saved_plans` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `loan_amount` DECIMAL(10, 2) NOT NULL,
  `interest_per_day` DECIMAL(10, 2) NOT NULL,
  `total_interest` DECIMAL(10, 2) NOT NULL,
  `revenue_fee` DECIMAL(10, 2) NOT NULL,
  `total_amount` DECIMAL(10, 2) NOT NULL,
  `tenure_days` INT NOT NULL DEFAULT 7,
  `due_date` VARCHAR(100) NOT NULL,
  `annual_interest_rate` DECIMAL(5, 2) NOT NULL DEFAULT 35.80,
  `note` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_saved_plans_user` (`user_id`),
  CONSTRAINT `fk_saved_plans_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Terms Acceptance Logs Table
CREATE TABLE IF NOT EXISTS `terms_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `accepted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` VARCHAR(255) DEFAULT NULL,
  CONSTRAINT `fk_terms_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
