 Automated Testing (Recommended):

  # Navigate to website directory
  cd /mnt/c/Users/grayt/Desktop/Vilara/website

  # Run the full test suite
  node test-activation-flow.js

  # Run with verbose output
  node test-activation-flow.js --verbose

  # Use a specific email address
  node test-activation-flow.js --tim@vilara.ai

  # Test just the activation step (after you get the token from email)
  node test-activation-flow.js --activate=your-64-char-token

  What the script tests:

  1. Health Check - Verifies backend is responding
  2. Signup Flow - Tests /api/universal-signup.php
  3. Rate Limiting - Confirms abuse protection works
  4. Activation - Tests /api/activate.php (manual email step required)

  Quick Manual Test (if you prefer):

  # 1. Test health
  curl https://vilara.ai/debug.php

  # 2. Test signup
  curl -X POST https://vilara.ai/api/universal-signup.php \
    -H "Content-Type: application/json" \
    -d '{
      "companyName": "Test Corp",
      "email": "your-email@company.com",
      "firstName": "Test",
      "lastName": "User",
      "companySize": "10-49",
      "migrationContext": "quickbooks"
    }'

  # 3. Check your email for activation token
  # 4. Test activation
  curl -X POST https://vilara.ai/api/activate.php \
    -H "Content-Type: application/json" \
    -d '{"token": "your-64-char-hex-token"}'

  Benefits of the automated script:

  ✅ Repeatable - Run anytime during development✅ Comprehensive - Tests all components✅ Detailed reporting - Shows exactly what passed/failed✅
  Future-ready - Easy to extend for Configuration Wizard testing✅ CI/CD ready - Can integrate into automated pipelines later

  My recommendation: Run the automated script first. It will tell you immediately if steps 1-5 are working correctly and give you a baseline for all future development.

  HTTP Status Codes Quick Reference:

  - 200: Success
  - 400: Bad Request (invalid data)
  - 403: Forbidden (authentication issue)
  - 404: Not Found
  - 429: Too Many Requests (rate limited) ← Your error
  - 500: Server Error

  Why Website Testing Should Work if rate limit hit by automated testing:
  1. Different Request Pattern
    - Website = single manual form submission
    - Test script = multiple rapid automated requests
    - You're unlikely to hit 5 requests in an hour with manual testing
  2. Rate Limit Status
    - The limit is 5 requests per hour per IP
    - Your test script used several requests
    - But you probably have 1-2 requests left in your quota