# Vilara AI Website & Backend

## Overview
Complete marketing website and backend system for Vilara AI Operating System. Features full PostgreSQL-backed signup flow with email activation and production-ready infrastructure.

**Live Site**: https://vilara.ai

## Implementation Status

### ✅ Phase 1: Universal Activation System (COMPLETE)
- **[activate.html](../../activate.html)** - Universal activation page with multi-deployment options
- **[activation.css](../../assets/css/activation.css)** - Professional responsive styling
- **[universal-signup.php](../../api/universal-signup.php)** - Token-based account creation API

### ✅ Phase 2: Contact Form Integration (COMPLETE)
- **[contact.html](../../contact.html)** - Enhanced with integrated signup form and dynamic plan selection
- **[pricing.html](../../pricing.html)** - Updated with direct plan selection and "Can't Decide Yet?" section
- **[main.js](../../assets/js/main.js)** - Form handling, plan detection, and dynamic UI updates
- Complete signup flow from pricing → contact → activation with plan pre-selection

### ✅ Phase 3: User Experience Enhancements (COMPLETE)
- Unified "Choose Your Plan" sections with actual pricing
- Dynamic form updates - Button text and copy changes based on selected plan
- "Can't Decide Yet?" sections added to Contact and Pricing pages
- Coming soon pages - Professional [videos.html](../../videos.html) and [office-hours.html](../../office-hours.html)
- Smart Migration UX - Context-aware migration paths with dynamic CTAs

### 🚀 Current Status: Production Ready
**Frontend Complete:** Full onboarding flow implemented
- Professional UI with responsive design
- Multi-plan selection with dynamic pricing
- Smart routing (Pricing → Contact → Activation)
- Plan-specific form customization
- Mobile-optimized throughout

**Backend Complete:** Fully deployed on Google Cloud Platform
- PostgreSQL database with complete schema
- Secure token-based activation system
- Rate limiting (5 requests/IP/hour)
- SendGrid email integration ready
- Auto-deployment via GitHub Actions

## Architecture

### Production Setup
- **Frontend**: Vercel (static HTML/CSS/JS)
- **Backend**: Google Cloud Run (PHP + PostgreSQL)  
- **Database**: Google Cloud SQL (PostgreSQL)
- **Email**: SendGrid API
- **Domain**: vilara.ai (unified domain)

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
    ├── docs/project-blueprints/  # Project documentation
    │   ├── README.md             # This file
    │   ├── BUSINESS_CONFIGURATION_WIZARD.md
    │   └── USER_ACTIVATION_ARCHITECTURE.md
    └── CLAUDE.md                 # Development guidelines
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

### Local Testing of New Features

#### Option 1: Quick Local Testing with Python Server
```bash
# Navigate to website directory
cd /mnt/c/Users/grayt/Desktop/Vilara/website

# Start a simple HTTP server
python3 -m http.server 8000
# Or with Python 2: python -m SimpleHTTPServer 8000

# Open in browser: http://localhost:8000
```

#### Option 2: Test with Vercel Dev (Most Realistic)
```bash
# Simulates production environment
npx vercel dev
# Opens at http://localhost:3000
```

#### Option 3: Preview Deployment (Recommended for Pre-Production)
1. **Push your feature branch** to GitHub
   ```bash
   git push -u origin your-feature-branch
   ```
2. **Create a Pull Request** on GitHub
3. **Vercel automatically creates a preview URL** (e.g., `vilara-website-abc123.vercel.app`)
4. **Test on the preview URL** - Full production environment without affecting main site
5. **Merge PR if tests pass** - Automatically deploys to production
6. **Close PR if issues found** - No impact on production

#### Benefits of Preview Deployments:
- ✅ Tests with real HTTPS and production environment
- ✅ No risk to main site
- ✅ Shareable link for team testing
- ✅ Automatic deployment on PR creation
- ✅ Easy rollback - just close the PR

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

**Backend (Google Cloud Run)**
- **Trigger**: Changes to `api/**` files only
- **Deploys**: Docker container with PHP backend + APIs
- **URL**: https://website-1040930643556.us-central1.run.app
- **Time**: ~5-8 minutes
- **Setup**: GitHub Actions workflow with Workload Identity Federation

### Manual Deployment (if needed)
```bash
# Frontend
npx vercel --prod

# Backend
gcloud builds submit --tag us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest --project vilara-dev
gcloud run deploy website --image us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest --region us-central1 --project vilara-dev
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
**Service Account**: `github-actions@vilara-dev.iam.gserviceaccount.com`
**Permissions**: Cloud Build Builder, Cloud Run Admin, Service Account User
**Workload Identity**: Configured for repository `vilara-ai/vilara-website`

### Domain Configuration
- **vilara.ai**: Points to Vercel for frontend
- **API requests**: Proxied from frontend to Cloud Run backend
- **SendGrid**: DNS records configured for email authentication

## Key Features
- **Unified Onboarding**: Single signup flow for all plan types
- **Email Activation**: Secure token-based account activation  
- **Lead Qualification**: Size-based routing (free vs consultation)
- **ROI Calculator**: Dynamic cost comparison with competitors
- **Interactive Demo**: 10-slide showcase of capabilities
- **Migration Tools**: ERP transition planning and cost analysis

## Implementation Plans
- **[Architecture-Agnostic Onboarding Plan](../archive/architecture-agnostic-onboarding-plan.md)** - Original implementation plan
- **[Complete Onboarding Bridge Plan](../archive/complete-onboarding-bridge-plan.md)** - Website-to-UI bridge specifications
- **[Business Configuration Wizard](BUSINESS_CONFIGURATION_WIZARD.md)** - Next phase implementation
- **[User Activation Architecture](USER_ACTIVATION_ARCHITECTURE.md)** - Technical activation flow details

## Support & Maintenance
- **Form Handling**: Formspree integration for contact forms
- **Email Templates**: HTML emails with SendGrid integration  
- **Error Handling**: Comprehensive error responses and logging
- **Performance**: Optimized for Core Web Vitals and mobile
- **Monitoring**: Cloud Logging for APIs, Vercel Analytics for frontend

---
**Last Updated**: September 8, 2025
**Production Status**: ✅ Live at https://vilara.ai