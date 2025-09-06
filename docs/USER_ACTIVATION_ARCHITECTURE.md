# Vilara AI User Activation Architecture
*Document Date: September 5, 2025*
*Related Document: [BUSINESS_CONFIGURATION_WIZARD.md](BUSINESS_CONFIGURATION_WIZARD.md) - Covers post-activation business setup*

## Executive Summary

This document outlines the user activation and authentication system for Vilara AI that aligns with our core value proposition: **"Vilara AI transforms manual operations into automated intelligence, integrating with existing processes immediately, reducing the time/costs for tasks by 95% and allowing for continuous modifications and improvements quickly and easily without the need for any developer interventions."**

## Core Philosophy & Value Proposition

**Vilara AI: Automated Intelligence for Business Operations**
- **Transform Manual → Automated**: Convert existing manual processes into intelligent workflows
- **Immediate Integration**: Works with current business processes without disruption
- **95% Time/Cost Reduction**: Dramatic efficiency gains through AI-powered automation
- **Continuous Improvement**: Easy modifications and enhancements without developer dependency
- **$0 Seat Licenses**: Pricing based on transaction volume, not user count

## What's Already Built

### Complete Marketing Website & Backend Infrastructure
- **Website**: Full responsive marketing site with pricing, demo, and contact pages
- **Domain**: vilara.ai fully configured and operational  
- **PostgreSQL Database**: Production database on Google Cloud SQL with signup and rate limiting tables
- **Signup API**: `/api/universal-signup.php` - Captures leads with secure token generation
- **Activation API**: `/api/activate.php` - Validates activation tokens and marks accounts as ready
- **Cloud Run Service**: https://website-1040930643556.us-central1.run.app (fully deployed and functional)
- **Security Features**: Rate limiting (5/hour per IP), CORS protection, SHA256 token hashing
- **GCP Integration**: Artifact Registry, Cloud Build, Secret Manager, Cloud Logging

### Current Architecture (Production Ready)
**Domain Flow**: 
- **vilara.ai** → Vercel (static website) + API proxy → Cloud Run (PHP backend) → Cloud SQL (PostgreSQL)

**Key Components**:
- **Vercel**: Hosts static marketing site with global CDN performance
- **API Proxy**: Vercel rewrites route `/api/*` calls to Cloud Run backend  
- **Cloud Run**: Executes PHP backend with full PostgreSQL connectivity
- **Cloud SQL**: Secure PostgreSQL database with proper schema and authentication
- **Unified Domain**: All functionality accessible through single vilara.ai domain

**API Endpoints** (Live & Functional):
- `POST vilara.ai/api/universal-signup.php` - User signup with email activation
- `POST vilara.ai/api/activate.php` - Token-based account activation
- Both endpoints include rate limiting, validation, and email integration

### Vilara AI Application System Status
**Location**: `/mnt/c/Users/grayt/Desktop/Vilara/UI/`

**✅ Core Application Features (Built):**
- **Natural Language Interface**: Complete web application (`vilara-app.html`) with NLP processor
- **Vilara-Core Integration**: Direct terminal session communication with Vilara-Core (AI Operating System backend)
- **Interactive Command Flows**: Multi-step conversations for complex operations
- **Entity Tracking**: Context-aware operations across business entities
- **15 Business Modules**: Business partners, invoices, projects, contacts, etc.
- **Dual Command Access**: Natural language OR direct Vilara-Core commands (`!bp list`)
- **Comprehensive Testing**: 13 automated tests covering all functionality

**🚨 Integration Gaps (Critical):**
- **Local-Only Operation**: Currently runs on local machine, not cloud-accessible
- **No Authentication Bridge**: No connection to vilara.ai signup/activation system
- **Vilara-Core Dependency**: Requires local Vilara-Core instance at `/opt/stk-local-default-*`
- **File Communication**: Uses local file system (`/tmp/chuck_stack_*`) for ERP communication
- **Single-User Design**: No multi-tenant or workspace isolation capabilities

**⚡ Integration Requirements:**
1. **Cloud Deployment**: Host UI application at `app.vilara.ai`
2. **Authentication Bridge**: Connect vilara.ai activation → app.vilara.ai access
3. **Multi-Tenant Architecture**: Workspace isolation for multiple customers
4. **Vilara-Core Cloud Strategy**: Solve AI Operating System access for cloud-hosted UI
5. **Transaction Metering**: Usage tracking for billing integration

