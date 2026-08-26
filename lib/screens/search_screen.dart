import 'package:flutter/material.dart';
import '../theme/slothify_theme.dart';
import '../models/track_model.dart';
import '../services/youtube_search_service.dart';
import '../state/app_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final YouTubeSearchService _searchService = YouTubeSearchService();
  
  List<TrackModel> _results = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _searchService.searchTracks(query);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            
            // ── Search Bar ──
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: SlothifyColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SlothifyColors.border, width: 0.6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      size: 20, color: SlothifyColors.textTertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Songs, Artists, Podcasts...',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: SlothifyColors.textTertiary),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _performSearch,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Search Results ──
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : _results.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_rounded,
                                      size: 64, color: SlothifyColors.textTertiary.withValues(alpha: 0.3)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Start searching for music',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final track = _results[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: track.imageUrl != null
                                        ? Image.network(track.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)
                                        : Container(
                                            width: 48,
                                            height: 48,
                                            color: Color(track.colorSeed),
                                            child: Center(child: Text(track.albumArt)),
                                          ),
                                  ),
                                  title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  trailing: const Icon(Icons.play_circle_fill, color: SlothifyColors.accent),
                                  onTap: () {
                                    final state = AppStateProvider.of(context);
                                    state.playTrack(track).catchError((e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    });
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
