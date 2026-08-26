class PlaylistModel {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final int colorSeed;
  final String? query;
  final String? spotifyId;

  const PlaylistModel({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.colorSeed,
    this.query,
    this.spotifyId,
  });
}
