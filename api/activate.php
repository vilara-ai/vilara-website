<?php
/**
 * Account Activation API Endpoint
 * Validates tokens and marks accounts as activated
 */

header('Content-Type: application/json');

// CORS configuration
$allowed_origins = [
    'https://vilara.ai',
    'https://www.vilara.ai',
    'http://localhost:3000',
    'http://localhost:8080'
];

$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
if (in_array($origin, $allowed_origins)) {
    header("Access-Control-Allow-Origin: $origin");
    header("Access-Control-Allow-Methods: GET, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");
    header("Access-Control-Allow-Credentials: true");
}

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only accept GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit();
}

// Include database
require_once __DIR__ . '/includes/database.php';

try {
    // Get token from query parameter
    $token = $_GET['token'] ?? '';
    
    if (empty($token)) {
        throw new Exception('Missing activation token');
    }
    
    // Validate token format (64 hex characters)
    if (!preg_match('/^[a-f0-9]{64}$/i', $token)) {
        throw new Exception('Invalid token format');
    }
    
    // Hash the token to match database storage
    $token_hash = hash('sha256', $token);
    
    // Connect to database
    $db = getDatabase();
    
    // Find signup with this token
    $stmt = $db->prepare("
        SELECT id, email, first_name, last_name, company_name, 
               company_size, migration_type, used_at, expires_at
        FROM signups 
        WHERE token_hash = ?
    ");
    $stmt->execute([$token_hash]);
    $signup = $stmt->fetch();
    
    if (!$signup) {
        throw new Exception('Invalid or expired activation token');
    }
    
    // Check if already used
    if ($signup['used_at']) {
        throw new Exception('This activation link has already been used');
    }
    
    // Check if expired
    if (strtotime($signup['expires_at']) < time()) {
        throw new Exception('This activation link has expired');
    }
    
    // Mark token as used
    $stmt = $db->prepare("
        UPDATE signups 
        SET used_at = NOW() 
        WHERE id = ?
    ");
    $stmt->execute([$signup['id']]);
    
    // Log successful activation
    error_log(json_encode([
        'event' => 'activation_success',
        'email' => $signup['email'],
        'company' => $signup['company_name'],
        'migration' => $signup['migration_type']
    ]));
    
    // Return success with user data
    echo json_encode([
        'success' => true,
        'message' => 'Account activated successfully',
        'user' => [
            'email' => $signup['email'],
            'firstName' => $signup['first_name'],
            'lastName' => $signup['last_name'],
            'companyName' => $signup['company_name'],
            'companySize' => $signup['company_size'],
            'migrationType' => $signup['migration_type']
        ]
    ]);
    
} catch (Exception $e) {
    error_log(json_encode([
        'event' => 'activation_error',
        'error' => $e->getMessage(),
        'token' => substr($token ?? '', 0, 8) . '...' // Log partial token for debugging
    ]));
    
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}