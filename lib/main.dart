import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'providers/audio_provider.dart';
import 'models/song.dart';
import 'providers/song_provider.dart';
import 'screens/player_screen.dart';
import 'widgets/audio_player_controls.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize just_audio_background for background playback
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.satyaananda.treble.channel.audio',
    androidNotificationChannelName: 'Treble Audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
    androidStopForegroundOnPause: true,
    notificationColor: Colors.deepPurple,
    fastForwardInterval: const Duration(seconds: 10),
    rewindInterval: const Duration(seconds: 10),
  );
  
  runApp(
    const ProviderScope(
      child: TrebleApp(),
    )
  );
}

class TrebleApp extends StatelessWidget {
  const TrebleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treble',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const TrebleScaffold(child: HomeScreen()),
    );
  }
}

class TrebleScaffold extends ConsumerWidget {
  final Widget child;

  const TrebleScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          currentSong.maybeWhen(
            data: (song) => song != null ? _buildMiniPlayer(context, ref, song) : const SizedBox(),
            orElse: () => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, WidgetRef ref, Song song) {
    final playbackState = ref.watch(playbackStateProvider);
    final audioService = ref.watch(audioServiceProvider);
    final albumCoverUrl = ref.watch(albumCoverUrlProvider(song.album));
    
    return GestureDetector(
      onTap: () => _openPlayerScreen(context),
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Album art with rounded corners
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: SizedBox(
                width: 60,
                height: 60,
                child: albumCoverUrl.when(
                  data: (url) => url.isEmpty
                    ? const Icon(Icons.music_note, color: Colors.white54)
                    : url.startsWith('http')
                      ? Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            Image.asset('assets/images/default_cover.png', fit: BoxFit.cover),
                        )
                      : Image.asset(url, fit: BoxFit.cover),
                  loading: () => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, __) => Image.asset(
                    'assets/images/default_cover.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
            
            // Player controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    audioService.skipToNext();
                  },
                ),
              ],
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