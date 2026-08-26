import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../state/app_state.dart';
import '../theme/slothify_theme.dart';

class PluginsScreen extends StatefulWidget {
  const PluginsScreen({super.key});

  @override
  State<PluginsScreen> createState() => _PluginsScreenState();
}

class _PluginsScreenState extends State<PluginsScreen> {
  final TextEditingController _urlController = TextEditingController(
      text: 'https://github.com/KRTirtho/spotube-plugin-youtube-audio');
  
  bool _isLoading = false;
  String? _statusMessage;

  Future<String> _resolveUrl(String url) async {
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
      // ignore and fallback
    }
    return url;
  }

  Future<void> _loadPlugin() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Resolving URL...';
    });

    try {
      final state = AppStateProvider.of(context);
      final resolvedUrl = await _resolveUrl(_urlController.text);
      
      setState(() => _statusMessage = 'Downloading plugin from resolved URL...');
      final response = await http.get(Uri.parse(resolvedUrl));
      if (response.statusCode == 200) {
        setState(() => _statusMessage = 'Extracting and Loading bytecode...');
        await state.pluginManager.loadPluginFromSmplug(response.bodyBytes);
        state.notifyPluginLoaded();
        
        setState(() => _statusMessage = 'Plugin loaded successfully!');
      } else {
        setState(() => _statusMessage = 'Failed to download plugin: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final installedPlugins = state.pluginManager.installedPlugins;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: SlothifyColors.background,
        appBar: AppBar(
          title: const Text('Plugins', style: TextStyle(color: Colors.white, fontSize: 20)),
          backgroundColor: SlothifyColors.surface,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Metadata'),
              Tab(text: 'Audio Source'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // URL input field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Paste download url or GitHub/',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.download, color: Colors.white),
                      onPressed: _isLoading ? null : _loadPlugin,
                    ),
                  ),
                ],
              ),
              
              if (_statusMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.contains('Error') || _statusMessage!.contains('Failed') 
                        ? Colors.red 
                        : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              const Text(
                'Installed',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.white24, height: 24),
              
              Expanded(
                child: installedPlugins.isEmpty
                    ? Center(
                        child: Text(
                          'No plugins installed',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: installedPlugins.length,
                        itemBuilder: (context, index) {
                          final plugin = installedPlugins[index];
                          return _buildPluginCard(plugin, state);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPluginCard(dynamic plugin, dynamic state) {
    // Temporary hardcoded logic to determine icon and color based on plugin name
    final isYouTube = plugin.name.toLowerCase().contains('youtube');
    final isSpotify = plugin.name.toLowerCase().contains('spotify');
    
    final iconColor = isYouTube ? Colors.red : (isSpotify ? Colors.green : Colors.blue);
    final iconData = isYouTube ? Icons.play_arrow : (isSpotify ? Icons.music_note : Icons.extension);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: Colors.white),
              ),
              const SizedBox(width: 12),
              
              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plugin.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plugin.description,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    
                    // Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (plugin.abilities.contains('audioSource'))
                          _buildChip(Icons.music_note, 'Audio Source', Colors.white),
                        if (plugin.abilities.contains('metadata'))
                          _buildChip(Icons.library_music, 'Metadata', Colors.white),
                          
                        _buildChip(Icons.verified, plugin.author == 'KRTirtho' ? 'Official' : 'Third-party', 
                            plugin.author == 'KRTirtho' ? Colors.white : Colors.blue),
                        
                        if (plugin.repository != null)
                          _buildChip(Icons.link, 'github.com', Colors.white),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    Text(
                      'Author: ${plugin.author}',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                    Text(
                      'Version: ${plugin.version}',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  await state.pluginManager.deletePlugin(plugin.id);
                  setState(() {});
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bottom Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (plugin.abilities.contains('audioSource'))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Default audio source', style: TextStyle(color: Colors.white, fontSize: 12)),
                )
              else if (plugin.abilities.contains('metadata'))
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SlothifyColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.login, size: 16),
                  label: const Text('Connect to Spotify'),
                  onPressed: () async {
                    try {
                      await state.pluginManager.authenticate();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authentication successful! Please restart or refresh the home page.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Auth failed: $e')),
                      );
                    }
                  },
                )
              else
                const SizedBox.shrink(),
                
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.favorite, size: 16),
                label: const Text('Support'),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
