import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/favorites_service.dart';

class MealCard extends StatefulWidget {
  final Meal meal;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.meal.idMeal);
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await _favoritesService.toggleFavorite(widget.meal.idMeal);
    setState(() {
      _isFavorite = newStatus;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'Added to favorites' : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: Image.network(
                      widget.meal.strMealThumb,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        onPressed: _toggleFavorite,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.meal.strMeal,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
