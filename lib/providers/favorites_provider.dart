import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  List<int> _favoriteRepositoryIds = [];

  FavoritesProvider() {
    _loadFavorites();
  }

  List<int> get favoriteRepositoryIds => _favoriteRepositoryIds;

  Future<void> _loadFavorites() async {
    _prefs = await SharedPreferences.getInstance();
    // отримання списку улюблених ID
    _favoriteRepositoryIds = _prefs?.getStringList('favorites')?.map(int.parse).toList() ?? [];
    notifyListeners();
  }

  Future<void> addFavoriteRepository(int repositoryId) async {
    if (!_favoriteRepositoryIds.contains(repositoryId)) {
      _favoriteRepositoryIds.add(repositoryId);
      await _prefs?.setStringList('favorites', _favoriteRepositoryIds.map((id) => id.toString()).toList());
      notifyListeners();
    }
  }

  Future<void> removeFavoriteRepository(int repositoryId) async {
    _favoriteRepositoryIds.remove(repositoryId);
    await _prefs?.setStringList('favorites', _favoriteRepositoryIds.map((id) => id.toString()).toList());
    notifyListeners();
  }
}
