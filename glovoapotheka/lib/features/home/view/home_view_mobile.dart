import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import 'package:glovoapotheka/core/widgets/top_navigation_bar.dart';
import 'package:glovoapotheka/data/models/product.dart';
import 'package:glovoapotheka/features/home/widgets/prescription_widget.dart';

import 'package:glovoapotheka/features/home/widgets/search_container_widget.dart';
import 'package:glovoapotheka/features/home/widgets/how_it_works_widget.dart';
import 'package:glovoapotheka/features/home/widgets/categories_widget.dart';
import 'package:glovoapotheka/features/home/widgets/discount_goods_widger.dart';
import 'package:glovoapotheka/features/home/widgets/popular_products_widget.dart';
import 'package:glovoapotheka/features/home/widgets/product_showcase_widget.dart';

import 'package:glovoapotheka/domain/services/popular_products_service.dart';


class HomeViewMobile extends StatefulWidget {
  const HomeViewMobile({super.key});

  @override
  _HomeViewMobileState createState() => _HomeViewMobileState();
}

class _HomeViewMobileState extends State<HomeViewMobile> {
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
                    PrescriptionWidget(),
                    SizedBox(height: 20),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 20),
                    ShowcaseWidget(
                      type: ShowcaseType.seasonal,
                      title: "Seasonal Products",
                      description: "Some description",
                      products: context.read<PopularProductsService>().getPopularProducts(),
                    ),
                    SizedBox(height: 20),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 20),
                    ShowcaseWidget(
                      type: ShowcaseType.popular,
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
        
        return TopNavigationBar(isMobile: true, screenWidth: screenWidth, isSearchBar: true, isTextMenu: false);
      },
    );
  }

  Widget _buildFooter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: 40, 
            horizontal: 16
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