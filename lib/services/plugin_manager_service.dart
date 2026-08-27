import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:hetu_script/hetu_script.dart';
import 'package:hetu_spotube_plugin/hetu_spotube_plugin.dart' as spotube_plugin;
import '../app.dart';
import 'package:hetu_std/hetu_std.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive.dart';

class SharedPreferencesLocalStorage implements spotube_plugin.Localstorage {
  final SharedPreferences _prefs;
  final String pluginSlug;

  SharedPreferencesLocalStorage(this._prefs, this.pluginSlug);

  String prefix(String key) {
    return 'spotube_plugin.$pluginSlug.$key';
  }

  @override
  Future<void> clear() {
    return _prefs.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(prefix(key));
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(prefix(key));
  }

  @override
  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(prefix(key));
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(prefix(key));
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(prefix(key));
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(prefix(key));
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(prefix(key));
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(prefix(key), value);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(prefix(key), value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(prefix(key), value);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(prefix(key), value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(prefix(key), value);
  }
}

class PluginManagerService {
  final Map<String, Hetu> pluginEngines = {};
  bool isPluginActive = false;
  bool isBootstrapping = true;
  bool _isInitialized = false;
  
  final List<PluginConfig> installedPlugins = [];

  Future<void> init() async {
    _isInitialized = true;
  }