### Database Schema
- **signups table**: Stores user information, company details, migration preferences, and secure tokens
- **rate_limits table**: Prevents abuse with IP-based request limiting
- **Full audit trail**: Created/expires/used timestamps for all signups

### Infrastructure Status
- ✅ **Authentication**: Google Cloud authentication configured
- ✅ **Deployment**: Automated Docker build and Cloud Run deployment
- ✅ **Database Connection**: Secure connection via Unix sockets to Cloud SQL
- ✅ **Monitoring**: Cloud Logging integrated with error tracking
- ✅ **Secrets Management**: Password and API keys stored in Google Secret Manager

### Ready for Next Phase
The complete technical foundation is in place to build the Vilara AI Operating System onboarding flow.

## Unified Onboarding Architecture

### Two Entry Points, One Destination

```
Entry Point 1: Self-Service Path
├── Free Plan (< 1,000 transactions/mo)
├── Professional Plan (1,000+ transactions/mo - employee count is general guide)  
└── Business Plan (2,000+ transactions/mo - employee count is general guide)

Entry Point 2: Enterprise Path
├── Enterprise Plan (250+ employees, custom needs)
├── Optional white-glove support
└── Still allows immediate self-service start

Both paths lead to: Full Vilara AI Operating System with progressive customization
```

### Key Architectural Principles

1. **Immediate Access**: Users start working in Vilara AI immediately (as soon as setup is completed)
2. **Progressive Customization**: Defaults first, customize while using
3. **Industry Intelligence**: Smart templates based on business type
4. **No Artificial Limits**: Same features available to all plans
5. **Workspace Isolation**: Each company gets dedicated environment

## Integration Architecture Analysis

### Current System Integration Gap

**Marketing Website (COMPLETE)** → **Authentication Bridge (MISSING)** → **AI Application (NEEDS FURTHER DEPLOYMENT)**

```
vilara.ai                     app.vilara.ai
    ↓                             ↓
✅ Signup & Activation    →   🚨 UI Application System
   (Cloud Ready)               (Local Development Only)
    ↓                             ↓
PostgreSQL Database       →   Vilara-Core AI Operating System
 (Production)                  (Local File Communication)
```

### Phase 1: Critical Integration Implementation

#### 1. UI Application Cloud Deployment
**Challenge**: Current UI runs locally with Vilara-Core file communication
**Solution Options**:

**Option A: Containerized Vilara-Core per Workspace**
```
app.vilara.ai → Cloud Run → Containerized Vilara-Core + UI per customer
```
- **Pros**: Full isolation, familiar architecture
- **Cons**: Resource intensive, complex deployment

**Option B: API Bridge Architecture**
```
app.vilara.ai → Cloud Run UI → API Bridge → Vilara-Core Service Layer
```
- **Pros**: Efficient resource usage, centralized Vilara-Core
- **Cons**: Need to build service layer, multi-tenancy complexity

**Option C: Hybrid Cloud-Local**
```
app.vilara.ai → Authentication → Local Vilara-Core Connector
```
- **Pros**: Leverage existing local setup
- **Cons**: Not fully cloud-native, deployment complexity

#### 2. Authentication Bridge Implementation
**Current Flow**: `vilara.ai/api/universal-signup.php` → Database storage
**Needed Flow**: Database activation → `app.vilara.ai` workspace provisioning

```javascript
// Enhanced activation response
POST /api/activate.php
{
  "token": "64-char-hex-token"
}

Response:
{
  "success": true,
  "workspace_id": "acme-corp-x7k9",
  "app_url": "https://app.vilara.ai/workspace/acme-corp-x7k9",
  "session_token": "jwt-or-session-identifier",
  "onboarding_required": true
}
```

#### 3. Multi-Tenant Workspace Architecture
**Current**: Single Vilara-Core instance, no isolation
**Needed**: Workspace isolation with transaction tracking

