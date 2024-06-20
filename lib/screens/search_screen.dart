import 'package:flutter/material.dart';
import 'package:primitive_repository_search_engine/core/constants.dart';
import 'package:provider/provider.dart';
import 'package:primitive_repository_search_engine/models/repository.dart';
import 'package:primitive_repository_search_engine/providers/favorites_provider.dart';
import 'package:primitive_repository_search_engine/screens/favorite_screen.dart';
import 'package:primitive_repository_search_engine/service/api_repositories.dart';
import 'package:primitive_repository_search_engine/service/search_history_service.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({Key? key}) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final GitHubService _gitHubService = GitHubService();
  final TextEditingController _searchController = TextEditingController();
  List<Repository> _repositories = [];
  List<Repository> _searchedRepositories = [];
  bool _isSearching = false;
  bool _isFocused = false; // Track whether the TextField is focused or not
  late FocusNode _focusNode; // FocusNode to track focus state
  Set<int> _favoriteIds = Set<int>(); // Set to track favorite repository ids

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(); // Initialize the FocusNode
    _focusNode.addListener(_onFocusChange); // Add listener for focus changes
    _loadSearchedRepositories();
    _loadFavorites();
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

  Future<void> _loadSearchedRepositories() async {
    _searchedRepositories = await SearchHistoryService.getSearchedRepositories();
    setState(() {});
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
        if (repositories.isNotEmpty) {
          for (var repo in repositories) {
            SearchHistoryService.addSearchedRepository(repo); // Додати кожен знайдений репозиторій до історії
          }
          _loadSearchedRepositories(); // Оновити список збережених репозиторіїв
        }
      });
    } catch (e) {
      print('Error searching repositories: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    var favorites = await Provider.of<FavoritesProvider>(context, listen: false)
        .getFavoriteRepositoryIds();
    setState(() {
      _favoriteIds.clear();
      _favoriteIds.addAll(favorites);
    });
  }

  void _toggleFavorite(int repositoryId) {
    setState(() {
      if (_favoriteIds.contains(repositoryId)) {
        _favoriteIds.remove(repositoryId);
        Provider.of<FavoritesProvider>(context, listen: false)
            .removeFavoriteRepository(repositoryId);
      } else {
        _favoriteIds.add(repositoryId);
        Provider.of<FavoritesProvider>(context, listen: false)
            .addFavoriteRepository(repositoryId);
      }
    });
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
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
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
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  hintStyle: TextStyle(
                    color: AppColors.colors['textPlaceholder'],
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(6, 16, 6, 6),
                  filled: true,
                  fillColor: _isFocused
                      ? Colors.green[100]
                      : AppColors.colors['Layer2'],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Image.asset(
                      IconConstants.searchOnBack,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: Image.asset(
                              IconConstants.close,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _repositories.clear();
                              });
                            },
                          ),
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _isFocused = _focusNode.hasFocus || value.isNotEmpty;
                    if (value.isEmpty) {
                      _repositories.clear();
                    }
                  });
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _searchRepositories(value);
                  }
                },
              ),
              if (_searchedRepositories.isNotEmpty &&
                  _searchController.text.isEmpty &&
                  !_isFocused)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Searched Repositories',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _searchedRepositories.length,
                      itemBuilder: (context, index) {
                        bool isFavorite = _favoriteIds
                            .contains(_searchedRepositories[index].id);
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _searchedRepositories[index].fullName,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: isFavorite ? Colors.green : null,
                                  ),
                                  onPressed: () {
                                    _toggleFavorite(
                                        _searchedRepositories[index].id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              if (_isSearching)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              if (!_isSearching &&
                  _repositories.isEmpty &&
                  _searchController.text.isNotEmpty)
                Text(
                  'What we found',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              if (!_isSearching &&
                  _repositories.isEmpty &&
                  _searchController.text.isEmpty &&
                  !_isFocused)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 160),
                      Image.asset(
                        IconConstants.noresult,
                      ),
                      Text(
                        'You have empty history.\nClick on search to start journey!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.colors['textPlaceholder'],
                        ),
                      ),
                    ],
                  ),
                ),
              if (!_isSearching && _repositories.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (_repositories.isNotEmpty)
                      Text(
                        'What we found',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _repositories.length,
                      itemBuilder: (context, index) {
                        bool isFavorite =
                            _favoriteIds.contains(_repositories[index].id);
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _repositories[index].fullName,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: isFavorite ? Colors.green : null,
                                  ),
                                  onPressed: () {
                                    _toggleFavorite(
                                        _repositories[index].id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
