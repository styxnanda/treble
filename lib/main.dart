import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

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
    fastForwardInterval: const Duration(seconds: 15),
    rewindInterval: const Duration(seconds: 15),
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
      home: const HomeScreen(),
    );
  }
}