import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/artist.dart';
import '../providers/song_provider.dart';
import '../main.dart';

class ArtistScreen extends ConsumerWidget {
  final String artistName;

  const ArtistScreen({
    Key? key,
    required this.artistName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAsync = ref.watch(artistProvider(artistName));

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
                        artist.imagePath.isNotEmpty
                            ? Image.asset(
                                artist.imagePath,
                                fit: BoxFit.cover,
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
                          artist.biography.isNotEmpty
                              ? artist.biography
                              : 'No biography available.',
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