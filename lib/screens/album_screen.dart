import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/album.dart';
import '../models/song.dart';
import '../providers/song_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';

class AlbumScreen extends ConsumerWidget {
  final String albumName;

  const AlbumScreen({
    Key? key,
    required this.albumName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumAsync = ref.watch(albumProvider(albumName));

    return Scaffold(
      body: albumAsync.when(
        data: (album) {
          if (album == null) {
            return const Center(child: Text('Album not found'));
          }
          
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, ref, album),
              _buildSongsList(context, ref, album.songs),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading album: $error'),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, WidgetRef ref, Album album) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(album.name),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Album cover
            album.coverUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: album.coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.album, size: 80, color: Colors.white30),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.album, size: 80, color: Colors.white30),
                    ),
                  ),
                  
            // Gradient overlay for better text visibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black87,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.play_circle_filled),
          tooltip: 'Play album',
          onPressed: () {
            ref.read(playSongProvider(PlayRequest(
              albumName: albumName,
              autoPlay: true,
            )));
          },
        ),
        IconButton(
          icon: const Icon(Icons.shuffle),
          tooltip: 'Shuffle',
          onPressed: () {
            // Get the songs and shuffle them before playing
            final songs = album.songs;
            if (songs.isNotEmpty) {
              final shuffled = List<Song>.from(songs)..shuffle();
              ref.read(playSongProvider(PlayRequest(
                songs: shuffled,
                autoPlay: true,
              )));
            }
          },
        ),
      ],
    );
  }

  Widget _buildSongsList(BuildContext context, WidgetRef ref, List<Song> songs) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = songs[index];
          return SongTile(
            song: song,
            showTrackNumber: true,
            onTap: () {
              ref.read(playSongProvider(PlayRequest(
                song: song,
                songs: songs,
              )));
            },
          );
        },
        childCount: songs.length,
      ),
    );
  }
}