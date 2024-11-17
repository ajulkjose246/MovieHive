import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart'; // Adjust the import path as needed
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleLogout() async {
    try {
      // Reset dashboard index to 0
      Provider.of<DashboardProvider>(context, listen: false)
          .setSelectedIndex(0);

      // Sign out from Google
      await _googleSignIn.signOut();
      // Use AuthProvider instead of direct Firebase Auth
      await Provider.of<AuthProvider>(context, listen: false).signOut();

      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/signin', (route) => false);
    } catch (e) {
      print(e.toString());
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 57,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: user?.photoURL == null
                            ? const Icon(Icons.person,
                                size: 60, color: Colors.white)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Updated name and email
              Text(user?.displayName ?? 'Anonymous User',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
              Text(user?.email ?? 'No email',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[400],
                      )),

              const SizedBox(height: 20),
              Divider(color: Colors.grey[800]),

              // Profile Options in Cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileOptionCard(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'App preferences and account settings',
                      onTap: () {},
                    ),
                    _buildProfileOptionCard(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help or contact support',
                      onTap: () {},
                    ),
                    _buildProfileOptionCard(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      subtitle: 'Sign out from your account',
                      onTap: _handleLogout,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: isDestructive ? Colors.redAccent : Colors.white,
          size: 28,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDestructive ? Colors.redAccent : Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.redAccent : Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}
