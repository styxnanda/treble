import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/artist.dart';
import '../providers/song_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/album_card.dart';
import 'album_screen.dart';
import '../main.dart';

class ArtistScreen extends ConsumerWidget {
  final int artistId;

  const ArtistScreen({
    Key? key,
    required this.artistId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAsync = ref.watch(artistProvider(artistId));

    return TrebleScaffold(
      child: Scaffold(
        body: artistAsync.when(
          data: (artist) {
            if (artist == null) {
              return const Center(child: Text('Artist not found'));
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(artist.name),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Artist image
                        artist.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: artist.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[900],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[900],
                                  child: const Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Colors.white30,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[900],
                                child: const Icon(
                                  Icons.person,
                                  size: 100,
                                  color: Colors.white30,
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
                ),
                // Biography section
                if (artist.biography != null) ...[
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Biography',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            artist.biography!,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                // Albums section
                if (artist.albums.isNotEmpty) ...[
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Albums',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: artist.albums.length,
                          itemBuilder: (context, index) {
                            final album = artist.albums[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: AlbumCard(
                                album: album,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AlbumScreen(albumId: album.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
                // Songs section
                if (artist.songs.isNotEmpty) ...[
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Songs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = artist.songs[index];
                        return SongTile(
                          song: song,
                          onTap: () {
                            ref.read(playSongProvider(PlayRequest(
                              song: song,
                              songs: artist.songs,
                            )));
                          },
                        );
                      },
                      childCount: artist.songs.length,
                    ),
                  ),
                ],
                // Add bottom padding
                const SliverPadding(padding: EdgeInsets.only(bottom: 32.0)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading artist: $error'),
          ),
        ),
      ),
    );
  }
}