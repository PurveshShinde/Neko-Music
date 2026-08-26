class TrackModel {
  final String title;
  final String artist;
  final String albumArt; // emoji placeholder
  final int colorSeed;   // procedurally tint the UI
  final String? imageUrl; // realistic art
  final bool isExplicit;
  final String? duration;
  final int playCount;
  String? videoId; // Real YouTube ID for playback (mutable for JIT resolution)
  final String? spotifyId; // Spotify ID

  TrackModel({
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.colorSeed,
    this.imageUrl,
    this.isExplicit = false,
    this.duration,
    this.playCount = 1,
    this.videoId,
    this.spotifyId,
  });
}