```sql
-- Enhanced database schema for workspaces
CREATE TABLE workspaces (
    id SERIAL PRIMARY KEY,
    workspace_id VARCHAR(255) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    plan_type VARCHAR(50) NOT NULL,
    chuck_stack_instance VARCHAR(255), -- Instance identifier or connection
    transaction_count INT DEFAULT 0,
    created_from_signup_id INT REFERENCES signups(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transaction tracking for billing
CREATE TABLE workspace_transactions (
    id SERIAL PRIMARY KEY,
    workspace_id VARCHAR(255) REFERENCES workspaces(workspace_id),
    user_command TEXT NOT NULL,
    chuck_stack_command TEXT,
    processing_time DECIMAL(10,3),
    transaction_type VARCHAR(50), -- 'nl_query', 'direct_command', 'multi_step'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Workspace Database Structure
```sql
-- Each signup creates isolated workspace
workspaces:
- workspace_id: 'acme-corp-x7k9' (primary key)
- company_name: 'ACME Corp'
- plan_type: 'professional'
- industry: 'retail'
- customization_progress: 0-100%
- active_users: []
- created_at, updated_at

-- Customizable business logic per workspace
work_instructions:
- workspace_id: FK to workspaces
- instruction_type: 'default|customized'
- business_area: 'sales|inventory|finance|operations'
- rules: JSONB -- Natural language business rules
- active: boolean
- created_at, updated_at

-- Industry-specific templates
industry_templates:
- industry: 'retail|manufacturing|services|healthcare'
- template_name: 'POS System|Inventory Management|Customer Service'
- default_rules: JSONB
- description: text
```

### Phase 2: Progressive Onboarding Experience

#### Stage 1: Immediate Value (60 seconds)
```
User Action: "Start Using Vilara"
System Response:
1. Create Google OAuth account (30 seconds)
2. Workspace provisioned with industry defaults (30 seconds)  
3. User lands in working Vilara AI Operating System

Key Insight: They can USE VILARA AI immediately - create orders, manage inventory, process transactions
```

#### Stage 2: Business Configuration (Vilara self-service customization process)
```
Business Configuration Wizard:
- Industry-specific templates and defaults
- Department-by-department setup
- Work instruction customization (.md files)
- Natural language command training
- Business rules configuration

See BUSINESS_CONFIGURATION_WIZARD.md for detailed implementation

Integration setup:
- Accounting software connections
- E-commerce platform sync
- Payment processor integration
- Custom reporting requirements

```

#### Stage 3: Smart Customization (While Using)
```
System observes usage patterns and prompts for additional customization:
- "We notice you do a lot of inventory transfers"
- "Want to customize that workflow?"
- "Your team seems focused on customer management"

User customizes based on real experience, not theoretical needs

```
### Phase 3: Multi-Tenancy & Isolation

#### Workspace Isolation Strategy
```
Option A: Shared Database (Recommended Start)
- All customers in same PostgreSQL instance
- workspace_id field segregates all data
- Cost-effective, easier maintenance
- Can migrate to dedicated DBs for Enterprise later

Option B: Database Per Customer  
- Each workspace gets dedicated DB
- Better isolation, meets enterprise requirements
- Higher maintenance overhead
- Use for Enterprise+ when needed
```

#### Data Access Pattern
```sql
-- Every query includes workspace isolation
SELECT * FROM orders 
WHERE workspace_id = 'acme-corp-x7k9' 
AND order_date > '2025-01-01';

-- Enforced at application level
class VillarQuery {
  private $workspace_id;
  
