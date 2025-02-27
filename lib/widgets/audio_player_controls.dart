import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../providers/audio_provider.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';

class AudioPlayerControls extends ConsumerWidget {
  final bool showFullControls;

  const AudioPlayerControls({
    super.key,
    this.showFullControls = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);
    final currentSong = ref.watch(currentSongProvider);
    final playbackState = ref.watch(playbackStateProvider);
    final duration = ref.watch(durationProvider);
    final position = ref.watch(positionProvider);
    final buffering = ref.watch(bufferingProvider);
    final repeatMode = ref.watch(repeatModeProvider);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          child: position.when(
            data: (pos) => duration.when(
              data: (dur) => ProgressBar(
                progress: pos,
                total: dur ?? Duration.zero,
                buffered: buffering.maybeWhen(
                  data: (isBuffering) => isBuffering ? Duration.zero : dur ?? Duration.zero,
                  orElse: () => dur ?? Duration.zero,
                ),
                onSeek: (duration) {
                  audioService.seek(duration);
                },
                thumbRadius: 8.0,
                timeLabelTextStyle: Theme.of(context).textTheme.bodySmall,
                timeLabelPadding: 8.0,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
        ),

        const SizedBox(height: 16),
        
        // Play controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showFullControls) ...[
              // Skip previous button
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded),
                iconSize: 40.0,
                onPressed: () {
                  audioService.skipToPrevious();
                },
              ),
              
              // Rewind button
              IconButton(
                icon: const Icon(Icons.replay_10_rounded),
                iconSize: 40.0,
                onPressed: () {
                  audioService.seekBackward();
                },
              ),
            ],
            
            // Play/pause button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: playbackState.when(
                data: (state) {
                  final isPlaying = state.playing;
                  final isBuffering = state.processingState == ProcessingState.buffering;
                  
                  if (isBuffering) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  }
                  
                  return IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    iconSize: showFullControls ? 56.0 : 40.0,
                    onPressed: () {
                      audioService.togglePlayPause();
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                error: (_, __) => IconButton(
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  iconSize: showFullControls ? 56.0 : 40.0,
                  onPressed: () {
                    audioService.togglePlayPause();
                  },
                ),
              ),
            ),
            
            if (showFullControls) ...[
              // Fast forward button
              IconButton(
                icon: const Icon(Icons.forward_10_rounded),
                iconSize: 40.0,
                onPressed: () {
                  audioService.seekForward();
                },
              ),
              
              // Skip next button
              IconButton(
                icon: const Icon(Icons.skip_next_rounded),
                iconSize: 40.0,
                onPressed: () {
                  audioService.skipToNext();
                },
              ),
            ],
          ],
        ),
        
        if (showFullControls) ...[
          const SizedBox(height: 16),
          
          // Repeat mode button
          repeatMode.when(
            data: (mode) => IconButton(
              icon: Icon(
                mode == RepeatMode.one
                    ? Icons.repeat_one_rounded
                    : mode == RepeatMode.all
                        ? Icons.repeat_rounded
                        : Icons.repeat_rounded,
                color: mode == RepeatMode.off
                    ? Theme.of(context).iconTheme.color?.withOpacity(0.5)
                    : Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                audioService.toggleRepeatMode();
              },
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ],
    );
  }
}