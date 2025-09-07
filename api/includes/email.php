<?php
/**
 * Email handler using SendGrid API
 * Sends activation emails with proper templates
 */

function sendActivationEmail($to_email, $first_name, $activation_url, $migration_type, $company_name) {
    try {
        // Get SendGrid API key from environment
        $api_key = $_ENV['SENDGRID_API_KEY'] ?? '';
        
        if (empty($api_key)) {
            error_log("SendGrid API key not configured");
            return false;
        }
        
        // Prepare email content based on migration type
        $subject = "Welcome to Vilara - Activate Your Account";
        
        $migration_messages = [
            'fresh' => "We're excited to be your AI ERP Assistant!",
            'enhance' => "Ready to enhance your existing ERP capabilities!",
            'full' => "Let's transform your ERP experience together!"
        ];
        
        $migration_message = $migration_messages[$migration_type] ?? $migration_messages['fresh'];
        
        // HTML email template
        $html_content = "
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px 10px 0 0; }
                .content { background: white; padding: 30px; border: 1px solid #e0e0e0; border-radius: 0 0 10px 10px; }
                .button { display: inline-block; padding: 15px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                .footer { text-align: center; color: #666; font-size: 12px; margin-top: 30px; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <img src='https://www.vilara.ai/assets/images/vilara_logo.png' alt='Vilara' style='width: 120px; margin-bottom: 20px;'>
                    <h1>Welcome to Vilara, {$first_name}!</h1>
                    <p>{$migration_message}</p>
                </div>
                <div class='content'>
                    <p>Thank you for choosing Vilara for {$company_name}.</p>
                    
                    <p><strong>You're just a few minutes away from supercharging your operations!</strong></p>
                    
                    <p>Click the button below to activate your account and get started:</p>
                    
                    <a href='{$activation_url}' class='button'>Activate Your Account</a>
                    
                    <p style='color: #666; font-size: 14px;'>
                        Or copy and paste this link into your browser:<br>
                        <code>{$activation_url}</code>
                    </p>
                    
                    <p><strong>This activation link expires in 24 hours.</strong></p>
                    
                    <h3>What happens next?</h3>
                    <ul>
                        <li>Complete your account activation</li>
                        <li>Set up your workspace preferences</li>
                        <li>Import your data (if applicable)</li>
                        <li>Customize your work instructions via the Vilara setup wizard</li>
                        <li>Start using natural language to manage your business</li>
                    </ul>
                </div>
                <div class='footer'>
                    <p>© 2025 Vilara. All rights reserved.</p>
                    <p>If you didn't sign up for Vilara, please ignore this email.</p>
                </div>
            </div>
        </body>
        </html>
        ";
        
        // Plain text fallback
        $text_content = "
Welcome to Vilara, {$first_name}!

{$migration_message}

Thank you for choosing Vilara for {$company_name}.

Activate your account by visiting:
{$activation_url}

This link expires in 24 hours.

What happens next?
- Complete your account activation
- Set up your workspace preferences
- Import your data (if applicable)
- Start using natural language to manage your business

© 2025 Vilara. All rights reserved.
        ";
        
        // Prepare SendGrid request
        $data = [
            'personalizations' => [
                [
                    'to' => [
                        ['email' => $to_email, 'name' => $first_name]
                    ],
                    'subject' => $subject
                ]
            ],
            'from' => [
                'email' => 'noreply@vilara.ai',
                'name' => 'Vilara'
            ],
            'content' => [
                ['type' => 'text/plain', 'value' => $text_content],
                ['type' => 'text/html', 'value' => $html_content]
            ]
        ];
        
        // Send via SendGrid API
        $ch = curl_init('https://api.sendgrid.com/v3/mail/send');
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $api_key,
            'Content-Type: application/json'
        ]);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        
        $response = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($http_code >= 200 && $http_code < 300) {
            error_log("Activation email sent successfully to {$to_email}");
            return true;
        } else {
            error_log("SendGrid error: HTTP {$http_code}, Response: {$response}");
            return false;
        }
        
    } catch (Exception $e) {
        error_log("Email sending failed: " . $e->getMessage());
        return false;
    }
}