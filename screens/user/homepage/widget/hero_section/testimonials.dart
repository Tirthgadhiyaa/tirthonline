import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models.dart';

class TestimonialsWidget extends StatelessWidget {
  final List<CustomerTestimonial> testimonials;
  final bool isMobile;
  final bool isTablet;
  final ColorScheme colorScheme;

  const TestimonialsWidget({
    super.key,
    required this.testimonials,
    required this.isMobile,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
      ),
      child: Column(
        children: [
          // Testimonials grid
          isMobile
              ? Column(
                  children: testimonials.map((testimonial) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _buildTestimonialCard(testimonial, colorScheme),
                    );
                  }).toList(),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: testimonials.map((testimonial) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildTestimonialCard(testimonial, colorScheme),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(
      CustomerTestimonial testimonial, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Quote icon
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.format_quote,
              color: Color(0xFFD4AF37),
              size: 24,
            ),
          ),

          const SizedBox(height: 30),

          // Testimonial text
          Text(
            testimonial.testimonial,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              height: 1.8,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          // Rating stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < testimonial.rating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFD4AF37),
                  size: 24,
                ),
              );
            }),
          ),

          const SizedBox(height: 30),

          // Client info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Client image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    imageUrl: testimonial.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colorScheme.surfaceVariant,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: colorScheme.surfaceVariant,
                      child: const Icon(Icons.person),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Client name and location
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testimonial.name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    testimonial.location,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Product purchased
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              testimonial.productPurchased,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
