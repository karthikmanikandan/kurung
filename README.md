# 🎯 YouTube Shorts Apple Watch App

A native Apple Watch app that streams YouTube Shorts with smooth Digital Crown navigation and gesture controls.

## 📱 Features

- **YouTube Shorts Streaming**: Watch vertical videos optimized for Apple Watch
- **Digital Crown Navigation**: Smooth scrolling between videos
- **Gesture Controls**: Tap to play/pause, swipe to navigate
- **Auto-refresh**: Automatically loads new content every 2 minutes
- **Offline Fallback**: Graceful error handling with fallback videos

## 🏗️ Project Structure

```
kurung/
├── insta-reels-backend/     # Node.js backend server
│   ├── server.js           # Express server with YouTube Shorts API
│   ├── fetchReels.js       # YouTube Shorts scraping logic
│   ├── package.json        # Node.js dependencies
│   └── render.yaml         # Render deployment configuration
├── kurungaanaoli/          # Apple Watch app (SwiftUI)
│   └── kurungaanaoli Watch App/
│       ├── ContentView.swift      # Main app interface
│       ├── ReelPlayerView.swift   # Video player component
│       ├── ReelsViewModel.swift   # Data management
│       ├── AppConfig.swift        # Backend URL configuration
│       └── Assets.xcassets/       # App icons and images
└── setup_render.sh         # Deployment script
```

## 🚀 Quick Start

### Backend Deployment (Render)

1. **Deploy to Render**:
   ```bash
   chmod +x setup_render.sh
   ./setup_render.sh
   ```

2. **Get your Render URL** (e.g., `https://kurung-backend-xxxx.onrender.com`)

3. **Update AppConfig.swift**:
   ```swift
   static let baseURL = "https://your-render-url.onrender.com"
   ```

### iOS App

1. **Open in Xcode**:
   ```bash
   open kurungaanaoli/kurungaanaoli.xcodeproj
   ```

2. **Select Watch Simulator** and run the app

3. **Test the app** with Digital Crown navigation

## 🔧 Configuration

### Backend Environment Variables

- `NODE_ENV`: `production`
- `USE_MOCK_DATA`: `true` (for testing) or `false` (for real scraping)
- `PORT`: `10000` (Render will override this)

### App Configuration

Update `kurungaanaoli/kurungaanaoli Watch App/Config/AppConfig.swift`:

```swift
static let baseURL = "https://your-render-url.onrender.com"
```

## 📡 API Endpoints

- `GET /health` - Health check
- `GET /reels?limit=N` - Get YouTube Shorts (limit optional)
- `POST /refresh` - Force refresh content

## 🎮 Controls

- **Digital Crown**: Scroll up/down to navigate between videos
- **Tap Video**: Toggle play/pause
- **Auto-play**: Videos automatically play when scrolled to
- **Smooth Transitions**: 0.3s ease-in-out animations

## 🛠️ Development

### Backend Development
```bash
cd insta-reels-backend
npm install
npm start
```

### Frontend Development
```bash
open kurungaanaoli/kurungaanaoli.xcodeproj
# Select Watch Simulator and run
```

## 🚀 Deployment

### Render Backend
- Automatic deployment on git push
- Free tier with cold starts (30-60s delay after inactivity)
- HTTPS enabled by default

### App Store
- Ready for TestFlight deployment
- Configured for watchOS 10.0+
- Optimized for Apple Watch Series 4 and later

## 📊 Performance

- **Backend**: < 2 seconds response time for mock data
- **Frontend**: 60fps crown navigation
- **Memory**: Efficient AVPlayer cleanup
- **Battery**: Minimal background processing

## 🔒 Security

- **HTTPS**: All network requests use HTTPS
- **ATS**: App Transport Security configured for required domains
- **CORS**: Properly configured for WatchOS app

## 📝 License

ISC License

---

**Ready for deployment!** 🎉 