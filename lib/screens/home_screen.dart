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
          await ref.refresh(songsProvider.future);
          await ref.refresh(albumsProvider.future);
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
    );
  }
}