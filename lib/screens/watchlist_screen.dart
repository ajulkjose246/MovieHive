import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moviehive/screens/details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Watchlist',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, authSnapshot) {
          if (!authSnapshot.hasData) {
            return Center(
              child: Text(
                'Please login to view your watchlist',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .doc(authSnapshot.data!.uid)
                .collection('watchlist')
                .orderBy('addedAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No movies in watchlist',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final movie =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  final movieId = snapshot.data!.docs[index].id;

                  return Dismissible(
                    key: Key(movieId),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _removeFromWatchlist(movieId);
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      leading: movie['posterPath'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://image.tmdb.org/t/p/w200${movie['posterPath']}',
                                width: 60,
                                height: 90,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 60,
                                  height: 90,
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 60,
                                  height: 90,
                                  color: Colors.grey[800],
                                  child: Icon(Icons.movie, color: Colors.white),
                                ),
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 90,
                              color: Colors.grey[800],
                              child: Icon(Icons.movie, color: Colors.white),
                            ),
                      title: Text(
                        movie['title'] ?? 'Unknown Title',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Added: ${_formatDate(movie['addedAt'] as Timestamp)}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              contentid: movie['contentid'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }

  Future<void> _removeFromWatchlist(String movieId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('watchlist')
            .doc(movieId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Movie removed from watchlist'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing movie: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
