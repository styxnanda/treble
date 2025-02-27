class AppConstants {
  // API configuration
  static const String apiBaseUrl = 'http://localhost:7000/api';
  
  // App theme
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  
  // Audio player settings
  static const int seekForwardSeconds = 15;
  static const int seekBackwardSeconds = 15;
  
  // Local storage keys
  static const String lastPlayedSongKey = 'last_played_song';
  static const String recentlyPlayedKey = 'recently_played';
  static const String playerPositionKey = 'player_position';
}