import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

void main() async {
  try {
    final url = 'https://github.com/sonic-liberation/spotube-plugin-spotify/releases/download/0.2.2/plugin.smplug';
    final response = await http.get(Uri.parse(url));
    print('Status: ${response.statusCode}');
    print('Content-Length: ${response.bodyBytes.length}');
    
    final archive = ZipDecoder().decodeBytes(response.bodyBytes);
    print('Files in zip: ${archive.length}');
    for (var file in archive) {
      print(' - ${file.name}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
