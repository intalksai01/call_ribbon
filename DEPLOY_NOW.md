# 🚀 Deploy Now - Exotel Call Ribbon

## ✅ What's Ready

Your widget is **BUILT** and ready to deploy!

Location: `/Users/arun/cursor/call_control/exotel-call-ribbon/widget/build/`

Files ready for deployment:
- `build/index.html` - Demo page
- `build/static/js/main.*.js` - Widget JavaScript (156 KB)
- `build/static/css/main.*.css` - Widget CSS (1.25 KB)

---

## 🎯 Deployment Options

### **Option 1: Netlify (Easiest & Free)** ⭐

#### **Method A: Drag & Drop (2 minutes)**

1. **Go to**: https://app.netlify.com/drop
2. **Drag the `build` folder** from:
   ```
   /Users/arun/cursor/call_control/exotel-call-ribbon/widget/build/
   ```
3. **Drop it** on the Netlify page
4. **Done!** You'll get a URL like: `https://random-name.netlify.app`

#### **Method B: Netlify CLI (5 minutes)**

```bash
# In your terminal (run without sudo):
cd /Users/arun/cursor/call_control/exotel-call-ribbon/widget

# Install Netlify CLI locally
npx netlify-cli login

# Deploy
npx netlify-cli deploy --dir=build --prod

# Follow prompts:
# - Create new site
# - Choose team
# - Site name: exotel-call-ribbon (or your choice)
```

**Result**: Your widget will be live at:
- Demo: `https://your-site-name.netlify.app`
- JS: `https://your-site-name.netlify.app/static/js/main.*.js`
- CSS: `https://your-site-name.netlify.app/static/css/main.*.css`

---

### **Option 2: Vercel (Also Easy & Free)**

```bash
cd /Users/arun/cursor/call_control/exotel-call-ribbon/widget

# Deploy with Vercel
npx vercel --prod

# Follow prompts
# - Login
# - Set up project
# - Deploy
```

**Result**: `https://your-project.vercel.app`

---

### **Option 3: GitHub Pages (Free)**

```bash
cd /Users/arun/cursor/call_control/exotel-call-ribbon

# Initialize git if not already done
git init
git add .
git commit -m "Initial commit"

# Create repo on GitHub, then:
git remote add origin https://github.com/yourusername/exotel-call-ribbon.git
git push -u origin main

# Deploy widget to gh-pages
cd widget
npm install --save-dev gh-pages

# Add to package.json scripts:
# "predeploy": "npm run build",
# "deploy": "gh-pages -d build"

npm run deploy
```

**Result**: `https://yourusername.github.io/exotel-call-ribbon`

---

### **Option 4: AWS S3 + CloudFront (Production)**

#### **Step 1: Create S3 Bucket**

```bash
# Install AWS CLI if not already done
# brew install awscli

# Configure AWS
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1), Format (json)

# Create bucket
aws s3 mb s3://exotel-call-ribbon --region us-east-1

# Upload files
cd /Users/arun/cursor/call_control/exotel-call-ribbon/widget
aws s3 sync build/ s3://exotel-call-ribbon/ \
  --acl public-read \
  --cache-control "max-age=31536000"
```

#### **Step 2: Create CloudFront Distribution**

1. Go to AWS Console → CloudFront
2. Create Distribution
3. Origin: `exotel-call-ribbon.s3.amazonaws.com`
4. Enable HTTPS only
5. Create

**Result**: `https://d111111abcdef8.cloudfront.net`

#### **Step 3: Add Custom Domain (Optional)**

1. Route 53 → Create hosted zone
2. Add CNAME: `cdn.yourcompany.com` → CloudFront URL
3. Update your domain's nameservers

**Result**: `https://cdn.yourcompany.com`

---

## 📋 After Deployment Checklist

Once deployed, your URLs will be:

### **Widget Files:**
- CSS: `https://your-domain.com/static/css/main.*.css`
- JS: `https://your-domain.com/static/js/main.*.js`

### **Test It:**

Open your browser to: `https://your-domain.com`

You should see:
- Call Control Ribbon - Demo
- Three customer buttons
- Ribbon at the bottom

---

## 🖥️ Deploy API Server

Now let's deploy the API server.

### **Option 1: Heroku (Easiest)**

```bash
cd /Users/arun/cursor/call_control/exotel-call-ribbon/api

# Install Heroku CLI if needed
# brew tap heroku/brew && brew install heroku

# Login
heroku login

# Create app
heroku create your-ribbon-api

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=$(openssl rand -base64 32)

# Initialize git if not already done
git init
git add .
git commit -m "Initial API deployment"

# Deploy
git push heroku main

# Open
heroku open
```

**Result**: `https://your-ribbon-api.herokuapp.com`

