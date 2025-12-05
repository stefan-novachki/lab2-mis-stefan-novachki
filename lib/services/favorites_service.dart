import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_meals';

  // Get all favorite meal IDs
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Add a meal to favorites
  Future<void> addFavorite(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    if (!favorites.contains(mealId)) {
      favorites.add(mealId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  // Remove a meal from favorites
  Future<void> removeFavorite(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    favorites.remove(mealId);
    await prefs.setStringList(_favoritesKey, favorites);
  }

  // Check if a meal is favorite
  Future<bool> isFavorite(String mealId) async {
    final favorites = await getFavorites();
    return favorites.contains(mealId);
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String mealId) async {
    final isFav = await isFavorite(mealId);
    
    if (isFav) {
      await removeFavorite(mealId);
      return false;
    } else {
      await addFavorite(mealId);
      return true;
    }
  }
}

