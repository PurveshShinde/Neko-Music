import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track_model.dart';
import '../models/playlist_model.dart';
import 'youtube_search_service.dart';

class RecommendationEngine {
  final SharedPreferences prefs;
  final YouTubeSearchService ytService;
  final Random _random = Random();

  RecommendationEngine(this.prefs, this.ytService);

  /// Fetch exactly 10 dynamic sections (or more) for the Home screen
  Future<List<Map<String, dynamic>>> getPersonalizedSections(List<TrackModel> recentTracks) async {
    final searchHistory = prefs.getStringList('search_history') ?? [];
    
    // Extract key entities to base recommendations on
    final List<String> recentArtists = recentTracks
        .map((t) => t.artist)
        .where((a) => a.isNotEmpty && a.toLowerCase() != 'unknown artist')
        .toSet()
        .toList();
        
    final List<String> recentSongTitles = recentTracks
        .map((t) => t.title.replaceAll(RegExp(r'\[.*?\]|\(.*?\)|official|video|audio|lyric|lyrics', caseSensitive: false), '').trim())
        .where((t) => t.isNotEmpty)
        .toList();

    List<Map<String, dynamic>> sections = [];
    List<Future<Map<String, dynamic>?>> sectionFutures = [];

    // Fallback/Generic queries if history is too small
    final defaultQueries = ['Viral 50', 'Global Hits', 'Lofi Study', 'Workout Pop', 'Acoustic Chill'];

    // 1. Because you listened to [Random Artist]
    if (recentArtists.isNotEmpty) {
      final artist = recentArtists[_random.nextInt(recentArtists.length)];
      sectionFutures.add(_fetchSection('Because you listened to $artist', '$artist mix', 'playlists'));
    }

    // 2. Based on your search for [Random Search]
    if (searchHistory.isNotEmpty) {
      final search = searchHistory[_random.nextInt(searchHistory.length)];
      sectionFutures.add(_fetchSection('Based on your search for "$search"', '$search playlist', 'playlists'));
    }

    // 3. Jump Back In (Top Mixes from recently played)
    if (recentSongTitles.isNotEmpty) {
      final song = recentSongTitles[_random.nextInt(recentSongTitles.length)];
      sectionFutures.add(_fetchSection('Jump back in', '$song mix', 'playlists'));
    } else {
      sectionFutures.add(_fetchSection('Jump back in', 'Today\'s Top Hits', 'playlists'));
    }

    // 4. More of [Another Random Artist]
    if (recentArtists.length > 1) {
      final artist2 = recentArtists.firstWhere((a) => !sections.any((s) => s['title'].toString().contains(a)), orElse: () => recentArtists.last);
      sectionFutures.add(_fetchSection('More of $artist2', '$artist2 essentials', 'playlists'));
    }

    // 5. Trending Now (Generic)
    sectionFutures.add(_fetchSection('Trending Now', 'Trending music playlists', 'playlists'));

    // 6. Discover something new (Random from defaults)
    final generic1 = defaultQueries[_random.nextInt(defaultQueries.length)];
    sectionFutures.add(_fetchSection('Discover something new', generic1, 'playlists'));

    // 7. Artists you might like (Similar to a recent artist)
    if (recentArtists.isNotEmpty) {
      final artist = recentArtists[_random.nextInt(recentArtists.length)];
      sectionFutures.add(_fetchSection('Similar to $artist', '$artist similar artists', 'playlists'));
    }

    // 8. Focus / Chill (Contextual generic)
    sectionFutures.add(_fetchSection('Focus & Chill', 'lofi study beats', 'playlists'));

    // 9. New Releases (Generic)
    sectionFutures.add(_fetchSection('New Releases', 'new music releases 2024', 'playlists'));

    // 10. Ultimate Throwbacks
    sectionFutures.add(_fetchSection('Ultimate Throwbacks', 'throwback hits', 'playlists'));

    // Await all concurrently
    final results = await Future.wait(sectionFutures);
    for (var result in results) {
      if (result != null && (result['items'] as List).isNotEmpty) {
        sections.add(result);
      }
    }

    return sections;
  }

  Future<Map<String, dynamic>?> _fetchSection(String title, String query, String category) async {
    try {
      final items = await ytService.searchCategorized(query, category);
      if (items.isNotEmpty) {
        return {
          'title': title,
          'items': items.whereType<PlaylistModel>().take(8).toList(),
        };
      }
    } catch (_) {}
    return null;
  }

  /// Get Personalized Track Carousel (for the Hero section)
  Future<List<TrackModel>> getHeroTracks(List<TrackModel> recentTracks) async {
    final searchHistory = prefs.getStringList('search_history') ?? [];
    String query = 'new pop music 2024';

    if (recentTracks.isNotEmpty) {
      query = '${recentTracks.first.artist} top songs';
    } else if (searchHistory.isNotEmpty) {
      query = '${searchHistory.first} songs';
    }

    try {
      final items = await ytService.searchTracks(query);
      return items.take(10).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get Personalized Recommendations (Grid section)
  Future<List<TrackModel>> getRecommendedTracks(List<TrackModel> recentTracks) async {
    final searchHistory = prefs.getStringList('search_history') ?? [];
    String query = 'trending hits';

    if (recentTracks.length > 1) {
      // Pick a random recent track that isn't the absolute first one to add variety
      final track = recentTracks[1]; 
      query = '${track.title} ${track.artist} similar songs';
    } else if (searchHistory.length > 1) {
      query = '${searchHistory[1]} hits';
    }

    try {
      final items = await ytService.searchTracks(query);
      return items.take(8).toList();
    } catch (_) {
      return [];
    }
  }
}
