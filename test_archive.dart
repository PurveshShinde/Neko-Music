import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

void main() async {
  try {
    final url = 'https://github.com/sonic-liberation/spotube-plugin-spotify/releases/download/0.2.2/plugin.smplug';
    final response = await http.get(Uri.parse(url));
    final archive = ZipDecoder().decodeBytes(response.bodyBytes);
    
    final file = archive.findFile('plugin.out');
    print('findFile result: ${file?.name}');
  } catch (e) {
    print('Error: $e');
  }
}
