import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:primitive_repository_search_engine/core/constants.dart';
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 160.0),
                    SvgPicture.asset(
                      IconConstants.noresult,
                    ),
                    Text(
                      'You have no favorites.\nClick on star while searching to add first favorite',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.secondaryRegular.copyWith(
                        color: AppColors.colors['secondaryRegular'],
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: favoritesProvider.favoriteRepositoryIds.length,
                  itemBuilder: (context, index) {
                    int repositoryId =
                        favoritesProvider.favoriteRepositoryIds[index];
                    return Dismissible(
                      key: Key(repositoryId.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: AppColors.colors['error'],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Icon(
                          Icons.delete,
                          color: AppColors.colors['Layer1'],
                        ),
                      ),
                      onDismissed: (direction) {
                        favoritesProvider
                            .removeFavoriteRepository(repositoryId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: AppColors.colors['Layer2'],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Repository ID: $repositoryId',
                                  style: AppTextStyles.primaryRegular.copyWith(
                                    color: AppColors.colors['textPrimary'],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.star_rounded,
                                    color: AppColors.colors['accent']),
                                onPressed: () {
                                  // Handle favorite toggle
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
