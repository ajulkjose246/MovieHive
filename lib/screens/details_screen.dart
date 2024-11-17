import 'package:flutter/material.dart';
import 'package:moviehive/api/fetch_data.dart';

class DetailsScreen extends StatefulWidget {
  final int contentid;
  const DetailsScreen({super.key, required this.contentid});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Future<Map<String, dynamic>> _movieDetailsFuture;
  final MovieApiService _apiService = MovieApiService();

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = _apiService.fetchMovieDetails(widget.contentid);
  }

  // Add this method to show rating dialog
  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Rate this movie', style: TextStyle(color: Colors.white)),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            5,
            (index) => IconButton(
              icon: Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onPressed: () {
                // Handle rating logic here
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
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
                        ? NetworkImage(posterUrl) as ImageProvider
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

                            // Rate Button
                            ElevatedButton(
                              onPressed: _showRatingDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.star_outline, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Rate',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
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
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    2, // Replace with actual comments count
                                itemBuilder: (context, index) =>
                                    _buildCommentItem(),
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
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
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

  Widget _buildCommentItem() {
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
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Name',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '2 days ago',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'This movie was amazing! The action scenes were incredible.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add Comment', style: TextStyle(color: Colors.white)),
        content: TextField(
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
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Handle adding comment logic here
              Navigator.pop(context);
            },
            child: Text('Post', style: TextStyle(color: Colors.white)),
          ),
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
}
