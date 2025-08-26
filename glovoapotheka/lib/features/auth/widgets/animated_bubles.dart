import 'package:flutter/material.dart';

class AnimatedBubles extends StatefulWidget {
  const AnimatedBubles({Key? key}) : super(key: key);

  @override
  State<AnimatedBubles> createState() => _AnimatedBublesState();
}

class _AnimatedBublesState extends State<AnimatedBubles>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  late Animation<double> _bubbleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _bubbleAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
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

}