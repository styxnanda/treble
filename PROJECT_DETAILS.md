# Project Treble

Project Name: Treble
Framework: Flutter (Supports Web, Android, iOS, and Desktop)
Storage & CDN: Cloudflare R2

## Project Overview
This is a music streaming app that plays FLAC files directly from Cloudflare R2 (served via CDN).

## Project Structure
```bash
Copy
Edit
lib/
├── main.dart           # Entry point
├── models/             # Data models (Song, Album, Artist)
├── providers/          # State management (SongProvider)
├── screens/            # UI screens (Home, Player)
├── widgets/            # Reusable UI components (Audio Player, Song Tile)
├── services/           # Cloudflare R2 service (fetch song list)
├── utils/              # Helpers (FLAC metadata extraction)
```

## Key Features
### Music Streaming

- Stream FLAC files directly from Cloudflare R2 + CDN.
- Display title, artist, album, cover art using embedded FLAC metadata.
- Implement basic audio player (play, pause, seek, next/prev, 15 seconds forward, 15 seconds backwards).

### Dynamic UI
- Home screen: Song list with album covers.
- Player screen: Large album art, playback controls, progress bar.

### Caching & Optimization
- Cache album art and last played song.
- Implement lazy loading for song list.

## Dependencies to Install
This is not a fixed list. Please adjust to make it more modern if there are better or industry-standard alternatives:
- just_audio → Handles FLAC streaming.
- audiotagger → Extracts metadata (title, artist, album, cover).
- Dio → Fetches file list from Cloudflare R2.
- shared_preferences → Stores last played song.
- riverpod / provider → State management.

## Workflow
1. Fetch song list from Cloudflare R2 (directory-based).
2. Extract metadata from FLAC files (title, artist, album, cover).
3. Display song list with album art.
4. Play music using just_audio (seek, next, prev, pause).
5. Optimize performance with caching.

## Deployment:
- For Web: Deploy to Vercel
- For Mobile: Generate APK (flutter build apk).
- Domain Setup: Point domain to Vercel.

## What to do on first setup
1. Initialize Flutter Project
2. Set up project structure & install dependencies.
3. Implement song list & metadata extraction.
4. Build UI screens (Home, Player, Album view).
5. Deploy Web version to Vercel.