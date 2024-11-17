import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
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
      body: Stack(
        children: [
          // Background Image
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/test_poster.jpg'),
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
                        Row(
                          children: [
                            Text('95% match',
                                style: TextStyle(color: Colors.green)),
                            const SizedBox(width: 10),
                            Text('2023', style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 10),
                            Text('R', style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 10),
                            Text('HD', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Play Button
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow, color: Colors.black),
                              Text('Play',
                                  style: TextStyle(color: Colors.black)),
                            ],
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
                          'Prolog',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'John Wick uncovers a path to defeating The High Table. But before he can earn his freedom, Wick must face off against a new enemy with powerful alliances across the globe and forces that turn old friends into foes.',
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
                            children: [
                              _buildCastMember('Keanu Reeves', 'John Wick'),
                              _buildCastMember(
                                  'Laurence Fishburne', 'Bowery King'),
                              _buildCastMember('George Geo...', 'The Elder'),
                            ],
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
                            itemCount: 2, // Replace with actual comments count
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
                              Icon(Icons.comment_outlined, color: Colors.white),
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
      ),
    );
  }

  Widget _buildCastMember(String name, String character) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
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
}
