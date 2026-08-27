import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../state/app_state.dart';

class DownloadSettingsScreen extends StatefulWidget {
  const DownloadSettingsScreen({super.key});

  @override
  State<DownloadSettingsScreen> createState() => _DownloadSettingsScreenState();
}

class _DownloadSettingsScreenState extends State<DownloadSettingsScreen> {
  String _downloadQuality = '320kbps';
  String _downloadPath = 'Default (App Data)';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _downloadQuality = prefs.getString('downloadQuality') ?? '320kbps';
      _downloadPath = prefs.getString('downloadPath') ?? 'Default (App Data)';
    });
  }

  Future<void> _pickDownloadPath() async {
    try {
      final selectedDirectory = await FilePicker.getDirectoryPath();
      if (selectedDirectory != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('downloadPath', selectedDirectory);
        setState(() {
          _downloadPath = selectedDirectory;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick directory: $e')));
      }
    }
  }

  Future<void> _resetDownloadPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('downloadPath');
    setState(() {
      _downloadPath = 'Default (App Data)';
    });
  }

  Future<void> _setQuality(String quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('downloadQuality', quality);
    setState(() {
      _downloadQuality = quality;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAmoled = AppStateProvider.of(context).isAmoledThemeEnabled;
    final surfaceColor = isAmoled ? Colors.black : Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Text(
            'Download Location',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Current Folder'),
            subtitle: Text(_downloadPath),
            trailing: IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: _pickDownloadPath,
            ),
          ),
          if (_downloadPath != 'Default (App Data)')
            TextButton.icon(
              onPressed: _resetDownloadPath,
              icon: const Icon(Icons.restore),
              label: const Text('Reset to Default Location'),
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
            ),
            
          if (Platform.isAndroid) ...[
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Storage Permission'),
              subtitle: const Text('Required to save to custom folders'),
              trailing: ElevatedButton(
                onPressed: () async {
                  final status = await Permission.manageExternalStorage.request();
                  if (status.isGranted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Permission Granted!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Permission Denied')),
                    );
                  }
                },
                child: const Text('Grant'),
              ),
            ),
          ],
            
          const SizedBox(height: 32),
          Text(
            'Download Quality',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildQualityOption('128kbps', 'Standard quality (smaller file size)'),
          _buildQualityOption('320kbps', 'High quality (recommended)'),
          _buildQualityOption('Lossless/Best', 'Best audio available'),
          _buildQualityOption('MP4 Video', 'Download as video file instead of audio'),
        ],
      ),
    );
  }

  Widget _buildQualityOption(String quality, String subtitle) {
    return RadioListTile<String>(
      title: Text(quality),
      subtitle: Text(subtitle),
      value: quality,
      groupValue: _downloadQuality,
      onChanged: (val) {
        if (val != null) _setQuality(val);
      },
      contentPadding: EdgeInsets.zero,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}
