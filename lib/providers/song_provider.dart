import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../services/music_api_service.dart';

// Provider for the MusicApiService
final musicApiServiceProvider = Provider<MusicApiService>((ref) {
  return MusicApiService();
});

// Provider for the album cover URL for a specific album name
final albumCoverUrlProvider = FutureProvider.family<String, String>((ref, albumName) async {
  final albums = await ref.watch(albumsProvider.future);
  final album = albums.firstWhere(
    (album) => album.name.toLowerCase() == albumName.toLowerCase(),
    orElse: () {
      return Album(name: '', coverUrl: '', songs: []);
    },
  );
  return album.coverUrl.isNotEmpty ? album.coverUrl : 'assets/images/default_cover.png';
});

// Provider for a list of all songs
final songsProvider = FutureProvider<List<Song>>((ref) async {
  final apiService = ref.read(musicApiServiceProvider);
  return await apiService.fetchSongs();
});

// Provider for the current list of filtered songs (by search query, genre, etc.)
final filteredSongsProvider = StateProvider<List<Song>>((ref) {
  final songs = ref.watch(songsProvider);
  return songs.maybeWhen(
    data: (data) => data,
    orElse: () => [],
  );
});

// Provider for a list of all albums
final albumsProvider = FutureProvider<List<Album>>((ref) async {
  final apiService = ref.read(musicApiServiceProvider);
  return await apiService.fetchAlbums();
});

// Provider for a list of all artists
final artistsProvider = FutureProvider<List<Artist>>((ref) async {
  final apiService = ref.read(musicApiServiceProvider);
  return await apiService.fetchArtists();
});

// Add a case-insensitive album provider
final albumProvider = FutureProvider.family<Album?, String>((ref, albumName) async {
  final songs = await ref.watch(songsProvider.future);
  final matchingSongs = songs.where(
    (song) => song.album.toLowerCase() == albumName.toLowerCase()
  ).toList();
  
  if (matchingSongs.isEmpty) {
    return null;
  }
  
  final firstSong = matchingSongs.first;
  final coverUrl = await ref.watch(albumCoverUrlProvider(firstSong.album).future);
  
  return Album(
    name: firstSong.album, // Use the original case from the first song
    coverUrl: coverUrl,
    songs: matchingSongs,
  );
});

// Provider for a specific artist
final artistProvider = FutureProvider.family<Artist?, String>((ref, artistName) async {
  // Local artist data
  final artists = {
    'Satya Ananda': Artist(
      name: 'Satya Ananda',
      albums: [],
      songs: [],
      biography: 'Satya Ananda is a musician and software developer with a passion for creating meaningful experiences through code and music.',
      imagePath: 'assets/images/satya.png',
    ),
    'Gene Parade': Artist(
      name: 'Gene Parade',
      albums: [],
      songs: [],
      biography: 'Gene Parade is the solo project of Satya Ananda, exploring various musical genres and experimental soundscapes.',
      imagePath: 'assets/images/gene_parade.jpg',
    ),
  };

  return Future.value(artists[artistName]);
});

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for search results
final searchResultsProvider = Provider<List<Song>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final songs = ref.watch(songsProvider);
  
  if (searchQuery.isEmpty) {
    return songs.maybeWhen(
      data: (data) => data,
      orElse: () => [],
    );
  }
  
  return songs.maybeWhen(
    data: (data) => data.where((song) =>
      song.title.toLowerCase().contains(searchQuery) ||
      song.artist.toLowerCase().contains(searchQuery) ||
      song.album.toLowerCase().contains(searchQuery)
    ).toList(),
    orElse: () => [],
  );
});

// Provider for the most recently played songs
final recentlyPlayedProvider = StateProvider<List<Song>>((ref) => []);