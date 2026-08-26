import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_new_pipe_extractor/flutter_new_pipe_extractor.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize media_kit — required before using the Player
  MediaKit.ensureInitialized();
  
  // Initialize NewPipe Extractor (fixes NullPointerException: downloader is null)
  await NewPipeExtractor.init();
  
  runApp(const SlothifyApp());
}
