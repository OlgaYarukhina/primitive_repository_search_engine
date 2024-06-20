import 'package:flutter/material.dart';
import 'package:primitive_repository_search_engine/core/constants.dart';
import 'package:primitive_repository_search_engine/providers/favorites_provider.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite repos list'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (favoritesProvider.favoriteRepositoryIds.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      IconConstants.noresult,
                      height: 120,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No favorite repositories found.',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.colors['textPlaceholder'],
                      ),
                    ),
                  ],
                ),
              ),
            if (favoritesProvider.favoriteRepositoryIds.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: favoritesProvider.favoriteRepositoryIds.length,
                  itemBuilder: (context, index) {
                    int repositoryId = favoritesProvider.favoriteRepositoryIds[index];
                    return Dismissible(
                      key: Key(repositoryId.toString()),
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        favoritesProvider.removeFavoriteRepository(repositoryId);
                      },
                      child: Padding(
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
                                  'Repository ID: $repositoryId',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.star_rounded, color: Colors.green),
                                onPressed: () {
                                  // Handle favorite toggle if needed
                                },
                              ),
                            ],
                          ),
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




