# Vilara Business Configuration Wizard Architecture
*Related Document: [USER_ACTIVATION_ARCHITECTURE.md](USER_ACTIVATION_ARCHITECTURE.md) - Covers user signup and authentication*

## Vision Statement
Enable customers to self-configure Vilara to their specific business needs through an intuitive configuration wizard that delivers immediate value with minimal effort, leveraging the 80/20 principle where 80% of value comes from 20% of configuration.

## Core Principles

### 1. **Progressive Disclosure**
- Start with essential configuration only
- Reveal advanced options as needed
- Avoid overwhelming users with choices

### 2. **Department-Centric Onboarding**
- Each department onboards independently
- Role-based configuration paths
- Cross-department integration happens automatically

### 3. **Immediate Value Delivery**
- Functional system after minimal setup
- Quick wins in first 15 minutes
- Incremental refinement over time

### 4. **Smart Defaults**
- Industry-optimized templates (80% cases)
- Minimal powerful core (20% customization)
- Learn from aggregate user choices

## Architecture Overview

### When This Runs
This configuration wizard runs AFTER user activation (see USER_ACTIVATION_ARCHITECTURE.md):
1. User signs up at vilara.ai
2. User activates account via email
3. **Configuration Wizard launches** (this document)
4. Customized Vilara instance is generated

```
┌─────────────────────────────────────────────────────────┐
│              Configuration Wizard Flow                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  1. Industry Selection → 2. Company Profile →           │
│  3. Department Setup → 4. Role Configuration →          │
│  5. Workflow Customization → 6. Vilara Generation       │
│                                                          │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│              Configuration Output                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  • Work Instructions (.md files)                        │
│  • NLP Patterns & Commands                              │
│  • Database Schema Extensions                           │
│  • UI Customizations                                    │
│  • Integration Mappings                                 │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Detailed Onboarding Process

### Phase 1: Industry & Company Profile (2-3 minutes)

#### Step 1.1: Industry Selection
```yaml
Question: "What industry is your business in?"
Options:
  - Manufacturing
  - Professional Services
  - Retail/E-commerce
  - Healthcare
  - Construction
  - Technology/Software
  - Education
  - Non-profit
  - Other (with text input)

Impact:
  - Loads industry-specific templates
  - Sets default workflows
  - Configures terminology
  - Enables relevant modules
```

#### Step 1.2: Company Size & Structure
```yaml
Question: "How many employees do you have?"
Options:
  - 1-5 (Startup)
  - 6-20 (Small)
  - 21-50 (Growing)
  - 51-250 (Mid-size)
  - 250+ (Enterprise)

Question: "What's your primary business model?"
Options:
  - B2B Services
  - B2C Products
  - B2B Products
  - B2C Services
  - Hybrid/Marketplace
  - Internal Operations

Impact:
  - Determines complexity level
  - Sets approval workflows
  - Configures reporting depth
```

### Phase 2: Department Setup (5-10 minutes per department)

#### Step 2.1: Department Identification
```yaml
Question: "Which department are you setting up?"
Options:
  - Sales & Customer Service
  - Operations & Fulfillment
  - Finance & Accounting
  - Human Resources
  - Marketing
  - IT & Development
  - Executive/Management

For each selected department:
  - Role selection
  - Key processes identification
  - Integration requirements
```

#### Step 2.2: Department-Specific Configuration

**Sales Department Example:**
```yaml
Questions:
  1. "What's your typical sales cycle?"
     - Same day (transactional)
     - 1-7 days (short)
     - 1-4 weeks (medium)
     - 1-6 months (long)
     - 6+ months (enterprise)

  2. "How do you track opportunities?"
     - Simple pipeline (Lead → Customer)
     - Standard CRM (Lead → Qualified → Proposal → Won/Lost)
     - Complex (Multiple stages with custom fields)
     - Custom (describe)

  3. "What are your key sales metrics?"
     [Multi-select checkboxes]
     - Revenue/bookings
     - Pipeline value
     - Conversion rates
     - Activity metrics
     - Customer acquisition cost
     - Lifetime value

Impact:
  - Configures sales workflows
  - Sets up pipeline stages
  - Creates dashboard metrics
  - Enables relevant automations
```

### Phase 3: Work Instruction Customization (10-15 minutes)

#### Step 3.1: Core Process Selection
```yaml
Present: Top 20% most-used processes for their industry/department
Format: Checklist with descriptions

Manufacturing + Operations Example:
  ☑ Create purchase order
  ☑ Receive inventory
  ☑ Create work order
  ☑ Ship products
  ☑ Process returns
  ☐ Manage warranties
  ☐ Track certifications
  
