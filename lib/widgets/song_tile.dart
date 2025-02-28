import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';
import '../providers/audio_provider.dart';
import '../providers/song_provider.dart';
import '../screens/album_screen.dart';
import '../screens/artist_screen.dart';

class SongTile extends ConsumerWidget {
  final Song song;
  final VoidCallback? onTap;
  final bool showTrackNumber;
  
  const SongTile({
    Key? key,
    required this.song,
    this.onTap,
    this.showTrackNumber = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final playbackState = ref.watch(playbackStateProvider);
    
    final isCurrentSong = currentSong.maybeWhen(
      data: (current) => current?.id == song.id,
      orElse: () => false,
    );
    
    return ListTile(
      onTap: onTap,
      selected: isCurrentSong,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      leading: _buildLeading(context, ref, isCurrentSong),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artistName} • ${song.albumName}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _buildTrailing(context, ref),
    );
  }
  
  Widget _buildLeading(BuildContext context, WidgetRef ref, bool isCurrentSong) {
    if (showTrackNumber) {
      return SizedBox(
        width: 32,
        child: Center(
          child: Text(
            song.trackNumber.toString(),
            style: TextStyle(
              color: isCurrentSong ? Theme.of(context).colorScheme.primary : Colors.white54,
            ),
          ),
        ),
      );
    }
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: ref.watch(albumCoverUrlProvider(song.albumId)).when(
          data: (url) => url.isEmpty
            ? Icon(
                Icons.music_note,
                color: isCurrentSong ? Theme.of(context).colorScheme.primary : Colors.white54,
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.music_note,
                  color: isCurrentSong ? Theme.of(context).colorScheme.primary : Colors.white54,
                ),
              ),
          loading: () => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => Icon(
            Icons.music_note,
            color: isCurrentSong ? Theme.of(context).colorScheme.primary : Colors.white54,
          ),
        ),
      ),
    );
  }
  
  Widget _buildTrailing(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Duration text
        Text(
          _formatDuration(song.duration),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        
        // Menu button
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            // Handle menu item selection
            switch (value) {
              case 'play':
                ref.read(playSongProvider(PlayRequest(song: song)));
                break;
                
              case 'view_album':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlbumScreen(albumId: song.albumId),
                  ),
                );
                break;
                
              case 'view_artist':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArtistScreen(artistId: song.artistId),
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'play',
              child: ListTile(
                leading: Icon(Icons.play_arrow),
                title: Text('Play'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'view_album',
              child: ListTile(
                leading: Icon(Icons.album),
                title: Text('View album'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'view_artist',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('View artist'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.round());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds - minutes * 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}