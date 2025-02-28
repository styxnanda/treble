import 'song.dart';
import 'album.dart';

class Artist {
  final int id;
  final String name;
  final String imageUrl;
  final String? biography;
  final List<Album> albums;
  final List<Song> songs;

  Artist({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.biography,
    this.albums = const [],
    this.songs = const [],
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      biography: json['biography'] as String?,
      albums: (json['albums'] as List<dynamic>?)
          ?.map((albumJson) => Album.fromJson(albumJson as Map<String, dynamic>))
          .toList() ?? [],
      songs: (json['songs'] as List<dynamic>?)
          ?.map((songJson) => Song.fromJson(songJson as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      if (biography != null) 'biography': biography,
      'albums': albums.map((album) => album.toJson()).toList(),
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Artist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}