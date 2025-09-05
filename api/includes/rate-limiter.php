<?php
/**
 * Rate limiting implementation
 * Tracks requests per IP address with configurable limits
 */

function checkRateLimit($ip_address, $max_requests = 5, $window_seconds = 3600) {
    try {
        $db = getDatabase();
        $endpoint = $_SERVER['REQUEST_URI'] ?? 'unknown';
        
        // Clean up old rate limit records (older than window)
        $db->exec("
            DELETE FROM rate_limits 
            WHERE window_start < NOW() - INTERVAL '{$window_seconds} seconds'
        ");
        
        // Check current rate limit
        $stmt = $db->prepare("
            SELECT request_count 
            FROM rate_limits 
            WHERE ip_address = ? 
            AND endpoint = ?
            AND window_start > NOW() - INTERVAL '{$window_seconds} seconds'
        ");
        $stmt->execute([$ip_address, $endpoint]);
        $result = $stmt->fetch();
        
        if ($result) {
            // Existing record found
            if ($result['request_count'] >= $max_requests) {
                // Rate limit exceeded
                error_log("Rate limit exceeded for IP: {$ip_address}, endpoint: {$endpoint}");
                return false;
            }
            
            // Increment counter
            $stmt = $db->prepare("
                UPDATE rate_limits 
                SET request_count = request_count + 1 
                WHERE ip_address = ? 
                AND endpoint = ?
            ");
            $stmt->execute([$ip_address, $endpoint]);
            
        } else {
            // Create new rate limit record
            $stmt = $db->prepare("
                INSERT INTO rate_limits (ip_address, endpoint, request_count, window_start) 
                VALUES (?, ?, 1, NOW())
                ON CONFLICT (ip_address, endpoint) 
                DO UPDATE SET 
                    request_count = rate_limits.request_count + 1,
                    window_start = CASE 
                        WHEN rate_limits.window_start < NOW() - INTERVAL '{$window_seconds} seconds' 
                        THEN NOW() 
                        ELSE rate_limits.window_start 
                    END
            ");
            $stmt->execute([$ip_address, $endpoint]);
        }
        
        return true;
        
    } catch (Exception $e) {
        error_log("Rate limiting error: " . $e->getMessage());
        // On error, allow the request (fail open)
        return true;
    }
}

/**
 * Get remaining requests for an IP
 */
function getRemainingRequests($ip_address, $max_requests = 5, $window_seconds = 3600) {
    try {
        $db = getDatabase();
        $endpoint = $_SERVER['REQUEST_URI'] ?? 'unknown';
        
        $stmt = $db->prepare("
            SELECT request_count 
            FROM rate_limits 
            WHERE ip_address = ? 
            AND endpoint = ?
            AND window_start > NOW() - INTERVAL '{$window_seconds} seconds'
        ");
        $stmt->execute([$ip_address, $endpoint]);
        $result = $stmt->fetch();
        
        if ($result) {
            return max(0, $max_requests - $result['request_count']);
        }
        
        return $max_requests;
        
    } catch (Exception $e) {
        error_log("Rate limiting query error: " . $e->getMessage());
        return $max_requests;
    }
}