import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:primitive_repository_search_engine/models/repository.dart';

class GitHubService {
  static const String baseUrl = 'https://api.github.com';
  static const String authToken = 'PLEASE INSERT HERE YOUR GIT AUTH TOKEN';

  Future<List<Repository>> searchRepositories(String query) async {
    final String searchUrl = '$baseUrl/search/repositories?q=$query&per_page=15';

    final http.Response response = await http.get(
      Uri.parse(searchUrl),
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'Authorization': authToken,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['items'];
      print(data);
      return data.map((item) => Repository.fromJson(item)).toList();
    } else {
      throw Exception('Failed to search repositories');
    }
  }
}
