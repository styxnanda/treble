import 'artist.dart';
import 'song.dart';

class Album {
  final String name;
  final String coverUrl;
  final List<Song> songs;

  Album({
    required this.name,
    required this.coverUrl,
    required this.songs,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      name: json['name'] ?? 'Unknown Album',
      coverUrl: json['coverUrl'] ?? '',
      songs: (json['songs'] as List<dynamic>?)
          ?.map((songJson) => Song.fromJson(songJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'coverUrl': coverUrl,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Album && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}