Each selection shows:
  - Default workflow steps
  - Quick customization options
  - "Advanced" link for detailed configuration
```

#### Step 3.2: Natural Language Training
```yaml
For each selected process:
  
Question: "How does your team typically request this?"
Show examples, allow additions:

Process: Create Purchase Order
Default phrases:
  - "Order 100 units of [product] from [supplier]"
  - "Create PO for [supplier]"
  - "Buy [quantity] [items]"
  
Your team's phrases (optional):
  [+ Add phrase]
  - "Restock [product]"
  - "Get more [item] from [vendor]"
```

#### Step 3.3: Business Rules Configuration
```yaml
Simple toggle/select for common rules:

Purchasing Rules:
  - Approval required over: [$5,000 ▼]
  - Preferred suppliers only: [Yes/No]
  - Require 3 quotes over: [$10,000 ▼]
  
Inventory Rules:  
  - Auto-reorder at minimum: [Yes/No]
  - Safety stock percentage: [20% ▼]
  - FIFO/LIFO/Average: [FIFO ▼]
```

### Phase 4: Role & Permission Setup (5 minutes)

#### Step 4.1: Role Templates
```yaml
Select roles that exist in your organization:
  ☑ Owner/CEO (full access)
  ☑ Department Manager (department access)
  ☑ Staff Member (task execution)
  ☐ Contractor (limited access)
  ☐ Auditor (read-only)
  
For each role:
  - Assign to departments
  - Set data access levels
  - Configure approval limits
```

#### Step 4.2: Quick Permission Matrix
```yaml
Visual grid: Roles × Actions
           Create | Edit | Delete | Approve | View
Manager      ✓      ✓       ✓        ✓       ✓
Staff        ✓      ✓       ✗        ✗       ✓  
Contractor   ✗      ✗       ✗        ✗       ✓
```

### Phase 5: Integration & Migration (Optional, 5-10 minutes)

#### Step 5.1: Existing System Detection
```yaml
Question: "Are you migrating from another system?"
Options:
  - Starting fresh
  - Spreadsheets (Excel/Google Sheets)
  - QuickBooks
  - NetSuite
  - SAP
  - Salesforce
  - Other ERP
  
If migrating:
  - Show migration checklist
  - Offer data mapping wizard
  - Schedule migration assistance
```

#### Step 5.2: Integration Requirements
```yaml
Question: "What tools does your team use daily?"
[Multi-select]
  ☐ Microsoft Office/Google Workspace
  ☐ Slack/Teams
  ☐ Email (Gmail/Outlook)
  ☐ Banking/Payment systems
  ☐ E-commerce (Shopify/Amazon)
  ☐ Shipping (FedEx/UPS)
  
For each selection:
  - Enable relevant connectors
  - Configure sync settings
  - Set up authentication
```

### Phase 6: Vilara Instance Generation

#### Step 6.1: Configuration Compilation
```javascript
// Generated configuration structure
{
  "company": {
    "name": "ACME Corp",
    "industry": "manufacturing",
    "size": "21-50",
    "model": "b2b_products"
  },
  "departments": {
    "operations": {
      "workflows": ["purchase_order", "inventory_receive", "work_order"],
      "nlp_patterns": {
        "purchase_order": [
          "order {quantity} units of {product} from {supplier}",
          "restock {product}",
          "buy {quantity} {items}"
        ]
      },
      "rules": {
        "approval_threshold": 5000,
        "require_quotes_over": 10000,
        "inventory_method": "FIFO"
      }
    }
  },
  "roles": {
    "manager": {
      "permissions": ["create", "edit", "delete", "approve", "view"],
      "departments": ["operations", "sales"]
    }
  },
  "integrations": {
    "enabled": ["gmail", "quickbooks", "fedex"],
    "migration_from": "spreadsheets"
  }
}
```

#### Step 6.2: Deployment Options
```yaml
Local Deployment:
  1. Generate customized package with:
     - Work instruction .md files
     - NLP configuration
     - Database migrations
     - Chuck-Stack modules
  2. Include configuration files
  3. Provide installation script
  4. Include quick-start guide

Cloud Deployment:
  1. Provision instance
  2. Deploy work instruction .md files
  3. Apply configuration
  4. Set up user accounts
  5. Send access credentials

Hybrid:
  1. Cloud configuration management
  2. Local execution with .md files
  3. Sync capabilities for updates
