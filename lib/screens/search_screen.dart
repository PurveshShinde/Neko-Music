import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/slothify_theme.dart';
import '../models/track_model.dart';
import '../models/playlist_model.dart';
import '../services/youtube_search_service.dart';
import '../state/app_state.dart';
import 'playlist_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final YouTubeSearchService _searchService = YouTubeSearchService();
  
  List<dynamic> _results = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  
  Timer? _debounce;
  List<String> _history = [];
  SharedPreferences? _prefs;

  final List<String> _categories = ['All', 'Songs', 'Albums', 'Playlists'];

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = _prefs?.getStringList('search_history') ?? [];
    });
  }

  void _saveToHistory(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    
    setState(() {
      _history.remove(q);
      _history.insert(0, q);
      if (_history.length > 10) _history = _history.sublist(0, 10);
    });
    _prefs?.setStringList('search_history', _history);
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
    _prefs?.remove('search_history');
  }

  void _removeHistoryItem(String item) {
    setState(() {
      _history.remove(item);
    });
    _prefs?.setStringList('search_history', _history);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query, saveHistory: false); // Don't save to history just for typing
    });
  }

  Future<void> _performSearch(String query, {bool saveHistory = true}) async {
    if (query.trim().isEmpty) return;
    
    if (saveHistory) {
      _saveToHistory(query);
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _searchService.searchCategorized(query, _selectedCategory);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    if (_controller.text.trim().isNotEmpty) {
      _performSearch(_controller.text, saveHistory: false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
                      onChanged: _onSearchChanged,
                      onSubmitted: (val) => _performSearch(val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // ── Category Chips ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => _onCategoryChanged(category),
                      backgroundColor: SlothifyColors.surfaceVariant,
                      selectedColor: SlothifyColors.accent,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
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
                          ? _controller.text.isEmpty && _history.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Recent Searches', style: Theme.of(context).textTheme.titleMedium),
                                        TextButton(
                                          onPressed: _clearHistory,
                                          child: const Text('Clear All', style: TextStyle(color: SlothifyColors.accent)),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: _history.length,
                                        itemBuilder: (context, index) {
                                          final item = _history[index];
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: const Icon(Icons.history, color: SlothifyColors.textTertiary),
                                            title: Text(item, style: Theme.of(context).textTheme.bodyMedium),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.close, color: SlothifyColors.textTertiary, size: 20),
                                              onPressed: () => _removeHistoryItem(item),
                                            ),
                                            onTap: () {
                                              _controller.text = item;
                                              _performSearch(item);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
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
                                  final item = _results[index];

                                  if (item is TrackModel) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: item.imageUrl != null
                                            ? Image.network(item.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)
                                            : Container(width: 48, height: 48, color: Color(item.colorSeed)),
                                      ),
                                      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      subtitle: Text('Song • ${item.artist}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                      trailing: const Icon(Icons.more_vert, color: SlothifyColors.textTertiary),
                                      onTap: () {
                                        final state = AppStateProvider.of(context);
                                        state.playTrack(item).catchError((e) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                        });
                                      },
                                    );
                                  } else if (item is PlaylistModel) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(item.isAlbum ? 8 : 48), // Circles for playlists
                                        child: item.imageUrl != null
                                            ? Image.network(item.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)
                                            : Container(width: 48, height: 48, color: Color(item.colorSeed)),
                                      ),
                                      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      subtitle: Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => PlaylistScreen(playlist: item)),
                                        );
                                      },
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
            ),
          ],
        ),
      ),
    );
  }
}
