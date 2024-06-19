import 'package:flutter/material.dart';
import 'package:primitive_repository_search_engine/core/constants.dart';
import 'package:provider/provider.dart';
import 'package:primitive_repository_search_engine/models/repository.dart';
import 'package:primitive_repository_search_engine/providers/favorites_provider.dart';
import 'package:primitive_repository_search_engine/screens/favorite_screen.dart';
import 'package:primitive_repository_search_engine/service/api_repositories.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final GitHubService _gitHubService = GitHubService();
  final TextEditingController _searchController = TextEditingController();
  List<Repository> _repositories = [];
  bool _isSearching = false;
  bool _isFocused = false; // Track whether the TextField is focused or not
  late FocusNode _focusNode; // FocusNode to track focus state

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(); // Initialize the FocusNode
    _focusNode.addListener(_onFocusChange); // Add listener for focus changes
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Clean up the FocusNode when done
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus; // Update the focus state
    });
  }

  Future<void> _searchRepositories(String query) async {
    setState(() {
      _isSearching = true;
    });
    try {
      List<Repository> repositories = await _gitHubService.searchRepositories(query);
      setState(() {
        _repositories = repositories;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching repositories: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(63.0),
        child: AppBar(
          title: const Text('Github repos list'),
          backgroundColor: Colors.white, 
          actions: [
            IconButton(
              icon: Image.asset(
                IconConstants.favorites,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 9.0),
            TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: AppTextStyles.secondaryRegular.copyWith(
                  color: AppColors.colors['textPlaceholder'],
                ),
                contentPadding: const EdgeInsets.fromLTRB(6, 16, 6, 6),
                filled: true,
                fillColor: _isFocused ? Colors.green[100] : AppColors.colors['Layer2'],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Image.asset(
                    IconConstants.searchOnBack,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Image.asset(
                          IconConstants.close,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _repositories.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    _repositories.clear();
                  });
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _searchRepositories(value);
                }
              },
            ),
            const SizedBox(height: 12),
            if (_repositories.isEmpty)
              Text(
                _searchController.text.isEmpty ? 'Search History' : 'Nothing was found',
                style: AppTextStyles.primaryRegular.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            if (_repositories.isEmpty && !_isSearching)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        IconConstants.noresult,
                      ),
                      Text(
                        'You have empty history.\nClick on search to start journey!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.secondaryRegular.copyWith(
                          color: AppColors.colors['textPlaceholder'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isSearching)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (_repositories.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 8),
                child: Text('What we found', style: TextStyle(fontSize: 18)),
              ),
            if (_repositories.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _repositories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _repositories[index].fullName,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.star_border),
                              onPressed: () {
                                Provider.of<FavoritesProvider>(context, listen: false)
                                    .addFavoriteRepository(_repositories[index].id);
                              },
                            ),
                          ],
                        ),
                      ),
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
