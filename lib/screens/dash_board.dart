import 'package:flutter/material.dart';
import 'package:moviehive/screens/home_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:moviehive/providers/dashboard_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text('List ', style: TextStyle(color: Colors.white))),
    const Center(child: Text('Saved', style: TextStyle(color: Colors.white))),
    const Center(child: Text('Profile', style: TextStyle(color: Colors.white))),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: PageView(
            controller: dashboardProvider.pageController,
            onPageChanged: (index) {
              dashboardProvider.setSelectedIndex(index);
            },
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                backgroundColor: Colors.black,
                color: Colors.grey[600]!,
                activeColor: Colors.white,
                tabBackgroundColor: Colors.grey.shade800,
                gap: 8,
                padding: const EdgeInsets.all(16),
                selectedIndex: dashboardProvider.selectedIndex,
                onTabChange: (index) {
                  dashboardProvider.setSelectedIndex(index);
                  dashboardProvider.pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                tabs: const [
                  GButton(
                    icon: Icons.home_outlined,
                    text: 'Home',
                  ),
                  GButton(
                    icon: Icons.movie_creation_outlined,
                    text: 'List',
                  ),
                  GButton(
                    icon: Icons.save_alt_outlined,
                    text: 'Saved',
                  ),
                  GButton(
                    icon: Icons.person_outline,
                    text: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
