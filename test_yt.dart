import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  final yt = YoutubeExplode();
  try {
    print('Getting playlist PLFgquLnL59amQZ5o2e01qJjFf5r8d-o5L');
    final playlist = await yt.playlists.get('PLFgquLnL59amQZ5o2e01qJjFf5r8d-o5L');
    print(playlist.title);
    final videos = await yt.playlists.getVideos(playlist.id).take(5).toList();
    print('Got ${videos.length} videos');
    for (var v in videos) {
      print(v.title);
    }
  } catch (e, st) {
    print(e);
    print(st);
  } finally {
    yt.close();
  }
}
