import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginButtonWidget extends StatelessWidget {
  final bool isMobile;

  const LoginButtonWidget({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return (
      IconButton(
        icon: Icon(Icons.person_outline), // Equivalent to Lucide User
        color: Colors.orange[700],
        iconSize: isMobile ? 24 : 28,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99), // Fully rounded
          ),
          padding: EdgeInsets.all(isMobile ? 8 : 10),
        ),
        onPressed: () {
          // Handle profile button tap
          context.go('/login', extra: null);
        },
      )
    );
  }
}