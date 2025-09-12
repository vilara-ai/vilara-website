# Vilara System Architecture
*Last Updated: September 11, 2025*

## Overview
Vilara consists of three distinct components that work together to provide a complete ERP solution:

1. **Website** - Marketing & authentication (this repository)
2. **UI** - User interface layer
3. **Vilara-Core** - Business logic & Customer Integration Agent

## System Flow

```
Customer Journey:
1. Visit vilara.ai (Website)
   ↓
2. Sign up & authenticate
   ↓
3. Click "Launch Vilara"
   ↓
4. UI loads with Vilara-Core connection
   ↓
5. Customer Integration Agent guides setup (within Vilara-Core)
```

## Component Responsibilities & Ownership

### Website (vilara.ai) - **YOUR RESPONSIBILITY**
- **Purpose**: Marketing, lead generation, authentication
- **Technology**: HTML/CSS/JS + PHP backend
- **Deployment**: ✅ **DEPLOYED** - Vercel (frontend) + Cloud Run (PHP backend)
- **Responsibilities**:
  - Marketing pages & content
  - User signup/authentication
  - Account activation via email
  - Launch point for UI
- **Status**: Complete and functional

### Combined UI + Vilara-Core Container - **JOINT RESPONSIBILITY**
- **Purpose**: Complete Vilara system (UI + Core) per customer
- **Technology**: HTML + Python API server + Vilara-Core (Nushell + PostgreSQL)
- **Deployment**: 🚧 **TO DEPLOY** - Incus containers (one per customer)
- **Container Architecture**: Single container with both UI and Core
- **Your Responsibilities**:
  - UI layer: web interface, session management, response formatting
  - Container integration: combine UI with Vilara-Core
  - Direct communication: Python ↔ Nushell (no API calls)
  - Handle authentication handoff from Website
- **Business Partner's Responsibilities**:
  - Vilara-Core: business logic, ERP functionality, Nushell commands
  - Customer Integration Agent within Vilara-Core
  - PostgreSQL schema and data management
  - Command execution and validation
- **Shared Deployment**:
  - Incus container per customer
  - Combined codebase deployment
  - Joint container maintenance

## Integration Points

### Website → UI
After successful authentication:
```javascript
// Website (activate.html)
function launchVilara() {
    const token = getUserToken();
    const userData = getUserData();
    
    // Navigate to UI with context
    window.location.href = `/app?token=${token}&company=${userData.company}`;
}
```

### UI → Vilara-Core (Direct Integration)
Within the same container, UI connects directly to Vilara-Core:
```python
# UI (vilara-api-server.py) - YOUR CODE
import subprocess

def execute_vilara_command(user_command):
    """
    Direct communication within same container:
    - Receive command from UI
    - Execute Vilara-Core Nushell command directly
    - Return response to UI (no API calls)
    """
    result = subprocess.run(
        ['nu', '-c', user_command],
        cwd='/app/vilara-core',
        capture_output=True,
        text=True,
        env=vilara_env
    )
    return result.stdout

def handle_first_time_user():
    """
    Your responsibility: Detect and handle new users
    - Check if user is first-time
    - Execute Customer Integration Agent via direct Nushell call
    - Display agent responses
    """
    if is_first_time_user:
        # Direct execution of Customer Integration Agent
        return execute_vilara_command('stk_integration start')
```

## Customer Integration Agent (Within Vilara-Core)

The Customer Integration Agent is a Vilara-Core feature that:
1. **Detects** first-time users
2. **Guides** through setup process
3. **Configures** business settings
4. **Customizes** based on industry/size
5. **Validates** setup completion

This replaces the previous Business Configuration Wizard approach, keeping all business logic within Vilara-Core.

## Deployment Architecture

