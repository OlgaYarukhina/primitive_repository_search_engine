import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const _key = 'search_history';

  static Future<List<String>> getSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList(_key);
    return history ?? [];
  }

  static Future<void> addToSearchHistory(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = await getSearchHistory();
    if (!history.contains(query)) {
      history.add(query);
      await prefs.setStringList(_key, history);
    }
  }

  // static Future<void> clearSearchHistory() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(_key);
  // }
}
