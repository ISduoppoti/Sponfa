import 'package:flutter/material.dart';

import 'package:glovoapotheka/features/search/view/search_bar_widget.dart';


class SearchContainer extends StatelessWidget {
  final bool isMobile;
  final double screenWidth;

  const SearchContainer({
    super.key,
    required this.isMobile,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {

    if (isMobile) {
      // Mobile: Stack vertically
      return SizedBox(width: 10);
    } else {
      // Desktop/Tablet: Single row
      return UnifiedSearchBar();
    }
  }
}