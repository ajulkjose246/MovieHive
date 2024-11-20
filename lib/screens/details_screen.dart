import 'package:flutter/material.dart';
import 'package:moviehive/api/fetch_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class DetailsScreen extends StatefulWidget {
  final int contentid;
  const DetailsScreen({super.key, required this.contentid});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Future<Map<String, dynamic>> _movieDetailsFuture;
  final MovieApiService _apiService = MovieApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add this state variable
  bool _isInWatchlist = false;

  // Add caching mechanism
  static final Map<int, Map<String, dynamic>> _cache = {};

  // Add these variables
  double? _userRating;
  double _averageRating = 0;
  int _totalRatings = 0;

  // Add these variables
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = _fetchAndCacheMovieDetails();
    _checkIfInWatchlist();
    _loadRatingData();
    _loadComments();
  }

  Future<Map<String, dynamic>> _fetchAndCacheMovieDetails() async {
    // Check cache first
    if (_cache.containsKey(widget.contentid)) {
      return _cache[widget.contentid]!;
    }

    // If not in cache, fetch and store
    final data = await _apiService.fetchMovieDetails(widget.contentid);
    _cache[widget.contentid] = data;
    return data;
  }

  // Add this method to check watchlist status
  Future<void> _checkIfInWatchlist() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('watchlist')
            .doc(widget.contentid.toString())
            .get();

        if (mounted) {
          setState(() {
            _isInWatchlist = docSnapshot.exists;
            print('Watchlist status: $_isInWatchlist');
          });
        }
      }
    } catch (e) {
      print('Error checking watchlist: $e');
    }
  }

  // Add this method to load rating data
  Future<void> _loadRatingData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Get user's rating
        final userRatingDoc = await _firestore
            .collection('movies')
            .doc(widget.contentid.toString())
            .collection('ratings')
            .doc(user.uid)
            .get();

        if (userRatingDoc.exists && mounted) {
          setState(() {
            _userRating = userRatingDoc.data()?['rating']?.toDouble();
          });
        }
      }

      // Get movie rating stats
      final movieDoc = await _firestore
          .collection('movies')
          .doc(widget.contentid.toString())
          .get();

      if (movieDoc.exists && mounted) {
        setState(() {
          _averageRating = movieDoc.data()?['averageRating']?.toDouble() ?? 0;
          _totalRatings = movieDoc.data()?['totalRatings'] ?? 0;
        });
      }
    } catch (e) {
      print('Error loading rating data: $e');
    }
  }

  // Replace the existing _showRatingDialog method
  void _showRatingDialog() {
    double selectedRating = _userRating ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Rate this movie', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    selectedRating = index + 1;
                    (context as Element).markNeedsBuild();
                  },
                ),
              ),
            ),
            if (_userRating != null)
              Text(
                'Your previous rating: ${_userRating!.toStringAsFixed(1)}',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _submitRating(selectedRating);
              Navigator.pop(context);
            },
            child: Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Add this method to submit the rating
  Future<void> _submitRating(double rating) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to rate movies'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final movieRef =
          _firestore.collection('movies').doc(widget.contentid.toString());
      final userRatingRef = movieRef.collection('ratings').doc(user.uid);

      // Start a batch write
      final batch = _firestore.batch();

      // Add or update user's rating
      batch.set(userRatingRef, {
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Get all ratings to calculate new average
      final ratingsSnapshot = await movieRef.collection('ratings').get();
      double totalRating = rating; // Include the new rating
      int totalCount = 1;

      // Sum up existing ratings (excluding the user's previous rating if it exists)
      for (var doc in ratingsSnapshot.docs) {
        if (doc.id != user.uid) {
          totalRating += doc.data()['rating'];
          totalCount++;
        }
      }

      // Calculate new average
      final newAverage = totalRating / totalCount;

      // Update movie document with new stats
      batch.set(
          movieRef,
          {
            'averageRating': newAverage,
            'totalRatings': totalCount,
          },
          SetOptions(merge: true));

      // Commit the batch
      await batch.commit();

      // Update state
      if (mounted) {
        setState(() {
          _userRating = rating;
          _averageRating = newAverage;
          _totalRatings = totalCount;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error submitting rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting rating: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add this method to handle save movie action
  Future<void> _handleSaveMovie() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to save movies'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final watchlistRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('watchlist')
          .doc(widget.contentid.toString());

      if (_isInWatchlist) {
        // Remove from watchlist
        await watchlistRef.delete();
        if (mounted) {
          setState(() {
            _isInWatchlist = false;
            print('Removed from watchlist');
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from watchlist'),
            backgroundColor: Colors.grey,
          ),
        );
      } else {
        // Add to watchlist
        final movieData = await _movieDetailsFuture;
        await watchlistRef.set({
          'contentid': widget.contentid,
          'title': movieData['title'],
          'posterPath': movieData['poster_path'],
          'addedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          setState(() {
            _isInWatchlist = true;
            print('Added to watchlist');
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to watchlist'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error saving movie: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add this method to load comments
  Future<void> _loadComments() async {
    try {
      final commentsSnapshot = await _firestore
          .collection('movies')
          .doc(widget.contentid.toString())
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _comments = commentsSnapshot.docs
              .map((doc) => {
                    ...doc.data(),
                    'id': doc.id,
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  // Replace the existing _showCommentDialog method
  void _showCommentDialog() {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add comments'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add Comment', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _commentController,
          style: TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write your comment...',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _commentController.clear();
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _submitComment();
              Navigator.pop(context);
            },
            child: Text('Post', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Add this method to submit comments
  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final user = _auth.currentUser!;
      final comment = {
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userPhoto': user.photoURL,
        'content': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('movies')
          .doc(widget.contentid.toString())
          .collection('comments')
          .add(comment);

      _commentController.clear();
      _loadComments(); // Reload comments

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment posted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error posting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error posting comment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Replace the existing _buildCommentItem method
  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final timestamp = comment['timestamp'] as Timestamp?;
    final timeAgo =
        timestamp != null ? timeago.format(timestamp.toDate()) : 'Just now';

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[800],
                backgroundImage: comment['userPhoto'] != null
                    ? CachedNetworkImageProvider(comment['userPhoto'])
                    : null,
                child: comment['userPhoto'] == null
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['userName'] ?? 'Anonymous',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (comment['userId'] == _auth.currentUser?.uid)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () => _deleteComment(comment['id']),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            comment['content'] ?? '',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Add this method to delete comments
  Future<void> _deleteComment(String commentId) async {
    try {
      await _firestore
          .collection('movies')
          .doc(widget.contentid.toString())
          .collection('comments')
          .doc(commentId)
          .delete();

      _loadComments(); // Reload comments

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment deleted'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      print('Error deleting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting comment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final movieData = snapshot.data!;
          final posterPath = movieData['poster_path'];
          final posterUrl = posterPath != null
              ? 'https://image.tmdb.org/t/p/w500$posterPath'
              : 'assets/img/test_poster.jpg';

          return Stack(
            children: [
              // Background Image
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: posterPath != null
                        ? CachedNetworkImageProvider(posterUrl) as ImageProvider
                        : AssetImage('assets/img/test_poster.jpg'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),

              // Content
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Movie Stats Row
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // IMDb Rating Row
                                  if (movieData['imdb_details']?['short']
                                          ?['aggregateRating'] !=
                                      null)
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/img/imdb_logo.png',
                                          height: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${movieData['imdb_details']['short']['aggregateRating']['ratingValue']}/10',
                                          style: TextStyle(
                                            color: Colors.amber,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),
                                  _buildRatingStats(),
                                  const SizedBox(height: 12),

                                  // Duration and Release Year Row
                                  Row(
                                    children: [
                                      if (movieData['imdb_details']?['short']
                                              ?['duration'] !=
                                          null)
                                        Row(
                                          children: [
                                            Icon(Icons.access_time,
                                                color: Colors.grey[400],
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDuration(
                                                  movieData['imdb_details']
                                                      ['short']['duration']),
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(width: 16),
                                      if (movieData['release_date'] != null)
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                color: Colors.grey[400],
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              movieData['release_date']
                                                  .substring(0, 4),
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Director Row
                                  if (movieData['imdb_details']?['short']
                                          ?['director'][0]['name'] !=
                                      null)
                                    Row(
                                      children: [
                                        Icon(Icons.movie_creation,
                                            color: Colors.grey[400], size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Director: ',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          movieData['imdb_details']['short']
                                              ['director'][0]['name'],
                                          style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Add Genre List here
                            if (movieData['genres'] != null)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: (movieData['genres'] as List)
                                      .map((genre) => Container(
                                            margin: EdgeInsets.only(right: 8),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[800],
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              genre['name'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Rate and Save Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _showRatingDialog,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[800],
                                      minimumSize: Size(0, 50),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.star_outline,
                                            color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Rate',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _handleSaveMovie,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isInWatchlist
                                          ? Colors.red[600]
                                          : Colors.grey[800],
                                      minimumSize: Size(0, 50),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isInWatchlist
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          _isInWatchlist ? 'Remove' : 'Save',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Synopsis
                            Text(
                              movieData['title'] ?? 'No Title',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              movieData['overview'] ?? 'No overview available',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),

                            // Cast Section
                            Text(
                              'Top Cast',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _buildCastList(movieData),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Comments Section
                            Text(
                              'Comments',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Existing comments list
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _comments.isEmpty
                                  ? Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        'No comments yet. Be the first to comment!',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _comments.length,
                                      itemBuilder: (context, index) =>
                                          _buildCommentItem(_comments[index]),
                                    ),
                            ),
                            const SizedBox(height: 16),

                            // Add comment button
                            ElevatedButton(
                              onPressed: _showCommentDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.comment_outlined,
                                      color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Add Comment',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Back Button
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Stack(
      children: [
        // Skeleton for poster
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          color: Colors.grey[800],
        ),

        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.35),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Skeleton for rating
                      Container(
                        width: 100,
                        height: 24,
                        color: Colors.grey[800],
                      ),
                      const SizedBox(height: 20),

                      // Skeleton for duration and year
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 16,
                            color: Colors.grey[800],
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 60,
                            height: 16,
                            color: Colors.grey[800],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Skeleton for title
                      Container(
                        width: double.infinity,
                        height: 30,
                        color: Colors.grey[800],
                      ),
                      const SizedBox(height: 20),

                      // Skeleton for overview
                      Column(
                        children: List.generate(
                            3,
                            (index) => Container(
                                  width: double.infinity,
                                  height: 16,
                                  margin: EdgeInsets.only(bottom: 8),
                                  color: Colors.grey[800],
                                )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Back Button
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCastList(Map<String, dynamic> movieData) {
    final imdbDetails =
        movieData['imdb_details']?['main']?['cast']?['edges'] as List?;

    if (imdbDetails == null || imdbDetails.isEmpty) {
      return [
        Center(
            child: Text('No cast information available',
                style: TextStyle(color: Colors.grey)))
      ];
    }

    return imdbDetails.map((castMember) {
      final node = castMember['node'];
      final name = node['name']?['nameText']?['text'] ?? 'Unknown';
      final character = node['characters']?[0]?['name'] ?? 'Unknown Role';
      final imageUrl = node['name']['primaryImage']?['url'];

      return _buildCastMember(name, character, imageUrl);
    }).toList();
  }

  Widget _buildCastMember(String name, String character, [String? imageUrl]) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                imageUrl != null ? CachedNetworkImageProvider(imageUrl) : null,
            backgroundColor: Colors.grey,
            child: imageUrl == null
                ? Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 8),
          Text(name, style: TextStyle(color: Colors.white)),
          Text(character, style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  String _formatDuration(String ptDuration) {
    // Remove 'PT' prefix and split into hours and minutes
    final duration = ptDuration.substring(2); // Remove 'PT'
    final hours =
        duration.contains('H') ? int.parse(duration.split('H')[0]) : 0;
    final minutes = duration.contains('M')
        ? int.parse(duration.split('H')[1].replaceAll('M', ''))
        : 0;

    return '${hours}:${minutes.toString().padLeft(2, '0')}min';
  }

  // In your build method, add this widget where you want to display the rating stats
  Widget _buildRatingStats() {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber, size: 20),
        SizedBox(width: 4),
        Text(
          '${_averageRating.toStringAsFixed(1)}/5',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8),
        Text(
          '($_totalRatings ${_totalRatings == 1 ? 'rating' : 'ratings'})',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
