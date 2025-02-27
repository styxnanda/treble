import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../models/song.dart';
import '../utils/constants.dart';
import 'music_api_service.dart';

enum RepeatMode {
  off, 
  all, 
  one
}

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final MusicApiService _apiService = MusicApiService();
  
  // Current playlist
  List<Song> _playlist = [];
  int _currentIndex = -1;
  
  // Stream controllers
  final _currentSongController = StreamController<Song?>.broadcast();
  final _playbackStateController = StreamController<PlaybackState>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _bufferingController = StreamController<bool>.broadcast();
  final _playlistController = StreamController<List<Song>>.broadcast();
  final _repeatModeController = StreamController<RepeatMode>.broadcast();
  
  // Public streams
  Stream<Song?> get currentSongStream => _currentSongController.stream;
  Stream<PlaybackState> get playbackStateStream => _playbackStateController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<bool> get bufferingStream => _bufferingController.stream;
  Stream<List<Song>> get playlistStream => _playlistController.stream;
  Stream<RepeatMode> get repeatModeStream => _repeatModeController.stream;
  
  // Current values
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _playlist.length 
      ? _playlist[_currentIndex] 
      : null;
  PlaybackState get playbackState => PlaybackState(
    playing: _audioPlayer.playing, 
    processingState: _audioPlayer.processingState
  );
  Duration? get duration => _audioPlayer.duration;
  Duration get position => _audioPlayer.position;
  bool get buffering => _audioPlayer.processingState == ProcessingState.buffering;
  List<Song> get playlist => List.unmodifiable(_playlist);
  RepeatMode get repeatMode {
    switch (_audioPlayer.loopMode) {
      case LoopMode.off: return RepeatMode.off;
      case LoopMode.all: return RepeatMode.all;
      case LoopMode.one: return RepeatMode.one;
    }
  }
  
  AudioService() {
    _init();
  }
  
  void _init() {
    // Set up listeners
    _audioPlayer.playbackEventStream.listen((event) {
      _playbackStateController.add(PlaybackState(
        playing: _audioPlayer.playing,
        processingState: _audioPlayer.processingState,
      ));
      
      // Update position
      _positionController.add(_audioPlayer.position);
      
      // Detect buffering state
      final isBuffering = _audioPlayer.processingState == ProcessingState.buffering;
      _bufferingController.add(isBuffering);
      
      // Handle auto-advance (for repeatMode.one)
      if (_audioPlayer.processingState == ProcessingState.completed &&
          _audioPlayer.loopMode != LoopMode.one) {
        skipToNext();
      }
    });

    // Set up position listener
    _audioPlayer.positionStream.listen((position) {
      _positionController.add(position);
      _savePosition(position);
    });

    // Set up duration listener
    _audioPlayer.durationStream.listen((duration) {
      _durationController.add(duration);
    });

    // Handle repeat mode changes
    _audioPlayer.loopModeStream.listen((_) {
      _repeatModeController.add(repeatMode);
    });
    
    // Restore last playback state
    _restoreLastPlaybackState();
  }

  // Load and prepare a playlist of songs
  Future<void> loadPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    if (songs.isEmpty) return;
    
    _playlist = List.from(songs);
    _playlistController.add(_playlist);
    _currentIndex = initialIndex.clamp(0, songs.length - 1); // Ensure valid index

    // Set up background audio handler with metadata
    await _setAudioSource();
    
    // Only try to skip if we have a valid playlist
    if (_playlist.isNotEmpty) {
      await skipToIndex(_currentIndex);
    }
  }

  // Set up the audio source from the current playlist
  Future<void> _setAudioSource() async {
    try {
      final audioSources = <AudioSource>[];
      
      for (var song in _playlist) {
        final streamUrl = await _apiService.getSongStreamUrl(song.path);
        if (streamUrl != null) {
          audioSources.add(
            AudioSource.uri(
              Uri.parse(streamUrl),
              tag: MediaItem(
                id: song.id,
                title: song.title,
                artist: song.artist,
                album: song.album,
                duration: Duration(seconds: song.duration.toInt()),
              ),
            ),
          );
        }
      }
      
      final audioSource = ConcatenatingAudioSource(children: audioSources);
      await _audioPlayer.setAudioSource(audioSource, initialIndex: _currentIndex);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting audio source: $e');
      }
    }
  }

  // Play the current song
  Future<void> play() async {
    await _audioPlayer.play();
    _saveLastPlayedSong();
  }

  // Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // Seek within the current song
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Skip to next song
  Future<void> skipToNext() async {
    if (_playlist.isEmpty) return;
    
    if (_currentIndex < _playlist.length - 1) {
      await skipToIndex(_currentIndex + 1);
    } else if (repeatMode == RepeatMode.all) {
      await skipToIndex(0);
    }
  }

  // Skip to previous song
  Future<void> skipToPrevious() async {
    if (_playlist.isEmpty) return;
    
    // If we're more than 3 seconds into the song, go back to the start
    if (_audioPlayer.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    
    if (_currentIndex > 0) {
      await skipToIndex(_currentIndex - 1);
    } else if (repeatMode == RepeatMode.all) {
      await skipToIndex(_playlist.length - 1);
    }
  }

  // Skip to specific song by index
  Future<void> skipToIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    
    _currentIndex = index;
    await _audioPlayer.seek(Duration.zero, index: index);
    _currentSongController.add(currentSong);
    
    if (_audioPlayer.playing) {
      await play();
    }
    
    _saveLastPlayedSong();
  }

  // Skip to specific song by id
  Future<void> skipToSong(String songId) async {
    final index = _playlist.indexWhere((song) => song.id == songId);
    if (index != -1) {
      await skipToIndex(index);
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await play();
    }
  }

  // Seek forward by specified seconds
  Future<void> seekForward() async {
    final position = _audioPlayer.position;
    final newPosition = position + Duration(seconds: AppConstants.seekForwardSeconds);
    
    // Make sure not to seek beyond duration
    if (_audioPlayer.duration != null && newPosition > _audioPlayer.duration!) {
      await seek(_audioPlayer.duration!);
    } else {
      await seek(newPosition);
    }
  }

  // Seek backward by specified seconds
  Future<void> seekBackward() async {
    final position = _audioPlayer.position;
    final newPosition = position - Duration(seconds: AppConstants.seekBackwardSeconds);
    
    // Make sure not to seek before the beginning
    if (newPosition.isNegative) {
      await seek(Duration.zero);
    } else {
      await seek(newPosition);
    }
  }

  // Set repeat mode
  Future<void> setRepeatMode(RepeatMode mode) async {
    LoopMode loopMode;
    
    switch (mode) {
      case RepeatMode.off:
        loopMode = LoopMode.off;
        break;
      case RepeatMode.all:
        loopMode = LoopMode.all;
        break;
      case RepeatMode.one:
        loopMode = LoopMode.one;
        break;
    }
    
    await _audioPlayer.setLoopMode(loopMode);
  }

  // Toggle through repeat modes
  Future<void> toggleRepeatMode() async {
    switch (repeatMode) {
      case RepeatMode.off:
        await setRepeatMode(RepeatMode.all);
        break;
      case RepeatMode.all:
        await setRepeatMode(RepeatMode.one);
        break;
      case RepeatMode.one:
        await setRepeatMode(RepeatMode.off);
        break;
    }
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // Save the last played song for restoration later
  Future<void> _saveLastPlayedSong() async {
    if (currentSong == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.lastPlayedSongKey, currentSong!.id);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving last played song: $e');
      }
    }
  }

  // Save current position
  Future<void> _savePosition(Duration position) async {
    if (currentSong == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${AppConstants.playerPositionKey}_${currentSong!.id}', 
          position.inMilliseconds);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving position: $e');
      }
    }
  }

  // Restore the last playback state
  Future<void> _restoreLastPlaybackState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSongId = prefs.getString(AppConstants.lastPlayedSongKey);
      
      if (lastSongId != null && _playlist.isNotEmpty) {
        final index = _playlist.indexWhere((song) => song.id == lastSongId);
        if (index != -1) {
          await skipToIndex(index);
          
          // Restore position
          final positionMs = prefs.getInt('${AppConstants.playerPositionKey}_$lastSongId');
          if (positionMs != null) {
            await seek(Duration(milliseconds: positionMs));
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring playback state: $e');
      }
    }
  }

  // Dispose resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _currentSongController.close();
    await _playbackStateController.close();
    await _durationController.close();
    await _positionController.close();
    await _bufferingController.close();
    await _playlistController.close();
    await _repeatModeController.close();
  }
}

class PlaybackState {
  final bool playing;
  final ProcessingState processingState;
  
  PlaybackState({
    required this.playing,
    required this.processingState,
  });
}