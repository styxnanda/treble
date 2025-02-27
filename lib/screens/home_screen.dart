import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';
import '../providers/song_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/album_card.dart';
import 'album_screen.dart';
import 'player_screen.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(songsProvider);
    final albums = ref.watch(albumsProvider);
    final currentSong = ref.watch(currentSongProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treble'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(songsProvider);
          ref.refresh(albumsProvider);
        },
        child: ListView(
          children: [
            // Albums section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Albums',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(
              height: 250,
              child: albums.when(
                data: (albumsList) => albumsList.isEmpty
                    ? const Center(child: Text('No albums found'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: albumsList.length,
                        itemBuilder: (context, index) {
                          final album = albumsList[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: AlbumCard(
                              album: album,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AlbumScreen(albumName: album.name),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading albums: $error'),
                ),
              ),
            ),
            
            // Songs section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Songs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            songs.when(
              data: (songsList) => songsList.isEmpty
                  ? const Center(child: Text('No songs found'))
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: songsList.length,
                      itemBuilder: (context, index) {
                        final song = songsList[index];
                        return SongTile(
                          song: song,
                          onTap: () {
                            ref.read(playSongProvider(
                              PlayRequest(
                                song: song,
                                songs: songsList,
                              ),
                            ));
                            _openPlayerScreen(context);
                          },
                        );
                      },
                    ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Text('Error loading songs: $error'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: currentSong.maybeWhen(
        data: (song) => song != null ? _buildMiniPlayer(context, ref, song) : null,
        orElse: () => null,
      ),
    );
  }
  
  Widget _buildMiniPlayer(BuildContext context, WidgetRef ref, Song song) {
    final playbackState = ref.watch(playbackStateProvider);
    final audioService = ref.watch(audioServiceProvider);
    
    return GestureDetector(
      onTap: () => _openPlayerScreen(context),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Music note icon since we don't have album art
            Container(
              width: 60,
              height: 60,
              color: Colors.grey[800],
              child: const Icon(Icons.music_note, color: Colors.white54),
            ),
              
            // Song info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${song.artist} • ${song.album}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Play/pause button
            playbackState.when(
              data: (state) => IconButton(
                icon: Icon(
                  state.playing ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  audioService.togglePlayPause();
                },
              ),
              loading: () => const SizedBox(
                width: 48,
                height: 48,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  audioService.play();
                },
              ),
            ),
            
            // Next button
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () {
                audioService.skipToNext();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _openPlayerScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PlayerScreen(),
      ),
    );
  }
}