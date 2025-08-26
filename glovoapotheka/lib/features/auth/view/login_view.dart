import 'package:flutter/material.dart';

import 'package:glovoapotheka/features/auth/widgets/pc_left_info_side.dart';
import 'package:glovoapotheka/features/auth/widgets/pc_right_login_side.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  late AnimationController _slideController;
  late Animation<double> _bubbleAnimation;
  late Animation<Offset> _slideAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bubbleAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeInOut,
    ));

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
    _bubbleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768 && screenSize.width < 1200;
    final isMobile = screenSize.width <= 768;

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
            _buildBackgroundBubbles(),
            
            // Main Content
            Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _slideController,
                  child: _buildSignInIsland(isMobile, isTablet),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundBubbles() {
    return Stack(
      children: [
        // Bubble 1
        AnimatedBuilder(
          animation: _bubbleAnimation,
          builder: (context, child) {
            return Positioned(
              top: -200 + _bubbleAnimation.value,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Bubble 2
        AnimatedBuilder(
          animation: _bubbleAnimation,
          builder: (context, child) {
            return Positioned(
              bottom: -300 - _bubbleAnimation.value,
              right: -200,
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8C42), Color(0xFFFFA726)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8C42).withValues(alpha: 0.08),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Bubble 3 (smaller accent)
        AnimatedBuilder(
          animation: _bubbleAnimation,
          builder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).size.height * 0.2 + _bubbleAnimation.value * 0.5,
              left: MediaQuery.of(context).size.width * 0.7,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B35).withValues(alpha: 0.1),
                      const Color(0xFFFF8C42).withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSignInIsland(bool isMobile, bool isTablet) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isMobile ? MediaQuery.of(context).size.width - 40 : 1200,
        // maxHeight: isMobile ? null : 500.0,
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
        child: isMobile 
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //_buildBenefitsSection(isMobile),
                //_buildSignInSection(isMobile),
              ],
            )
          : Row(
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