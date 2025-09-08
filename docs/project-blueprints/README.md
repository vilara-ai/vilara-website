# Vilara AI Website & Backend

## Overview
Complete marketing website and backend system for Vilara AI Operating System. Features full PostgreSQL-backed signup flow with email activation and production-ready infrastructure.

**Live Site**: https://vilara.ai

## Architecture

### Production Setup
- **Frontend**: Vercel (static HTML/CSS/JS)
- **Backend**: Google Cloud Run (PHP + PostgreSQL)  
- **Database**: Google Cloud SQL (PostgreSQL)
- **Email**: SendGrid API
- **Domain**: vilara.ai (unified domain)

### Deployment Architecture
```
GitHub Repository (vilara-ai/vilara-website)
├── Frontend Changes → Vercel (Auto-deploy)
└── Backend Changes (api/**) → GitHub Actions → Google Cloud Run
```

### User Flow
```
vilara.ai → Vercel Static Site
    ↓
Contact Form Submission → api/universal-signup.php (Cloud Run)
    ↓  
PostgreSQL (Cloud SQL) + SendGrid Email
    ↓
User Clicks Activation Link → api/activate.php (Cloud Run)
    ↓
Account Activated → Ready for app.vilara.ai
```

## Project Structure
```
website/
├── Frontend (Vercel)
│   ├── index.html                 # Homepage with ROI calculator
│   ├── demo.html                  # Interactive 10-slide demo
│   ├── pricing.html               # Transparent pricing tables
│   ├── contact.html               # Lead qualification forms
│   ├── how-it-works.html         # Technical architecture
│   ├── migration.html            # ERP migration tools
│   ├── solutions/                # Solution-specific pages
│   └── assets/                   # CSS, JS, images
│
├── Backend (Cloud Run)
│   ├── api/
│   │   ├── universal-signup.php   # User registration API
│   │   ├── activate.php          # Email activation API
│   │   ├── schema.sql            # PostgreSQL database schema
│   │   └── includes/             # Shared backend utilities
│   ├── Dockerfile                # Container configuration
│   └── debug.php                 # Backend debugging endpoint
│
├── Configuration
│   ├── vercel.json               # Deployment + API proxy config
│   ├── .vercelignore             # Excludes backend from static deploy
│   └── .gcloudignore             # Excludes frontend from container
│
└── Documentation
    ├── docs/unified-onboarding-architecture.md
    ├── CLAUDE.md                 # Development guidelines
    └── README.md                 # This file
```

## Development

### Local Development
```bash
# Frontend development (static files)
npx vercel dev

# Backend development (requires Docker)
docker build -t vilara-website .
docker run -p 8080:8080 vilara-website
```

### Testing APIs
```bash
# Test signup API (replace with real email)
curl -X POST https://vilara.ai/api/universal-signup.php \
  -H "Content-Type: application/json" \
  -d '{"companyName":"Test Co","email":"test@example.com","firstName":"John","lastName":"Doe","companySize":"1-4","migrationContext":"none"}'

# Test activation (replace with real token from email)
curl -X POST https://vilara.ai/api/activate.php \
  -H "Content-Type: application/json" \
  -d '{"token":"your-64-char-hex-token-here"}'
```

## Deployment

### Automatic Deployment System

**Frontend (Vercel)**
- **Trigger**: Any push to `main` branch
- **Deploys**: All static files (HTML, CSS, JS, images)
- **URL**: https://vilara.ai
- **Time**: ~2-3 minutes
- **Setup**: Connected via Vercel GitHub integration

**Backend (Google Cloud Run)**
- **Trigger**: Changes to `api/**` files only
- **Deploys**: Docker container with PHP backend + APIs
- **URL**: https://website-1040930643556.us-central1.run.app
- **Time**: ~5-8 minutes
- **Setup**: GitHub Actions workflow with Workload Identity Federation

### Manual Deployment (if needed)

**Frontend:**
```bash
npx vercel --prod
```

