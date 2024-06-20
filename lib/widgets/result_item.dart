import 'package:flutter/material.dart';
import 'package:primitive_repository_search_engine/core/constants.dart';
import 'package:primitive_repository_search_engine/models/repository.dart';

class RepositoryItem extends StatelessWidget {
  final Repository repository;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onDelete; 

  const RepositoryItem({
    super.key,
    required this.repository,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.onDelete, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Dismissible(
        key: Key(repository.id.toString()),
        direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
        onDismissed: (direction) {
          if (onDelete != null) {
            onDelete!();
          }
        },
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
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.colors['Layer2'],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  repository.fullName,
                  style: AppTextStyles.primaryRegular.copyWith(
                    color: AppColors.colors['textPrimary'],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.star_rounded,
                  color: isFavorite
                      ? AppColors.colors['accent']
                      : AppColors.colors['secondaryRegular'],
                ),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
