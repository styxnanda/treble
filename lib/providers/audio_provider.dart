import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';
import '../models/song.dart';
import 'song_provider.dart';

// Main audio service provider
final audioServiceProvider = Provider<AudioService>((ref) {
  final audioService = AudioService();
  ref.onDispose(() {
    audioService.dispose();
  });
  return audioService;
});

// Provider for the currently playing song
final currentSongProvider = StreamProvider<Song?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.currentSongStream;
});

// Provider for the current playback state
final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.playbackStateStream;
});

// Provider for the current audio duration
final durationProvider = StreamProvider<Duration?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.durationStream;
});

// Provider for the current playback position
final positionProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.positionStream;
});

// Provider for buffering state
final bufferingProvider = StreamProvider<bool>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.bufferingStream;
});

// Provider for the current playlist
final playlistProvider = StreamProvider<List<Song>>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.playlistStream;
});

// Provider for the current repeat mode
final repeatModeProvider = StreamProvider<RepeatMode>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.repeatModeStream;
});

// Provider function to load and play a song
final playSongProvider = Provider.family<Future<void>, PlayRequest>((ref, request) async {
  final audioService = ref.read(audioServiceProvider);
  final allSongsAsync = ref.read(songsProvider);
  
  // If we have a specific song to play
  if (request.song != null) {
    final songs = request.songs ?? [request.song!];
    final index = songs.indexOf(request.song!);
    
    await audioService.loadPlaylist(songs, initialIndex: index);
    if (request.autoPlay) {
      await audioService.play();
    }
    
    // Update recently played list
    final recentlyPlayed = ref.read(recentlyPlayedProvider.notifier);
    final currentList = ref.read(recentlyPlayedProvider);
    
    // Add the song at the beginning if not already there, or move it to the beginning
    final List<Song> updatedList = List.from(currentList);
    updatedList.removeWhere((s) => s.id == request.song!.id);
    updatedList.insert(0, request.song!);
    
    // Keep only the 20 most recent songs
    if (updatedList.length > 20) {
      updatedList.removeRange(20, updatedList.length);
    }
    
    recentlyPlayed.state = updatedList;
    return;
  }
  
  // If we have a list of songs but no specific song
  if (request.songs != null && request.songs!.isNotEmpty) {
    await audioService.loadPlaylist(request.songs!, initialIndex: request.initialIndex ?? 0);
    if (request.autoPlay) {
      await audioService.play();
    }
    return;
  }
  
  // If we have an album name
  if (request.albumName != null) {
    final albumAsync = ref.read(albumProvider(request.albumName!));
    
    return albumAsync.when(
      data: (album) async {
        if (album != null && album.songs.isNotEmpty) {
          await audioService.loadPlaylist(album.songs, initialIndex: request.initialIndex ?? 0);
          if (request.autoPlay) {
            await audioService.play();
          }
        }
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }
  
  // Fall back to playing all songs
  return allSongsAsync.when(
    data: (songs) async {
      if (songs.isNotEmpty) {
        await audioService.loadPlaylist(songs, initialIndex: request.initialIndex ?? 0);
        if (request.autoPlay) {
          await audioService.play();
        }
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Class to define a play request
class PlayRequest {
  final Song? song;
  final List<Song>? songs;
  final String? albumName;  // Changed from albumId to albumName
  final int? initialIndex;
  final bool autoPlay;
  
  PlayRequest({
    this.song,
    this.songs,
    this.albumName,  // Changed from albumId to albumName
    this.initialIndex,
    this.autoPlay = true,
  });
}