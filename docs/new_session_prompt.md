# Session Start Prompt - Phase 1: Workspace Provisioning

Vilara's complete marketing website and backend infrastructure is **LIVE IN PRODUCTION** at vilara.ai. The next phase is implementing workspace provisioning and the actual Vilara AI application system.

**✅ PRODUCTION INFRASTRUCTURE COMPLETE:**
1. ✅ **vilara.ai domain** - Fully operational with Vercel + Cloud Run architecture
2. ✅ **Complete signup flow** - `/api/universal-signup.php` with database storage and email activation
3. ✅ **PostgreSQL database** - Production Cloud SQL with signups and rate limiting tables
4. ✅ **Email activation system** - SendGrid integration with HTML email templates
5. ✅ **Rate limiting & security** - IP-based limiting, CORS, SHA256 token hashing
6. ✅ **End-to-end testing** - Full signup → activation → database confirmation working
7. ✅ **Cloud Run deployment** - Automated Docker builds with PHP 8.2 + Apache + PostgreSQL

**✅ CURRENT PRODUCTION ARCHITECTURE:**
```
vilara.ai → Vercel (static site) → API proxy → Cloud Run (PHP backend) → Cloud SQL (PostgreSQL)
```

**✅ WORKING ENDPOINTS:**
- `POST vilara.ai/api/universal-signup.php` - User registration with email activation
- `POST vilara.ai/api/activate.php` - Token-based account activation
- Both include comprehensive error handling, logging, and security measures

## GCP Environment (current state)
- **Org / Identity**
  - Cloud Identity set up for **vilara.ai**.
  - Primary user/admin: **tim@vilara.ai**.
  - GCP enabled for domain; using Organization **vilara.ai**.

- **Projects**
  - Active dev project: **vilara-dev** (ID: `vilara-dev`).  
  - Recommended later: `vilara-staging`, `vilara-prod`.

- **Region**
  - Default region: **us-central1**.

- **Billing**
  - Billing account linked to `vilara-dev`.

- **Enabled APIs**
  - Cloud Run, Artifact Registry, Cloud Build, Secret Manager, IAM, Cloud SQL Admin, Cloud Logging/Monitoring, Cloud Storage, Pub/Sub (visible), etc.

- **IAM (key bindings)**
  - Users **tim@vilara.ai** (Owner) and **chuck@vilara.ai** (Owner).
  - Cloud Build default SA: `<PROJECT_NUMBER>@cloudbuild.gserviceaccount.com` with:
    - `roles/run.admin`, `roles/iam.serviceAccountUser`,
    - `roles/artifactregistry.writer`, `roles/secretmanager.secretAccessor`,
    - (Google service agents present as expected).
  - Runtime SA (Compute default): `<PROJECT_NUMBER>-compute@developer.gserviceaccount.com` with:
    - `roles/secretmanager.secretAccessor`,
    - `roles/cloudsql.client`,
    - `roles/artifactregistry.reader`.

- **Org Policy / Public Access**
  - Project vilara-dev has Domain Restricted Sharing reset (no project-level restriction).
  - Cloud Run services can be public by adding the allUsers invoker binding per service (the api service is public now).

## Runtime & Services (dev)
- **Cloud Run**
  - Service **`website`** deployed (production image with PHP/Apache backend).
  - Region: `us-central1`.
  - Cloud SQL instance attached via `--add-cloudsql-instances`.
  - Env vars set for DB host/name/user/port; secret mapped for DB password.
  - Service URL (dev): `https://website-1040930643556.us-central1.run.app`.
  - Invocation: public (the website service has roles/run.invoker for allUsers).
  - **Status**: ✅ FULLY FUNCTIONAL - Signup and activation APIs working

