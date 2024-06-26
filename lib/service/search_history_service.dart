import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:primitive_repository_search_engine/models/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  var logger = Logger();
  static const _historyKey = 'search_history';
  static const _repositoriesKey = 'searched_repositories';

  static Future<List<String>> getSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList(_historyKey);
    return history ?? [];
  }

  // Add a query to search history in SharedPreferences
  static Future<void> addToSearchHistory(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = await getSearchHistory();
    if (!history.contains(query)) {
      history.add(query);
      await prefs.setStringList(_historyKey, history);
    }
  }

  static Future<List<Repository>> getSearchedRepositories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? repositoriesJson = prefs.getStringList(_repositoriesKey);
    if (repositoriesJson == null) {
      return [];
    }
    return repositoriesJson.map((json) => Repository.fromJson(jsonDecode(json))).toList();
  }

  // Add a repository to searched repositories in SharedPreferences
  static Future<void> addSearchedRepository(Repository repository) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Repository> repositories = await getSearchedRepositories();
    repositories.add(repository);
    List<String> repositoriesJson = repositories.map((repo) => jsonEncode(repo.toJson())).toList();
    await prefs.setStringList(_repositoriesKey, repositoriesJson);
  }
  
  static Future<void> clearSearchedRepositories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_repositoriesKey);
  }
  
}
