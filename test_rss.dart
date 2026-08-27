import 'package:http/http.dart' as http;
void main() async {
  final res = await http.get(Uri.parse('https://www.youtube.com/feeds/videos.xml?playlist_id=PLFgquLnL59amQZ5o2e01qJjFf5r8d-o5L'));
  print(res.statusCode);
  print(res.body.substring(0, 200));
}
