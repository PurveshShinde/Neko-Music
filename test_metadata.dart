import 'package:flutter/material.dart';
import 'package:slothify/services/plugin_manager_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final manager = PluginManagerService();
  await manager.bootstrapPlugins();
  
  final engine = manager.getMetadataEngine();
  if (engine != null) {
    try {
      final raw = await engine.invoke('metadataPlugin.browse.sections', namedArgs: {'limit': 10, 'offset': 0});
      print('Sections: $raw');
      print('Type: ${raw.runtimeType}');
    } catch (e) {
      print('Error: $e');
    }
  } else {
    print('No metadata engine found');
  }
}
