import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moviehive/providers/dashboard_provider.dart';
import 'package:moviehive/screens/dash_board.dart';
import 'package:moviehive/screens/details_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: ({
          '/': (context) => const Dashboard(),
          '/movie_details': (context) => const DetailsScreen(),
        }),
        initialRoute: '/',
      ),
    );
  }
}
