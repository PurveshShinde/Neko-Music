import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'dart:convert';

void main() async {
  try {
    final url = 'https://github.com/KRTirtho/spotube-plugin-youtube-audio';
    final parsedUri = Uri.parse(url);
    final apiUri = parsedUri.replace(
      host: "api.github.com",
      pathSegments: [
        "repos",
        ...parsedUri.pathSegments,
        "releases",
      ],
      queryParameters: {
        "per_page": "1",
        "page": "1",
      },
    );
    
    print('Fetching apiUri: $apiUri');
    final res = await http.get(apiUri);
    print('API status: ${res.statusCode}');
    final releases = jsonDecode(res.body) as List;
    final latestRelease = releases.first;
    final assets = latestRelease["assets"] as List;
    final smplugAsset = assets.firstWhere((asset) => (asset["name"] as String).endsWith(".smplug"), orElse: () => null);
    
    final downloadUrl = smplugAsset["browser_download_url"];
    print('Download URL: $downloadUrl');
    
    final response = await http.get(Uri.parse(downloadUrl));
    print('Zip status: ${response.statusCode}, bytes: ${response.bodyBytes.length}');
    
    final archive = ZipDecoder().decodeBytes(response.bodyBytes);
    final file = archive.findFile('plugin.out');
    print('plugin.out found: ${file != null}');
    
  } catch (e) {
    print('Error: $e');
  }
}
