import 'song.dart';

class Artist {
  final String name;
  final List<String> albums;
  final List<Song> songs;

  Artist({
    required this.name,
    required this.albums,
    required this.songs,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name'] ?? 'Unknown Artist',
      albums: (json['albums'] as List<dynamic>?)?.cast<String>() ?? [],
      songs: (json['songs'] as List<dynamic>?)
          ?.map((songJson) => Song.fromJson(songJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'albums': albums,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Artist && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}