# Customer Handoff Architecture: Website → Vilara Implementation
*Last Updated: September 11, 2025*

## Overview
This document details the complete customer handoff process from initial website registration to launching their fully customized Vilara implementation with Demo, Test, and Live environments.

## Current State vs Target State

### Current Handoff (Implemented)
```
Customer Registration → Email Activation → "Launch Vilara" Button → /app?token=X
                                                                      ↓
                                                            Placeholder UI (app.html)
```

### Target Handoff (To Implement)
```
Customer Registration → Email Activation → "Launch Vilara" Button → Container Provisioning
                                                                      ↓
                                                           Customer's Complete Vilara World:
                                                           ├── Demo Environment
                                                           ├── Test Environment  
                                                           ├── Live Environment
                                                           └── Customized Work Instructions
```

## The Complete Handoff Process

### Phase 1: Customer Registration (✅ DONE)
**Location**: Website (vilara.ai)
**Process**:
1. Customer visits vilara.ai and signs up
2. Email activation with unique token
3. Customer clicks activation link
4. activate.html validates token and shows "Launch Vilara" button

**Data Collected**:
- `company`: Company name
- `firstName`, `lastName`: User details
- `email`: Contact information
- `companySize`: For qualification
- `token`: Unique authentication token

### Phase 2: Container Provisioning (🚧 TO IMPLEMENT)
**Location**: Backend container orchestration
**What Should Happen When Customer Clicks "Launch Vilara"**:

```javascript
// Enhanced activateWebUI() function
function activateWebUI() {
    // Current data collection (already implemented)
    const userData = {
        token: activationData.onboarding_token,
        company: activationData.user_data.company,
        firstName: activationData.user_data.firstName,
        email: activationData.user_data.email,
        companySize: activationData.user_data.companySize
    };
    
    // NEW: Trigger container provisioning
    provisionCustomerContainer(userData)
        .then(containerInfo => {
            // Redirect to customer's specific container
            window.location.href = containerInfo.url;
        });
}

async function provisionCustomerContainer(userData) {
    // Call backend to create customer's Incus container
    const response = await fetch('/api/provision-container.php', {
        method: 'POST',
        body: JSON.stringify(userData)
    });
    
    return await response.json(); // Returns: { url: "https://vilara-host.com:8001", containerId: "customer_123" }
}
```

**Container Provisioning Steps**:
1. **Generate Customer ID**: `customer_${company_slug}_${timestamp}`
2. **Create Incus Container**: Based on Vilara template
3. **Initialize Customer Database**: PostgreSQL with customer schema
4. **Set Environment Variables**: Customer-specific configuration
5. **Start Services**: UI + Vilara-Core + Database
6. **Assign Port**: Unique port for customer access
7. **Return Access URL**: `https://vilara-host.com:${customer_port}`

### Phase 3: Customer's Vilara Implementation (🚧 TO IMPLEMENT)
**Location**: Customer's dedicated Incus container
**What Customer Gets**:

```
Customer Container: https://vilara-host.com:8001
┌─────────────────────────────────────────────┐
│  Customer: ABC Corporation                  │
├─────────────────────────────────────────────┤
│  🎮 Demo Environment                        │
│  ├── Sample data & transactions            │
│  ├── Interactive tutorials                 │
│  └── "Try before you configure"           │
│                                            │
│  🧪 Test Environment(s) - FULL ERP         │
│  ├── Complete ERP functionality            │
│  ├── Spin up/destroy at will               │
│  ├── Multiple instances allowed            │
│  ├── Safe experimentation space            │
│  └── "Reset anytime" capability            │
│                                            │
│  🏢 Live Environment - PROTECTED           │
│  ├── Production data ONLY                  │
│  ├── Never contaminated with test data     │
│  ├── Full ERP functionality               │
│  └── Controlled promotion from Test        │
│                                            │
│  📋 Customized Work Instructions           │
│  ├── Industry-specific workflows          │
│  ├── Company-specific procedures          │
│  └── Role-based task guidance             │
└─────────────────────────────────────────────┘
```

## Environment Architecture Within Customer Container

### Demo Environment
**Purpose**: Let customers explore Vilara without risk
```
Demo Database: vilara_demo_${customer_id}
├── Sample business partners (customers/vendors)
├── Example invoices and transactions  
├── Project data and timesheets
├── Interactive tutorial scenarios
└── Pre-configured business workflows
```

**Customer Integration Agent Role**:
- **Onboarding Tour**: "Welcome to Vilara! Here's how it works..."
- **Feature Demonstration**: Show key ERP functions with sample data
- **Natural Language Training**: "Try saying 'show me all customers'"

### Test Environment  
**Purpose**: Full ERP system that customers can spin up and destroy at will
```
Test Database: vilara_test_${customer_id}_${instance}
├── Complete ERP functionality (same as Live)
├── All business modules and features
├── Customer's configuration and data
├── Safe testing and experimentation
└── Disposable - can be reset/recreated anytime
```

**Key Features**:
- **Full ERP Capabilities**: Every feature available in Live
- **Spin Up/Down**: Create new test instances instantly
- **Reset Anytime**: "Start fresh" without affecting Live
- **Safe Experimentation**: Test configurations, imports, workflows
- **Multiple Instances**: Can have multiple test environments simultaneously

**Customer Integration Agent Role**:
- **Setup Wizard**: "Let's configure Vilara for your business"
- **Experimentation**: "Want to try a different approach? Spin up a new test instance"
- **Validation**: "Test your workflows here before promoting to Live"
- **Training**: "Practice using Vilara with real scenarios"

