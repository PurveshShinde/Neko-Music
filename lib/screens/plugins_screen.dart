import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/neko_theme.dart';

class PluginsScreen extends StatefulWidget {
  const PluginsScreen({super.key});

  @override
  State<PluginsScreen> createState() => _PluginsScreenState();
}

class _PluginsScreenState extends State<PluginsScreen> {
  final TextEditingController _urlController = TextEditingController(text: '');
  
  bool _isLoading = false;
  String? _statusMessage;



  Future<void> _loadPlugin() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Resolving URL...';
    });

    try {
      final state = AppStateProvider.of(context);
      
      setState(() => _statusMessage = 'Downloading and installing plugin...');
      await state.pluginManager.installFromUrl(_urlController.text);
      state.notifyPluginLoaded();
      
      setState(() => _statusMessage = 'Plugin loaded successfully!');
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

        appBar: AppBar(
          title: Text('Plugins', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20)),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
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
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Paste download url or GitHub/',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: _isLoading
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface, strokeWidth: 2))
                          : Icon(Icons.download, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: _isLoading ? null : _loadPlugin,
                    ),
                  ),
                ],
              ),
              
              if (_statusMessage != null) ...[
                SizedBox(height: 8),
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
              
              SizedBox(height: 24),
              Text(
                'Installed',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24), height: 24),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (installedPlugins.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              'No plugins installed',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                            ),
                          ),
                        )
                      else
                        ...installedPlugins.map((plugin) => _buildPluginCard(plugin, state)),
                        
                      const SizedBox(height: 32),
                      Text(
                        'Not Installed',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24), height: 24),
                      
                      _buildRecommendedPluginCard(context, state),
                      const SizedBox(height: 32),
                    ],
                  ),
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
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
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
                child: Icon(iconData, color: Theme.of(context).colorScheme.onSurface),
              ),
              SizedBox(width: 12),
              
              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plugin.name,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      plugin.description,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    
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
                    
                    SizedBox(height: 8),
                    Text(
                      'Author: ${plugin.author}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                    ),
                    Text(
                      'Version: ${plugin.version}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              // Delete Button
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  await state.pluginManager.deletePlugin(plugin.id);
                  setState(() {});
                },
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Bottom Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (plugin.abilities.contains('audioSource'))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Default audio source', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12)),
                )
              else if (plugin.abilities.contains('metadata'))
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NekoColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(Icons.login, size: 16),
                  label: Text('Connect to Spotify'),
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
                icon: Icon(Icons.favorite, size: 16),
                label: Text('Support'),
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
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRecommendedPluginCard(BuildContext context, dynamic state) {
    // Check if JioSaavn is already installed
    final isInstalled = (state.pluginManager.installedPlugins as List).any((p) => p.name.toString().toLowerCase().contains('jiosaavn'));
    if (isInstalled) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JioSaavn Audio',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Provides high quality audio streams from JioSaavn',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () {
                _urlController.text = 'https://github.com/KRTirtho/spotube-plugin-jiosaavn-audio';
                _loadPlugin();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NekoColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Install'),
            ),
          ),
        ],
      ),
    );
  }
}

