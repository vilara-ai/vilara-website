# Vilara.ai Deployment Guide

## 🚀 Quick Deploy (Recommended: Vercel)

### **Method 1: One-Click Vercel Deploy**

1. **Install Vercel CLI:**
   ```bash
   npm i -g vercel
   ```

2. **Navigate to website directory:**
   ```bash
   cd /mnt/c/Users/grayt/Desktop/Vilara/website
   ```

3. **Deploy:**
   ```bash
   vercel
   ```
   - Choose "N" for linking to existing project
   - Project name: `vilara-website`
   - Build command: (leave blank)
   - Output directory: (leave blank)

4. **Configure vilara.ai domain:**
   - Go to Vercel dashboard → Your project → Settings → Domains
   - Add custom domain: `vilara.ai`
   - Vercel will provide DNS instructions

---

## 🌐 DNS Configuration

**At your domain registrar (where you bought vilara.ai):**

### For Vercel:
```
Type: CNAME
Name: www
Value: cname.vercel-dns.com

Type: A
Name: @
Value: 76.76.19.61
```

### For Netlify:
```
Type: CNAME  
Name: www
Value: your-site-name.netlify.app

Type: A
Name: @
Value: 75.2.60.5
```

---

## 📋 Pre-Deployment Checklist

✅ **Forms Configuration**
- [ ] Sign up for [Formspree](https://formspree.io)
- [ ] Replace `YOUR_FORM_ID` in contact.html with actual form IDs:
  - Demo form: `/contact.html` line ~49
  - Migration form: `/contact.html` line ~89  
  - Pilot form: `/contact.html` line ~135
  - General form: `/contact.html` line ~177

✅ **Analytics Setup**
- [ ] Add Google Analytics code to all HTML files (before `</head>`)
- [ ] Set up conversion goals for demo bookings, contact forms

✅ **SEO Optimization**
- [ ] Submit sitemap to Google Search Console
- [ ] Verify meta descriptions are under 160 characters
- [ ] Test site speed with PageSpeed Insights

---

## 🔧 Alternative Deployment Methods

### **Method 2: Netlify Drag & Drop**
1. Go to [netlify.com](https://netlify.com)
2. Drag the entire `/website` folder to the deploy area
3. Configure custom domain in Site Settings

### **Method 3: GitHub Pages**
1. Create GitHub repository
2. Push website files to main branch
3. Enable Pages in repository settings
4. Add CNAME file with `vilara.ai`

### **Method 4: Traditional Web Hosting**
1. Upload files via FTP to web host
2. Point domain to hosting provider
3. Configure SSL certificate

---

## ⚙️ Environment Variables (if needed)

For contact forms, you may want to set up environment variables:

```bash
# Formspree API keys
FORMSPREE_DEMO_ID=your_demo_form_id
FORMSPREE_MIGRATION_ID=your_migration_form_id
FORMSPREE_PILOT_ID=your_pilot_form_id
FORMSPREE_GENERAL_ID=your_general_form_id

# Analytics
GOOGLE_ANALYTICS_ID=GA_MEASUREMENT_ID
```

---

## 🧪 Testing Your Deployment

### **Functionality Checklist:**
- [ ] Homepage loads correctly
- [ ] All navigation links work
- [ ] ROI calculator functions
- [ ] Migration calculator works
- [ ] Contact forms submit properly
- [ ] Demo presentation displays
- [ ] Mobile responsiveness
- [ ] Page load speed under 3 seconds

### **Test URLs:**
- https://vilara.ai (homepage)
- https://vilara.ai/demo (integrated demo)
- https://vilara.ai/pricing (pricing page)
- https://vilara.ai/contact (contact forms)
- https://vilara.ai/solutions/augmentation (solution page)

---

## 🔄 Continuous Deployment

### **Git Setup for Automatic Deploys:**
```bash
# Initialize git repository
git init
git add .
git commit -m "Initial Vilara website deployment"

# Connect to GitHub/GitLab
git remote add origin https://github.com/yourusername/vilara-website.git
git push -u origin main
```

### **Vercel GitHub Integration:**
1. Connect Vercel account to GitHub
2. Import your repository
3. Every push to main branch auto-deploys

---

## 📊 Post-Launch Tasks

### **Week 1:**
- [ ] Set up Google Analytics goals
- [ ] Monitor form submissions
- [ ] Test all user flows
- [ ] Check mobile performance

### **Week 2:**
- [ ] Analyze traffic patterns
- [ ] A/B test key CTAs
- [ ] Monitor page load speeds
- [ ] Review conversion rates

### **Ongoing:**
- [ ] Monthly performance reviews
- [ ] Content updates based on user feedback
- [ ] SEO optimization
- [ ] Feature additions

---

## 🆘 Troubleshooting

### **Common Issues:**

**Forms not working:**
- Check Formspree configuration
- Verify form IDs are correct
- Ensure CORS is configured

**Domain not resolving:**
- Wait 24-48 hours for DNS propagation
- Double-check DNS records
- Clear browser cache

**Slow loading:**
- Optimize image sizes
- Enable CDN
- Check hosting provider performance

---

## 📞 Support

Need help with deployment? Contact:
- **Technical Issues:** Check hosting provider documentation
- **DNS Problems:** Contact domain registrar support
- **Form Issues:** Visit [Formspree docs](https://help.formspree.io)

Your Vilara website is ready to convert visitors into customers! 🚀