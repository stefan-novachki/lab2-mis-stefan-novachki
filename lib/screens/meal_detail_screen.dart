import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';
import '../services/api_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;
  final MealDetail? mealDetail;

  const MealDetailScreen({
    super.key,
    required this.mealId,
    this.mealDetail,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final ApiService _apiService = ApiService();
  MealDetail? _mealDetail;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.mealDetail != null) {
      _mealDetail = widget.mealDetail;
      _isLoading = false;
    } else {
      _loadMealDetail();
    }
  }

  Future<void> _loadMealDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final mealDetail = await _apiService.getMealDetail(widget.mealId);
      setState(() {
        _mealDetail = mealDetail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openYouTube(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No YouTube link available')),
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mealDetail?.strMeal ?? 'Recipe Details'),
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
                        onPressed: _loadMealDetail,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _mealDetail == null
                  ? const Center(child: Text('No data available'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            _mealDetail!.strMealThumb,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 250,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error, size: 50),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _mealDetail!.strMeal,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // YouTube Button
                                if (_mealDetail!.strYoutube.isNotEmpty)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _openYouTube(
                                        _mealDetail!.strYoutube,
                                      ),
                                      icon: const Icon(Icons.play_arrow),
                                      label: const Text('Watch on YouTube'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                const SizedBox(height: 24),
                                
                                // Ingredients Section
                                const Text(
                                  'Ingredients',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: List.generate(
                                      _mealDetail!.ingredients.length,
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.circle,
                                              size: 8,
                                              color: Colors.orange,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${_mealDetail!.measures[index]} ${_mealDetail!.ingredients[index]}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Instructions Section
                                const Text(
                                  'Instructions',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _mealDetail!.strInstructions,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