**Backend:**
```bash
# Build and push Docker image
gcloud builds submit --tag us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest --project vilara-dev

# Deploy to Cloud Run
gcloud run deploy website --image us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest --region us-central1 --project vilara-dev
```

### Backend (Manual)
```bash
# Set GCP project
gcloud config set project vilara-dev

# Build and deploy to Cloud Run
gcloud builds submit --tag us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest .

# Deploy to Cloud Run (if needed)
gcloud run deploy website --image us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest --region us-central1 --port 8080
```

## Database Schema

### Core Tables
```sql
-- User signups with activation tokens
signups (
  id, company_name, email, first_name, last_name,
  company_size, migration_context, workspace_id,
  token_hash, expires_at, is_used, created_at
)

-- Rate limiting for API abuse prevention  
rate_limits (
  id, ip_address, request_count, window_start, created_at
)
```

## API Endpoints

### POST /api/universal-signup.php
User registration with email activation
```json
{
  "companyName": "ACME Corp",
  "email": "user@acme.com", 
  "firstName": "John",
  "lastName": "Doe",
  "companySize": "10-49",
  "migrationContext": "netsuite"
}
```

### POST /api/activate.php
Token-based account activation
```json
{
  "token": "64-character-hex-token-from-email"
}
```

## Security Features
- **Rate Limiting**: 5 requests per IP per hour
- **Token Security**: SHA256 hashed tokens with 24-hour expiry
- **CORS Protection**: Configured for production domains
- **SQL Injection Protection**: PDO prepared statements
- **Secret Management**: Google Secret Manager integration

## Configuration

### Environment Variables
Backend requires these secrets in Google Secret Manager:
- `db-appuser-password`: PostgreSQL database password  
- `sendgrid-api-key`: SendGrid API key for emails

### GitHub Actions Setup
The automatic backend deployment uses Workload Identity Federation:

**Service Account**: `github-actions@vilara-dev.iam.gserviceaccount.com`
**Permissions**: 
- `roles/cloudbuild.builds.builder`
- `roles/run.admin` 
- `roles/iam.serviceAccountUser`

**Workload Identity Pool**: `github-pool`
**Provider**: Configured for repository `vilara-ai/vilara-website`

**Required Repository Settings**:
- Actions → General → Workflow permissions: "Read and write permissions"
- Actions → General → "Allow GitHub Actions to create and approve pull requests" ✓

### Domain Configuration
- **vilara.ai**: Points to Vercel for frontend
- **API requests**: Proxied from frontend JavaScript to Cloud Run backend
- **SendGrid**: DNS records configured in GoDaddy for email authentication

## Key Features
- **Unified Onboarding**: Single signup flow for all plan types
- **Email Activation**: Secure token-based account activation  
- **Lead Qualification**: Size-based routing (free vs consultation)
- **ROI Calculator**: Dynamic cost comparison with competitors
- **Interactive Demo**: 10-slide showcase of capabilities
- **Migration Tools**: ERP transition planning and cost analysis

## Brand Guidelines
- **Colors**: CSS variables in `:root` for consistent theming
- **Typography**: System fonts for performance
- **Messaging**: "$0 seat licenses" and "95% faster" value props
- **Target Audience**: 1-250 employee companies seeking ERP solutions

## Monitoring & Debugging
- **Cloud Logging**: All API requests and errors logged
- **Debug Endpoint**: `/debug.php` for backend diagnostics  
- **Vercel Analytics**: Frontend performance monitoring
- **Database Monitoring**: Cloud SQL insights and query analysis

## Support & Maintenance
- **Form Handling**: Formspree integration for contact forms
- **Email Templates**: HTML emails with SendGrid integration  
- **Error Handling**: Comprehensive error responses and logging
- **Performance**: Optimized for Core Web Vitals and mobile

---
**Last Updated**: September 5, 2025
**Production Status**: ✅ Live at https://vilara.ai
