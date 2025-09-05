<?php
/**
 * Database connection handler for PostgreSQL on Google Cloud SQL
 * Uses Unix socket for secure connection
 */

function getDatabase() {
    static $pdo = null;
    
    if ($pdo === null) {
        try {
            // Get configuration from environment variables
            $db_host = $_ENV['DB_HOST'] ?? '/cloudsql/vilara-dev:us-central1:vilara-dev-sql';
            $db_name = $_ENV['DB_NAME'] ?? 'appdb';
            $db_user = $_ENV['DB_USER'] ?? 'appuser';
            $db_pass = $_ENV['DB_PASSWORD'] ?? '';
            $db_port = $_ENV['DB_PORT'] ?? '5432';
            
            // Build DSN for PostgreSQL
            if (strpos($db_host, '/cloudsql/') === 0) {
                // Unix socket connection for Cloud SQL
                $dsn = "pgsql:host={$db_host};dbname={$db_name}";
            } else {
                // TCP connection for local development
                $dsn = "pgsql:host={$db_host};port={$db_port};dbname={$db_name}";
            }
            
            // URL encode password to handle special characters
            $db_pass_encoded = $db_pass;
            
            // Create PDO instance
            $pdo = new PDO($dsn, $db_user, $db_pass_encoded, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]);
            
        } catch (PDOException $e) {
            error_log("Database connection failed: " . $e->getMessage());
            throw new Exception('Database connection error');
        }
    }
    
    return $pdo;
}

/**
 * Initialize database schema if needed
 */
function initializeDatabase() {
    try {
        $db = getDatabase();
        
        // Create signups table if not exists
        $db->exec("
            CREATE TABLE IF NOT EXISTS signups (
                id SERIAL PRIMARY KEY,
                email VARCHAR(255) NOT NULL,
                first_name VARCHAR(100) NOT NULL,
                last_name VARCHAR(100) NOT NULL,
                company_name VARCHAR(255) NOT NULL,
                company_size VARCHAR(50) NOT NULL,
                phone VARCHAR(20),
                migration_type VARCHAR(20) NOT NULL DEFAULT 'fresh',
                token_hash VARCHAR(64) NOT NULL UNIQUE,
                ip_address VARCHAR(45),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                expires_at TIMESTAMP NOT NULL,
                used_at TIMESTAMP,
                INDEX idx_email (email),
                INDEX idx_token_hash (token_hash),
                INDEX idx_expires_at (expires_at)
            )
        ");
        
        // Create rate_limits table if not exists
        $db->exec("
            CREATE TABLE IF NOT EXISTS rate_limits (
                id SERIAL PRIMARY KEY,
                ip_address VARCHAR(45) NOT NULL,
                endpoint VARCHAR(100) NOT NULL,
                request_count INT DEFAULT 1,
                window_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY unique_ip_endpoint (ip_address, endpoint),
                INDEX idx_window_start (window_start)
            )
        ");
        
        return true;
        
    } catch (PDOException $e) {
        error_log("Database initialization failed: " . $e->getMessage());
        return false;
    }
}