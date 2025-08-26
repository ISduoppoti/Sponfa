import 'package:flutter/material.dart';

import 'package:glovoapotheka/features/auth/widgets/pc_left_info_side.dart';
import 'package:glovoapotheka/features/auth/widgets/pc_right_login_side.dart';

import 'package:glovoapotheka/features/auth/widgets/animated_bubles.dart';

class LoginViewDesktop extends StatefulWidget {
  const LoginViewDesktop({Key? key}) : super(key: key);

  @override
  State<LoginViewDesktop> createState() => _LoginViewDesktopState();
}

class _LoginViewDesktopState extends State<LoginViewDesktop>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start slide animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
        ),
        child: Stack(
          children: [
            // Background Bubbles
            AnimatedBubles(),
            
            // Main Content
            Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _slideController,
                  child: _buildSignInIsland(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInIsland() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 1200,
      ),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 50,
            offset: const Offset(0, 25),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Expanded(child: LoginLeftSide()),
            VerticalDivider(width: 1, color: Colors.grey.withValues(alpha: 0.2)),
            Expanded(child: LoginRegisterForm()),
          ],
        ),
      ),
    );
  }
}