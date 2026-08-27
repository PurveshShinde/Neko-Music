class PlaylistModel {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final int colorSeed;
  final String? query;
  final String? spotifyId;
  final bool isAlbum;

  const PlaylistModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.colorSeed,
    this.query,
    this.spotifyId,
    this.isAlbum = false,
  });

  PlaylistModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    int? colorSeed,
    String? query,
    String? spotifyId,
    bool? isAlbum,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      colorSeed: colorSeed ?? this.colorSeed,
      query: query ?? this.query,
      spotifyId: spotifyId ?? this.spotifyId,
      isAlbum: isAlbum ?? this.isAlbum,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'colorSeed': colorSeed,
      'query': query,
      'spotifyId': spotifyId,
      'isAlbum': isAlbum,
    };
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['imageUrl'] as String?,
      colorSeed: json['colorSeed'] as int,
      query: json['query'] as String?,
      spotifyId: json['spotifyId'] as String?,
      isAlbum: json['isAlbum'] as bool? ?? false,
    );
  }
}
