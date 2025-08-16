# CLAUDE.md - Vilara Website Development

## Project Overview
**Vilara Website** is the marketing and lead generation website for Vilara ERP. Built with modern web standards, the site showcases Vilara's unique value proposition of $0 seat licenses, 95% faster task completion, and natural language ERP interface.

**Primary Goals**: Convert visitors to qualified leads through a tiered approach based on company size.

## Project Structure
```
website/
├── index.html                    # Homepage with hero, solutions paths, ROI calculator
├── demo.html                     # Interactive 10-slide demo showcase
├── pricing.html                  # Transparent pricing with competitor comparisons
├── contact.html                  # Lead qualification forms (#free, #consultation)
├── how-it-works.html            # Technical architecture and capabilities
├── migration.html               # ERP migration tools and calculator
├── solutions/                   # Solution-specific landing pages
│   ├── augmentation.html        # Augment existing ERP approach
│   ├── replacement.html         # Replace legacy ERP approach
│   └── first-time.html          # First-time ERP implementation
├── assets/
│   ├── css/styles.css           # Main stylesheet with responsive design
│   ├── js/main.js              # Interactive functionality and calculations
│   └── images/                  # Logos and visual assets
└── vercel.json                  # Deployment configuration
```

## Key Technologies & Frameworks
- **Frontend**: Pure HTML5, CSS3, JavaScript (no framework dependencies)
- **Styling**: Custom CSS with CSS Grid, Flexbox, CSS Variables
- **Deployment**: Vercel with automated builds
- **Forms**: Formspree integration for contact handling
- **Analytics**: Google Analytics (can be added)
- **Performance**: Optimized for Core Web Vitals

## Development Commands
```bash
# Deploy to production
npx vercel --prod

# Local development server
npx vercel dev

# Check deployment status
vercel ls
```

## Design System & Conventions
- **Color Palette**: CSS variables in `:root` for consistent theming
- **Typography**: System fonts with fallbacks for performance
- **Responsive Design**: Mobile-first approach with breakpoints
- **Component Pattern**: Reusable CSS classes (.btn, .feature-item, .path-card)
- **Naming Convention**: BEM-inspired class names for clarity

## Architecture & Design Patterns
- **Lead Qualification**: Two-path approach based on company size
  - Free tier: Under 10 employees → Instant access
  - Consultation: 10+ employees → Personalized demo
- **Content Strategy**: Problem-focused messaging with clear value props
- **Conversion Funnels**: Multiple entry points (demo, pricing, solutions)
- **Technical Credibility**: PostgreSQL + Nushell foundation highlighted

## Key Pages & Functions

### Homepage (index.html)
- Hero section with 95% faster messaging
- Three solution paths (augment, replace, start fresh)
- ROI calculator with dynamic results
- Tiered CTA section for lead qualification

### Demo Page (demo.html)
- 10-slide interactive demonstration
- Specific use cases and time comparisons
- Animated elements showing speed advantages
- Clear progression from problem to solution

### Pricing Page (pricing.html)
- Free Starter (up to 10 employees)
- Transparent paid tiers (Professional, Business, Enterprise)
- Cost comparison table vs NetSuite/SAP
- No hidden fees messaging

### Contact Page (contact.html)
- Anchor-based navigation (#free, #consultation)
- Company size qualification forms
- FAQ addressing common objections
- Multiple contact methods

## Content Strategy
- **Value Proposition**: $0 seat licenses, 95% faster, natural language
- **Competitive Positioning**: Cost comparison tables, feature advantages
- **Trust Building**: Technical architecture, PostgreSQL foundation
- **Lead Qualification**: Size-based segmentation prevents unqualified demos

## Deployment & Environment
- **Production**: Auto-deployed via Vercel on git push
- **Staging**: Preview deployments for pull requests
- **Domain**: vilara.ai (or custom domain in Vercel settings)
- **CDN**: Global edge network through Vercel
- **SSL**: Automatic HTTPS with certificate management

## Performance Optimization
- **Images**: Optimized formats, proper sizing
- **CSS**: Single stylesheet, minimal external dependencies
- **JavaScript**: Vanilla JS for maximum performance
- **Fonts**: System fonts to avoid web font loading delays
- **Caching**: Vercel edge caching for static assets

## SEO & Marketing
- **Meta Tags**: Optimized for each page with unique descriptions
- **Schema Markup**: Structured data for better search results
- **Core Web Vitals**: Optimized for Google PageSpeed metrics
- **Social Sharing**: Open Graph tags for social media

## Lead Generation Strategy
- **Free Tier**: Immediate value for small businesses
- **Enterprise Tier**: Consultation-based approach for larger companies
- **Content Funnels**: Educational content driving to contact forms
- **Conversion Tracking**: Form submissions and engagement metrics

## Common Maintenance Tasks
1. **Content Updates**: Modify pricing, features, or messaging
2. **Form Management**: Update Formspree endpoints or add new forms
3. **Asset Updates**: Replace logos, images, or add new visuals
4. **Performance Monitoring**: Check Core Web Vitals and loading times
5. **SEO Updates**: Refresh meta descriptions and content

## Important Files & Entry Points
- **Main stylesheet**: `assets/css/styles.css`
- **Interactive functionality**: `assets/js/main.js`
- **Deployment config**: `vercel.json`
- **Contact forms**: Use Formspree integration (update endpoints)

## Integration Points
- **Formspree**: Contact form submissions
- **Vercel**: Hosting and deployment
- **Parent Project**: Links to chuck-stack-claude documentation
- **Analytics**: Ready for Google Analytics integration

## Security Considerations
- **Form Protection**: Formspree handles spam filtering
- **HTTPS**: Enforced by Vercel for all traffic
- **Content Security**: No user-generated content, static site security
- **Privacy**: No sensitive data collection on frontend

## Project-Specific Guidelines for Claude
- **Always test**: Preview changes locally before deployment
- **Mobile-first**: Ensure responsive design on all modifications
- **Performance**: Keep dependencies minimal, optimize for speed
- **Conversion**: Any changes should support lead generation goals
- **Brand consistency**: Maintain visual and messaging coherence
- **User experience**: Prioritize clarity over complexity

## Recent Changes & Notes
- **2025-08-16**: Implemented tiered lead qualification system
- **Company size focus**: Free for under 10 employees, consultation for 10+
- **Messaging refinement**: Added "blow my mind features" and "nirvana" language
- **Cost comparison**: Added "Additional Seat Licenses" row highlighting $0 advantage

---
*Last Updated: 2025-08-16*
*This file guides Claude Code in maintaining and improving the Vilara website.*