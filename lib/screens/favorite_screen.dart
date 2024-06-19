import 'package:flutter/material.dart';
import 'package:primitive_repository_search_engine/providers/favorites_provider.dart';
import 'package:provider/provider.dart';


class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite repos list'),
      ),
      body: ListView.builder(
        itemCount: favoritesProvider.favoriteRepositoryIds.length,
        itemBuilder: (context, index) {
          int repositoryId = favoritesProvider.favoriteRepositoryIds[index];
          return ListTile(
            title: Text('Repository ID: $repositoryId'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                favoritesProvider.removeFavoriteRepository(repositoryId);
              },
            ),
          );
        },
      ),
    );
  }
}