```
Production Environment:
┌─────────────────────────────────────────────┐
│             Google Cloud Platform            │
├─────────────────────────────────────────────┤
│                                              │
│  ┌──────────────┐        ┌──────────────┐  │
│  │   Vercel     │        │  Cloud Run   │  │
│  │              │        │              │  │
│  │  Website     │───────►│  PHP Backend │  │
│  │  (Static)    │        │  (Auth APIs) │  │
│  └──────────────┘        └──────────────┘  │
│                                    │        │
│                                    ▼        │
│                          ┌──────────────┐  │
│                          │  Cloud SQL   │  │
│                          │ (PostgreSQL) │  │
│                          └──────────────┘  │
│                                              │
│  ┌─────────────────────────────────────┐   │
│  │      Incus Container Host           │   │
│  ├─────────────────────────────────────┤   │
│  │ ┌─────────────────────────────────┐ │   │
│  │ │  Customer A Container (Incus)   │ │   │
│  │ │  ┌──────────┬──────────────┐   │ │   │
│  │ │  │UI Layer  │ Vilara-Core  │   │ │   │
│  │ │  │(Python)  │ (Nushell +   │   │ │   │
│  │ │  │          │  PostgreSQL) │   │ │   │
│  │ │  └──────────┴──────────────┘   │ │   │
│  │ └─────────────────────────────────┘ │   │
│  │                                     │   │
│  │ ┌─────────────────────────────────┐ │   │
│  │ │  Customer B Container (Incus)   │ │   │
│  │ │  ┌──────────┬──────────────┐   │ │   │
│  │ │  │UI Layer  │ Vilara-Core  │   │ │   │
│  │ │  │(Python)  │ (Nushell +   │   │ │   │
│  │ │  │          │  PostgreSQL) │   │ │   │
│  │ │  └──────────┴──────────────┘   │ │   │
│  │ └─────────────────────────────────┘ │   │
│  └─────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

## Implementation Plan

### Your Tasks (UI Integration)
1. **Create Combined Container**
   - Create Dockerfile that includes both UI and Vilara-Core
   - Configure direct Python ↔ Nushell communication
   - Set up container-local PostgreSQL for each customer

2. **Implement Direct Integration**
   - Replace API calls with direct subprocess execution
   - Handle Vilara-Core responses and format for UI
   - Manage authentication handoff from Website

3. **Test Container Locally**
   - Test combined UI + Core functionality
   - Verify customer isolation
   - Test authentication and session management

### Business Partner's Tasks (Vilara-Core)
1. **Vilara-Core Development**
   - Nushell command modules and business logic
   - Customer Integration Agent implementation
   - PostgreSQL schema and data management

2. **Container Integration Support**
   - Provide Vilara-Core installation/setup scripts
   - Ensure Nushell commands work in container environment
   - Database initialization and migration scripts

### Joint Tasks (Deployment)
1. **Incus Container Setup**
   - Configure Incus for customer containers
   - Set up per-customer container provisioning
   - Configure networking and isolation

### Future Enhancements
- Multi-tenant architecture
- Horizontal scaling
- Advanced monitoring
- Backup and disaster recovery

## Environment Variables

### Website
```env
DB_HOST=<Cloud SQL host>
DB_NAME=appdb
DB_USER=appuser
SENDGRID_API_KEY=<SendGrid key>
```

### UI Layer
```env
VILARA_CORE_URL=<Vilara-Core service URL>
SESSION_SECRET=<Secret key>
```

### Vilara-Core
```env
DATABASE_URL=<PostgreSQL connection string>
INTEGRATION_AGENT_ENABLED=true
```

## Security Considerations

1. **Authentication Flow**
   - Token-based authentication from Website
   - Token validation in UI layer
   - Secure session management

2. **Data Protection**
   - HTTPS everywhere
   - Encrypted database connections
   - Secrets in Google Secret Manager

3. **Access Control**
   - Rate limiting on APIs
   - Role-based access control
   - Audit logging

## Summary

This architecture provides:
- **Clean separation** of concerns
- **Scalable** deployment model
- **Simplified** business logic (all in Vilara-Core)
- **Better** user experience with integrated setup

The Customer Integration Agent within Vilara-Core handles all business configuration, eliminating the need for separate wizards or complex UI-based setup flows.