**Test**: `https://your-ribbon-api.herokuapp.com/health`

---

### **Option 2: Railway (Modern Alternative)**

```bash
cd /Users/arun/cursor/call_control/exotel-call-ribbon/api

# Install Railway CLI
npm install -g railway

# Login
railway login

# Initialize
railway init

# Deploy
railway up

# Add PostgreSQL
railway add

# Set variables
railway variables set NODE_ENV=production
```

**Result**: `https://your-project.railway.app`

---

### **Option 3: DigitalOcean App Platform**

1. Go to: https://cloud.digitalocean.com/apps
2. Click "Create App"
3. Connect GitHub repository
4. Select `api` folder
5. Auto-detects Node.js
6. Add PostgreSQL database
7. Deploy

**Result**: `https://your-app.ondigitalocean.app`

---

## 🔗 Connect Widget to API

Once both are deployed, update the widget to use your API:

### **Update Widget Build:**

```javascript
// In widget/src/widget-entry.js
// Change this line:
const apiUrl = config.apiUrl || 'https://YOUR-API-URL.herokuapp.com';
```

### **Rebuild and Redeploy:**

```bash
cd /Users/arun/cursor/call_control/exotel-call-ribbon/widget
npm run build

# Redeploy to Netlify
npx netlify-cli deploy --dir=build --prod

# Or drag & drop build folder again
```

---

## 🎯 Quick Start: Recommended Path

### **For Testing (5 minutes):**

1. **Widget**: Drag `build` folder to https://app.netlify.com/drop
2. **API**: Deploy to Heroku with free plan
3. **Test**: Open Netlify URL

### **For Production:**

1. **Widget**: AWS S3 + CloudFront
2. **API**: Heroku or DigitalOcean
3. **Custom Domains**: cdn.yourcompany.com, api.yourcompany.com

---

## 📝 Your Deployment URLs

Fill this in after deployment:

```
Widget (CDN):
  Demo: https://_____________________.netlify.app
  CSS:  https://_____________________.netlify.app/static/css/main.*.css
  JS:   https://_____________________.netlify.app/static/js/main.*.js

API Server:
  URL:    https://_____________________.herokuapp.com
  Health: https://_____________________.herokuapp.com/health

Custom Domains (if using):
  Widget: https://cdn.yourcompany.com
  API:    https://api.yourcompany.com
```

---

## 🧪 Test Your Deployment

### **Test Widget:**

```html
<!-- Create test.html -->
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="https://YOUR-NETLIFY-URL/static/css/main.*.css">
</head>
<body>
  <h1>Test Page</h1>
  <script src="https://YOUR-NETLIFY-URL/static/js/main.*.js"></script>
</body>
</html>
```

### **Test API:**

```bash
# Test health endpoint
curl https://YOUR-API-URL/health

# Test init endpoint
curl -X POST https://YOUR-API-URL/api/ribbon/init \
  -H "Content-Type: application/json" \
  -d '{"apiKey": "demo-api-key-789", "domain": "localhost"}'
```

---

## 🎉 Success Criteria

You're deployed when:

- [ ] Widget demo loads at your URL
- [ ] You can see the ribbon at the bottom
- [ ] API health endpoint responds with 200
- [ ] Test API key returns credentials
- [ ] No console errors in browser

---

## 📞 Next Steps After Deployment

1. **Update CLIENT_GUIDE.md** with your actual URLs
2. **Create client API keys** in `api/server.js`
3. **Test with a real Exotel account**
4. **Share docs with pilot clients**

---

## 🆘 Need Help?

### **Widget Issues:**
- Check browser console (F12)
- Verify files uploaded correctly
- Test URL in incognito mode

### **API Issues:**
- Check Heroku logs: `heroku logs --tail`
- Verify environment variables
- Test health endpoint

### **CORS Issues:**
- Update CORS_ORIGINS in API .env
- Add your widget URL to allowed origins

---

## 🚀 Start Deploying Now!

### **Fastest Path:**

```bash
# 1. Deploy Widget (2 minutes)
open https://app.netlify.com/drop
# Drag: /Users/arun/cursor/call_control/exotel-call-ribbon/widget/build

# 2. Deploy API (5 minutes)
cd /Users/arun/cursor/call_control/exotel-call-ribbon/api
npx heroku create
git init && git add . && git commit -m "deploy"
git push heroku main

# 3. Test
# Open your Netlify URL
```

---

**You're ready to deploy!** 🎉

Choose your deployment method above and follow the steps!

---

**Questions?** Check:
- docs/DEPLOYMENT.md - Complete guide
- docs/CLIENT_GUIDE.md - For clients

**All files are ready in:**
```
/Users/arun/cursor/call_control/exotel-call-ribbon/
```
