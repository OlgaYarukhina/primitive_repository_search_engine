import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:primitive_repository_search_engine/core/constants.dart';
import 'package:primitive_repository_search_engine/widgets/result_item.dart';
import 'package:provider/provider.dart';
import 'package:primitive_repository_search_engine/models/repository.dart';
import 'package:primitive_repository_search_engine/providers/favorites_provider.dart';
import 'package:primitive_repository_search_engine/screens/favorite_screen.dart';
import 'package:primitive_repository_search_engine/service/api_repositories.dart';
import 'package:primitive_repository_search_engine/service/search_history_service.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final GitHubService _gitHubService = GitHubService();
  final TextEditingController _searchController = TextEditingController();
  late FocusNode _focusNode;
  var logger = Logger();
  List<Repository> _repositories = [];
  List<Repository> _searchedRepositories = [];
  final Set<int> _favoriteIds = <int>{};
  bool _isSearching = false;
  bool _isFocused = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _loadSearchedRepositories();
    _loadFavorites();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  Future<void> _loadSearchedRepositories() async {
    _searchedRepositories =
        await SearchHistoryService.getSearchedRepositories();
    setState(() {});
  }

  Future<void> _searchRepositories(String query) async {
    setState(() {
      _isSearching = true;
    });
    try {
      List<Repository> repositories =
          await _gitHubService.searchRepositories(query);
      setState(() {
        _repositories = repositories;
        _isSearching = false;
        _hasSearched = true; // Встановлюємо стан пошуку в true
        if (repositories.isNotEmpty) {
          for (var repo in repositories) {
            SearchHistoryService.addSearchedRepository(repo);
          }
          _loadSearchedRepositories();
        }
      });
    } catch (e) {
      logger.e('Error searching repositories', error: e);
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

  void _deleteSearchedRepository(int repositoryId) {
    setState(() {
      _searchedRepositories.removeWhere((repo) => repo.id == repositoryId);
      // Will finish it later
      //   SearchHistoryService.removeSearchedRepository(repositoryId);
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
                icon: SvgPicture.asset(
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
                  hintStyle: AppTextStyles.secondaryRegular.copyWith(
                    color: AppColors.colors['secondaryRegular'],
                  ),
                  filled: true,
                  fillColor: _isFocused
                      ? AppColors.colors['Layer3']
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
                    child: GestureDetector(
                      onTap: () {
                        if (_searchController.text.isNotEmpty) {
                          _searchRepositories(_searchController.text);
                        }
                      },
                      child: _isFocused
                          ? SvgPicture.asset(
                              IconConstants.search,
                            )
                          : SvgPicture.asset(
                              IconConstants.searchOnBack,
                            ),
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: SvgPicture.asset(
                              IconConstants.close,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _repositories.clear();
                                _hasSearched = false;
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
                      _hasSearched = false;
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
                    const SizedBox(height: 16),
                    Text(
                      'Search History',
                      style: AppTextStyles.primaryRegular.copyWith(
                        color: AppColors.colors['accent'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchedRepositories.length,
                      itemBuilder: (context, index) {
                        bool isFavorite = _favoriteIds
                            .contains(_searchedRepositories[index].id);
                        return RepositoryItem(
                          repository: _searchedRepositories[index],
                          isFavorite: isFavorite,
                          onFavoriteToggle: () =>
                              _toggleFavorite(_searchedRepositories[index].id),
                          onDelete: () => _deleteSearchedRepository(
                              _searchedRepositories[index].id),
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
              if (_hasSearched && !_isSearching && _repositories.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'What we found',
                              style: AppTextStyles.primaryRegular.copyWith(
                                color: AppColors.colors['accent'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 160.0),
                      SvgPicture.asset(
                        IconConstants.noresult,
                      ),
                      Text(
                        'Nothing was found for your search.\nPlease check the spelling',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.secondaryRegular.copyWith(
                          color: AppColors.colors['secondaryRegular'],
                        ),
                      ),
                    ],
                  ),
                ),
              if (!_isSearching &&
                  _repositories.isEmpty &&
                  _searchController.text.isEmpty &&
                  !_isFocused &&
                  !_hasSearched)
                Center(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Search History',
                              style: AppTextStyles.primaryRegular.copyWith(
                                color: AppColors.colors['accent'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 160.0),
                      SvgPicture.asset(
                        IconConstants.noresult,
                      ),
                      Text(
                        'You have empty history.\nClick on search to start journey!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.secondaryRegular.copyWith(
                          color: AppColors.colors['secondaryRegular'],
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
                    Text(
                      'What we found',
                      style: AppTextStyles.primaryRegular.copyWith(
                        color: AppColors.colors['accent'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _repositories.length,
                      itemBuilder: (context, index) {
                        bool isFavorite =
                            _favoriteIds.contains(_repositories[index].id);
                        return RepositoryItem(
                          repository: _repositories[index],
                          isFavorite: isFavorite,
                          onFavoriteToggle: () =>
                              _toggleFavorite(_repositories[index].id),
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