- **Cloud SQL (PostgreSQL)**
  - Instance: **`vilara-dev-sql`** (Postgres 15), zone `us-central1-c`, tier `db-custom-1-3840`.
  - Connection name: `vilara-dev:us-central1:vilara-dev-sql`.
  - Database **`appdb`** ✅ CREATED with full schema (signups, rate_limits tables).
  - User **`appuser`** ✅ CREATED with working password.
  - Secret Manager: `db-appuser-password` (version 4 only) holds DB password.
  - **IMPORTANT**: Use `printf` not `echo` when creating secrets to avoid newline corruption

- **Artifact Registry**
  - Repository: **`vilara-docker`** in `us-central1` ✅ CREATED.
  - Current image: `us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest`.
  - **Status**: Successfully building and deploying PHP/Apache container with full backend

## Tech Choices / Conventions
- **Backend**: PHP 8.2 + Apache on Cloud Run (PDO_PGSQL), or similar.  
- **DB access**: Unix socket `/cloudsql/<connectionName>` (no public IP).  
- **Email**: SendGrid (secret `SENDGRID_API_KEY` in Secret Manager).  
- **Tokens**: 64-hex (random bytes), **hash stored** in DB, 24h expiry, mark `used_at` on activation.  
- **Rate Limiting**: App-level rate limiting (5 requests/IP/hour). Note: Cloud Armor requires an HTTPS Load Balancer + serverless NEG if we use it later.
- **CORS**: Allow origins: `https://vilara.ai`, `https://www.vilara.ai`, localhost (dev).
- **Monitoring**: Cloud Logging for all requests, Cloud Error Reporting for exceptions.
- **Backup Strategy**: Configure Cloud SQL automated daily backups (7-day retention) and enable point-in-time recovery (to do).
- **Endpoints**
  - `POST /api/universal-signup.php?migration=fresh|enhance|full` → issue token, store, email link.
  - `GET /api/activate.php?token=...` → validate (not expired/used), mark used.
  - Frontend activation URL: `/activate.html?token=...`.
- **Windows dev conventions**
  - Use **Command Prompt (cmd.exe)** one-liners (no multi-line commands).
  - Env vars often set as: `set PROJECT_ID=vilara-dev` (session) or `setx` (persist).
  - Always verify with `gcloud config set account tim@vilara.ai` and `gcloud config set project vilara-dev`.

## 🚀 PHASE 1 GOALS: Workspace Provisioning & App Integration

**Objective**: Build the actual Vilara AI application system that activated users access after completing signup.

### **🎯 Critical Architecture Decisions Needed:**

#### 1. **Workspace Provisioning Strategy**
- **Question**: How should we create and manage individual customer workspaces?
- **Options**: 
  - Shared database with workspace_id isolation
  - Database-per-customer for enterprise security
  - Hybrid approach based on plan type
- **Impact**: Affects scalability, security, and operational complexity

#### 2. **Transaction Definition & Metering**
- **Question**: What constitutes a "transaction" for billing purposes?
- **Considerations**:
  - Natural language command processing = 1 transaction?
  - Database operations vs business logic operations?
  - Multi-step workflows = multiple transactions?
- **Impact**: Core to pricing model and usage analytics

#### 3. **App Hosting Architecture** 
- **Question**: Where and how should `app.vilara.ai` be deployed?
- **Options**:
  - Same Cloud Run service with different routing
  - Separate Cloud Run service for app vs marketing
  - Different GCP project for app vs marketing
- **Impact**: Performance, security isolation, deployment complexity

#### 4. **Session & Authentication Management**
- **Question**: How do users transition from vilara.ai to app.vilara.ai?
- **Considerations**:
  - JWT tokens vs server-side sessions
  - Session duration and renewal
  - Cross-domain authentication (vilara.ai ↔ app.vilara.ai)
- **Impact**: User experience and security model

### **📋 Phase 1 Implementation Scope:**
1. **Workspace Creation API** - Provision new customer environments post-activation
2. **User Authentication System** - Seamless login across marketing and app domains  
3. **Transaction Tracking** - Define and implement usage metering
4. **Basic App Framework** - Core structure for app.vilara.ai
5. **Vilara-Core Integration** - Connect to core Vilara AI Operating System backend

