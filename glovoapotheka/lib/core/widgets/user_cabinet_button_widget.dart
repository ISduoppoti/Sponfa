import 'package:flutter/material.dart';

class UserCabinetButtonWidget extends StatelessWidget {
  final bool isMobile;

  const UserCabinetButtonWidget({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(99), // Fully rounded to match login button
          // Optional: add subtle shadow to match elevated appearance
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person,
              color: Colors.orange[700],
              size: isMobile ? 20 : 24,
            ),
            SizedBox(width: isMobile ? 2 : 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: isMobile ? 16 : 18,
              color: Colors.orange[700],
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, size: 18, color: Colors.orange[700]),
              const SizedBox(width: 12),
              const Text('Personal Account'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, size: 18, color: Colors.orange[700]),
              const SizedBox(width: 12),
              const Text('Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 18, color: Colors.red),
              const SizedBox(width: 12),
              const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'profile':
            // Navigate to profile page
            // Navigator.pushNamed(context, '/profile');
            break;
          case 'settings':
            // Navigate to settings page
            // Navigator.pushNamed(context, '/settings');
            break;
          case 'logout':
            // Handle logout
            // context.read<AuthCubit>().logout();
            break;
        }
      },
    );
  }
}