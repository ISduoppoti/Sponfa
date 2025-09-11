import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:glovoapotheka/features/auth/cart/view/cart_view.dart';
import 'package:http/http.dart' as http;

import 'package:glovoapotheka/data/models/city.dart';

class CartService extends ChangeNotifier {


  
  void showCartPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          width: 1200,
          height: 800,
          child: CartPage(), // reuse
        ),
      ),
    );
  }
}