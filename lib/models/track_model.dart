class TrackModel {
  final String title;
  final String artist;
  final String albumArt; // emoji placeholder
  final int colorSeed;   // procedurally tint the UI
  final String? imageUrl; // realistic art
  final bool isExplicit;
  String? duration;
  final int playCount;
  String? videoId; // Real YouTube ID for playback (mutable for JIT resolution)
  final String? spotifyId; // Spotify ID

  String get id => videoId ?? spotifyId ?? '${title}_$artist';

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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'colorSeed': colorSeed,
      'imageUrl': imageUrl,
      'isExplicit': isExplicit,
      'duration': duration,
      'playCount': playCount,
      'videoId': videoId,
      'spotifyId': spotifyId,
    };
  }

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      title: json['title'] as String,
      artist: json['artist'] as String,
      albumArt: json['albumArt'] as String,
      colorSeed: json['colorSeed'] as int,
      imageUrl: json['imageUrl'] as String?,
      isExplicit: json['isExplicit'] as bool? ?? false,
      duration: json['duration'] as String?,
      playCount: json['playCount'] as int? ?? 1,
      videoId: json['videoId'] as String?,
      spotifyId: json['spotifyId'] as String?,
    );
  }
}
