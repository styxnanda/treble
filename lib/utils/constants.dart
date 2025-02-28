class AppConstants {
  // API configuration
  static const String apiBaseUrl = 'https://treble-api.vercel.app/api';
  
  // App theme
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  
  // Audio player settings
  static const int seekForwardSeconds = 10;
  static const int seekBackwardSeconds = 10;
  
  // Local storage keys
  static const String lastPlayedSongKey = 'last_played_song';
  static const String recentlyPlayedKey = 'recently_played';
  static const String playerPositionKey = 'player_position';
}