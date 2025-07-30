# Render Deployment Guide for kurung Backend

## Overview
This guide will help you deploy the kurung backend to Render, a cloud platform that offers free hosting for Node.js applications.

## Prerequisites
1. A GitHub account
2. A Render account (free at https://render.com)
3. Your backend code pushed to a GitHub repository

## Step 1: Prepare Your Repository

### 1.1 Ensure your repository structure is correct:
```
insta-reels-backend/
├── server.js
├── fetchReels.js
├── package.json
├── package-lock.json
├── render.yaml
├── env.example
└── node_modules/ (will be installed by Render)
```

### 1.2 Verify package.json has correct scripts:
```json
{
  "scripts": {
    "start": "node server.js"
  }
}
```

## Step 2: Deploy to Render

### 2.1 Create a Render Account
1. Go to https://render.com
2. Sign up with your GitHub account
3. Verify your email

### 2.2 Create a New Web Service
1. Click "New +" in your Render dashboard
2. Select "Web Service"
3. Connect your GitHub repository
4. Select the repository containing your backend code

### 2.3 Configure the Service
- **Name**: `kurung-backend`
- **Environment**: `Node`
- **Region**: Choose closest to your users
- **Branch**: `main` (or your default branch)
- **Build Command**: `npm install`
- **Start Command**: `npm start`

### 2.4 Environment Variables
Add these environment variables in Render:
- `NODE_ENV`: `production`
- `USE_MOCK_DATA`: `true` (for testing, can be `false` for real scraping)
- `PORT`: `10000` (Render will override this)

### 2.5 Deploy
1. Click "Create Web Service"
2. Render will automatically build and deploy your app
3. Wait for the build to complete (usually 2-5 minutes)

## Step 3: Update Your WatchOS App

### 3.1 Get Your Render URL
After deployment, Render will provide a URL like:
`https://kurung-backend-xxxx.onrender.com`

### 3.2 Update AppConfig.swift
```swift
// In kurungaanaoli/kurungaanaoli Watch App/Config/AppConfig.swift
static let baseURL = "https://kurung-backend-xxxx.onrender.com"
```

### 3.3 Update Info.plist
Add your Render domain to the ATS exceptions:
```xml
<key>NSExceptionDomains</key>
<dict>
    <key>onrender.com</key>
    <dict>
        <key>NSExceptionAllowsInsecureHTTPLoads</key>
        <true/>
        <key>NSExceptionMinimumTLSVersion</key>
        <string>TLSv1.2</string>
    </dict>
</dict>
```

## Step 4: Test Your Deployment

### 4.1 Test the Health Endpoint
```bash
curl https://kurung-backend-xxxx.onrender.com/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "mockData": true,
  "source": "youtube-shorts",
  "message": "YouTube Shorts backend is running"
}
```

### 4.2 Test the Reels Endpoint
```bash
curl https://kurung-backend-xxxx.onrender.com/reels?limit=5
```

## Step 5: Monitor and Maintain

### 5.1 Render Dashboard Features
- **Logs**: View real-time application logs
- **Metrics**: Monitor CPU, memory, and response times
- **Deployments**: Automatic deployments on git push
- **Environment Variables**: Easy management of config

### 5.2 Free Tier Limitations
- **Sleep after inactivity**: Your app will sleep after 15 minutes of inactivity
- **Cold starts**: First request after sleep may take 30-60 seconds
- **Bandwidth**: 750 hours/month included
- **Build minutes**: 500 minutes/month included

### 5.3 Scaling Considerations
- Free tier is sufficient for development and testing
- For production, consider upgrading to paid plans
- Monitor usage in Render dashboard

## Troubleshooting

### Common Issues

#### 1. Build Failures
- Check that all dependencies are in `package.json`
- Verify `package-lock.json` is committed
- Check build logs in Render dashboard

#### 2. Runtime Errors
- Check application logs in Render dashboard
- Verify environment variables are set correctly
- Test locally with same environment variables

#### 3. CORS Issues
- Verify CORS configuration in `server.js`
- Check that your Render URL is in the allowed origins
- Test with curl or Postman first

#### 4. Cold Start Delays
- This is normal for free tier
- Consider using mock data initially (`USE_MOCK_DATA=true`)
- Upgrade to paid plan for better performance

### Getting Help
1. Check Render documentation: https://render.com/docs
2. View your application logs in Render dashboard
3. Test endpoints manually before updating your app

## Next Steps

### For Production
1. **Enable Real Scraping**: Set `USE_MOCK_DATA=false`
2. **Add Error Monitoring**: Consider services like Sentry
3. **Add Caching**: Implement Redis or similar for better performance
4. **Add Rate Limiting**: Protect your API from abuse
5. **Add Authentication**: If needed for your use case

### For Development
1. **Local Development**: Keep using `localhost:3000` for development
2. **Environment Switching**: Use different configs for dev/staging/prod
3. **Testing**: Add automated tests for your API endpoints

## Security Considerations

### For Production Deployment
1. **HTTPS**: Render provides SSL certificates automatically
2. **CORS**: Restrict origins to your app's domain only
3. **Rate Limiting**: Implement to prevent abuse
4. **Input Validation**: Validate all API inputs
5. **Error Handling**: Don't expose sensitive information in errors

### Environment Variables
- Never commit sensitive data to git
- Use Render's environment variable management
- Rotate secrets regularly
- Use different values for different environments

## Cost Optimization

### Free Tier Tips
1. **Use Mock Data**: Reduces processing time and costs
2. **Optimize Dependencies**: Remove unused packages
3. **Monitor Usage**: Stay within free tier limits
4. **Cache Responses**: Reduce repeated processing

### When to Upgrade
- Exceeding free tier limits
- Need for better performance
- Production requirements
- Custom domain needs

---

**Note**: This guide assumes you're using the free tier of Render. For production applications, consider upgrading to paid plans for better performance and reliability. 