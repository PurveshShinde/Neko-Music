import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  final yt = YoutubeExplode();
  try {
    final search = await yt.search.search('saheba');
    final video = search.first;
    print('Found video: ${video.title} (${video.id.value})');
    
    final related = await yt.videos.getRelatedVideos(video);
    if (related == null) {
      print('Related videos returned null.');
    } else {
      print('Found ${related.length} related videos:');
      for (var r in related.take(5)) {
        print('- ${r.title}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
  yt.close();
}
