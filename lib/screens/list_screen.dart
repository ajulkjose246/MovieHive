import 'package:flutter/material.dart';
import 'package:moviehive/api/fetch_data.dart';
import 'package:moviehive/screens/details_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final MovieApiService _apiService = MovieApiService();
  List<dynamic> _movies = [];
  bool _isLoading = true;

  // Add filter state variables
  String? _selectedType;
  String? _selectedYear;
  String? _selectedGenre;
  String? _selectedLanguage;

  // Genre ID mapping (TMDB uses IDs for genres)
  final Map<String, String> _genreIds = {
    'action': '28',
    'adventure': '12',
    'animation': '16',
    'comedy': '35',
    'crime': '80',
    'documentary': '99',
    'drama': '18',
    'family': '10751',
    'fantasy': '14',
    'history': '36',
    'horror': '27',
    'music': '10402',
    'mystery': '9648',
    'romance': '10749',
    'science fiction': '878',
    'tv movie': '10770',
    'thriller': '53',
    'war': '10752',
    'western': '37',
  };

  // Language mapping (TMDB uses ISO 639-1 codes for languages)
  final Map<String, String> _languages = {
    'English': 'en',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Italian': 'it',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Chinese': 'zh',
    'Russian': 'ru',
    'Hindi': 'hi',
    'Malayalam': 'ml',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Kannada ': 'kn',
  };

  // Static data maps
  final List<String> _types = ['movie', 'tv'];
  final List<int> _years =
      List.generate(25, (index) => DateTime.now().year - index);

  // Add pagination variables
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMovies();
    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Add scroll listener for pagination
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasNextPage) {
        _loadMoreMovies();
      }
    }
  }

  Future<void> _loadMovies() async {
    try {
      setState(() {
        _isLoading = true;
        _currentPage = 1; // Reset page when loading new filters
      });

      final result = await _apiService.fetchAllMovies(
        primaryReleaseYear: _selectedYear,
        withGenres: _selectedGenre != null ? _genreIds[_selectedGenre] : null,
        withOriginalLanguage: _selectedLanguage,
        sortBy: 'popularity.desc',
        page: _currentPage.toString(),
      );

      setState(() {
        _movies = result['results'] as List<dynamic>;
        _hasNextPage = (result['total_pages'] as int) > _currentPage;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading movies: $e');
      setState(() => _isLoading = false);
    }
  }

  // Add method to load more movies
  Future<void> _loadMoreMovies() async {
    if (_isLoadingMore) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      final result = await _apiService.fetchAllMovies(
        primaryReleaseYear: _selectedYear,
        withGenres: _selectedGenre != null ? _genreIds[_selectedGenre] : null,
        withOriginalLanguage: _selectedLanguage,
        sortBy: 'popularity.desc',
        page: (_currentPage + 1).toString(),
      );

      final newMovies = result['results'] as List<dynamic>;

      setState(() {
        _movies.addAll(newMovies);
        _currentPage++;
        _hasNextPage = (result['total_pages'] as int) > _currentPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      print('Error loading more movies: $e');
      setState(() => _isLoadingMore = false);
    }
  }

  // Add language handler
  void _handleLanguageSelection(String value) {
    setState(() {
      _selectedLanguage = _languages[value];
    });
    _loadMovies();
  }

  // Add filter handling methods
  void _handleTypeSelection(String value) {
    setState(() {
      _selectedType = value;
      // TODO: Implement TV series support when needed
    });
    _loadMovies();
  }

  void _handleYearSelection(int value) {
    setState(() {
      _selectedYear = value.toString();
    });
    _loadMovies();
  }

  void _handleGenreSelection(String value) {
    setState(() {
      _selectedGenre = value;
    });
    _loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Header with back button and title
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Contents',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    // TODO: Implement search functionality
                  },
                ),
              ],
            ),
          ),

          // Updated filter options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterButton(
                  icon: Icons.movie_outlined,
                  label: _selectedType?.toUpperCase() ?? 'Type',
                  items: _types
                      .map((type) => PopupMenuItem(
                            value: type,
                            child: Text(type.toUpperCase()),
                          ))
                      .toList(),
                  onSelected: _handleTypeSelection,
                ),
                const SizedBox(width: 12),
                _buildFilterButton(
                  icon: Icons.calendar_today,
                  label: _selectedYear ?? 'Year',
                  items: _years
                      .map((year) => PopupMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ))
                      .toList(),
                  onSelected: (int value) => _handleYearSelection(value),
                ),
                const SizedBox(width: 12),
                _buildFilterButton(
                  icon: Icons.category_outlined,
                  label: _selectedGenre?.toUpperCase() ?? 'Genres',
                  items: _genreIds.keys
                      .map((genre) => PopupMenuItem(
                            value: genre,
                            child: Text(genre.toUpperCase()),
                          ))
                      .toList(),
                  onSelected: _handleGenreSelection,
                ),
                const SizedBox(width: 12),
                _buildFilterButton(
                  icon: Icons.language,
                  label: _languages.entries
                      .firstWhere(
                        (entry) => entry.value == _selectedLanguage,
                        orElse: () => const MapEntry('Language', ''),
                      )
                      .key,
                  items: _languages.keys
                      .map((language) => PopupMenuItem(
                            value: language,
                            child: Text(language),
                          ))
                      .toList(),
                  onSelected: _handleLanguageSelection,
                ),
              ],
            ),
          ),

          // Updated clear filters check
          if (_selectedType != null ||
              _selectedYear != null ||
              _selectedGenre != null ||
              _selectedLanguage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    label: const Text(
                      'Clear Filters',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedType = null;
                        _selectedYear = null;
                        _selectedGenre = null;
                        _selectedLanguage = null;
                      });
                      _loadMovies();
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Updated grid view with loading indicator
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    controller: _scrollController, // Add scroll controller
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the bottom while loading more
                      if (index == _movies.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final movie = _movies[index];
                      final posterPath = movie['poster_path'];
                      final imageUrl = posterPath != null
                          ? 'https://image.tmdb.org/t/p/w500$posterPath'
                          : null;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                contentid: movie['id'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image: AssetImage(
                                        'assets/img/test_poster.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      );
                    },
                    itemCount: _movies.length + (_isLoadingMore ? 1 : 0),
                  ),
          ),
        ],
      ),
    );
  }

  // Helper method to build filter buttons with consistent styling
  Widget _buildFilterButton<T>({
    required IconData icon,
    required String label,
    required List<PopupMenuItem<T>> items,
    required void Function(T) onSelected,
  }) {
    return PopupMenuButton<T>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[900]!, Colors.grey[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[700]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => items,
    );
  }
}
