import 'package:flutter/material.dart';
import 'package:flutter_new_pipe_extractor/flutter_new_pipe_extractor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NewPipeExtractor.init(youtube: true);
  
  try {
    print('Testing musicAlbums...');
    final results = await NewPipeExtractor.search(
      'arijit singh',
      contentFilters: [SearchContentFilters.musicAlbums],
    );
    print('musicAlbums count: ${results.length}');
  } catch (e) {
    print('Albums Error: $e');
  }

  try {
    print('Testing playlists...');
    final results2 = await NewPipeExtractor.search(
      'arijit singh',
      contentFilters: [SearchContentFilters.playlists],
    );
    print('playlists count: ${results2.length}');
  } catch (e) {
    print('Playlists Error: $e');
  }
}
