const express = require('express');
const cors = require('cors');
const { fetchReels } = require('./fetchReels');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Render-specific configuration
const isProduction = process.env.NODE_ENV === 'production';

// Enhanced CORS for WatchOS app
app.use(cors({
  origin: isProduction ? ['https://kurung.onrender.com', 'https://kurung-backend.onrender.com'] : ['*'], // Production vs development
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Session-Token']
}));

app.use(express.json({ limit: '10mb' }));

// YouTube Shorts don't require session management

// Request queuing to prevent multiple Chrome instances
let isScrapingInProgress = false;
let scrapingQueue = [];

async function processScrapingQueue() {
  if (isScrapingInProgress || scrapingQueue.length === 0) {
    return;
  }
  
  isScrapingInProgress = true;
  console.log('🔄 Processing scraping queue...');
  
  try {
    const { resolve, reject, limit } = scrapingQueue.shift();
    console.log(`📊 Processing request for ${limit} YouTube Shorts...`);
    const reels = await fetchReels(limit);
    resolve(reels);
  } catch (error) {
    if (scrapingQueue.length > 0) {
      const { reject } = scrapingQueue.shift();
      reject(error);
    }
  } finally {
    isScrapingInProgress = false;
    console.log('✅ Scraping queue processing completed');
    // Process next request if any
    if (scrapingQueue.length > 0) {
      setTimeout(processScrapingQueue, 1000); // 1 second delay between requests
    }
  }
}

// Environment variable to control mock data - default to false for real YouTube Shorts
const USE_MOCK_DATA = process.env.USE_MOCK_DATA === 'true';

console.log('🚀 YouTube Shorts Backend Setup');
console.log(`📊 Mock Data: ${USE_MOCK_DATA ? 'ENABLED' : 'DISABLED'}`);
console.log('✅ No login required for YouTube Shorts');

console.log('\n🌐 Starting the API server...');
console.log(`🔧 Server running on port: ${PORT}`);
console.log('🔧 Available endpoints:');
console.log('   - GET  /health - Health check');
console.log('   - GET  /reels?limit=N - Get YouTube Shorts (limit optional)');
console.log('   - POST /refresh - Force refresh Shorts');

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    mockData: USE_MOCK_DATA,
    source: 'youtube-shorts',
    message: 'YouTube Shorts backend is running'
  });
});

// Instagram Reels endpoint
app.get('/reels', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;

    console.log(`📊 Requesting up to ${limit} YouTube Shorts...`);
    console.log('✅ YouTube Shorts scraping with session support');

    let shorts = [];

    if (USE_MOCK_DATA) {
      console.log('🎭 Using mock data');
      shorts = generateMockReels(limit);
    } else {
      console.log('🌐 Queuing YouTube Shorts scraping request...');
      
      try {
        // Queue the request instead of calling directly
        shorts = await new Promise((resolve, reject) => {
          scrapingQueue.push({ resolve, reject, limit });
          processScrapingQueue();
        });
        
        console.log(`✅ Successfully scraped ${shorts.length} YouTube Shorts`);
      } catch (scrapingError) {
        console.error('❌ Scraping failed, falling back to mock data:', scrapingError.message);
        shorts = generateMockReels(limit);
      }
    }

    // Limit the number of shorts returned
    const limitedShorts = shorts.slice(0, limit);

    const response = {
      reels: limitedShorts,
      metadata: {
        total: limitedShorts.length,
        scrapedAt: new Date().toISOString(),
        source: 'instagram-reels'
      }
    };

    res.json(response);

  } catch (error) {
    console.error('❌ Error fetching Instagram Reels:', error);
    res.status(500).json({
      error: 'Failed to fetch Instagram Reels',
      message: error.message
    });
  }
});

// Force refresh endpoint
app.post('/refresh', async (req, res) => {
  try {
    console.log('🔄 Force refreshing Instagram Reels...');
    
    if (USE_MOCK_DATA) {
      res.json({
        success: true,
        message: 'Mock data refreshed',
        timestamp: new Date().toISOString()
      });
      return;
    }

    // Clear any cached data and re-scrape
    let shorts = [];
    try {
      shorts = await fetchReels();
    } catch (error) {
      console.error('❌ Scraping failed during refresh:', error.message);
      console.log('🔄 Falling back to mock data for refresh');
      shorts = generateMockReels(10);
    }
    
    res.json({
      success: true,
      count: shorts.length,
      message: `Refreshed ${shorts.length} Instagram Reels`,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ Error refreshing YouTube Shorts:', error);
  res.status(500).json({
    success: false,
      error: 'Failed to refresh YouTube Shorts',
      message: error.message
  });
  }
});

// Mock data generator with YouTube Shorts format - using reliable video URLs for watch simulator
function generateMockReels(limit) {
  const mockShorts = [];
  // Using more reliable video URLs that work better in watch simulator
  const verticalVideos = [
    {
      type: 'short',
      link: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      videoId: 'sample-video-1',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      scrapedAt: new Date().toISOString()
    },
    {
      type: 'short',
      link: 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',
      videoId: 'sample-video-2',
      videoUrl: 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',
      scrapedAt: new Date().toISOString()
    },
    {
      type: 'short',
      link: 'https://file-examples.com/storage/fe68c0e8c0c7a3b0193bf57/2017/10/file_example_MP4_480_1_5MG.mp4',
      videoId: 'sample-video-3',
      videoUrl: 'https://file-examples.com/storage/fe68c0e8c0c7a3b0193bf57/2017/10/file_example_MP4_480_1_5MG.mp4',
      scrapedAt: new Date().toISOString()
    },
    {
      type: 'short',
      link: 'https://www.w3schools.com/html/mov_bbb.mp4',
      videoId: 'sample-video-4',
      videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
      scrapedAt: new Date().toISOString()
    },
    {
      type: 'short',
      link: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      videoId: 'sample-video-5',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      scrapedAt: new Date().toISOString()
    }
  ];
  
  for (let i = 0; i < limit; i++) {
    const baseVideo = verticalVideos[i % verticalVideos.length];
    const uniqueId = `${baseVideo.videoId}-${Date.now()}-${i}`;
    
    mockShorts.push({
      type: 'short',
      link: `https://www.youtube.com/shorts/${uniqueId}`,
      videoId: uniqueId,
      videoUrl: baseVideo.videoUrl, // Use original URL without query params
      scrapedAt: new Date().toISOString()
    });
  }
  return mockShorts;
}

// Start the server
app.listen(PORT, () => {
  console.log(`🎉 YouTube Shorts Server is running on port ${PORT}`);
  console.log('📱 Ready to receive requests from WatchOS app!');
  console.log('🎬 No authentication required for YouTube Shorts');
  console.log('🚀 Deployed on Render - Production ready!');
});

module.exports = app;
