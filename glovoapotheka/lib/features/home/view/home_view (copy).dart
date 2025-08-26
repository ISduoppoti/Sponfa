import 'package:glovoapotheka/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

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
  String _selectedCity = "Select City";

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
            _buildHowItWorks(),
            _buildCategories(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // Login Button Component
  Widget _buildLoginButton(isMobile) {
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
          Navigator.pushNamed(context, '/login');
        },
      )
    );
  }


  Widget _buildUserCabinetButton(isMobile) {
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
              color: Colors.black.withOpacity(0.1),
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
            SizedBox(width: isMobile ? 4 : 6),
            Text(
              'Gey Oleg Eduardovich', // Replace with user's name
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isMobile ? 14 : 16,
                color: Colors.orange[700],
              ),
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

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 768;
        final isTablet = screenWidth >= 768 && screenWidth < 1024;
        
        return Container(
          height: isMobile ? 550 : 450,
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
                // Background with pharmacy crosses
                Container(
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
                Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VolumetricPharmacyIcon(size: isMobile ? 32 : 40),
                            SizedBox(width: isMobile ? 8 : 16),
                            Flexible(
                              child: Text(
                                "PharmaCompare",
                                style: TextStyle(
                                  fontSize: isMobile ? 20 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B35),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Menu items
                      Row(
                        children: [
                           // Shopping Cart Button
                          IconButton(
                            icon: Icon(Icons.shopping_cart_outlined), // Equivalent to Lucide Shopping Cart
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
                              // Handle shopping cart button tap
                              print('Shopping Cart button tapped');
                            },
                          ),
                          
                          SizedBox(width: isMobile ? 8 : 12), // Spacing between buttons

                          // List Button (e.g., Wishlist)
                          IconButton(
                            icon: Icon(Icons.assignment_outlined), // Equivalent to Lucide Clipboard List
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
                              // Handle list button tap
                              print('List button tapped');
                            },
                          ),

                          SizedBox(width: isMobile ? 8 : 12), // Spacing between buttons

                          // User Profile Button
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              if (state.status == AuthStatus.authenticated) {
                                return _buildUserCabinetButton(isMobile);
                              } else {
                                return _buildLoginButton(isMobile);
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                
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
                              fontSize: isMobile ? 28 : (isTablet ? 36 : 48),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Search container
                          _buildSearchContainer(isMobile, isTablet, screenWidth),
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

  Widget _buildSearchContainer(bool isMobile, bool isTablet, double screenWidth) {
    if (isMobile) {
      // Mobile: Stack vertically
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          children: [
            // City selector
            Container(
              width: double.infinity,
              height: 50,
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextButton(
                onPressed: _showCitySelector,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Color(0xFFFF6B35)),
                    SizedBox(width: 8),
                    Text(
                      _selectedCity,
                      style: TextStyle(color: Color(0xFFFF6B35)),
                    ),
                  ],
                ),
              ),
            ),
            
            // Search field and button
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter medication...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 20),
                          SizedBox(width: 4),
                          Text("Go", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Desktop/Tablet: Single row
      return Container(
        width: math.min(screenWidth * 0.8, 700),
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // City selector
            Container(
              width: isTablet ? 120 : 150,
              height: 60,
              child: TextButton(
                onPressed: _showCitySelector,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Color(0xFFFF6B35)),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _selectedCity,
                        style: TextStyle(color: Color(0xFFFF6B35)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              width: 1,
              height: 30,
              color: Colors.grey[300],
            ),
            
            // Search field
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Enter medication name...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
            
            // Search button
            Container(
              width: isTablet ? 100 : 120,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search),
                    if (!isTablet) ...[
                      SizedBox(width: 4),
                      Text("Search", style: TextStyle(fontSize: 16)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildHowItWorks() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 768;
        
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 40, 
            horizontal: isMobile ? 16 : 24
          ),
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
                Text(
                  "How Pharma Works",
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A59),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 20),
                
                if (isMobile) 
                  Column(
                    children: [
                      _buildHowItWorksStep(
                        icon: Icons.compare_arrows,
                        title: "Compare prices",
                        isMobile: true,
                      ),
                      SizedBox(height: 24),
                      _buildHowItWorksStep(
                        icon: Icons.local_offer,
                        title: "Get free coupons",
                        isMobile: true,
                      ),
                      SizedBox(height: 24),
                      _buildHowItWorksStep(
                        icon: Icons.local_pharmacy,
                        title: "Show to your pharmacist",
                        isMobile: true,
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildHowItWorksStep(
                        icon: Icons.compare_arrows,
                        title: "Compare prices",
                        isMobile: false,
                      ),
                      _buildHowItWorksStep(
                        icon: Icons.local_offer,
                        title: "Get free coupons",
                        isMobile: false,
                      ),
                      _buildHowItWorksStep(
                        icon: Icons.local_pharmacy,
                        title: "Show to your pharmacist",
                        isMobile: false,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHowItWorksStep({
    required IconData icon,
    required String title,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? double.infinity : 300,
      constraints: BoxConstraints(maxWidth: 300),
      child: Column(
        children: [
          Container(
            width: isMobile ? 80 : 100,
            height: isMobile ? 80 : 100,
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isMobile ? 40 : 50),
            ),
            child: Icon(
              icon,
              size: isMobile ? 40 : 50,
              color: Color(0xFFFF6B35),
            ),
          ),
          
          SizedBox(height: 24),
          
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A59),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 768;
        
        final categories = [
          {"name": "Diabetes", "color": Color(0xFF4CAF50), "icon": Icons.healing},
          {"name": "Fever & Infection", "color": Color(0xFF2196F3), "icon": Icons.thermostat},
          {"name": "Hair & Skin Care", "color": Color(0xFF9C27B0), "icon": Icons.face},
          {"name": "Thyroid", "color": Color(0xFF673AB7), "icon": Icons.favorite},
          {"name": "Women Care", "color": Color(0xFFE91E63), "icon": Icons.woman},
          {"name": "Heart", "color": Color(0xFFF44336), "icon": Icons.favorite},
          {"name": "Bone Health", "color": Color(0xFFFF9800), "icon": Icons.accessibility},
        ];

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 60, 
            horizontal: isMobile ? 16 : 24
          ),
          color: Colors.transparent,
          child: Column(
            children: [
              Text(
                "Browse by Category",
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 40),
              
              if (isMobile)
                // Mobile: Grid view
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryCard(
                      category["name"] as String,
                      category["color"] as Color,
                      category["icon"] as IconData,
                      isMobile: true,
                    );
                  },
                )
              else
                // Desktop: Horizontal scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      return Container(
                        margin: EdgeInsets.only(right: 16),
                        child: _buildCategoryCard(
                          category["name"] as String,
                          category["color"] as Color,
                          category["icon"] as IconData,
                          isMobile: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(String name, Color color, IconData icon, {required bool isMobile}) {
    return Container(
      width: isMobile ? null : 200,
      height: isMobile ? null : 250,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(isMobile ? 30 : 40),
            ),
            child: Icon(
              icon,
              size: isMobile ? 30 : 40,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            name,
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  void _showCitySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Your City"),
        content: Container(
          width: 300,
          height: 200,
          child: ListView(
            children: [
              "New York",
              "Los Angeles",
              "Chicago",
              "Houston",
              "Phoenix",
              "Philadelphia",
              "San Antonio",
              "San Diego",
            ].map((city) {
              return ListTile(
                title: Text(city),
                onTap: () {
                  setState(() {
                    _selectedCity = city;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
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
    const double crossSize = 120.0;
    final double centerY = size.height / 2;
    
    // Left cross (half visible - positioned at left edge)
    _drawCross(canvas, Offset(0 + 90, centerY + 15), crossSize);
    
    // Right cross (half visible - positioned at right edge)
    _drawCross(canvas, Offset(size.width - 90, centerY + 100), crossSize);
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
      panelHeight = size.height * 0.55;
    } else {
      panelWidth = size.width * 0.7;
      panelHeight = size.height * 0.5;
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

class VolumetricPharmacyIcon extends StatelessWidget {
  final double size;

  const VolumetricPharmacyIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final double crossThickness = size * 0.3;
    final double verticalBarHeight = size * 0.8;
    final double horizontalBarWidth = size * 0.8;
    final double cornerRadius = size * 0.05;

    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Horizontal part
          Container(
            width: horizontalBarWidth,
            height: crossThickness,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 245, 150, 7),
                  Color.fromARGB(255, 245, 200, 53),
                ],
              ),
            ),
          ),
          // Vertical part
          Container(
            width: crossThickness,
            height: verticalBarHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 245, 150, 7),
                  Color.fromARGB(255, 245, 200, 53),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}