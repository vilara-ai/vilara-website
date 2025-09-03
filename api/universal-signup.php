<?php
/**
 * Universal Signup Bridge API
 * Handles account creation and generates deployment-agnostic activation tokens
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    // Get POST data
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Invalid JSON input');
    }
    
    // Validate required fields
    $required_fields = ['email', 'company', 'password', 'industry'];
    foreach ($required_fields as $field) {
        if (empty($input[$field])) {
            throw new Exception("Missing required field: $field");
        }
    }
    
    $email = filter_var($input['email'], FILTER_VALIDATE_EMAIL);
    if (!$email) {
        throw new Exception('Invalid email address');
    }
    
    $company = trim($input['company']);
    $password = $input['password'];
    $industry = trim($input['industry']);
    
    // Password validation
    if (strlen($password) < 8) {
        throw new Exception('Password must be at least 8 characters');
    }
    
    // Create user account
    $user_id = createUser($email, $company, $password, $industry);
    
    if (!$user_id) {
        throw new Exception('Failed to create user account');
    }
    
    // Generate universal activation token (24-hour expiry)
    $activation_token = generateActivationToken($user_id);
    
    // Generate short activation code for desktop apps
    $desktop_code = generateShortCode($activation_token);
    
    // Prepare response with multiple activation methods
    $response = [
        'success' => true,
        'onboarding_token' => $activation_token,
        'user_data' => [
            'email' => $email,
            'company' => $company,
            'industry' => $industry
        ],
        'ui_activation_methods' => [
            'web_ui' => getWebUIActivationURL($activation_token),
            'desktop_app' => [
                'activation_code' => $desktop_code,
                'instruction' => 'Enter this code in Vilara Desktop App',
                'download_url' => 'https://vilara.ai/download'
            ],
            'private_network' => [
                'activation_token' => $activation_token,
                'instruction' => 'Share this token with your IT administrator',
                'setup_guide_url' => 'https://vilara.ai/docs/enterprise-setup'
            ]
        ]
    ];
    
    // Log successful signup
    logSignupEvent($user_id, $email, $company, $_SERVER['REMOTE_ADDR']);
    
    echo json_encode($response);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}

/**
 * Create user account in database
 */
function createUser($email, $company, $password, $industry) {
    try {
        $pdo = getDatabaseConnection();
        
        // Check if user already exists
        $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->execute([$email]);
        
        if ($stmt->fetch()) {
            throw new Exception('Email address already registered');
        }
        
        // Hash password
        $password_hash = password_hash($password, PASSWORD_DEFAULT);
        
        // Insert new user
        $stmt = $pdo->prepare("
            INSERT INTO users (email, company, password_hash, industry, created_at) 
            VALUES (?, ?, ?, ?, NOW())
        ");
        
        $stmt->execute([$email, $company, $password_hash, $industry]);
        
        return $pdo->lastInsertId();
        
    } catch (PDOException $e) {
        error_log("Database error in createUser: " . $e->getMessage());
        return false;
    }
}

/**
 * Generate secure activation token
 */
function generateActivationToken($user_id) {
    $token = bin2hex(random_bytes(32));
    
    try {
        $pdo = getDatabaseConnection();
        
        // Store token with 24-hour expiry
        $stmt = $pdo->prepare("
            INSERT INTO activation_tokens (user_id, token, expires_at, created_at) 
            VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 24 HOUR), NOW())
        ");
        
        $stmt->execute([$user_id, $token]);
        
        return $token;
        
    } catch (PDOException $e) {
        error_log("Database error in generateActivationToken: " . $e->getMessage());
        return false;
    }
}

/**
 * Generate short code for desktop app activation
 */
function generateShortCode($activation_token) {
    // Create 8-character code based on token hash
    $hash = hash('sha256', $activation_token);
    $code = strtoupper(substr($hash, 0, 4) . '-' . substr($hash, 4, 4));
    return $code;
}

/**
 * Get web UI activation URL
 */
function getWebUIActivationURL($token) {
    // Default to localhost for current alpha version
    return "http://localhost:5006/activate?token=" . $token;
}

/**
 * Get database connection
 */
function getDatabaseConnection() {
    $config = [
        'host' => $_ENV['DB_HOST'] ?? 'localhost',
        'dbname' => $_ENV['DB_NAME'] ?? 'vilara',
        'username' => $_ENV['DB_USER'] ?? 'vilara_user',
        'password' => $_ENV['DB_PASS'] ?? 'vilara_password'
    ];
    
    $dsn = "mysql:host={$config['host']};dbname={$config['dbname']};charset=utf8mb4";
    
    try {
        $pdo = new PDO($dsn, $config['username'], $config['password'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
        
        return $pdo;
        
    } catch (PDOException $e) {
        error_log("Database connection failed: " . $e->getMessage());
        throw new Exception('Database connection failed');
    }
}

/**
 * Log signup event for analytics
 */
function logSignupEvent($user_id, $email, $company, $ip_address) {
    try {
        $pdo = getDatabaseConnection();
        
        $stmt = $pdo->prepare("
            INSERT INTO signup_events (user_id, email, company, ip_address, created_at) 
            VALUES (?, ?, ?, ?, NOW())
        ");
        
        $stmt->execute([$user_id, $email, $company, $ip_address]);
        
    } catch (PDOException $e) {
        error_log("Failed to log signup event: " . $e->getMessage());
        // Don't throw exception - this is non-critical
    }
}
?>