import 'song.dart';
import 'artist.dart';

class Album {
  final int id;
  final String name;
  final String coverUrl;
  final List<Song> songs;
  final List<Artist> artists;

  Album({
    required this.id,
    required this.name,
    required this.coverUrl,
    this.songs = const [],
    this.artists = const [],
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      songs: (json['songs'] as List<dynamic>?)
          ?.map((songJson) => Song.fromJson(songJson as Map<String, dynamic>))
          .toList() ?? [],
      artists: (json['artists'] as List<dynamic>?)
          ?.map((artistJson) => Artist.fromJson(artistJson as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverUrl': coverUrl,
      'songs': songs.map((song) => song.toJson()).toList(),
      'artists': artists.map((artist) => artist.toJson()).toList(),
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Album && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}