# Vilara AI Unified Onboarding Architecture
*Document Date: September 5, 2025*

## Executive Summary

This document outlines a unified authentication and onboarding system for Vilara AI Operating System that aligns with our core value propositions of "$0 seat licenses" and "95% faster" implementation.

## Core Philosophy

**One System, Multiple Entry Points**
- All users access the same powerful Vilara AI Operating System
- No feature limitations based on plan type
- Pricing based on usage/features, not user count
- Immediate value delivery during customization process

## What's Already Built

### Complete Marketing Website & Backend
- **Website**: Full responsive marketing site with pricing, demo, and contact pages
- **PostgreSQL Database**: Production database on Google Cloud SQL with signup and rate limiting tables
- **Signup API**: `/api/universal-signup.php` - Captures leads with secure token generation
- **Activation API**: `/api/activate.php` - Validates activation tokens and marks accounts as ready
- **Cloud Run Service**: https://website-1040930643556.us-central1.run.app (fully deployed and functional)
- **Security Features**: Rate limiting (5/hour per IP), CORS protection, SHA256 token hashing
- **GCP Integration**: Artifact Registry, Cloud Build, Secret Manager, Cloud Logging

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

## Technical Implementation Plan

### Phase 1: Authentication & Workspace Provisioning

#### Single Signup Flow
```javascript
POST /api/signup.php
{
  "email": "user@company.com",
  "company": "ACME Corp", 
  "plan": "professional", // free|professional|business|enterprise
  "auth_method": "google", // google|password|sso
  "industry": "retail" // optional, for smart defaults
}

Response:
{
  "success": true,
  "workspace_id": "acme-corp-x7k9",
  "app_url": "https://app.vilara.ai/workspace/acme-corp-x7k9",
  "onboarding_url": "https://app.vilara.ai/onboard",
  "status": "ready_to_customize"
}
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

#### Stage 2: Advanced Configuration (Vilara self-service customization process)
```
Workinstruction building:
- QA process that builds / customizes workflows for each customer

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

### Immediate Next Steps ("Website" side - Tim)
1. **Authentication Integration**: Add Google OAuth to current signup flow
2. **Workspace Provisioning**: Build workspace creation system with transaction tracking
3. **Basic Multi-Tenancy**: Implement workspace isolation
4. **Vilara App Foundation**: Create app.vilara.ai subdomain structure
5. **Usage Analytics System**: Build transaction volume monitoring and plan upgrade suggestions

### Immediate Next Steps (vilara-core side - Chuck)
1. **Industry Templates**: Build default work instruction sets
2. **Progressive Onboarding UI**: Create guided customization flow
3. **Usage Analytics**: Track patterns for smart suggestions
4. **Customization Engine**: Build rule modification interface

### Longer Term 
1. **Advanced Integrations**: Accounting, e-commerce, payment systems
2. **Enterprise SSO**: SAML, Azure AD, Okta for large customers
3. **Dedicated Instances**: Database-per-customer for enterprise
4. **Advanced Analytics**: Business intelligence and reporting tools

## Key Decisions Needed

### Technical Architecture
1. **App Hosting**: Same Cloud Run or separate project for app.vilara.ai?
2. **Database Strategy**: Start with shared DB or plan for dedicated from day 1?
3. **Session Management**: JWT tokens, server sessions, or stateless auth?
4. **Transaction Tracking**: How to define and count transactions across different business processes?
5. **Usage Analytics**: Real-time vs batch processing for transaction volume monitoring?

### Workspace Provisioning System Requirements
The system must support transaction-based pricing model:
- **Track transaction volume** per workspace across all business processes
- **Monitor usage patterns** to suggest plan upgrades at appropriate thresholds
- **Handle plan transitions** seamlessly without service disruption
- **Provide usage analytics** so customers understand their consumption and forecast costs
- **Automated billing** based on actual transaction volume vs plan limits

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

This unified architecture eliminates artificial barriers between trial and production usage, aligning perfectly with Vilara's "adapt to existing processes and delivers value immediately and '95% faster' than current processes' value propositions. By giving all users immediate access to full functionality while providing progressive customization, we create a competitive advantage that traditional operations / ERPs cannot match.

The technical foundation is already in place with our working backend APIs and database. 

The next step is building the authentication and workspace provisioning system and guided onboarding flows.

---
*This document serves as the architectural blueprint for Vilara's unified onboarding system and should be updated as implementation progresses.*