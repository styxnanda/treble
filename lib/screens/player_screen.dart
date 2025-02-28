import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/audio_provider.dart';
import '../providers/song_provider.dart';
import '../widgets/audio_player_controls.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Now Playing'),
        centerTitle: true,
      ),
      body: currentSong.when(
        data: (song) {
          if (song == null) {
            return const Center(child: Text('No song is currently playing'));
          }
          
          return Column(
            children: [
              // Expanded album art and song info
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Album art container
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 400, // Maximum width for desktop screens
                          maxHeight: 400, // Maximum height to match width
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            color: Colors.grey[800],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ref.watch(albumCoverUrlProvider(song.albumId)).when(
                            data: (url) => url.isEmpty
                              ? const Icon(Icons.music_note, size: 80, color: Colors.white54)
                              : Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.music_note, size: 80, color: Colors.white54),
                                ),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const Icon(Icons.music_note, size: 80, color: Colors.white54),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Song info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            // Song title
                            Text(
                              song.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Artist name
                            Text(
                              song.artistName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[400],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Album name
                            Text(
                              song.albumName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Player controls
              Container(
                padding: const EdgeInsets.only(bottom: 40, top: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
                child: const AudioPlayerControls(showFullControls: true),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading current song: $error'),
        ),
      ),
    );
  }
}