### **⚡ Immediate Next Steps:**
1. **Define transaction model** - What gets counted and how?
2. **Design workspace architecture** - Shared vs isolated database approach
3. **Plan app.vilara.ai hosting** - Same Cloud Run or separate service?
4. **Architect user session flow** - Marketing site → App transition

## Useful IDs / Defaults
- GCP Organization: `vilara.ai`
- Organization ID: `269052776008`
- GCP Directory_Customer_ID: `C03luti42`
- Cloud Identity super admins: `info@vilara.ai`, `tim@vilara.ai`
- Project: `vilara-dev` (region `us-central1`)
- Cloud SQL: `vilara-dev-sql` → `vilara-dev:us-central1:vilara-dev-sql`
- Planned AR repo: `vilara-docker`
- Cloud Run (test): service `api` (hello image) is live & authenticated


## Quick Shell Rehydration (Windows cmd.exe)
# Run these in a fresh Command Prompt to restore context/vars fast.

gcloud config set account tim@vilara.ai
gcloud config set project vilara-dev
set "REGION=us-central1"
set "DB_USER=appuser"
for /f "tokens=*" %i in ('gcloud sql instances describe vilara-dev-sql --format="value(connectionName)"') do set CONN=%i
for /f "tokens=*" %i in ('gcloud run services describe api --region=%REGION% --format="value(status.url)"') do set API_URL=%i

# Public call (service has roles/run.invoker for allUsers)
curl %API_URL%

# Private call (no allUsers binding)
for /f "tokens=*" %i in ('gcloud auth print-identity-token') do set TOKEN=%i
curl -H "Authorization: Bearer %TOKEN%" %API_URL%

# Optional quick check:
echo %REGION% & echo %DB_USER% & echo %CONN% & echo %API_URL%

## Public Access & Org Policy (Cloud Run)

- By default, org policy can block public (`allUsers`) access. For `vilara-dev` we already reset the project policy; services can be made public.

### Make a Cloud Run service public (project: vilara-dev)
gcloud services enable orgpolicy.googleapis.com --project=vilara-dev
gcloud org-policies reset constraints/iam.allowedPolicyMemberDomains --project=vilara-dev
gcloud run services add-iam-policy-binding <SERVICE_NAME> --region=us-central1 --member=allUsers --role=roles/run.invoker
gcloud run services get-iam-policy <SERVICE_NAME> --region=us-central1 --format="table(bindings.role,bindings.members)"  # expect roles/run.invoker  allUsers

### If you need org-policy rights (run as Cloud Identity admin: info@vilara.ai)
gcloud organizations add-iam-policy-binding 269052776008 --member=user:tim@vilara.ai --role=roles/resourcemanager.organizationViewer
gcloud organizations add-iam-policy-binding 269052776008 --member=user:tim@vilara.ai --role=roles/orgpolicy.policyAdmin



## 💡 **Success Metrics for Phase 1:**
- **Workspace Provisioning**: < 30 seconds from activation to working app environment
- **User Experience**: Seamless transition from vilara.ai → app.vilara.ai
- **Transaction Tracking**: Accurate usage metering with plan upgrade prompts
- **System Performance**: Support 100+ concurrent workspaces with sub-second response
- **Integration Quality**: Reliable connection to Vilara-Core processing system

## 🔗 **Integration Context:**
The marketing website (vilara.ai) handles lead generation and account creation. Phase 1 builds the actual Vilara AI Operating System (app.vilara.ai) where users interact with business operations through natural language - whether augmenting existing ERPs or using Vilara as a complete ERP+ solution.

**Key Integration Point**: Users flow from vilara.ai signup → account activation → app.vilara.ai workspace with full Vilara AI capabilities.

---

Please help me architect and implement Phase 1 workspace provisioning and app integration system using Google Cloud Platform best practices. The marketing infrastructure is complete - now we need to build the actual Vilara AI Operating System that can integrate with existing business processes or function as a complete ERP+ solution.