<?php
/**
 * Universal Signup API Endpoint
 * Handles new signups with migration context and token generation
 * GCP Cloud Run + PostgreSQL implementation
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
    header("Access-Control-Allow-Methods: POST, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");
    header("Access-Control-Allow-Credentials: true");
}

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit();
}

// Include required files
require_once __DIR__ . '/includes/database.php';
require_once __DIR__ . '/includes/email.php';
require_once __DIR__ . '/includes/rate-limiter.php';

try {
    // Get client IP
    $ip_address = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '';
    
    // Rate limiting check
    if (!checkRateLimit($ip_address, 20, 3600)) { // 20 requests per hour
        http_response_code(429);
        echo json_encode(['success' => false, 'error' => 'Too many requests. Please try again later.']);
        exit();
    }
    
    // Parse input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Invalid JSON input');
    }
    
    // Validate required fields
    $required_fields = ['email', 'firstName', 'lastName', 'companyName', 'companySize'];
    foreach ($required_fields as $field) {
        if (empty($input[$field])) {
            throw new Exception("Missing required field: $field");
        }
    }
    
    // Validate email
    $email = filter_var($input['email'], FILTER_VALIDATE_EMAIL);
    if (!$email) {
        throw new Exception('Invalid email address');
    }
    
    // Get migration type from query parameter
    $migration_type = $_GET['migration'] ?? 'fresh';
    if (!in_array($migration_type, ['fresh', 'enhance', 'full'])) {
        $migration_type = 'fresh';
    }
    
    // Connect to database
    $db = getDatabase();
    
    // Check if email already has pending activation
    $stmt = $db->prepare("
        SELECT id FROM signups 
        WHERE email = ? 
        AND used_at IS NULL 
        AND expires_at > NOW()
    ");
    $stmt->execute([$email]);
    
    if ($stmt->fetch()) {
        throw new Exception('An activation link has already been sent to this email.');
    }
    
    // Generate secure token
    $token = bin2hex(random_bytes(32)); // 64 character hex token
    $token_hash = hash('sha256', $token);
    
    // Store signup in database
    $stmt = $db->prepare("
        INSERT INTO signups (
            email, first_name, last_name, company_name, company_size,
            phone, migration_type, token_hash, ip_address,
            created_at, expires_at
        ) VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?,
            NOW(), NOW() + INTERVAL '24 hours'
        )
    ");
    
    $success = $stmt->execute([
        $email,
        $input['firstName'],
        $input['lastName'],
        $input['companyName'],
        $input['companySize'],
        $input['phone'] ?? null,
        $migration_type,
        $token_hash,
        $ip_address
    ]);
    
    if (!$success) {
        throw new Exception('Failed to create signup record');
    }
    
    // Send activation email
    $activation_url = "https://vilara.ai/activate.html?token=$token";
    $email_sent = sendActivationEmail(
        $email,
        $input['firstName'],
        $activation_url,
        $migration_type,
        $input['companyName']
    );
    
    if (!$email_sent) {
        error_log("Warning: Failed to send activation email to $email");
        // Continue anyway - token is stored
    }
    
    // Log successful signup
    error_log(json_encode([
        'event' => 'signup_success',
        'email' => $email,
        'company' => $input['companyName'],
        'migration' => $migration_type,
        'ip' => $ip_address
    ]));
    
    // Return success response
    echo json_encode([
        'success' => true,
        'token' => $token,
        'message' => 'Activation link sent to your email'
    ]);
    
} catch (Exception $e) {
    error_log(json_encode([
        'event' => 'signup_error',
        'error' => $e->getMessage(),
        'ip' => $ip_address ?? 'unknown'
    ]));
    
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}