```

## Implementation Architecture

### Option 1: Website-Based Configuration (Recommended)

**Pros:**
- Zero installation for configuration
- Centralized template management
- Easy updates and improvements
- Analytics on common patterns
- A/B testing capabilities

**Cons:**
- Requires internet for initial setup
- Need to handle configuration storage
- Security considerations for sensitive data

**Architecture:**
```
Website Onboarding Wizard
         ↓
Configuration API (stores selections)
         ↓
Configuration Generator Service
         ↓
Package Builder / Instance Provisioner
         ↓
Customized Vilara Deployment
```

### Option 2: Local Configuration Wizard

**Pros:**
- Complete offline capability
- Data never leaves premises
- Immediate configuration

**Cons:**
- Requires initial download
- Harder to update templates
- No aggregate learning

### Option 3: Hybrid Approach (Best of Both)

**Recommended Architecture:**
```
1. Website wizard for initial configuration
2. Generate configuration package
3. Download includes local configuration tool
4. Local tool for sensitive/detailed configuration
5. Configuration can be edited locally anytime
```

## Technical Implementation Details

### Configuration Storage Format
```yaml
# vilara-config.yaml
version: "1.0"
generated: "2025-09-06T10:00:00Z"
company:
  id: "acme-corp-2025"
  name: "ACME Corporation"
  
templates:
  base: "manufacturing-small"
  extensions:
    - "quality-control"
    - "multi-warehouse"
    
work_instructions:
  # References to markdown files that will be generated
  - "instructions/purchase_order.md"
  - "instructions/inventory_management.md"
  - "instructions/customer_service.md"
  - "instructions/invoicing.md"
    
nlp:
  patterns:
    - pattern: "order {quantity:number} {product} from {supplier}"
      command: "purchase_order.create"
      parameters:
        map_quantity: "quantity"
        map_product: "item_lookup(product)"
        map_supplier: "supplier_lookup(supplier)"
```

### Generated Work Instruction Example (.md)
```markdown
# Purchase Order Work Instruction

## Overview
This work instruction defines how ACME Corporation creates and manages purchase orders.

## Triggers
- Inventory below reorder point
- Manual request from operations team
- Scheduled replenishment

## Natural Language Commands
- "Order 100 units of widgets from SupplierCo"
- "Create PO for raw materials"
- "Restock inventory"

## Workflow Steps

### 1. Validate Supplier
- Check if supplier is approved
- Verify supplier is active
- Confirm payment terms

### 2. Budget Check
- Threshold: $5,000
- Verify budget availability
- Check department allocation

### 3. Approval Process
- Under $5,000: Auto-approve
- $5,000-$25,000: Manager approval
- Over $25,000: Director approval

### 4. Send Order
- Generate PO number
- Send to supplier via preferred method
- Record in system

### 5. Track Delivery
- Monitor shipment status
- Update expected delivery date
- Alert on delays

## Business Rules
- Preferred suppliers get priority
- Require 3 quotes for orders over $10,000
- Payment terms: Net 30 default

## Integration Points
- QuickBooks: Sync PO for accounting
- Email: Send PO to supplier
- Inventory: Update on-order quantities

## Customization Notes
*Generated for: ACME Corporation*
*Industry: Manufacturing*
*Size: 21-50 employees*
```

### Module Generation System
```python
class VilararConfigGenerator:
    def __init__(self, config):
        self.config = config
        self.base_template = self.load_template(config['templates']['base'])
        
    def generate(self):
        # 1. Start with base template (80% standard)
        modules = self.base_template.modules.copy()
        
        # 2. Apply customizations (20% specific)
        for dept in self.config['departments']:
            modules.extend(self.generate_department_modules(dept))
            
        # 3. Configure NLP patterns
        nlp_config = self.generate_nlp_configuration()
        
        # 4. Generate work instruction markdown files
        work_instructions = self.generate_work_instruction_files()
        
        # 5. Create database extensions
        db_migrations = self.generate_db_migrations()
        
        return VilararInstance(
            modules=modules,
            nlp=nlp_config,
            instructions=work_instructions,  # List of .md file paths
            migrations=db_migrations
        )
    
    def generate_work_instruction_files(self):
        """Generate markdown files for each work instruction"""
        instruction_files = []
        
        for workflow in self.config['workflows']:
            md_content = self.create_instruction_markdown(workflow)
            filename = f"instructions/{workflow['name']}.md"
            
            # Write the markdown file
            with open(filename, 'w') as f:
                f.write(md_content)
            
            instruction_files.append(filename)
        
        return instruction_files
    
    def create_instruction_markdown(self, workflow):
        """Create a markdown work instruction from workflow config"""
        return f"""# {workflow['title']} Work Instruction

## Overview
{workflow['description']}

## Natural Language Commands
{chr(10).join([f"- \"{cmd}\"" for cmd in workflow['nlp_commands']])}

## Workflow Steps
{self.format_workflow_steps(workflow['steps'])}

## Business Rules
{chr(10).join([f"- {rule}" for rule in workflow['rules']])}

## Customization Notes
*Generated for: {self.config['company']['name']}*
*Industry: {self.config['company']['industry']}*
"""
```

### Progressive Enhancement Strategy
```javascript
// Start with minimal viable configuration
const minimalConfig = {
  company: { name, industry },
  departments: ['operations'],  // Just one to start
  workflows: ['invoice', 'payment', 'customer']  // Top 3
};