  public function find($table, $conditions) {
    $conditions['workspace_id'] = $this->workspace_id;
    return parent::find($table, $conditions);
  }
}
```

## Competitive Advantages

### vs NetSuite/SAP Implementation
| Traditional Systems | Vilara AI |
|---------------------|-----------|
| 6-18 month implementation | Working in 60 seconds |
| $50k+ consultant fees | $0 setup cost |
| Complex customization process | Customize while using |
| User training nightmare | Natural language interface |
| Per-seat licensing | $0 seat licenses |

### vs Smaller Business Systems
| Typical SaaS | Vilara AI |
|--------------|-----------|
| Limited trial → Full version | Full version immediately |
| Feature restrictions by plan | Same features, usage-based pricing |
| Generic workflows | Industry-intelligent defaults |
| Static setup | Progressive customization |

## Business Model Alignment

### Revenue Sources
- **Free Plan**: Lead generation, upsell when transaction volume grows
- **Professional/Business**: Monthly/annual fees based on transaction volume
- **Enterprise**: Premium support, advanced integrations, dedicated resources
- **Add-ons**: Specialized modules, integrations, advanced analytics

### Transaction-Based Pricing Model
**Key Insight**: Plans are primarily determined by transaction volume, with employee count as a general guide only.

- **Natural Scaling**: Pricing grows with customer business activity and success
- **Growth Friendly**: No artificial limits on team size ($0 seat licenses maintained)
- **Value Aligned**: More transactions = more value delivered = higher willingness to pay
- **Predictable**: Customers can forecast costs based on business growth expectations

### Cost Structure Benefits
- **Shared Infrastructure**: Multi-tenancy reduces per-customer costs
- **Self-Service Onboarding**: Minimal support overhead
- **Progressive Complexity**: Users only pay for what they need when ready

## Implementation Priorities

### Phase 1 Implementation Roadmap

#### Architecture Foundation
**Priority 1**: Resolve Vilara-Core cloud deployment strategy
- **Decision Required**: Choose Option A, B, or C for Vilara-Core architecture  
- **Deliverable**: Proof of concept for chosen approach
- **Success Criteria**: Multi-tenant Vilara-Core access working in cloud

**Priority 2**: Define transaction billing model
- **Decision Required**: What constitutes a billable transaction
- **Deliverable**: Transaction tracking implementation
- **Success Criteria**: Accurate usage metering with billing integration

#### Integration Bridge Development  
**Priority 3**: Build authentication bridge
- **Enhancement**: Extend `/api/activate.php` to provision workspaces
- **New API**: `/api/provision-workspace.php` for post-activation setup
- **Integration**: Connect activation flow → app.vilara.ai access

**Priority 4**: Deploy UI application system
- **Target**: Host Vilara AI application at `app.vilara.ai`
- **Requirements**: Cloud-accessible version of current local UI
- **Integration**: Connect to authentication bridge and workspace system

#### Testing & Polish
**Priority 5**: End-to-end integration testing
- **Flow**: vilara.ai signup → activation → app.vilara.ai workspace access
- **Validation**: Transaction tracking, multi-tenancy, security isolation
- **Performance**: Sub-30-second workspace provisioning

### Longer Term 
1. **Advanced Integrations**: Accounting, e-commerce, payment systems
2. **Enterprise SSO**: SAML, Azure AD, Okta for large customers
3. **Dedicated Instances**: Database-per-customer for enterprise
4. **Advanced Analytics**: Business intelligence and reporting tools

## Critical Decisions Needed for Phase 1

### 1. Fundamental Deployment Architecture (HIGHEST PRIORITY)
**Decision**: Local vs Cloud deployment - This choice determines the entire technical approach and business model.

**Options Analysis**:

**Option A: Cloud Deployment** (Original Assumption)
```
vilara.ai signup → app.vilara.ai workspace (cloud-hosted UI + Vilara-Core)
```
*Pros*: 
- Immediate browser access, no installation required
- Centralized updates, easy feature deployment
- Built-in usage analytics and transaction tracking
- Simplified support with centralized logging
- Modern SaaS business model

*Cons*:
- Complex multi-tenancy architecture required
- Customer data hosted on Vilara infrastructure
- Network dependency, requires internet connection
- Higher infrastructure costs scaling with customers
- Limited integration with customer's local systems

**Option B: Local Deployment** (Reconsidered Approach)  
```
vilara.ai signup → download → local installation (UI + Vilara-Core together)
```
*Pros*:
- **Immediate integration with existing customer systems**
- Complete data sovereignty - customer data stays local
- Zero network dependency, works offline
- **Existing architecture already functional** 
- Lower infrastructure costs, privacy compliance built-in
- **Aligns with "integrating with existing processes immediately"**

*Cons*:
- Distribution and update management complexity
- Support across different customer environments
- Usage tracking for billing requires different approach
- Installation experience must be foolproof
- Version management across customer base

**Option C: Hybrid Deployment**
```
Local Vilara-Core + Cloud Services (updates, licensing, analytics)
```
*Pros*: Best of both approaches
*Cons*: Increased complexity, multiple systems to maintain

### 2. Transaction Definition & Billing Model
**Decision**: What constitutes a billable "transaction" in Vilara AI?

**Considerations**:
- **Natural Language Query**: User types "show me all customers" = 1 transaction?
- **Vilara-Core Command**: Each AI Operating System command execution = 1 transaction?
- **Multi-Step Workflow**: "Create invoice for ACME Corp" (involves customer lookup + invoice creation) = 1 or 2 transactions?
- **Context Operations**: Follow-up questions in same conversation = separate transactions?

**Business Impact**: Core to pricing model and competitive positioning

### 3. Authentication & Session Architecture
**Decision**: How do users transition from vilara.ai → app.vilara.ai?

**Technical Requirements**:
- Cross-domain session management (vilara.ai ↔ app.vilara.ai)
- Workspace isolation and security
- Session duration and renewal policies
- Integration with existing activation token system

### 4. UI Application Hosting Strategy
**Decision**: Where and how to deploy the Vilara AI application?

**Current State**: Local-only with file communication to Vilara-Core
**Options**:
- Same Cloud Run service with routing (`/app/*`)
- Separate Cloud Run service (`app.vilara.ai`)
- Different GCP project for isolation
- Hybrid cloud-local architecture

### 5. Multi-Tenancy & Data Isolation
**Decision**: How to ensure customer data isolation?

**Database Strategy**:
- Shared PostgreSQL with workspace_id filtering
- Database-per-workspace (expensive but secure)
- Hybrid approach based on plan type

**Vilara-Core Isolation**:
- How to ensure customer A cannot see customer B's data
- Instance-level vs application-level isolation

### Business Process  
1. **Onboarding Depth**: How much customization is required vs optional?
2. **Industry Focus**: Starting with consulting / professional servcies. Which industries to template next?
3. **Support Model**: How much hand-holding for Enterprise vs self-service?

### User Experience
1. **Customization Complexity**: Simple key-value rules or full workflow builder?
2. **Default Experience**: How functional should uncustomized system be?
3. **Migration Path**: How do users import existing data/processes?

## Success Metrics

### User Experience
- **Time to First Value**: < X minutes from signup to first useful action
- **Onboarding Completion**: > 80% complete basic customization
- **User Activation**: > 70% return within 7 days

### Business Impact
- **Conversion Rate**: Signup to paid plan conversion within X days
- **New Customer Growth**: X% growth per month / Y% growth per quarter
- **Customer Lifetime Value**: Expected customer life x Average customer monthly subscription
- **Onboarding Efficiency**: Total average time invested in customer onboarding per month / New customers (free and paid) per month
- **Support Efficiency**: Self-service vs. support ticket ratio

## Risk Mitigation

### Technical Risks
- **Database Performance**: Monitor query performance with workspace isolation
- **Security Isolation**: Ensure no cross-workspace data leakage
- **Scalability**: Plan for rapid user growth with shared infrastructure

### Business Risks
- **Support Overhead**: Enterprise customers expecting high-touch service
- **Customization Complexity**: Users overwhelmed by options
- **Feature Creep**: Maintaining simplicity while adding capabilities

## Conclusion

This unified architecture delivers on Vilara AI's core value proposition: **"Transform manual operations into automated intelligence, integrating with existing processes immediately, reducing time/costs by 95% with continuous improvements without developer interventions."**

### Current Status Summary

**✅ Foundation Complete:**
- Marketing website with production backend (vilara.ai)  
- User signup, activation, and database systems operational
- Comprehensive UI application with Vilara-Core integration (local)
- Natural language processing with 15 business modules supported

**🚨 Critical Integration Gap:**
- UI application is local-only, needs cloud deployment
- No authentication bridge between website activation and UI access
- Vilara-Core multi-tenancy architecture undefined
- Transaction billing model needs definition

### Next Phase Focus

**The primary blocker** is the fundamental deployment architecture decision: Local vs Cloud. This choice determines:
- All subsequent technical architecture decisions
- Business model and pricing strategy approach
- Customer onboarding and integration experience  
- Support and maintenance methodology
- Competitive market positioning

Once this foundational decision is made, all other development can proceed with clear direction.

**Success will be measured by**: Complete user journey from vilara.ai signup → activation → app.vilara.ai workspace → productive AI Operating System usage within 30 seconds.

This architecture positions Vilara AI to deliver unprecedented speed and ease of adoption, transforming how businesses interact with their operational systems through AI-powered automation and intelligent process integration - whether augmenting existing ERPs or functioning as a complete ERP+ solution.

---
*This document serves as the architectural blueprint for Vilara's unified onboarding system and should be updated as implementation progresses.*