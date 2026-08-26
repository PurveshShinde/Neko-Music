import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_new_pipe_extractor/flutter_new_pipe_extractor.dart';

void main() {
  testWidgets('Test NewPipe Music Songs', (WidgetTester tester) async {
    try {
      print('Testing NewPipe Search...');
      final results = await NewPipeExtractor.search(
        'khamoshiyan',
        contentFilters: [SearchContentFilters.musicSongs],
      );
      print('musicSongs count: ${results.length}');
      
      for (var item in results) {
        if (item is VideoSearchResultItem) {
          print('Song: ${item.name} | duration: ${item.duration} | url: ${item.url}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  });
}
