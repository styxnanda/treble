import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../models/song.dart';
import '../utils/constants.dart';

enum RepeatMode {
  off, 
  all, 
  one
}

class PlaybackState {
  final bool playing;
  final ProcessingState processingState;

  PlaybackState({
    required this.playing,
    required this.processingState,
  });
}

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
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
    // Set up playback event listener
    _audioPlayer.playbackEventStream.listen((event) async {
      _playbackStateController.add(PlaybackState(
        playing: _audioPlayer.playing,
        processingState: _audioPlayer.processingState,
      ));
      
      // Update position
      _positionController.add(_audioPlayer.position);
      
      // Detect buffering state
      final isBuffering = _audioPlayer.processingState == ProcessingState.buffering;
      _bufferingController.add(isBuffering);
      
      // Handle auto-advance and update current song
      if (_audioPlayer.processingState == ProcessingState.completed) {
        if (_audioPlayer.loopMode == LoopMode.one) {
          // For repeat one, just seek to beginning
          await _audioPlayer.seek(Duration.zero);
          await _audioPlayer.play();
        } else {
          // For normal playback or repeat all, go to next song
          if (_currentIndex < _playlist.length - 1 || _audioPlayer.loopMode == LoopMode.all) {
            await _audioPlayer.seekToNext();
            await _audioPlayer.play();
          }
        }
      }
    });

    // Keep track of current index changes
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index != _currentIndex) {
        _currentIndex = index;
        _currentSongController.add(currentSong);
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
        if (song.url != null) {
          audioSources.add(
            AudioSource.uri(
              Uri.parse(song.url!),
              tag: MediaItem(
                id: song.id.toString(),
                title: song.title,
                artist: song.artistName,
                album: song.albumName,
                duration: Duration(seconds: song.duration.toInt()),
              ),
            ),
          );
        }
      }
      
      if (audioSources.isNotEmpty) {
        await _audioPlayer.setAudioSource(
          ConcatenatingAudioSource(children: audioSources),
          preload: false,
          initialIndex: _currentIndex,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting audio source: $e');
      }
    }
  }

  // Play/pause controls
  Future<void> play() => _audioPlayer.play();
  Future<void> pause() => _audioPlayer.pause();
  Future<void> togglePlayPause() {
    if (_audioPlayer.playing) {
      return pause();
    } else {
      return play();
    }
  }

  // Seek controls
  Future<void> seek(Duration position) => _audioPlayer.seek(position);
  Future<void> seekForward() => seek(position + const Duration(seconds: 10));
  Future<void> seekBackward() => seek(position - const Duration(seconds: 10));

  // Skip controls
  Future<void> skipToNext() async {
    if (_currentIndex < _playlist.length - 1) {
      await skipToIndex(_currentIndex + 1);
    } else if (repeatMode == RepeatMode.all) {
      await skipToIndex(0);
    }
  }

  Future<void> skipToPrevious() async {
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
    
    // Ensure duration is updated when switching songs
    final duration = await _audioPlayer.duration;
    if (duration != null) {
      _durationController.add(duration);
    }
    
    if (_audioPlayer.playing) {
      await play();
    }
    
    _saveLastPlayedSong();
  }

  // Repeat mode control
  Future<void> toggleRepeatMode() async {
    switch (_audioPlayer.loopMode) {
      case LoopMode.off:
        await _audioPlayer.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await _audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
    _repeatModeController.add(repeatMode);
  }

  // Save/restore playback state
  Future<void> _savePosition(Duration position) async {
    if (currentSong == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastPosition', position.inSeconds);
      await prefs.setString('lastSongId', currentSong!.id.toString());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving position: $e');
      }
    }
  }

  Future<void> _saveLastPlayedSong() async {
    if (currentSong == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastSongId', currentSong!.id.toString());
      await prefs.setString('lastSongData', currentSong!.toJson().toString());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving last played song: $e');
      }
    }
  }

  Future<void> _restoreLastPlaybackState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPosition = prefs.getInt('lastPosition');
      final lastSongId = prefs.getString('lastSongId');
      final lastSongData = prefs.getString('lastSongData');
      
      if (lastSongId != null && lastSongData != null) {
        // TODO: Implement restoring last played song from ID
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring playback state: $e');
      }
    }
  }

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