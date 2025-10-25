import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:glovoapotheka/domain/services/popular_products_service.dart';

enum ShowcaseType { seasonal, popular }

class ShowcaseWidget extends StatelessWidget {
  final ShowcaseType type;
  final String title;
  final String description;
  final List<Product> products;

  const ShowcaseWidget({
    super.key,
    required this.type,
    required this.title,
    required this.description,
    required this.products,
  });

  Map<String, dynamic> _theme() {
    switch (type) {
      case ShowcaseType.seasonal:
        return {
          "gradient": LinearGradient(
            colors: [Colors.deepOrange.shade200, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          "color": Colors.deepOrange,
          "icon": Icons.local_florist,
          "buttonText": "Take a look",
        };
      case ShowcaseType.popular:
        return {
          "gradient": LinearGradient(
            colors: [Colors.purple.shade200, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          "color": Colors.purple,
          "icon": Icons.star_rounded,
          "buttonText": "Shop now",
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final theme = _theme();

        if (isMobile) {
          return _buildMobileLayout(theme, constraints);
        } else {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: theme["gradient"],
              borderRadius: BorderRadius.circular(20),
            ),
            child: _buildDesktopLayout(theme),
          );
        }
      },
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Left side
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 60),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(theme["icon"], color: Colors.white, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {},
                        child: Text(
                          theme["buttonText"],
                          style: TextStyle(
                            color: theme["color"],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 20),

        /// Right side (products)
        Expanded(
          child: SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              padding: const EdgeInsets.only(right: 20),
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildProductCard(products[index], theme);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> theme, BoxConstraints constraints) {
    final availableWidth = constraints.maxWidth - 32;
    final sep = 8.0;
    final cardWidth = (availableWidth - 2 * sep) / 2.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(theme["icon"], color: Colors.deepOrange, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) => SizedBox(width: sep),
            itemBuilder: (context, index) {
              return _buildProductCard(
                products[index],
                theme,
                cardWidth: cardWidth.clamp(140.0, 170.0),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product, Map<String, dynamic> theme, {double? cardWidth}) {
    final width = cardWidth ?? 180.0;
    final isMobile = cardWidth != null;

    if (!isMobile) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product image
            Container(
              height: isMobile ? 100 : 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                product.imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),

            /// Product info
            Text(
              product.name,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: Colors.black
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              product.strength,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "By ${product.manufacturer}",
              style: TextStyle(
                fontSize: isMobile ? 10 : 11,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            /// Price + Quantity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${product.price}€",
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "${product.quantity} pcs",
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            /// Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme["color"], width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: isMobile ? 6 : 8,
                  ),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "Find",
                  style: TextStyle(
                    color: theme["color"],
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      // Mobile-specific design
      return SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                product.imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.manufacturer,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 0, 0, 0),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              product.strength,
              style: const TextStyle(
                fontSize: 12,
                color: Color.fromARGB(179, 0, 0, 0),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${product.price} €",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                Text(
                  "${product.quantity} pcs",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color.fromARGB(179, 0, 0, 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme["color"],
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "Find",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}