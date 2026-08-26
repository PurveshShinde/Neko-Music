import 'package:http/http.dart' as http;

void main() async {
  try {
    final url = '/KRTirtho/spotube-plugin-youtube-audio';
    final response = await http.get(Uri.parse(url));
    print('Status: ${response.statusCode}');
    print('Length: ${response.bodyBytes.length}');
  } catch (e) {
    print('Error: $e');
  }
}
