// lib/screens/user/homepage/widget/hero_section/education_center.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EducationCenterWidget extends StatelessWidget {
  final bool isMobile;
  final ColorScheme colorScheme;

  const EducationCenterWidget({
    super.key,
    required this.isMobile,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 60,
      ),
      color: colorScheme.surface,
      child: Column(
        children: [
          // Section title
          Text(
            "Diamond Education Center",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // Section subtitle
          Text(
            "Learn about the 4Cs and make an informed purchase decision",
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: isMobile ? 14 : 16,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Education cards
          isMobile
              ? Column(
                  children: _buildEducationCards(context),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildEducationCards(context)
                      .map((card) => Expanded(child: card))
                      .toList(),
                ),

          const SizedBox(height: 40),

          // CTA button
          OutlinedButton(
            onPressed: () {
              context.push('/education/diamond-guide');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: const Color(0xFFD4AF37), width: 1),
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              "EXPLORE FULL DIAMOND GUIDE",
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEducationCards(BuildContext context) {
    final educationTopics = [
      {
        'icon': FontAwesomeIcons.gem,
        'title': 'Cut',
        'description':
            'Learn how a diamond\'s cut affects its brilliance and value.',
        'route': '/education/diamond-cut',
      },
      {
        'icon': FontAwesomeIcons.palette,
        'title': 'Color',
        'description':
            'Understand the color grading scale from colorless to light yellow.',
        'route': '/education/diamond-color',
      },
      {
        'icon': FontAwesomeIcons.magnifyingGlass,
        'title': 'Clarity',
        'description':
            'Discover how inclusions and blemishes impact a diamond\'s clarity.',
        'route': '/education/diamond-clarity',
      },
      {
        'icon': FontAwesomeIcons.weightScale,
        'title': 'Carat',
        'description':
            'Explore how a diamond\'s weight affects its appearance and price.',
        'route': '/education/diamond-carat',
      },
    ];

    return educationTopics.map((topic) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () {
            context.push(topic['route'] as String);
          },
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    topic['icon'] as IconData,
                    color: const Color(0xFFD4AF37),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  topic['title'] as String,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  topic['description'] as String,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "LEARN MORE",
                  style: TextStyle(
                    color: const Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