  Future<void> bootstrapPlugins() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final pluginDir = Directory('${dir.path}/plugins');
      if (await pluginDir.exists()) {
        final files = pluginDir.listSync();
        for (final file in files) {
          if (file is File && file.path.endsWith('.smplug')) {
            final bytes = await file.readAsBytes();
            await loadPluginFromSmplug(bytes, saveToDisk: false);
          }
        }
      }
    } catch (e) {
      debugPrint('Error bootstrapping plugins: $e');
    } finally {
      isBootstrapping = false;
    }
  }

  Future<String> resolvePluginUrl(String url) async {
    if (url.endsWith('.smplug')) return url;
    
    // Assume it's a Github repo URL
    try {
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
      
      final res = await http.get(apiUri);
      if (res.statusCode == 200) {
        final releases = jsonDecode(res.body) as List;
        if (releases.isNotEmpty) {
          final latestRelease = releases.first;
          final assets = latestRelease["assets"] as List;
          final smplugAsset = assets.firstWhere((asset) => (asset["name"] as String).endsWith(".smplug"), orElse: () => null);
          if (smplugAsset != null) {
            return smplugAsset["browser_download_url"];
          }
        }
      }
    } catch (e) {
      debugPrint('Error resolving plugin URL: $e');
    }
    return url;
  }

  Future<void> installFromUrl(String url) async {
    final resolvedUrl = await resolvePluginUrl(url);
    final response = await http.get(Uri.parse(resolvedUrl));
    if (response.statusCode == 200) {
      await loadPluginFromSmplug(response.bodyBytes);
    } else {
      throw Exception('Failed to download plugin: ${response.statusCode}');
    }
  }

  Future<void> loadPluginFromSmplug(Uint8List smplugBytes, {bool saveToDisk = true}) async {
    if (!_isInitialized) await init();
    
    // An .smplug file is just a zip archive
    final archive = ZipDecoder().decodeBytes(smplugBytes);
    
    // Find plugin.json to get entryPoint and metadata
    final pluginJsonFile = archive.findFile('plugin.json');
    if (pluginJsonFile == null) {
      throw Exception('Invalid .smplug file: plugin.json not found');
    }
    
    final pluginJsonStr = utf8.decode(pluginJsonFile.content as List<int>);
    final pluginJson = jsonDecode(pluginJsonStr) as Map<String, dynamic>;
    final entryPoint = pluginJson['entryPoint'] as String? ?? 'Plugin';
    
    final pluginId = pluginJson['name'].toString().toLowerCase().replaceAll(' ', '_');
    
    // Save to disk if requested
    if (saveToDisk) {
      try {
        final dir = await getApplicationSupportDirectory();
        final pluginDir = Directory('${dir.path}/plugins');
        if (!await pluginDir.exists()) {
          await pluginDir.create(recursive: true);
        }
        
        final file = File('${pluginDir.path}/$pluginId.smplug');
        await file.writeAsBytes(smplugBytes);
      } catch (e) {
        debugPrint('Error saving plugin: $e');
      }
    }
    
    // Find plugin.out inside the archive
    final pluginOutFile = archive.findFile('plugin.out');
    if (pluginOutFile == null) {
      throw Exception('Invalid .smplug file: plugin.out not found');
    }
    
    final bytecode = pluginOutFile.content as List<int>;
    
    // Create a new Hetu instance for this specific plugin
    final pluginHetu = Hetu();
    pluginHetu.init();
    await HetuStdLoader.loadBytecodeFlutter(pluginHetu);
    await spotube_plugin.HetuSpotubePluginLoader.loadBytecodeFlutter(pluginHetu);
    
    final prefs = await SharedPreferences.getInstance();
    HetuStdLoader.loadBindings(pluginHetu);
    spotube_plugin.HetuSpotubePluginLoader.loadBindings(
      pluginHetu,
      localStorageImpl: SharedPreferencesLocalStorage(prefs, 'neko_plugin_$pluginId'),
      onNavigatorPush: (route) {
        if (navigatorKey.currentState != null) {
          return navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Plugin Authentication')),
                body: route,
              ),
            ),
          );
        }
        return null;
      },
      onNavigatorPop: () {
        navigatorKey.currentState?.pop();
      },
      onShowForm: (title, fields) async => <Map<String, dynamic>>[],
      createYoutubeEngine: () => spotube_plugin.YouTubeEngine(
        search: (query) async => [],
        getVideo: (videoId) async => {},
        streamManifest: (videoId) async => [],
      ),
    );
    
    pluginHetu.loadBytecode(bytes: Uint8List.fromList(bytecode), moduleName: "plugin");
    pluginHetu.eval("""
      import "module:plugin" as plugin
      var Plugin = plugin.$entryPoint
      var metadataPlugin = Plugin()
    """);

    final config = PluginConfig.fromJson(pluginJson, pluginId);
    
    // Add or update in list and engine map
    installedPlugins.removeWhere((p) => p.id == pluginId);
    installedPlugins.add(config);
    pluginEngines[pluginId] = pluginHetu;

    isPluginActive = true;
  }
  
  Hetu? getMetadataEngine() {
    final metadataPlugin = installedPlugins.firstWhere(
      (p) => p.abilities.contains('metadata'), 
      orElse: () => installedPlugins.first
    );
    return pluginEngines[metadataPlugin.id];
  }

  Hetu? getAudioSourceEngine() {
    final audioPlugin = installedPlugins.firstWhere(
      (p) => p.abilities.contains('audioSource'),
      orElse: () => installedPlugins.first
    );
    return pluginEngines[audioPlugin.id];
  }
  
  Future<bool> isAuthenticated() async {
    final engine = getMetadataEngine();
    if (engine == null) return false;
    try {
      return engine.eval("metadataPlugin.auth.isAuthenticated()") as bool;
    } catch (_) {
      return false; // Plugin doesn't support auth or errored
    }
  }

  Future<void> authenticate() async {
    final engine = getMetadataEngine();
    if (engine == null) return;
    try {
      await engine.eval("metadataPlugin.auth.authenticate()");
    } catch (e) {
      debugPrint('Auth error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final engine = getMetadataEngine();
    if (engine == null) return;
    try {
      await engine.eval("metadataPlugin.auth.logout()");
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
  
  Future<void> deletePlugin(String pluginId) async {
    installedPlugins.removeWhere((p) => p.id == pluginId);
    pluginEngines.remove(pluginId);
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/plugins/$pluginId.smplug');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting plugin: $e');
    }
    if (installedPlugins.isEmpty) {
      isPluginActive = false;
    }
  }
}

class PluginConfig {
  final String id;
  final String name;
  final String description;
  final String author;
  final String version;
  final List<String> abilities;
  final String? repository;
  
  PluginConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.version,
    required this.abilities,
    this.repository,
  });

  factory PluginConfig.fromJson(Map<String, dynamic> json, String id) {
    return PluginConfig(
      id: id,
      name: json['name'] ?? 'Unknown Plugin',
      description: json['description'] ?? '',
      author: json['author'] ?? 'Unknown',
      version: json['version'] ?? '1.0.0',
      abilities: List<String>.from(json['abilities'] ?? []),
      repository: json['repository']?.toString(),
    );
  }
}
