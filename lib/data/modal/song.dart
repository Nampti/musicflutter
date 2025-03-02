class Song {
  Song({
    required this.id,
    required this.title,
    required this.albums,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
  });

  factory Song.fromJson(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      albums: map['albums'] ?? '',
      artist: map['artist'] ?? '',
      source: map['source'] ?? '',
      image: map['image'] ?? '',
      duration: map['duration'] ?? 0,
    );
  }

  String id;
  String title;
  String albums;
  String artist;
  String source;
  String image;
  int duration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, title: $title, albums: $albums, artist: $artist, source: $source, image: $image, duration: $duration}';
  }
}