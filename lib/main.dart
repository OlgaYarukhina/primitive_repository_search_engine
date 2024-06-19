import 'package:flutter/material.dart';
import 'package:primitive_repository_search_engine/core/constants.dart';
import 'package:primitive_repository_search_engine/providers/favorites_provider.dart';
import 'package:primitive_repository_search_engine/screens/favorite_screen.dart';
import 'package:primitive_repository_search_engine/screens/loading_screen.dart';
import 'package:primitive_repository_search_engine/screens/search_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FavoritesProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Primitive git rep search engine',
      theme: ThemeData(
        primaryColor: const Color(0xFF0CC509),
        scaffoldBackgroundColor: const Color(0xFFFAFAFC),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.4),
          titleTextStyle: AppTextStyles.primarySemibold.copyWith(
            color: AppColors.colors['textPrimary'],
          ),
        ),
      ),
      initialRoute: Constants.searchScreen,
      routes: {
        Constants.loadingScreen: (context) => const LoadingScreen(),
        Constants.searchScreen: (context) => const SearchResultsScreen(),
        Constants.favoriteScreen: (context) => const FavoritesScreen(),
      },
    );
  }
}
