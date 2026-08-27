import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_new_pipe_extractor/flutter_new_pipe_extractor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize media_kit — required before using the Player
  MediaKit.ensureInitialized();
  
  // Initialize NewPipe Extractor (fixes NullPointerException: downloader is null)
  await NewPipeExtractor.init();

  // Enable edge-to-edge UI for Android
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(NekoApp(prefs: prefs));
}
