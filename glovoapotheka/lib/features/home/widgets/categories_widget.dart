import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategorySelector extends StatefulWidget {
  final Function(String)? onCategorySelected;
  final Function(String)? onPopularItemSelected;
  
  const CategorySelector({
    Key? key,
    this.onCategorySelected,
    this.onPopularItemSelected,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  
  // Track hover states
  String? hoveredCategory;
  String? hoveredPopularItem;
  
  // Main categories with their SVG paths
  final Map<String, String> categories = {
    'Health & care': 'assets/images/health_care.svg',
    'Vitamins': 'assets/images/vitamins.svg',
    'Cosmetics': 'assets/images/cosmetics.svg',
    'Sexual health': 'assets/images/sexual_health.svg',
    'Child care': 'assets/images/child_care.svg',
    'Medical equipment': 'assets/images/med_instr.svg',
    'Sport': 'assets/images/sport.svg',
    'Pets': 'assets/images/pets.svg',
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        if (isMobile) {
          return _buildMobileLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main categories row
        SizedBox(
          width: double.infinity,
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: categories.entries.map((entry) {
              return Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => hoveredCategory = entry.key),
                  onExit: (_) => setState(() => hoveredCategory = null),
                  child: AnimatedScale(
                    scale: hoveredCategory == entry.key ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: GestureDetector(
                      onTap: () {
                        widget.onCategorySelected?.call(entry.key);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.orange.shade100.withValues(alpha: 0.4),
                              Colors.orange.shade50.withValues(alpha: 0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              entry.value,
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                entry.key,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shop by category',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // 2x4 Grid layout for mobile
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories.keys.elementAt(index);
              return GestureDetector(
                onTap: () {
                  widget.onCategorySelected?.call(category);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}