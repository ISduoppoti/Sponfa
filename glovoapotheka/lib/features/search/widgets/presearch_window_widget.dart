import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchWidgetWindow extends StatelessWidget {
  final Size? searchBarSize;
  final VoidCallback? onClose;
  final FocusNode? focusNode;

  const SearchWidgetWindow({
    Key? key,
    this.searchBarSize,
    this.onClose,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    if (isMobile) {
      return _buildMobileView(context, screenSize);
    } else {
      return _buildDesktopView(context, screenSize);
    }
  }

  Widget _buildDesktopView(BuildContext context, Size screenSize) {
    final widgetWidth = searchBarSize?.width ?? 400.0;
    final maxWidth = (screenSize.width * 0.9).clamp(300.0, 800.0);
    final finalWidth = widgetWidth.clamp(300.0, maxWidth);

    return Container(
      width: finalWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPopularSection(context, false),
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          _buildCategoriesSection(context, false),
        ],
      ),
    );
  }

  Widget _buildMobileView(BuildContext context, Size screenSize) {
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPopularSection(context, true),
                    const Divider(height: 1, color: Color(0xFFE5E5E5)),
                    _buildCategoriesSection(context, true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSection(BuildContext context, bool isMobile) {
    final popularItems = [
      'Vitamin D3 + K2',
      'Alpha-Lipoic Acid',
      'Lemon Balm',
      'Liposomal Vitamin C',
      'Peppermint Oil',
      'D-Mannose',
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular',
            style: TextStyle(
              fontSize: isMobile ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: popularItems.map((item) => _buildPopularChip(item, isMobile)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularChip(String text, bool isMobile) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('Popular item pressed: $text');
          focusNode?.unfocus(); // Unfocus search field on tap
          onClose?.call(); // Close the search widget
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 12,
            vertical: isMobile ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 14 : 13,
              color: Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, bool isMobile) {
    final categories = [
      CategoryItem('Health & care', 'assets/images/health_care.svg'),
      CategoryItem('Vitamins', 'assets/images/vitamins.svg'),
      CategoryItem('Cosmetics', 'assets/images/cosmetics.svg'),
      CategoryItem('Sexual health', 'assets/images/sexual_health.svg'),
      CategoryItem('Child care', 'assets/images/child_care.svg'),
      CategoryItem('Medical equipment', 'assets/images/med_instr.svg'),
      CategoryItem('Sport', 'assets/images/sport.svg'),
      CategoryItem('Pets', 'assets/images/pets.svg'),
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse',
            style: TextStyle(
              fontSize: isMobile ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildCategoriesGrid(categories, isMobile),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(List<CategoryItem> categories, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isMobile ? 2 : 4;
        final childAspectRatio = isMobile ? 2.2 : 2.0;
        final maxCrossAxisExtent = constraints.maxWidth / crossAxisCount;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: isMobile ? 12 : 16,
            mainAxisSpacing: isMobile ? 12 : 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryCard(
              categories[index],
              isMobile,
              maxCrossAxisExtent - (isMobile ? 12 : 16),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(CategoryItem category, bool isMobile, double maxWidth) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _CategoryCardContent(
          category: category,
          isMobile: isMobile,
          onTap: () {
            print('Category pressed: ${category.name}');
            focusNode?.unfocus(); // Unfocus search field on tap
            onClose?.call(); // Close the search widget
          },
        ),
      ),
    );
  }
}

class _CategoryCardContent extends StatefulWidget {
  final CategoryItem category;
  final bool isMobile;
  final VoidCallback onTap;

  const _CategoryCardContent({
    required this.category,
    required this.isMobile,
    required this.onTap,
  });

  @override
  State<_CategoryCardContent> createState() => _CategoryCardContentState();
}

class _CategoryCardContentState extends State<_CategoryCardContent> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.isMobile ? null : (_) => setState(() => _isHovered = true),
      onExit: widget.isMobile ? null : (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered && !widget.isMobile ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(widget.isMobile ? 12.0 : 16.0),
              child: Row(
                children: [
                  Container(
                    width: widget.isMobile ? 32 : 28,
                    height: widget.isMobile ? 32 : 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(widget.isMobile ? 6 : 6),
                    child: SvgPicture.asset(
                      widget.category.iconPath,
                      width: widget.isMobile ? 20 : 16,
                      height: widget.isMobile ? 20 : 16,
                    ),
                  ),
                  SizedBox(width: widget.isMobile ? 12 : 10),
                  Expanded(
                    child: Text(
                      widget.category.name,
                      style: TextStyle(
                        fontSize: widget.isMobile ? 15 : 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
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
  }
}

class CategoryItem {
  final String name;
  final String iconPath;

  CategoryItem(this.name, this.iconPath);
}

// Usage example widget showing how to position the search widget
class SearchWidgetOverlay extends StatelessWidget {
  final Widget child;
  final bool showWidget;
  final Size? searchBarSize;
  final Offset? searchBarPosition;
  final VoidCallback? onClose;

  const SearchWidgetOverlay({
    Key? key,
    required this.child,
    required this.showWidget,
    this.searchBarSize,
    this.searchBarPosition,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showWidget) ...[
          // Background overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Search widget
          _buildPositionedWidget(context),
        ],
      ],
    );
  }

  Widget _buildPositionedWidget(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    if (isMobile) {
      return Positioned.fill(
        child: SearchWidgetWindow(
          searchBarSize: searchBarSize,
          onClose: onClose,
        ),
      );
    } else {
      final topPosition = (searchBarPosition?.dy ?? 60) + (searchBarSize?.height ?? 40) + 8;
      final leftPosition = searchBarPosition?.dx ?? 16;
      
      return Positioned(
        top: topPosition,
        left: leftPosition,
        child: SearchWidgetWindow(
          searchBarSize: searchBarSize,
          onClose: onClose,
        ),
      );
    }
  }
}