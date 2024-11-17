import 'package:flutter/material.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
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

          // Filter options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      children: const [
                        Icon(Icons.movie_outlined,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Type',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                  onSelected: (String value) {
                    // TODO: Handle type selection
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'movie',
                      child: Text('Movie'),
                    ),
                    const PopupMenuItem(
                      value: 'series',
                      child: Text('TV Series'),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                PopupMenuButton<int>(
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      children: const [
                        Icon(Icons.calendar_today,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Year',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                  onSelected: (int value) {
                    // TODO: Handle year selection
                  },
                  itemBuilder: (BuildContext context) => [
                    for (int i = 2024; i >= 2020; i--)
                      PopupMenuItem(
                        value: i,
                        child: Text(i.toString()),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      children: const [
                        Icon(Icons.category_outlined,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Genres',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                  onSelected: (String value) {
                    // TODO: Handle genre selection
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'action',
                      child: Text('Action'),
                    ),
                    const PopupMenuItem(
                      value: 'comedy',
                      child: Text('Comedy'),
                    ),
                    const PopupMenuItem(
                      value: 'drama',
                      child: Text('Drama'),
                    ),
                    const PopupMenuItem(
                      value: 'horror',
                      child: Text('Horror'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Grid of movies
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/movie_details'),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: AssetImage('assets/img/test_poster.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
              itemCount: 10, // Adjust based on your needs
            ),
          ),
        ],
      ),
    );
  }
}
