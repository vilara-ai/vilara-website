<?php
/**
 * Debug endpoint to check environment variables and database connection
 */

header('Content-Type: application/json');

$debug_info = [];

// Check environment variables
$debug_info['environment'] = [
    'DB_HOST' => $_ENV['DB_HOST'] ?? 'NOT SET',
    'DB_NAME' => $_ENV['DB_NAME'] ?? 'NOT SET', 
    'DB_USER' => $_ENV['DB_USER'] ?? 'NOT SET',
    'DB_PORT' => $_ENV['DB_PORT'] ?? 'NOT SET',
    'DB_PASSWORD' => isset($_ENV['DB_PASSWORD']) ? 'SET (length: ' . strlen($_ENV['DB_PASSWORD']) . ') - VALUE: [' . $_ENV['DB_PASSWORD'] . ']' : 'NOT SET'
];

// Test database connection with detailed error info
try {
    $db_host = $_ENV['DB_HOST'] ?? '/cloudsql/vilara-dev:us-central1:vilara-dev-sql';
    $db_name = $_ENV['DB_NAME'] ?? 'appdb';
    $db_user = $_ENV['DB_USER'] ?? 'appuser';
    $db_pass = $_ENV['DB_PASSWORD'] ?? '';
    $db_port = $_ENV['DB_PORT'] ?? '5432';
    
    $debug_info['connection_attempt'] = [
        'host' => $db_host,
        'dbname' => $db_name,
        'user' => $db_user,
        'port' => $db_port,
        'password_length' => strlen($db_pass)
    ];
    
    if (strpos($db_host, '/cloudsql/') === 0) {
        $dsn = "pgsql:host={$db_host};dbname={$db_name}";
    } else {
        $dsn = "pgsql:host={$db_host};port={$db_port};dbname={$db_name}";
    }
    
    $debug_info['dsn'] = $dsn;
    
    $pdo = new PDO($dsn, $db_user, $db_pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
    
    $debug_info['database'] = 'CONNECTION SUCCESS';
    
    // Test a simple query
    $stmt = $pdo->query("SELECT current_database(), current_user, version()");
    $result = $stmt->fetch();
    $debug_info['database_info'] = $result;
    
} catch (PDOException $e) {
    $debug_info['database_error'] = [
        'code' => $e->getCode(),
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ];
}

echo json_encode($debug_info, JSON_PRETTY_PRINT);