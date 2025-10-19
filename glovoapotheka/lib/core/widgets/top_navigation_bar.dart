import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/core/widgets/mobile_search_sheet_widget.dart';
import 'package:glovoapotheka/core/widgets/volumetric_pharmacy_icon.dart';
import 'package:glovoapotheka/data/providers/cart_provider.dart';
import 'package:glovoapotheka/features/auth/cubit/auth_cubit.dart';

import 'package:glovoapotheka/core/widgets/login_button_widget.dart';
import 'package:glovoapotheka/core/widgets/user_cabinet_button_widget.dart';
import 'package:glovoapotheka/features/search/view/search_bar_widget.dart';
import 'package:go_router/go_router.dart';

class TopNavigationBar extends StatelessWidget {
  final bool isMobile;
  final double screenWidth;
  final bool isSearchBar;
  final bool isTextMenu;
  final String? controllerText;
  final Color? color;
  final bool isShadow;

  const TopNavigationBar({
    super.key, 
    required this.isMobile, 
    required this.screenWidth,
    this.isSearchBar = false,
    this.isTextMenu = false,
    this.controllerText,
    this.color,
    this.isShadow = false,
  });

  static const double minWidthForTextMenu = 1442;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileLayout(context);
    } else {
      return _buildDesktopLayout(context);
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color ?? Colors.transparent,
        boxShadow: isShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ]
            : [], // If isShadow is false, the list is empty, and no shadow is rendered.
      ),
      child: GestureDetector(
        onTap: () {
          context.go('/', extra: null);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VolumetricPharmacyIcon(size: 40),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Sponfa",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 18),
                  if (isTextMenu && screenWidth > minWidthForTextMenu)
                  ...[
                    Container(
                      width: 1,
                      height: 30,
                      color: const Color.fromARGB(255, 129, 129, 129),
                    ),
                    SizedBox(width: 10),
                    Row(
                      children: [
                        TextButton(
                          child: Text(
                            "How it works",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () {
                            final Size screenSize = MediaQuery.of(context).size;
                            final double screenWidth = screenSize.width;
                            print('Current screen width: $screenWidth');
                          },
                        ),
                        TextButton(
                          child: Text(
                            "Help",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () {},
                        ),
                        TextButton(
                          child: Text(
                            "Contact",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 12),

            // Search bar
            if (isSearchBar)
              Expanded(
                child: UnifiedSearchBar(isNavBar: true, isCitySelector: false, controllerText: controllerText),
              ),

            SizedBox(width: 12),
            
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
                    cart.showCartPopup(context);
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
                      return UserCabinetButtonWidget(isMobile: isMobile);
                    } else {
                      return LoginButtonWidget(isMobile: isMobile);
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final cart = context.read<CartProvider>();
    
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        boxShadow: isShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: () {
              context.go('/', extra: null);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VolumetricPharmacyIcon(size: 32),
                SizedBox(width: 6),
                Text(
                  "Sponfa",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 12),

          // Search Bar
          if (isSearchBar)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _showMobileSearch(context, controllerText);
                },
                child: Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controllerText?.isNotEmpty == true 
                              ? controllerText! 
                              : "Search products...",
                          style: TextStyle(
                            color: controllerText?.isNotEmpty == true 
                                ? Colors.black87 
                                : Colors.grey[500],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          SizedBox(width: 12),

          // Shopping Cart Button
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            color: Colors.orange[700],
            iconSize: 24,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
              padding: EdgeInsets.all(8),
            ),
            onPressed: () {
              cart.showCartPopup(context);
            },
          ),
        ],
      ),
    );
  }

  void _showMobileSearch(BuildContext context, String? initialText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileSearchSheet(initialText: initialText),
    );
  }
}