# Music API Endpoints Documentation

This document provides detailed information about the music-related endpoints available in the Treble API.

## List All Songs
**Endpoint:** `GET /songs`
**Description:** Retrieves a list of all songs in the system.
**Input:** None
**Output:** Array of Song objects
```json
[
  {
    "id": "album-name/song.flac",
    "title": "Song Title",
    "artist": "Artist Name",
    "album": "Album Name",
    "duration": 240.5,
    "path": "album-name/song.flac"
  }
]
```

## List All Albums
**Endpoint:** `GET /albums`
**Description:** Retrieves a list of all albums in the system.
**Input:** None
**Output:** Array of Album objects
```json
[
  {
    "name": "Album Name",
    "coverUrl": "https://pre-signed-url-to-cover-image.jpg",
    "songs": [
      {
        "id": "album-name/song.flac",
        "title": "Song Title",
        "artist": "Artist Name",
        "album": "Album Name",
        "duration": 240.5,
        "path": "album-name/song.flac"
      }
    ]
  }
]
```

## List All Artists
**Endpoint:** `GET /artists`
**Description:** Retrieves a list of all artists in the system.
**Input:** None
**Output:** Array of Artist objects
```json
[
  {
    "name": "Artist Name",
    "albums": ["Album Name 1", "Album Name 2"],
    "songs": [
      {
        "id": "album-name/song.flac",
        "title": "Song Title",
        "artist": "Artist Name",
        "album": "Album Name",
        "duration": 240.5,
        "path": "album-name/song.flac"
      }
    ]
  }
]
```

## Get Pre-signed URL for Song
**Endpoint:** `GET /song`
**Description:** Generates a pre-signed URL for accessing a specific song file.
**Input:**
- Query Parameters:
  - `path` (string, required): The path to the song file (e.g., "album-name/song.flac")

**Output:** String containing the pre-signed URL
```json
"https://cloudflare-r2-pre-signed-url.com/your-bucket/album-name/song.flac?signature=..."
```

## Get Album Details
**Endpoint:** `GET /album/:name`
**Description:** Retrieves detailed information about a specific album.
**Input:**
- URL Parameters:
  - `name` (string, required): The name of the album

**Output:** Single Album object or null if not found
```json
{
  "name": "Album Name",
  "coverUrl": "https://pre-signed-url-to-cover-image.jpg",
  "songs": [
    {
      "id": "album-name/song.flac",
      "title": "Song Title",
      "artist": "Artist Name",
      "album": "Album Name",
      "duration": 240.5,
      "path": "album-name/song.flac"
    }
  ]
}
```

## Get Artist Details
**Endpoint:** `GET /artist/:name`
**Description:** Retrieves detailed information about a specific artist.
**Input:**
- URL Parameters:
  - `name` (string, required): The name of the artist

**Output:** Single Artist object or null if not found
```json
{
  "name": "Artist Name",
  "albums": ["Album Name 1", "Album Name 2"],
  "songs": [
    {
      "id": "album-name/song.flac",
      "title": "Song Title",
      "artist": "Artist Name",
      "album": "Album Name",
      "duration": 240.5,
      "path": "album-name/song.flac"
    }
  ]
}
```

---

Note: 
- All endpoints return promises and are asynchronous
- URLs are pre-signed and valid for 1 hour (3600 seconds)
- Duration is in seconds
- File paths use forward slashes and are relative to the bucket root
- All audio files are in FLAC format
- If an album or artist is not found, the endpoint returns null