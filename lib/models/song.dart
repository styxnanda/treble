class Song {
  final int id;
  final String title;
  final int artistId;
  final String artistName;
  final int albumId;
  final String albumName;
  final double duration;
  final int trackNumber;
  final String? url;

  Song({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.albumId,
    required this.albumName,
    required this.duration,
    required this.trackNumber,
    this.url,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      artistId: json['artistId'] as int? ?? 0,
      artistName: json['artistName'] as String? ?? '',
      albumId: json['albumId'] as int? ?? 0,
      albumName: json['albumName'] as String? ?? '',
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      trackNumber: json['trackNumber'] as int? ?? 0,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artistId': artistId,
      'artistName': artistName,
      'albumId': albumId,
      'albumName': albumName,
      'duration': duration,
      'trackNumber': trackNumber,
      if (url != null) 'url': url,
    };
  }

  @override
  String toString() => '$title by $artistName from $albumName';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Song && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}