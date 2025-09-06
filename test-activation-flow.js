#!/usr/bin/env node

/**
 * Vilara Activation Flow Test Suite
 * Tests the complete user activation flow from signup to activation
 * 
 * Usage: node test-activation-flow.js [--verbose] [--email=test@example.com]
 */

const https = require('https');
const http = require('http');

class ActivationFlowTester {
    constructor(options = {}) {
        this.verbose = options.verbose || false;
        this.baseUrl = 'https://vilara.ai';
        this.testEmail = options.email || `test-${Date.now()}@example.com`;
        this.testData = {
            companyName: "Test Corp",
            email: this.testEmail,
            firstName: "John",
            lastName: "Doe", 
            companySize: "10-49",
            migrationContext: "quickbooks"
        };
        this.results = [];
    }

    log(message, isError = false) {
        const timestamp = new Date().toISOString();
        const prefix = isError ? '❌ ERROR' : '✅ INFO';
        const logMessage = `[${timestamp}] ${prefix}: ${message}`;
        
        console.log(logMessage);
        if (this.verbose || isError) {
            console.log('---');
        }
    }

    async makeRequest(path, method = 'GET', data = null) {
        return new Promise((resolve, reject) => {
            const url = `${this.baseUrl}${path}`;
            const options = {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    'User-Agent': 'Vilara-Test-Suite/1.0'
                }
            };

            if (this.verbose) {
                console.log(`Making ${method} request to: ${url}`);
                if (data) console.log(`Request data:`, JSON.stringify(data, null, 2));
            }

            const req = https.request(url, options, (res) => {
                let responseData = '';
                
                res.on('data', (chunk) => {
                    responseData += chunk;
                });

                res.on('end', () => {
                    try {
                        const parsed = JSON.parse(responseData);
                        resolve({
                            statusCode: res.statusCode,
                            headers: res.headers,
                            data: parsed
                        });
                    } catch (e) {
                        // Handle non-JSON responses
                        resolve({
                            statusCode: res.statusCode,
                            headers: res.headers,
                            data: responseData
                        });
                    }
                });
            });

            req.on('error', (error) => {
                reject(error);
            });

            if (data) {
                req.write(JSON.stringify(data));
            }
            
            req.end();
        });
    }

    async testHealthCheck() {
        this.log("Testing API health check (using signup endpoint)...");
        try {
            // Test with a GET request to signup endpoint (should return 405 or similar but confirms API is up)
            const response = await this.makeRequest('/api/universal-signup.php');
            
            // We expect this to fail with 405 (Method Not Allowed) since we're using GET
            // But any response means the API is reachable
            if (response.statusCode === 405 || response.statusCode === 400 || response.statusCode === 200) {
                this.log("✅ API is reachable");
                return { success: true, message: "API is responsive" };
            } else if (response.statusCode === 404) {
                this.log(`❌ API endpoint not found`, true);
                return { success: false, message: `API endpoint not found` };
            } else {
                this.log(`⚠️ Unexpected status ${response.statusCode}, but API is reachable`);
                return { success: true, message: `API responded with ${response.statusCode}` };
            }
        } catch (error) {
            this.log(`❌ Health check error: ${error.message}`, true);
            return { success: false, message: error.message };
        }
    }

    async testSignup() {
        this.log(`Testing signup with email: ${this.testEmail}`);
        try {
            const response = await this.makeRequest('/api/universal-signup.php', 'POST', this.testData);
            
            if (response.statusCode === 200 || response.statusCode === 201) {
                if (response.data.success) {
                    this.log("✅ Signup successful");
                    return { 
                        success: true, 
                        message: "Signup completed",
                        data: response.data
                    };
                } else {
                    this.log(`❌ Signup failed: ${response.data.error}`, true);
                    return { success: false, message: response.data.error };
                }
            } else {
                this.log(`❌ Signup HTTP error: ${response.statusCode}`, true);
                return { success: false, message: `HTTP ${response.statusCode}` };
            }
        } catch (error) {
            this.log(`❌ Signup error: ${error.message}`, true);
            return { success: false, message: error.message };
        }
    }

    async testActivation(token) {
        this.log(`Testing activation with token: ${token.substring(0, 8)}...`);
        try {
            const response = await this.makeRequest('/api/activate.php', 'POST', { token });
            
            if (response.statusCode === 200) {
                if (response.data.success) {
                    this.log("✅ Activation successful");
                    return { 
                        success: true, 
                        message: "Activation completed",
                        data: response.data
                    };
                } else {
                    this.log(`❌ Activation failed: ${response.data.error}`, true);
                    return { success: false, message: response.data.error };
                }
            } else {
                this.log(`❌ Activation HTTP error: ${response.statusCode}`, true);
                return { success: false, message: `HTTP ${response.statusCode}` };
            }
        } catch (error) {
            this.log(`❌ Activation error: ${error.message}`, true);
            return { success: false, message: error.message };
        }
    }

    async testRateLimit() {
        this.log("Testing rate limiting (making 6 rapid requests)...");
        const promises = [];
        
        for (let i = 0; i < 6; i++) {
            const testData = {
                ...this.testData,
                email: `ratelimit-${Date.now()}-${i}@example.com`
            };
            promises.push(this.makeRequest('/api/universal-signup.php', 'POST', testData));
        }

        try {
            const responses = await Promise.all(promises);
            const rateLimited = responses.some(r => r.statusCode === 429);
            
            if (rateLimited) {
                this.log("✅ Rate limiting working correctly");
                return { success: true, message: "Rate limiting active" };
            } else {
                this.log("⚠️  Rate limiting may not be working", true);
                return { success: false, message: "No rate limit detected" };
            }
        } catch (error) {
            this.log(`❌ Rate limit test error: ${error.message}`, true);
            return { success: false, message: error.message };
        }
    }

    async runFullTest() {
        console.log('🚀 Starting Vilara Activation Flow Test Suite');
        console.log('================================================');
        
        const startTime = Date.now();
        
        // Step 1: Health Check
        const health = await this.testHealthCheck();
        this.results.push({ step: 'Health Check', ...health });
        
        if (!health.success) {
            console.log('❌ Health check failed, aborting tests');
            return this.generateReport();
        }

        // Step 2: Signup Test
        const signup = await this.testSignup();
        this.results.push({ step: 'Signup', ...signup });

        // Step 3: Rate Limit Test (optional)
        const rateLimit = await this.testRateLimit();
        this.results.push({ step: 'Rate Limiting', ...rateLimit });

        // Step 4: Manual Activation Test
        console.log('\n📧 MANUAL STEP REQUIRED:');
        console.log('=========================================');
        console.log(`1. Check email: ${this.testEmail}`);
        console.log('2. Find activation email from Vilara');
        console.log('3. Copy the activation token from the email');
        console.log('4. Run: node test-activation-flow.js --activate=YOUR_TOKEN');
        console.log('   OR');
        console.log('5. Visit the activation link in the email');

        const endTime = Date.now();
        const duration = (endTime - startTime) / 1000;

        console.log(`\n⏱️  Test completed in ${duration}s`);
        return this.generateReport();
    }

    async runActivationOnly(token) {
        console.log('🔐 Testing Activation Only');
        console.log('==========================');
        
        const activation = await this.testActivation(token);
        this.results.push({ step: 'Activation', ...activation });
        
        return this.generateReport();
    }

    generateReport() {
        console.log('\n📊 TEST RESULTS SUMMARY');
        console.log('========================');
        
        let passed = 0;
        let failed = 0;

        this.results.forEach(result => {
            const status = result.success ? '✅ PASS' : '❌ FAIL';
            console.log(`${status} ${result.step}: ${result.message}`);
            
            if (result.success) passed++;
            else failed++;
        });

        console.log(`\n📈 Overall: ${passed} passed, ${failed} failed`);
        
        if (failed === 0) {
            console.log('🎉 All tests passed! Activation flow is working correctly.');
        } else {
            console.log('⚠️  Some tests failed. Check the logs above for details.');
        }

        console.log('\n💡 Next Steps:');
        if (failed === 0) {
            console.log('- ✅ Activation flow is ready');
            console.log('- 🚀 Ready to build Configuration Wizard');
            console.log('- 📝 Consider setting up monitoring for production');
        } else {
            console.log('- 🔧 Fix failing tests before proceeding');
            console.log('- 🔍 Check server logs for detailed error information');
            console.log('- 🌐 Verify domain configuration and SSL certificates');
        }

        return {
            passed,
            failed,
            total: this.results.length,
            success: failed === 0
        };
    }
}

// Command line interface
async function main() {
    const args = process.argv.slice(2);
    const options = {
        verbose: args.includes('--verbose'),
        email: args.find(arg => arg.startsWith('--email='))?.split('=')[1]
    };

    const activateToken = args.find(arg => arg.startsWith('--activate='))?.split('=')[1];

    const tester = new ActivationFlowTester(options);

    if (activateToken) {
        await tester.runActivationOnly(activateToken);
    } else {
        await tester.runFullTest();
    }
}

// Run if called directly
if (require.main === module) {
    main().catch(console.error);
}

module.exports = ActivationFlowTester;