import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../services/music_api_service.dart';

// Provider for the MusicApiService
final musicApiServiceProvider = Provider<MusicApiService>((ref) {
  return MusicApiService();
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

// Provider for a specific album by name
final albumProvider = FutureProvider.family<Album?, String>((ref, albumName) async {
  final apiService = ref.read(musicApiServiceProvider);
  return await apiService.fetchAlbumDetails(albumName);
});

// Provider for a specific artist
final artistProvider = FutureProvider.family<Artist?, String>((ref, artistName) async {
  final apiService = ref.read(musicApiServiceProvider);
  return await apiService.fetchArtistDetails(artistName);
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