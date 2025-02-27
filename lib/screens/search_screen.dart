import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/song_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Reset search query when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchQueryProvider.notifier).state = '';
    });
    
    // Update search results as user types
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    
    _searchController.value = TextEditingValue(
      text: searchQuery,
      selection: TextSelection.collapsed(offset: searchQuery.length),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search songs, artists, albums...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: searchQuery.isEmpty
          ? const Center(
              child: Text('Type to search...'),
            )
          : searchResults.isEmpty
              ? const Center(
                  child: Text('No results found'),
                )
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final song = searchResults[index];
                    return SongTile(
                      song: song,
                      onTap: () {
                        ref.read(playSongProvider(
                          PlayRequest(song: song)
                        ));
                      },
                    );
                  },
                ),
    );
  }
}