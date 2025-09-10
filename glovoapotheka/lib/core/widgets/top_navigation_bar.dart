import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/core/widgets/volumetric_pharmacy_icon.dart';
import 'package:glovoapotheka/features/auth/cubit/auth_cubit.dart';

import 'package:glovoapotheka/core/widgets/login_button_widget.dart';
import 'package:glovoapotheka/core/widgets/user_cabinet_button_widget.dart';
import 'package:glovoapotheka/features/search/view/search_bar_widget.dart';


class TopNavigationBar extends StatelessWidget {
  final bool isMobile;
  final double screenWidth;
  final bool isSearchBar;
  final bool isTextMenu;
  final String? controllerText;

  const TopNavigationBar({
    super.key, 
    required this.isMobile, 
    required this.screenWidth,
    this.isSearchBar = false,
    this.isTextMenu = false,
    this.controllerText,
  });

  static const double minWidthForTextMenu = 1442;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout(context);
    }
  }

  Widget _buildDesktopLayout(context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 24),
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
    );
  }
}

Widget _buildMobileLayout () {
  return Text(
    "Smt"
  );
}