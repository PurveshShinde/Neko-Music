import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  final yt = YoutubeExplode();
  final results = await yt.search.search('similar to Faded Alan Walker');
  for (var r in results.take(5)) {
    print('- ${r.title} by ${r.author}');
  }
  yt.close();
}
