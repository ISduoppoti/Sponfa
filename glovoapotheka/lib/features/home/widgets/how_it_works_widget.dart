import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:math' as Math;

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({Key? key}) : super(key: key);

  // Defined a reference width at which the base sizes look optimal.
  // All other sizes will scale proportionally to this reference.
  static const double _referenceDesktopWidth = 1600.0;

  // Base dimensions for desktop mode components when at _referenceDesktopWidth
  static const double _baseIconSize = 200.0;
  static const double _baseConnectorWidth = 120.0;
  static const double _baseConnectorHeight = 60.0; // The max height of the wavy line container
  static const double _baseDotRadius = 6.0;
  static const double _baseDotSpacing = 16.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      color: Colors.grey[50],
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 727) {
            // Calculate the scaling factor based on the current available width.
            // We use Math.min(1.0, ...) to ensure elements don't grow beyond
            // their base size even on very large screens, unless desired.
            // Math.max(0.5, ...) ensures a minimum scale, preventing elements from becoming too small.
            double scaleFactor = Math.min(1.0, constraints.maxWidth / _referenceDesktopWidth);
            scaleFactor = Math.max(0.5, scaleFactor);

            return _buildDesktopLayout(scaleFactor);
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(double scaleFactor) {
    // Calculate the actual dimensions based on the scaleFactor
    final double iconSize = _baseIconSize * scaleFactor;
    final double connectorWidth = _baseConnectorWidth * scaleFactor;
    final double connectorHeight = _baseConnectorHeight * scaleFactor;
    final double dotRadius = _baseDotRadius * scaleFactor;
    final double dotSpacing = _baseDotSpacing * scaleFactor;

    return Center(
      child: ConstrainedBox(
        // The overall row itself can be constrained to the reference width
        // or a maximum percentage of the screen width to prevent it from getting too wide.
        // Here, it's set to the _referenceDesktopWidth, allowing its contents to scale within it.
        constraints: const BoxConstraints(maxWidth: _referenceDesktopWidth),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnector(
              shift: 1,
              connectorWidth: connectorWidth,
              connectorHeight: connectorHeight,
              dotRadius: dotRadius,
              dotSpacing: dotSpacing,
            ),
            _buildStep(
              iconPath: 'assets/images/how_search.svg',
              iconSize: iconSize,
              step: 1,
            ),
            _buildConnector(
              shift: 0,
              connectorWidth: connectorWidth,
              connectorHeight: connectorHeight,
              dotRadius: dotRadius,
              dotSpacing: dotSpacing,
            ),
            _buildStep(
              iconPath: 'assets/images/how_pharma.svg',
              iconSize: iconSize,
              step: 2,
            ),
            _buildConnector(
              shift: 1,
              connectorWidth: connectorWidth,
              connectorHeight: connectorHeight,
              dotRadius: dotRadius,
              dotSpacing: dotSpacing,
            ),
            _buildStep(
              iconPath: 'assets/images/how_book.svg',
              iconSize: iconSize,
              step: 3,
            ),
            _buildConnector(
              shift: 0, 
              connectorWidth: connectorWidth,
              connectorHeight: connectorHeight,
              dotRadius: dotRadius,
              dotSpacing: dotSpacing,
            ),
            _buildStep(
              iconPath: 'assets/images/how_pick.svg',
              iconSize: iconSize,
              step: 4,
            ),
            _buildConnector(
              shift: 1,
              connectorWidth: connectorWidth,
              connectorHeight: connectorHeight,
              dotRadius: dotRadius,
              dotSpacing: dotSpacing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    // For mobile, you can define a separate fixed scale or responsive logic.
    // Here, icons are scaled down to 70% of their base desktop size.
    final double mobileIconSize = _baseIconSize * 0.7;

    return Column(
      children: [
        _buildStep(
          iconPath: 'assets/images/how_search.svg',
          iconSize: mobileIconSize,
          step: 1,
        ),
        _buildVerticalConnector(
          shift: 0,
          // Mobile vertical connector specific sizing
          connectorWidth: 60,
          connectorHeight: 80,
          dotRadius: 3,
          dotSpacing: 8,
        ),
        _buildStep(
          iconPath: 'assets/images/how_pharma.svg',
          iconSize: mobileIconSize,
          step: 2,
        ),
        _buildVerticalConnector(
          shift: 0,
          connectorWidth: 60,
          connectorHeight: 80,
          dotRadius: 3,
          dotSpacing: 8,
        ),
        _buildStep(
          iconPath: 'assets/images/how_book.svg',
          iconSize: mobileIconSize,
          step: 3,
        ),
        _buildVerticalConnector(
          shift: 0,
          connectorWidth: 60,
          connectorHeight: 80,
          dotRadius: 3,
          dotSpacing: 8,
        ),
        _buildStep(
          iconPath: 'assets/images/how_pick.svg',
          iconSize: mobileIconSize,
          step: 4,
        ),
      ],
    );
  }

  Widget _buildStep({
    required String iconPath,
    required double iconSize,
    required int step,
  }) {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Center(
        child: SvgPicture.asset(
          iconPath,
          width: iconSize,
          height: iconSize,
        ),
      ),
    );
  }

  Widget _buildConnector({
    required int shift,
    required double connectorWidth,
    required double connectorHeight,
    required double dotRadius,
    required double dotSpacing,
  }) {
    return Container(
      width: connectorWidth,
      height: connectorHeight,
      child: CustomPaint(
        painter: WavyDottedLinePainter(
          color: Colors.orange[300]!,
          dotRadius: dotRadius,
          dotSpacing: dotSpacing,
          shift: shift,
        ),
      ),
    );
  }

  Widget _buildVerticalConnector({
    required int shift,
    required double connectorWidth,
    required double connectorHeight,
    required double dotRadius,
    required double dotSpacing,
  }) {
    return Container(
      width: connectorWidth,
      height: connectorHeight,
      margin: const EdgeInsets.symmetric(vertical: 10), // Fixed margin for vertical
      child: CustomPaint(
        painter: WavyDottedLinePainter(
          color: Colors.orange[300]!,
          dotRadius: dotRadius,
          dotSpacing: dotSpacing,
          isVertical: true,
          shift: shift,
        ),
      ),
    );
  }
}

class WavyDottedLinePainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double dotSpacing;
  final bool isVertical;
  final int shift; // '0' for upward curve, '1' for downward curve

  WavyDottedLinePainter({
    required this.color,
    required this.dotRadius,
    required this.dotSpacing,
    required this.shift,
    this.isVertical = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (isVertical) {
      _paintVerticalWavy(canvas, size, paint);
    } else {
      _paintHorizontalWavy(canvas, size, paint);
    }
  }

  void _paintHorizontalWavy(Canvas canvas, Size size, Paint paint) {
    double totalLength = size.width;
    int numberOfDots = (totalLength / dotSpacing).floor();
    if (numberOfDots == 0 && totalLength > 0) {
      numberOfDots = 1;
    }
    
    for (int i = 0; i < numberOfDots; i++) {
      double x = (i * dotSpacing) + (dotSpacing / 2);
      double progress = x / totalLength;
      
      double waveAmplitude = size.height / 2;
      double y;


      if (shift == 0) {
        y = size.height / 2 + (waveAmplitude * 1.5) - waveAmplitude * Math.sin(progress * Math.pi / 2);
      } else {
        y = size.height / 2 + (waveAmplitude * 1.5) + waveAmplitude * Math.sin(progress * Math.pi / 2);
      }
      
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  void _paintVerticalWavy(Canvas canvas, Size size, Paint paint) {
    double totalLength = size.height;
    int numberOfDots = (totalLength / dotSpacing).floor();
    if (numberOfDots == 0 && totalLength > 0) {
      numberOfDots = 1;
    }
    
    for (int i = 0; i < numberOfDots; i++) {
      double y = (i * dotSpacing) + (dotSpacing / 2);
      
      double progress = y / totalLength;
      
      double waveAmplitude = size.width / 2;
      double x;

      if (shift == 0) {
        x = size.width / 2 + waveAmplitude * Math.sin(progress * Math.pi / 2);
      } else {
        x = size.width / 2 - waveAmplitude * Math.sin(progress * Math.pi / 2);
      }
      
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is WavyDottedLinePainter) {
      return oldDelegate.color != color ||
             oldDelegate.dotRadius != dotRadius ||
             oldDelegate.dotSpacing != dotSpacing ||
             oldDelegate.isVertical != isVertical ||
             oldDelegate.shift != shift;
    }
    return true;
  }
}
