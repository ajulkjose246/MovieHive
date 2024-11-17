import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with gradient
              Container(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 57,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.person,
                            size: 60, color: Colors.white),
                      ),
                    ),
                    // Edit button
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Name and Email
              Text('John Doe',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
              Text('john.doe@example.com',
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
                      onTap: () {},
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
