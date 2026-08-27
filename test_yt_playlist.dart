import 'package:flutter/material.dart';
import 'lib/services/youtube_search_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final yt = YouTubeSearchService();
  final tracks = await yt.getPlaylistTracks('PL4fGSI1pI0ACuS7V0BwZkic8R-VjT-951');
  print('Fetched \${tracks.length} tracks!');
  for (var track in tracks.take(5)) {
    print('- \${track.title}');
  }
}
