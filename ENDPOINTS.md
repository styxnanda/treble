# Music API Endpoints Documentation

This document provides detailed information about the music-related endpoints available in the Treble API.

## List All Songs

**Endpoint:** `GET /api/songs`
**Description:** Retrieves a list of all songs from the database.
**Input:** None
**Output:** Array of SongResponse objects
```json
[
  {
    "id": 1,
    "title": "Song Title",
    "artistId": 1,
    "artistName": "Artist Name",
    "albumId": 1,
    "albumName": "Album Name",
    "duration": 240.5,
    "trackNumber": 1
  }
]
```

## List All Albums

**Endpoint:** `GET /api/albums`
**Description:** Retrieves a lightweight list of all albums with cover URLs.
**Input:** None
**Output:** Array of AlbumListItem objects
```json
[
  {
    "id": 1,
    "name": "Album Name",
    "coverUrl": "https://pre-signed-url-to-cover-image.jpg"
  }
]
```

## List All Artists

**Endpoint:** `GET /api/artists`
**Description:** Retrieves a lightweight list of all artists with profile images.
**Input:** None
**Output:** Array of basic Artist objects
```json
[
  {
    "id": 1,
    "name": "Artist Name",
    "imageUrl": "https://pre-signed-url-to-artist-image.jpg"
  }
]
```

## Get Song Details

**Endpoint:** `GET /api/songs/:id`
**Description:** Retrieves detailed information about a specific song including a pre-signed URL for streaming.
**Input:**
- URL Parameters:
  - `id` (number, required): The ID of the song
**Output:** SongResponse object or 404 if not found
```json
{
  "id": 1,
  "title": "Song Title",
  "artistId": 1,
  "artistName": "Artist Name",
  "albumId": 1,
  "albumName": "Album Name",
  "duration": 240.5,
  "trackNumber": 1,
  "url": "https://cloudflare-r2-pre-signed-url.com/your-bucket/path/to/song.flac?signature=..."
}
```

## Get Album Details

**Endpoint:** `GET /api/albums/:id`
**Description:** Retrieves detailed information about a specific album including songs and artists.
**Input:**
- URL Parameters:
  - `id` (number, required): The ID of the album
**Output:** AlbumResponse object or 404 if not found
```json
{
  "id": 1,
  "name": "Album Name",
  "coverUrl": "https://pre-signed-url-to-cover-image.jpg",
  "songs": [
    {
      "id": 1,
      "title": "Song Title",
      "artistId": 1,
      "artistName": "Artist Name",
      "albumId": 1,
      "albumName": "Album Name",
      "duration": 240.5,
      "trackNumber": 1,
      "url": "https://cloudflare-r2-pre-signed-url.com/your-bucket/path/to/song.flac?signature=..."
    }
  ],
  "artists": [
    {
      "id": 1,
      "name": "Artist Name"
    }
  ]
}
```

## Get Artist Details

**Endpoint:** `GET /api/artists/:id`
**Description:** Retrieves detailed information about a specific artist including albums and songs.
**Input:**
- URL Parameters:
  - `id` (number, required): The ID of the artist
**Output:** ArtistResponse object or 404 if not found
```json
{
  "id": 1,
  "name": "Artist Name",
  "imageUrl": "https://pre-signed-url-to-artist-image.jpg",
  "biography": "Artist biography text",
  "albums": [
    {
      "id": 1,
      "name": "Album Name",
      "coverUrl": "https://pre-signed-url-to-cover-image.jpg"
    }
  ],
  "songs": [
    {
      "id": 1,
      "title": "Song Title",
      "artistId": 1,
      "artistName": "Artist Name",
      "albumId": 1,
      "albumName": "Album Name",
      "duration": 240.5,
      "trackNumber": 1
    }
  ]
}
```

Note: 
- All endpoints are prefixed with `/api`
- All endpoints return promises and are asynchronous
- URLs are pre-signed and valid for 1 hour (3600 seconds)
- Duration is in seconds
- File paths use forward slashes and are relative to the bucket root
- All audio files are in FLAC format
- If an object is not found, the endpoint returns a 404 status code
- The API uses PostgreSQL for metadata storage and R2 only for media content retrieval