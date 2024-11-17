import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moviehive/providers/dashboard_provider.dart';
import 'package:moviehive/screens/details_screen.dart';
import 'package:provider/provider.dart';
import 'package:moviehive/providers/auth_provider.dart';
import 'package:moviehive/api/fetch_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieApiService _movieApiService = MovieApiService();
  Map<String, dynamic>? _popularMovies;
  Map<String, dynamic>? _upcomingMovies;
  Map<String, dynamic>? _topRatedMovies;
  Map<String, dynamic>? _nowPlayingMovies;
  late PageController _featuredMovieController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _featuredMovieController = PageController();
    _startAutoScroll();
    _fetchPopularMovies();
    _fetchUpcomingMovies();
    _fetchTopRatedMovies();
    _fetchNowPlayingMovies();
  }

  Future<void> _fetchPopularMovies() async {
    try {
      final movies = await _movieApiService.fetchPopularMovies();
      setState(() {
        _popularMovies = movies;
      });
    } catch (e) {
      print('Error fetching popular movies: $e');
    }
  }

  Future<void> _fetchUpcomingMovies() async {
    try {
      final movies = await _movieApiService.fetchUpcomingMovies();
      setState(() {
        _upcomingMovies = movies;
      });
    } catch (e) {
      print('Error fetching upcoming movies: $e');
    }
  }

  Future<void> _fetchTopRatedMovies() async {
    try {
      final movies = await _movieApiService.fetchTopRatedMovies();
      setState(() {
        _topRatedMovies = movies;
      });
    } catch (e) {
      print('Error fetching top rated movies: $e');
    }
  }

  Future<void> _fetchNowPlayingMovies() async {
    try {
      final movies = await _movieApiService.fetchNowPlayingMovies();
      setState(() {
        _nowPlayingMovies = movies;
      });
    } catch (e) {
      print('Error fetching now playing movies: $e');
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_popularMovies != null) {
        final nextPage = (_featuredMovieController.page?.toInt() ?? 0) + 1;
        _featuredMovieController.animateToPage(
          nextPage % 5,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _featuredMovieController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Widget _buildFeaturedMovies() {
    if (_popularMovies == null) {
      return const SizedBox(
        height: 500,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final moviesList = (_popularMovies!['results'] as List).take(5).toList();

    return SizedBox(
      height: 500 + MediaQuery.of(context).padding.top,
      child: PageView.builder(
        controller: _featuredMovieController,
        itemCount: moviesList.length,
        itemBuilder: (context, index) {
          final movie = moviesList[index];
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://image.tmdb.org/t/p/original${movie['backdrop_path']}',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                  stops: const [0.4, 0.8, 1.0],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    movie['title'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontFamily: 'BebasNeue',
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoChip(
                          movie['release_date'].toString().substring(0, 4)),
                      _buildDot(),
                      _buildInfoChip(
                          '${(movie['vote_average'] as num).toStringAsFixed(1)}/10'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.play_arrow, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Watch Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                contentid: movie['id'],
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeaturedMovies(),
              _buildCategory('Now Playing'),
              _buildHorizontalMovieList('now_playing'),
              _buildCategory('Popular'),
              _buildHorizontalMovieList('popular'),
              _buildCategory('Top Rated'),
              _buildHorizontalMovieList('top_rated'),
              _buildCategory('Upcoming'),
              _buildHorizontalMovieList('upcoming'),
            ],
          ),

          // Top bar overlaid on featured content
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      final dashboardProvider =
                          context.read<DashboardProvider>();
                      dashboardProvider.setSelectedIndex(3);
                      PageController pageController =
                          Provider.of<DashboardProvider>(context, listen: false)
                              .pageController;
                      pageController.animateToPage(
                        3,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          context.watch<AuthProvider>().user?.photoURL != null
                              ? NetworkImage(
                                  context.watch<AuthProvider>().user!.photoURL!)
                              : null,
                      child:
                          context.watch<AuthProvider>().user?.photoURL == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '•',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildRatingWidget(String source, String rating) {
    return Row(
      children: [
        Text(
          source,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rating,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategory(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'See all',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalMovieList(String type) {
    final movies = type == 'popular'
        ? _popularMovies
        : type == 'upcoming'
            ? _upcomingMovies
            : type == 'now_playing'
                ? _nowPlayingMovies
                : _topRatedMovies;

    if (movies == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final moviesList = movies['results'] as List;

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: moviesList.length,
        itemBuilder: (context, index) {
          final movie = moviesList[index];
          final posterPath = movie['poster_path'];

          return Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(
                    contentid: movie['id'],
                  ),
                ),
              ),
              child: Container(
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500$posterPath',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
