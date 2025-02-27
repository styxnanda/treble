import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';
import '../providers/audio_provider.dart';

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
    
    final isPlaying = playbackState.maybeWhen(
      data: (state) => state.playing,
      orElse: () => false,
    );
    
    return ListTile(
      leading: _buildLeading(context, isCurrentSong, isPlaying),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isCurrentSong 
            ? TextStyle(color: Theme.of(context).colorScheme.primary)
            : null,
      ),
      subtitle: Text(
        '${song.artist} • ${song.album}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _buildTrailing(context, ref),
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          // Default behavior: play this song
          ref.read(playSongProvider(PlayRequest(song: song)));
        }
      },
    );
  }
  
  Widget _buildLeading(BuildContext context, bool isCurrentSong, bool isPlaying) {
    // Since we don't have coverUrl in the new model, we'll just use a music note icon
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Icon(
        Icons.music_note,
        color: isCurrentSong ? Theme.of(context).colorScheme.primary : Colors.white54,
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
                // Navigate to album screen
                Navigator.pushNamed(
                  context,
                  '/album',
                  arguments: song.album,
                );
                break;
                
              case 'view_artist':
                // Navigate to artist screen
                Navigator.pushNamed(
                  context,
                  '/artist',
                  arguments: song.artist,
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
    final remainingSeconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}