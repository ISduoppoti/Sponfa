import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginLeftSide extends StatelessWidget {
  const LoginLeftSide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFeatureItem(
            icon: _buildShieldIcon(),
            title: 'Verified Pharmacies',
            description: 'All offers go through license and product availability verification. You only see verified and reliable pharmacies next to you.',
            isFirst: true,
          ),
          const SizedBox(height: 48),
          _buildFeatureItem(
            icon: _buildPercentIcon(),
            title: 'Up to 80% savings',
            description: 'We compare prices at dozens of pharmacies at once, so you get the best offer. Price differences for the same drug can reach hundreds of hryvnias.',
          ),
          const SizedBox(height: 48),
          _buildFeatureItem(
            icon: _buildTimerIcon(),
            title: '1-minute booking',
            description: 'Found what you need? Book online in just a few clicks — and it will be waiting for you at your chosen pharmacy.',
          ),
          const SizedBox(height: 48),
          _buildFeatureItem(
            icon: _buildBoxIcon(),
            title: 'Pickup or delivery',
            description: 'Get your order today: pick it up in person or arrange courier delivery.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required Widget icon,
    required String title,
    required String description,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon column with connecting dots
        Column(
          children: [
            // Top connecting dots (hidden for first item)
            if (!isFirst) _buildConnectingDots(),
            // Icon container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8D6), // Light orange background
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(child: icon),
            ),
            // Bottom connecting dots (hidden for last item)
            if (!isLast) _buildConnectingDots(),
          ],
        ),
        const SizedBox(width: 24),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35), // Orange color
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectingDots() {
    return Container(
      height: 26,
      width: 2,
      child: Column(
        children: [
          Container(
            width: 2,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB088),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 2,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB088),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 2,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB088),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShieldIcon() {
    return SvgPicture.string(
      '''<svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 2L4 7V11C4 16.55 7.84 21.74 12 23C16.16 21.74 20 16.55 20 11V7L12 2Z" fill="#FF6B35"/>
        <path d="M10 12L8.5 10.5L7.08 11.92L10 14.84L16.92 7.92L15.5 6.5L10 12Z" fill="white"/>
      </svg>''',
      width: 32,
      height: 32,
    );
  }

  Widget _buildPercentIcon() {
    return SvgPicture.string(
      '''<svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="12" cy="12" r="10" stroke="#FF6B35" stroke-width="2" fill="none"/>
        <path d="M9 15L15 9" stroke="#FF6B35" stroke-width="2"/>
        <circle cx="9.5" cy="9.5" r="1.5" fill="#FF6B35"/>
        <circle cx="14.5" cy="14.5" r="1.5" fill="#FF6B35"/>
      </svg>''',
      width: 32,
      height: 32,
    );
  }

  Widget _buildTimerIcon() {
    return SvgPicture.string(
      '''<svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="12" cy="13" r="9" stroke="#FF6B35" stroke-width="2" fill="none"/>
        <path d="M12 7V13L16 15" stroke="#FF6B35" stroke-width="2" stroke-linecap="round"/>
        <path d="M9 2H15" stroke="#FF6B35" stroke-width="2" stroke-linecap="round"/>
      </svg>''',
      width: 32,
      height: 32,
    );
  }

  Widget _buildBoxIcon() {
    return SvgPicture.string(
      '''<svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 2L2 7V17C2 17.5304 2.21071 18.0391 2.58579 18.4142C2.96086 18.7893 3.46957 19 4 19H20C20.5304 19 21.0391 18.7893 21.4142 18.4142C21.7893 18.0391 22 17.5304 22 17V7L12 2Z" stroke="#FF6B35" stroke-width="2" fill="#FF6B35" fill-opacity="0.1"/>
        <path d="M2 7L12 12L22 7" stroke="#FF6B35" stroke-width="2"/>
        <path d="M12 12V12" stroke="#FF6B35" stroke-width="2"/>
      </svg>''',
      width: 32,
      height: 32,
    );
  }
}