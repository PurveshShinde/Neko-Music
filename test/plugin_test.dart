import 'package:flutter_test/flutter_test.dart';
import 'package:neko/services/plugin_manager_service.dart';
import 'package:hetu_script/values.dart';
void main() {
  testWidgets('Test Spotube Plugin Search', (WidgetTester tester) async {
    final pm = PluginManagerService();
    await pm.init();
    final engine = pm.getMetadataEngine();
    if (engine == null) {
      print('Engine is null');
      return;
    }
    
    try {
      final metadataPlugin = engine.fetch("metadataPlugin") as HTInstance;
      final searchEndpoint = metadataPlugin.memberGet("search");
      print('Search member exists! $searchEndpoint');
      
      final res = await (searchEndpoint as HTInstance).invoke("search", positionalArgs: ["arijit", "track"]);
      print('Search result: $res');
    } catch (e) {
      print('Error: $e');
    }
  });
}
