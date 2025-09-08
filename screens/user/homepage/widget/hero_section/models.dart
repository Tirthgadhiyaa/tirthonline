import 'package:flutter/material.dart';

class FeaturedCollection {
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final String category;
  final String cta;
  final String route;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;

  FeaturedCollection({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.category,
    required this.cta,
    required this.route,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
  });
}

class CategoryShowcase {
  final String name;
  final String image;
  final IconData icon;
  final String route;

  CategoryShowcase({
    required this.name,
    required this.image,
    required this.icon,
    required this.route,
  });
}

class CustomerTestimonial {
  final String name;
  final String location;
  final String image;
  final String testimonial;
  final int rating;
  final String productPurchased;

  CustomerTestimonial({
    required this.name,
    required this.location,
    required this.image,
    required this.testimonial,
    required this.rating,
    required this.productPurchased,
  });
}
