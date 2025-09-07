# Registration & Onboarding Research

## Superhuman's Onboarding Approach

### Overview
Superhuman uses a highly distinctive, high-touch onboarding process that has become part of their brand identity and value proposition.

### Key Elements

#### 1. **No Self-Service Signup**
- No immediate access after signup
- Users request access and wait for scheduling
- Access is gated behind mandatory onboarding
- Creates exclusivity and anticipation

#### 2. **Mandatory 30-Minute Video Call**
- Every new user must complete this call
- Personal onboarding specialist guides the session
- User shares screen and drives while specialist coaches
- Focus on keyboard shortcuts and workflow optimization
- Specialist configures the tool during the call

#### 3. **Authentication Method**
- Uses Google OAuth (connects directly to Gmail)
- No custom passwords needed
- But OAuth alone doesn't grant access - onboarding call is still required

#### 4. **Post-Onboarding**
- Daily tips emails "from" CEO Rahul Vohra
- Continued education and feature discovery
- High-touch support continues after initial setup

### Why This Works for Superhuman
- **Premium Positioning**: $30/month price point justifies high-touch service
- **Ensures Adoption**: Users are properly trained, reducing churn
- **Creates Virality**: Memorable experience drives word-of-mouth
- **Qualification**: Weeds out casual users who aren't serious
- **Brand Differentiation**: The onboarding IS part of the product

### Potential Downsides
- Slows user acquisition
- High operational cost
- Doesn't scale infinitely
- May frustrate users who want immediate access

---

## Registration Approaches for B2B SaaS

### Option 1: Google OAuth + Business Info (Recommended for Vilara)
**Flow**: Google Sign-in → Business Info Form → Immediate Access

**Pros:**
- Fastest time to value (< 2 minutes)
- No password management
- Email already verified by Google
- Reduces friction significantly
- Modern user expectation

**Cons:**
- Requires Google account
- Less control over user data
- May need fallback for non-Google users

**Best For:** Products targeting modern businesses who value speed

### Option 2: Traditional Email + Password
**Flow**: Signup Form → Email Verification → Access

**Pros:**
- Full control over user data
- Works for everyone
- Traditional/expected flow

**Cons:**
- Requires email service (SendGrid)
- Users may not check email immediately
- Password fatigue
- Higher abandonment rate

**Best For:** Industries requiring high security/compliance

### Option 3: Hybrid Approach
**Flow**: Choose Google OAuth OR Email Signup

**Pros:**
- Maximum flexibility
- Caters to all preferences
- Professional appearance

**Cons:**
- More complex to implement
- Requires maintaining both systems

**Best For:** Enterprise products with diverse user base

### Option 4: High-Touch (Superhuman Style)
**Flow**: Request Access → Schedule Call → Guided Setup

**Pros:**
- Premium positioning
- High conversion to paid
- Deep user understanding
- Low support burden later

**Cons:**
- Slow growth
- High operational cost
- Doesn't suit all markets

**Best For:** Premium products with complex onboarding needs

---

## Recommendation for Vilara

### Primary Recommendation: **Google OAuth + Progressive Business Profiling**

**Why this makes sense for Vilara:**

1. **AI-First Product** - Your users expect modern, frictionless experiences
2. **Natural Language Interface** - Reduces learning curve, doesn't need intensive training
3. **Time-to-Value** - Users can experience AI benefits immediately
4. **Market Position** - Competing against slow, traditional ERPs (differentiate with speed)
5. **Scalability** - Can grow without operational bottleneck

**Suggested Flow:**
```
1. Click "Start Now"
2. Google OAuth sign-in
3. Minimal business info (company name, size)
4. Land in Vilara with guided first experience
5. Progressive profiling (ask for more info as they use it)
```

### Secondary Path: **Enterprise High-Touch**
For enterprise customers (100+ employees), offer Superhuman-style onboarding:
- Scheduled demo/onboarding call
- Custom configuration
- Training sessions
- White-glove service

This gives you the best of both worlds: self-service for SMBs, high-touch for enterprise.

---

## Companies to Model After

### 1. **Notion** (Best Overall Model for Vilara)
- **Why Similar**: Flexible workspace tool, natural language features, B2B focus
- **Onboarding**: Google OAuth → Template selection → Immediate workspace access
- **Key Insight**: Progressive disclosure - starts simple, reveals complexity gradually
- **What to Copy**: Template-based quick starts, in-app guidance

### 2. **Linear** (For Professional Polish)
- **Why Similar**: B2B productivity tool replacing older solutions
- **Onboarding**: OAuth → Team creation → Issue tracking immediately
- **Key Insight**: Opinionated defaults that work out-of-box
- **What to Copy**: Clean, professional aesthetic; keyboard-first design

### 3. **Airtable** (For Business User Focus)
- **Why Similar**: Replacing traditional tools (spreadsheets) with modern alternative
- **Onboarding**: OAuth OR email → Choose template → Start building
- **Key Insight**: Templates make complex product immediately useful
- **What to Copy**: Industry-specific templates and use cases

### 4. **Slack** (For Team Adoption)
- **Why Similar**: Replacing email with better alternative
- **Onboarding**: Create workspace → Invite team → Start chatting
- **Key Insight**: Network effects drive adoption
- **What to Copy**: Easy team invites, immediate value for single user

### 5. **Retool** (For Technical Audience)
- **Why Similar**: Low-code platform for business operations
- **Onboarding**: OAuth → Connect data source → Build first app
- **Key Insight**: Show power quickly with minimal setup
- **What to Copy**: Quick connection to existing data sources

### Avoid Modeling After:
- **Salesforce**: Too complex, slow onboarding
- **SAP**: Requires consultants to set up
- **Oracle**: Not self-service friendly

---

## Specific Recommendations for Vilara

### Immediate Actions:
1. **Implement Google OAuth** as primary registration method
2. **Create 3-5 industry templates** users can choose from
3. **Build "quick win" guided first experience** (create first invoice in 60 seconds)
4. **Add progressive profiling** - ask for info when relevant, not upfront

### For Your Current Situation:
Given that you already have the form built but email isn't working:

**Short-term Fix:**
- Remove email verification requirement
- Let users access immediately after form submission
- Send "welcome" email when SendGrid is configured (non-blocking)

**Medium-term Solution:**
- Add Google OAuth as primary option
- Keep form as fallback
- Configure SendGrid for transactional emails (receipts, reports)

**Long-term Vision:**
- Self-service for <50 employees
- Guided onboarding for 50-100 employees  
- High-touch sales for 100+ employees

### The "Vilara Way":
Your competitive advantage is **speed and simplicity**. Your onboarding should reflect this:
- **Traditional ERP**: Months to implement
- **Vilara**: Productive in 5 minutes

Make the onboarding itself a demonstration of your value proposition.

---

## Questions to Consider

1. **What's your primary customer segment?**
   - SMBs → Optimize for self-service
   - Enterprise → Offer high-touch option
   - Both → Hybrid approach

2. **What's your pricing model?**
   - Freemium → Remove ALL friction
   - Paid only → Some friction is OK (qualification)
   - Trial → Make trial signup frictionless

3. **What's your growth strategy?**
   - Product-led → Focus on immediate value
   - Sales-led → Capture leads for follow-up
   - Hybrid → Different paths for different segments

4. **What data is absolutely essential?**
   - Minimize upfront requirements
   - Collect rest progressively
   - Consider what you NEED vs what's nice to have

---

*Last Updated: September 6, 2025*
*Research compiled from public sources and industry best practices*