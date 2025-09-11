# Quick Local Testing Guide for UI Integration

## 1. Test with Python's Built-in Server (Easiest)
```bash
# Navigate to website directory
cd /mnt/c/Users/grayt/Desktop/Vilara/website

# Start a simple HTTP server
python3 -m http.server 8000

# Or with Python 2
python -m SimpleHTTPServer 8000
```

Then open: http://localhost:8000/test-ui-integration.html

## 2. Test with Vercel Dev (Most Realistic)
```bash
# This simulates the production environment
npx vercel dev
```

Then visit: http://localhost:3000/test-ui-integration.html

## 3. Manual Flow Test
1. Go to http://localhost:8000/contact.html
2. Fill out the Free Tier form (under 5 employees)
3. You'll be redirected to activation page
4. Click "Launch Web Interface"
5. You'll see the new app.html interface

## What to Check:
- ✓ Activation page loads with user data
- ✓ "Launch Web Interface" navigates to app.html
- ✓ App shows personalized welcome message
- ✓ Business setup wizard appears for new users
- ✓ Navigation between pages works smoothly

## Note:
The backend API calls will fail unless you have the Python server running on port 5006, but the UI flow should work fine.