// Layer on complexity as needed
if (userWantsMore) {
  config.addDepartment('sales');
  config.addWorkflow('purchase_order');
  config.addIntegration('quickbooks');
}

// Save progress between sessions
localStorage.setItem('vilara-onboarding-progress', JSON.stringify(config));
```

## Success Metrics

### Onboarding Metrics
- Time to first value: < 15 minutes
- Completion rate: > 80%
- Configuration accuracy: > 90%
- User satisfaction: > 4.5/5

### Usage Metrics
- Adoption of configured workflows: > 70%
- Customization rate post-onboarding: < 20%
- Support tickets for configuration: < 5%

### Business Metrics
- Customer activation rate: > 60%
- Time to productivity: < 1 day
- Feature utilization: > 50% of configured features

## Implementation Roadmap

### Phase 1: MVP (4-6 weeks)
- [ ] Basic industry templates (3 industries)
- [ ] Simple Q&A flow (10-15 questions)
- [ ] Configuration generator
- [ ] Local deployment package

### Phase 2: Enhanced (6-8 weeks)
- [ ] All major industries
- [ ] Department-specific flows
- [ ] NLP pattern training
- [ ] Cloud deployment option

### Phase 3: Intelligence (8-12 weeks)
- [ ] ML-based recommendations
- [ ] Pattern learning from usage
- [ ] Automated optimization
- [ ] Integration marketplace

### Phase 4: Scale (Ongoing)
- [ ] Multi-tenant architecture
- [ ] White-label capabilities
- [ ] Partner integrations
- [ ] Industry-specific plugins

## Risk Mitigation

### Complexity Risk
**Risk:** Onboarding becomes too complex
**Mitigation:** 
- Start with absolutely minimal config
- Use progressive disclosure
- Provide "Quick Start" vs "Custom" paths
- Allow skipping and returning later

### Accuracy Risk
**Risk:** Configuration doesn't match business needs
**Mitigation:**
- Provide preview/test mode
- Easy rollback options
- Configuration versioning
- In-app configuration editing

### Adoption Risk
**Risk:** Users don't complete onboarding
**Mitigation:**
- Save progress automatically
- Email reminders for incomplete setup
- Offer assisted onboarding option
- Gamification elements (progress bar, achievements)

## Recommendation: Implementation Approach

### Recommended Architecture: Website-Based with Local Enhancement

1. **Website Onboarding Wizard**
   - Hosted on vilara.ai/onboard
   - Stores configuration in cloud temporarily
   - Generates downloadable package

2. **Configuration Package Includes:**
   - Pre-configured Vilara instance
   - Local configuration editor
   - Quick-start documentation
   - Sample data for their industry

3. **Deployment Flexibility:**
   - Download for local installation
   - One-click cloud deployment
   - Hybrid (local with cloud backup)

4. **Why This Approach:**
   - Lowest barrier to entry (just visit website)
   - Centralized template management and updates
   - Progressive enhancement (start simple, add complexity)
   - Analytics to improve templates
   - Security through separation (config vs. execution)

### Next Steps

1. **Create wireframes** for onboarding flow
2. **Define industry templates** (start with top 3)
3. **Build configuration schema** (YAML/JSON structure)
4. **Develop MVP wizard** (10-question flow)
5. **Create configuration generator** (template → instance)
6. **Test with pilot customers** (iterate based on feedback)
7. **Scale to more industries** and departments

## Conclusion

This onboarding architecture leverages the 80/20 principle to deliver immediate value with minimal configuration effort. By starting with industry-optimized defaults and allowing progressive customization, customers can have a functional Vilara instance in under 15 minutes while retaining the flexibility to refine their configuration over time.

The website-based approach with local enhancement provides the best balance of ease-of-use, security, and flexibility, while enabling continuous improvement through aggregate learning from all customers' configurations.

---
*Last Updated: 2025-09-06*
*Author: Vilara Architecture Team*