# Session Start Prompt - Current State: Container Implementation

Vilara's complete marketing website and backend infrastructure is **LIVE IN PRODUCTION** at vilara.ai. The architecture is clearly defined with single-container Incus deployment. Ready for implementation of container provisioning and customer handoff.

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
  - Service URL (dev): `https://website-2donpjh2tq-uc.a.run.app`.
  - Invocation: public (the website service has roles/run.invoker for allUsers).
  - **Status**: ✅ FULLY FUNCTIONAL - Signup and activation APIs working with mobile-optimized UX and GitHub Actions automation

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
- **Rate Limiting**: App-level rate limiting (20 requests/IP/hour). Note: Cloud Armor requires an HTTPS Load Balancer + serverless NEG if we use it later.
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

## 🚀 CURRENT PHASE: Container Provisioning Implementation

**Status**: Architecture fully defined. Ready for implementation of customer container provisioning.

### **✅ Architecture Decisions Made:**

#### ✅ Customer Implementation Strategy: **Single Container per Customer**
- **Approach**: Incus containers with UI + Vilara-Core + PostgreSQL combined
- **Isolation**: Complete customer separation at container level
- **Communication**: Direct Python ↔ Nushell (no API calls)
- **Access**: Port-based URLs (vilara-host.com:8001, 8002, etc.)

#### ✅ Customer Environment Structure: **Demo/Test/Live**
- **Demo Environment**: Sample data for exploration
- **Test Environment(s)**: Full ERP, disposable, spin up/destroy at will
- **Live Environment**: Pristine production data, never contaminated with tests
- **Management**: Test environments are disposable, Live is protected

#### ✅ Container Contents: **Everything Included**
- **UI Layer**: Python API server with web interface (port 5006)
- **Vilara-Core**: Nushell modules with business logic
- **PostgreSQL**: Customer database with Demo/Test/Live separation
- **Customer Integration Agent**: Setup and onboarding within Vilara-Core

#### ✅ Handoff Process: **Container Provisioning**
- **Trigger**: Customer clicks "Launch Vilara" after email activation
- **Process**: Website calls container provisioning API
- **Result**: Customer gets unique URL to their complete Vilara world
- **Timeline**: Target < 30 seconds from click to working environment

### **📋 Implementation Scope (Ready to Code):**
1. **Container Provisioning API** (`/api/provision-container.php`)
2. **Website Handoff Update** (modify `activateWebUI()` in `activate.html`)
3. **Combined Container Setup** (Dockerfile with UI + Vilara-Core)
4. **Incus Infrastructure** (container template and port management)
5. **Direct Integration** (Python ↔ Nushell communication)

### **⚡ Immediate Implementation Steps:**
1. **Create provisioning API** - Handle container creation when customer clicks "Launch Vilara"
2. **Update website handoff** - Modify activation flow to trigger provisioning
3. **Build container template** - Combine UI + Vilara-Core in single container
4. **Set up Incus infrastructure** - Container hosting and port management

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



## 💡 **Success Metrics for Container Implementation:**
- **Container Provisioning**: < 30 seconds from "Launch Vilara" to working customer environment
- **User Experience**: Seamless transition from vilara.ai → customer's Vilara world
- **Customer Isolation**: Complete separation between customer containers
- **Environment Management**: Easy switching between Demo/Test/Live environments
- **System Performance**: Support 100+ customer containers with sub-second response

## 🔗 **Current Integration Context:**
The marketing website (vilara.ai) handles lead generation and account creation. Container implementation creates customer's complete Vilara world where they interact with business operations through natural language - whether augmenting existing ERPs or using Vilara as a complete ERP+ solution.

**Key Integration Point**: Users flow from vilara.ai signup → account activation → their own containerized Vilara implementation with Demo/Test/Live environments.

## 📋 **Available Resources:**
- **Vilara-Core**: Fully functional in `/mnt/c/Users/grayt/Desktop/Vilara/vilara-core/`
- **UI Components**: Complete web interface in `/mnt/c/Users/grayt/Desktop/Vilara/UI/`
- **Architecture Docs**: Detailed blueprints in `/website/docs/project-blueprints/`
- **Implementation Guide**: `/website/docs/project-blueprints/IMPLEMENTATION_NEXT_STEPS.md`

---

**Current Status**: Ready to implement container provisioning. All architecture decisions made. No blockers from Vilara-Core - can proceed with existing code.

Please help implement the container provisioning system using Incus containers with the single-container approach (UI + Vilara-Core + PostgreSQL per customer).