### Live Environment
**Purpose**: Protected production ERP system - never has test data
```
Live Database: vilara_live_${customer_id}
├── Production business data ONLY
├── Real transactions and operations
├── Full audit trails and compliance
├── Performance monitoring
├── Backup and disaster recovery
└── PROTECTED: No test/experimental data ever
```

**Key Protection Features**:
- **Pristine Production Data**: Never contaminated with test data
- **Controlled Access**: Only validated configurations promoted from Test
- **Audit Compliance**: Clean audit trails for regulatory requirements
- **Data Integrity**: Production operations never mixed with experiments
- **Backup Strategy**: Only production-quality data backed up

**Customer Integration Agent Role**:
- **Go-Live Support**: "Ready to promote your tested configuration to Live?"
- **Production Guidance**: Help with daily operations on live data
- **Data Protection**: "This will affect live data - are you sure?"
- **Optimization**: "I noticed you're doing X often, here's a shortcut"

## Implementation Requirements

### Backend Container API (NEW)
**File**: `/api/provision-container.php`
```php
<?php
// Handle container provisioning request
if ($_POST) {
    $userData = json_decode(file_get_contents('php://input'), true);
    
    // Generate customer ID
    $customerId = generateCustomerId($userData['company']);
    
    // Create Incus container
    $containerId = createIncusContainer($customerId, $userData);
    
    // Initialize environments
    initializeEnvironments($containerId, $userData);
    
    // Return access info
    echo json_encode([
        'success' => true,
        'url' => "https://vilara-host.com:" . getCustomerPort($customerId),
        'containerId' => $containerId,
        'environments' => ['demo', 'test', 'live']
    ]);
}

function createIncusContainer($customerId, $userData) {
    // Execute Incus commands to create customer container
    $command = "incus launch vilara-template $customerId";
    exec($command);
    
    // Configure environment variables
    $envVars = [
        'CUSTOMER_ID' => $customerId,
        'CUSTOMER_NAME' => $userData['company'],
        'USER_EMAIL' => $userData['email']
    ];
    
    foreach ($envVars as $key => $value) {
        exec("incus config set $customerId environment.$key '$value'");
    }
    
    return $customerId;
}

function initializeEnvironments($containerId, $userData) {
    // Initialize Demo environment with sample data
    exec("incus exec $containerId -- /app/scripts/init-demo.sh");
    
    // Initialize Test environment management (full ERP, disposable)
    exec("incus exec $containerId -- /app/scripts/init-test-manager.sh '{$userData['company']}'");
    
    // Initialize Live environment (pristine production, protected)
    exec("incus exec $containerId -- /app/scripts/init-live.sh '{$userData['company']}'");
}
?>
```

### Customer Integration Agent Enhancement (Business Partner's Responsibility)
**Location**: Within Vilara-Core
**New Capabilities Needed**:

```nushell
# Environment management commands
def "environment switch" [env: string] {
    # Switch between demo/test/live environments
}

def "environment status" [] {
    # Show current environment and data status
}

# Test environment management
def "test create" [name?: string] {
    # Create new test environment instance
}

def "test destroy" [name: string] {
    # Destroy test environment instance
}

def "test list" [] {
    # Show all test environment instances
}

def "test reset" [name: string] {
    # Reset test environment to clean state
}

# Enhanced onboarding
def "integration welcome" [] {
    # Multi-environment welcome experience
}

def "integration demo" [] {
    # Interactive demo with sample data
}

def "integration setup" [] {
    # Guided configuration in test environment
}

def "integration promote" [] {
    # Promote tested configuration to Live
}

def "integration protect" [] {
    # Explain Live environment protection
}
```

## Customized Work Instructions

### Industry-Specific Templates
Based on customer data, provide relevant workflows:

**Manufacturing**: 
- Material requirements planning
- Production scheduling workflows  
- Quality control procedures

**Services**:
- Project management workflows
- Time tracking procedures
- Client billing processes

**Retail**:
- Inventory management
- Point-of-sale integration
- Customer loyalty workflows

### Company-Specific Customization
**Generated during Test Environment setup**:
- Customer's specific business partner list
- Their product/service catalog  
- Custom fields and workflows
- Integration with existing systems
- Compliance requirements

## Security & Isolation

### Container-Level Separation
- Each customer gets completely isolated container
- No shared data or processes between customers
- Dedicated PostgreSQL databases per environment
- Separate file systems and network namespaces

### Environment Separation Within Container
```
Customer Container
├── Demo Environment (read-only sample data)
├── Test Environment(s) (full ERP, disposable, multiple instances)
└── Live Environment (pristine production data, protected)
```

### Data Flow Controls
- **Demo → Test**: Allow copying sample configurations to new test instances
- **Test → Live**: Controlled promotion of validated setups only
- **Test Management**: Create/destroy/reset test instances at will
- **Live Protection**: No test data ever contaminates production
- **Multiple Test Instances**: "test-marketing-config", "test-new-workflow", etc.
- **No Cross-Customer Data**: Complete isolation between customers


## Conclusion

This handoff architecture transforms the customer experience from "seeing a demo" to "getting their own complete Vilara world" with Demo, Test, and Live environments plus customized work instructions. 

The key innovation is providing each customer with their own isolated, complete ERP implementation that's pre-configured for their industry and business size, guided by an intelligent Customer Integration Agent that helps them every step of the way from exploration to production use.