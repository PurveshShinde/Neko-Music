import 'package:flutter/material.dart';
import 'package:slothify/services/plugin_manager_service.dart';
import 'package:hetu_script/hetu_script.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pm = PluginManagerService();
  await pm.init();
  final engine = pm.getMetadataEngine();
  if (engine != null) {
    try {
      final metadataPlugin = engine.fetch("metadataPlugin") as HTInstance;
      
      // Print all members of metadataPlugin
      print('--- Metadata Plugin ---');
      try {
        final search = metadataPlugin.memberGet("search");
        print('Search member exists! $search');
        
        final res = await (search as HTInstance).invoke("search", positionalArgs: ["arijit", "track"], namedArgs: {"limit": 5});
        print('Search result: $res');
      } catch (e) {
        print('Search check failed: $e');
      }
      
    } catch (e) {
      print('Error: $e');
    }
  }
}
