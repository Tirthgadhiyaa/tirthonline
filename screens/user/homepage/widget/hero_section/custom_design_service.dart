// lib/screens/user/homepage/widget/hero_section/custom_design_service.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDesignServiceWidget extends StatelessWidget {
  final bool isMobile;
  final ColorScheme colorScheme;

  const CustomDesignServiceWidget({
    super.key,
    required this.isMobile,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 100,
        horizontal: isMobile ? 20 : 60,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                _buildContent(),
                const SizedBox(height: 60),
                _buildImage(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildContent(),
                ),
                Expanded(
                  flex: 4,
                  child: _buildImage(),
                ),
              ],
            ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        const Text(
          "Create a one-of-a-kind piece that tells your unique story. Our expert designers will work closely with you to bring your vision to life, from initial sketch to final creation.",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            height: 1.8,
            letterSpacing: 0.3,
          ),
        ),

        const SizedBox(height: 50),

        // Process steps
        _buildProcessStep(
          number: "01",
          title: "Consultation",
          description:
              "Meet with our design team to discuss your vision and preferences.",
        ),
        const SizedBox(height: 30),
        _buildProcessStep(
          number: "02",
          title: "Design & Approval",
          description:
              "Review sketches and 3D renderings until the design is perfect.",
        ),
        const SizedBox(height: 30),
        _buildProcessStep(
          number: "03",
          title: "Creation",
          description:
              "Our master craftsmen bring your design to life with precision.",
        ),
        const SizedBox(height: 30),
        _buildProcessStep(
          number: "04",
          title: "Delivery",
          description:
              "Receive your custom creation with a certificate of authenticity.",
        ),

        const SizedBox(height: 50),

        // CTA button
        ElevatedButton(
          onPressed: () {
            // Navigate to custom design page
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
          ),
          child: const Text(
            "SCHEDULE CONSULTATION",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 25),

          // Step content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      margin: EdgeInsets.only(left: isMobile ? 0 : 60),
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage(
            "https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=1974",
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
