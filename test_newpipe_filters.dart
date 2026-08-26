import 'package:flutter/material.dart';
import 'package:flutter_new_pipe_extractor/flutter_new_pipe_extractor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('Testing NewPipe Search...');
    final results = await NewPipeExtractor.search(
      'khamishoiya',
      contentFilters: [SearchContentFilters.musicSongs],
    );
    print('musicSongs count: ${results.length}');
    
    final results2 = await NewPipeExtractor.search(
      'khamishoiya',
      contentFilters: [SearchContentFilters.musicVideos],
    );
    print('musicVideos count: ${results2.length}');

    final results3 = await NewPipeExtractor.search(
      'khamishoiya',
      contentFilters: [SearchContentFilters.videos],
    );
    print('videos count: ${results3.length}');
  } catch (e) {
    print('Error: $e');
  }
}
