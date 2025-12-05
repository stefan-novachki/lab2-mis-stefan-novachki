import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/meal_detail.dart';
import '../services/favorites_service.dart';
import '../services/api_service.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final ApiService _apiService = ApiService();
  List<Meal> _favoriteMeals = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final favoriteIds = await _favoritesService.getFavorites();
      
      if (favoriteIds.isEmpty) {
        setState(() {
          _favoriteMeals = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch details for each favorite meal
      List<Meal> meals = [];
      for (String id in favoriteIds) {
        try {
          final mealDetail = await _apiService.getMealDetail(id);
          meals.add(Meal(
            idMeal: mealDetail.idMeal,
            strMeal: mealDetail.strMeal,
            strMealThumb: mealDetail.strMealThumb,
          ));
        } catch (e) {
          // Skip meals that fail to load
          continue;
        }
      }

      setState(() {
        _favoriteMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFavorites,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _favoriteMeals.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No favorite recipes yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add recipes by tapping the heart icon',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavorites,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _favoriteMeals.length,
                        itemBuilder: (context, index) {
                          final meal = _favoriteMeals[index];
                          return MealCard(
                            meal: meal,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MealDetailScreen(
                                    mealId: meal.idMeal,
                                  ),
                                ),
                              );
                              // Refresh the list when returning
                              _loadFavorites();
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

