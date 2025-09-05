import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import 'package:glovoapotheka/core/widgets/top_navigation_bar.dart';
import 'package:glovoapotheka/data/models/product.dart';

import 'package:glovoapotheka/features/home/widgets/search_container_widget.dart';
import 'package:glovoapotheka/features/home/widgets/how_it_works_widget.dart';
import 'package:glovoapotheka/features/home/widgets/categories_widget.dart';
import 'package:glovoapotheka/features/home/widgets/discount_goods_widger.dart';
import 'package:glovoapotheka/features/home/widgets/popular_products_widget.dart';
import 'package:glovoapotheka/features/home/widgets/product_showcase_widget.dart';

import 'package:glovoapotheka/domain/services/popular_products_service.dart';

// Product model
class Product {
  final String name;
  final String brand;
  final String description;
  final double price;
  final String currency;
  final String? imageUrl;

  Product({
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    this.currency = 'грн',
    this.imageUrl,
  });
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  final List<Particle> _particles = [];
  Offset _mousePosition = Offset.zero;
  bool _isMouseInHeader = false;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      duration: Duration(milliseconds: 33),
      vsync: this,
    )..repeat();

    _particleController.addListener(() {
      _updateParticles();
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _updateParticles() {
    setState(() {
      // Update existing particles
      _particles.removeWhere((particle) => particle.isDead);
      
      for (var particle in _particles) {
        particle.update();
      }
      
      // Add new particles near mouse if needed and mouse is in header
      if (_isMouseInHeader && _mousePosition != Offset.zero) {
        if (_particles.length < 30) {
          // Add some randomness to particle spawn position
          final random = math.Random();
          final spawnOffset = Offset(
            _mousePosition.dx + (random.nextDouble() - 0.5) * 500,
            _mousePosition.dy + (random.nextDouble() - 0.5) * 500,
          );
          _particles.add(Particle(spawnOffset));
        }
      }
    });
  }

  DateTime _lastMouseUpdate = DateTime.now();

  void _onMouseMove(Offset position) {
    final now = DateTime.now();
    
    // Throttle mouse updates to every 50ms
    if (now.difference(_lastMouseUpdate).inMilliseconds < 50) return;
    
    _lastMouseUpdate = now;
    
    setState(() {
      _mousePosition = position;
    });
  }

  void _onHeaderHover(bool isHovered) {
    if (_isMouseInHeader != isHovered) {
      setState(() {
        _isMouseInHeader = isHovered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1600),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:Column(
                  children: [
                    SizedBox(height: 20),
                    CategorySelector(),
                    SizedBox(height: 20),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 20),
                    //PopularProductsRail(),
                    ShowcaseWidget(
                      type: ShowcaseType.popular,
                      title: "Popular Products",
                      description: "Some description",
                      products: context.read<PopularProductsService>().getPopularProducts(),
                    ),
                    SizedBox(height: 20),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 20),
                    HowItWorksSection(),
                    SizedBox(height: 20),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 20),
                    ShowcaseWidget(
                      type: ShowcaseType.seasonal,
                      title: "Popular Products",
                      description: "Some description",
                      products: context.read<PopularProductsService>().getPopularProducts(),
                    ),
                    //DiscountGoods()
                    SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 768;
        
        return Container(
          height: 350,
          child: MouseRegion(
            onHover: isMobile ? null : (event) {
              _onMouseMove(event.localPosition);
              if (!_isMouseInHeader) {
                _onHeaderHover(true);
              }
            },
            onExit: isMobile ? null : (event) {
              _onHeaderHover(false);
            },
            child: Stack(
              children: [
                ClipRRect( // For BigCrossesPainter to not overflow
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFF3E0),
                          Color(0xFFFFE0B2),
                          Color(0xFFFFCC80),
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      painter: BigCrossesPainter(),
                      child: Container(),
                    ),
                  ),
                ),
                
                // Glassy background for content area
                Positioned.fill(
                  child: CustomPaint(
                    painter: CenterIslandPainter(screenWidth: screenWidth),
                  ),
                ),

                // Particle system
                if (!isMobile) ...[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ParticlePainter(_particles),
                    ),
                  ),
                ],

                // Top navigation
                TopNavigationBar(isMobile: isMobile, screenWidth: screenWidth, isSearchBar: false, isTextMenu: true),
                
                // Main content
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main title
                          Text(
                            "Your local pharmacies in one place",
                            style: TextStyle(
                              fontSize: isMobile ? 28 : 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Search container
                          SearchContainer(isMobile: isMobile, screenWidth: screenWidth),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: 40, 
            horizontal: isMobile ? 16 : 24
          ),
          color: Color(0xFF2E3A59),
          child: Text(
            "© 2024 Pharma. All rights reserved.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  double life;
  double maxLife;
  Color color;
  double size;

  Particle(Offset startPosition) 
    : position = startPosition,
      velocity = Offset(
        (math.Random().nextDouble() - 0.5) * 1,
        (math.Random().nextDouble() - 0.5) * 1,
      ),
      life = 45.0,
      maxLife = 45.0,
      size = 2.0 + math.Random().nextDouble() * 4.0,
      color = Color.fromARGB(255, 255, 255, 255);

  void update() {
    position += velocity;
    life -= 1.0;
    velocity *= 0.99; // Friction
  }

  bool get isDead => life <= 0;
  
  double get opacity => (life / maxLife) * 0.8;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    
    for (var particle in particles) {
      paint.color = particle.color.withValues(alpha: particle.opacity);
      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BigCrossesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double crossSize = 100.0;
    final double centerY = size.height / 2;
    
    // Left cross (half visible - positioned at left edge)
    _drawCross(canvas, Offset(0 + 90, centerY + 60), crossSize);
    
    // Right cross (half visible - positioned at right edge)
    _drawCross(canvas, Offset(size.width - 90, centerY + 80), crossSize);
  }

  void _drawCross(Canvas canvas, Offset center, double crossSize) {
    final double radius = 12.0;
    final double armWidth = crossSize;
    final double armLength = crossSize * 3;

    // Create rounded cross using RRect union approach
    final horizontalRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: armLength,
        height: armWidth,
      ),
      Radius.circular(radius),
    );

    final verticalRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: armWidth,
        height: armLength,
      ),
      Radius.circular(radius),
    );

    // Create paths from rounded rectangles
    final Path crossPath = Path();
    crossPath.addRRect(horizontalRect);
    crossPath.addRRect(verticalRect);
    
    // Use PathOperation.union to merge them into one smooth shape
    final Path unifiedCross = Path.combine(PathOperation.union, 
      Path()..addRRect(horizontalRect), 
      Path()..addRRect(verticalRect)
    );

    // Inner glow/fill with orange gradient
    final fillPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Color.fromARGB(255, 255, 141, 53).withValues(alpha: 0.4), // Bright orange center
          Color(0xFFFF8C42).withValues(alpha: 0.3), // Orange-yellow middle
          Color(0xFFFFB347).withValues(alpha: 0.2), // Light orange edges
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCenter(
        center: center,
        width: armLength,
        height: armLength,
      ));

    canvas.drawPath(unifiedCross, fillPaint);

    // Outer glow effect
    final glowPaint = Paint()
      ..color = Color.fromARGB(255, 252, 120, 73).withValues(alpha: 0.2)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawPath(unifiedCross, glowPaint);

    // Main vivid border
    final borderPaint = Paint()
      ..color = Color(0xFFFF6B35) // Bright orange border
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(unifiedCross, borderPaint);

    // Inner bright border for extra definition
    final innerBorderPaint = Paint()
      ..color = Color(0xFFFFB347).withValues(alpha: 0.8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(unifiedCross, innerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CenterIslandPainter extends CustomPainter {
  final double screenWidth;

  CenterIslandPainter({required this.screenWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Calculate responsive dimensions
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    // Adjust glass panel size based on screen size
    double panelWidth;
    double panelHeight;
    
    if (isMobile) {
      panelWidth = size.width * 0.9;
      panelHeight = size.height * 0.65;
    } else if (isTablet) {
      panelWidth = size.width * 0.8;
      panelHeight = size.height * 0.65;
    } else {
      panelWidth = size.width * 0.7;
      panelHeight = size.height * 0.65;
    }

    if (panelWidth < 720 && !isMobile) {
      panelWidth = 720; // Minimum width for desktop
    }
    
    final radius = 24.0;
    
    // Create the main glass panel rectangle
    final glassRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: panelWidth,
        height: panelHeight,
      ),
      Radius.circular(radius),
    );
    
    // Create a path for the glass effect
    final Path glassPath = Path()..addRRect(glassRect);
    
    // Background blur effect (simulating glass)
    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(glassPath, backgroundPaint);
    
    // Add frosted glass effect with gradient
    final frostPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.2),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(glassRect.outerRect);
    
    canvas.drawPath(glassPath, frostPaint);
    
    // Add subtle inner glow
    final innerGlowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0);
    
    canvas.drawPath(glassPath, innerGlowPaint);
    
    // Add border with glass-like appearance
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.6),
          Colors.white.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.4),
        ],
      ).createShader(glassRect.outerRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawPath(glassPath, borderPaint);
    
    // Add subtle shadow behind the glass
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0);
    
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx + 2, center.dy + 4),
        width: panelWidth,
        height: panelHeight,
      ),
      Radius.circular(radius),
    );
    
    canvas.drawRRect(shadowRect, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is CenterIslandPainter) {
      return oldDelegate.screenWidth != screenWidth;
    }
    return true;
  }
}