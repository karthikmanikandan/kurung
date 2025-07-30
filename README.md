
# ⌚️ Kurungaanaoli – A Shorts/Reels WatchOS App

Kurungaanaoli is an experimental **Apple Watch app** that lets you scroll through ** Shorts & Reels** using the **Digital Crown** — all in a vertical swipe-friendly format.  
It’s a dream project, built from scratch in just **5 days**.

---

## 🚀 Highlights

- 📲 Stream YouTube Shorts & Reels on Apple Watch  
- 🔁 Smooth scrolling with Digital Crown  
- 🔊 AVPlayer-based native video playback  
- 🌐 Backend scraper (Node.js + Puppeteer)  
- 🧪 Built with Combine, SwiftUI & gesture controls  
- ☁️ Hosted backend using **Render** and tested with **ngrok**

---

## 🧠 Why I Built This

Inside VIT classroom, I often felt bored and thought — *"What if I build something cool and real from scratch?"*  
This is the origin story of `kurungaanaoli (KURUNG)` — an Apple Watch app that scrolls Shorts.  
I challenged myself to build this entire idea (both frontend + backend) in **5 days**, often skipping food and sleep to complete it!

---

## 🛠️ Tech Stack

| Frontend  | Backend     | Tools/Infra |
|-----------|-------------|-------------|
| SwiftUI   | Node.js     | Ngrok       |
| Combine   | Express.js  | Render.com  |
| AVPlayer  | Puppeteer   | JSON        |
| WatchKit  | JavaScript  | Cursor AI   |

---

## 📁 Project Structure

kurungaanaoli/
├── kurungaanaoli Watch App/     # SwiftUI App
│   ├── ContentView.swift
│   ├── ReelPlayerView.swift
│   ├── ReelsViewModel.swift
│   └── AppConfig.swift
├── insta-reels-backend/         # Node.js API
│   ├── server.js
│   ├── fetchReels.js
│   ├── routes/reels.js
│   └── render.yaml
└── setup_render.sh              # Auto-deploy script

---

## ⚙️ Setup Instructions

### 1. 🧩 Install Backend

```bash
cd insta-reels-backend
npm install
node server.js

Use ngrok or Render to expose your localhost:

ngrok http 3000

2. 📲 Configure App

Update AppConfig.swift:

static let baseURL = "https://your-backend-url.onrender.com"

3. 🧪 Run Watch App

open kurungaanaoli/kurungaanaoli.xcodeproj
# Run on Watch Simulator


⸻

📡 API Endpoints
	•	GET /api/reels?limit=5 – Get 5 videos
	•	GET /health – Check server health
	•	POST /refresh – Refresh Reels

⸻

🔒 Ethics & Legal Note

⚠️ Disclaimer: This project is only for educational and experimental purposes.

	•	❌ No data is stored or reused
	•	🔒 Scraper logic (Puppeteer) is disabled or mocked during public deployment
	•	📵 No videos are hosted or downloaded — only previewed directly via source URLs
	•	✅ USE_MOCK_DATA=true is used in production

I realized that scraping  Shorts or  Reels may raise legal & policy concerns.
That’s why I won’t upload this app to the App Store.
If a company officially implements this — I’d be thrilled, but I respect their terms.

⸻

💬 My Learnings
	•	First time working with ngrok, Render, Node.js backend, and Puppeteer scraping
	•	Learned AVPlayer optimization on WatchOS
	•	Understood Digital Crown interaction, gesture detection, and JSON decoding issues
	•	Fixed async playback, audio sessions, and Watch Simulator limitations
	•	Coordinated fullstack dev across macOS, Xcode, SwiftUI, and backend APIs

⸻

🔗 GitHub Link

🔗 github.com/karthikmanikandan/kurungaanaoli

⚠️ I’ve messed up the scraper logic intentionally — so it won’t work directly 😅.
You can still learn from the structure, flow, and tech stack.

⸻

📦 Deployment Notes
	•	✅ Deployed on Render (Free Tier) with HTTPS
	•	🕒 Cold-start delay: ~60 sec
	•	🧪 Tested via Watch Simulator + localhost
	•	🌐 Used ngrok for dev tunnel

⸻

📝 License

MIT License.
Use the code with ❤️ and caution.

⸻

🤝 Connect with Me

Built with 💻, ☕️, and 🎧 in 5 long days.
Let’s innovate more together!

👋 karthikmanikandan.dev • Apple Watch Dev • Fullstack Learner

---
