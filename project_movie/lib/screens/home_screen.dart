import 'package:flutter/material.dart';
import 'package:project_movie/models/movie.dart';
import 'package:project_movie/screens/detail_screen.dart';
import 'package:project_movie/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  List<Movie> _allMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final allMoviesData = await _apiService.getAllMovies();
      final trendingMoviesData = await _apiService.getTrendingMovies();
      final popularMoviesData = await _apiService.getPopularMovies();

      setState(() {
        _allMovies =
            allMoviesData.map((e) => Movie.fromJson(e)).toList();
        _trendingMovies =
            trendingMoviesData.map((e) => Movie.fromJson(e)).toList();
        _popularMovies =
            popularMoviesData.map((e) => Movie.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading movies: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilem'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMovieList('All Movies', _allMovies),
                  _buildMovieList('Trending Movies', _trendingMovies),
                  _buildMovieList('Popular Movies', _popularMovies),
                ],
              ),
            ),
    );
  }

  Widget _buildMovieList(String title, List<Movie> movies) {
    if (movies.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(movie: movie),
                  ),
                ),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                          height: 160,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}