import 'package:flutter/material.dart';

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