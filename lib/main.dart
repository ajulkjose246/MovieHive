import 'package:flutter/material.dart';
import 'package:moviehive/screens/dash_board.dart';
import 'package:moviehive/screens/movie_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: ({
        '/': (context) => const Dashboard(),
        '/movie_details': (context) => const MovieDetails(),
      }),
      initialRoute: '/',
    );
  }
}
