# Vilara System Architecture
*Last Updated: January 2025*

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

## Component Responsibilities

### Website (vilara.ai)
- **Purpose**: Marketing, lead generation, authentication
- **Technology**: HTML/CSS/JS + PHP backend
- **Deployment**: Vercel (frontend) + Cloud Run (PHP backend)
- **Responsibilities**:
  - Marketing pages & content
  - User signup/authentication
  - Account activation via email
  - Launch point for UI

### UI Layer
- **Purpose**: User interface for Vilara system
- **Technology**: HTML + Python API server
- **Deployment**: To be deployed on Cloud Run
- **Responsibilities**:
  - Display interface to users
  - Handle user inputs
  - Communicate with Vilara-Core
  - Session management

### Vilara-Core
- **Purpose**: Business logic and ERP functionality
- **Technology**: Nushell + PostgreSQL
- **Deployment**: To be containerized and deployed
- **Responsibilities**:
  - Customer Integration Agent (setup wizard)
  - Business logic processing
  - Data management
  - ERP operations
  - Natural language processing

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

### UI → Vilara-Core
The UI connects to Vilara-Core through API calls:
```python
# UI (vilara-api-server.py)
def connect_to_core():
    # Establish connection to Vilara-Core
    core_connection = VilaraCore.connect(
        user_token=token,
        company_id=company_id
    )
    
    # Initialize Customer Integration Agent
    if is_first_time_user:
        core_connection.start_integration_agent()
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
│  │      Cloud Run (To Deploy)          │   │
│  ├─────────────────────────────────────┤   │
│  │   UI Layer    │   Vilara-Core       │   │
│  │   (Python)    │   (Nushell)         │   │
│  └─────────────────────────────────────┘   │
│                                              │
└──────────────────────────────────────────────┘
```

## Next Steps

### Immediate Priority
1. **Deploy UI to Cloud Run**
   - Containerize Python UI server
   - Set up Cloud Run service
   - Configure environment variables

2. **Deploy Vilara-Core**
   - Containerize Vilara-Core
   - Include Customer Integration Agent
   - Set up API endpoints

3. **Connect Components**
   - Update UI to connect to deployed Vilara-Core
   - Pass authentication from Website to UI
   - Initialize Customer Integration Agent for new users

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