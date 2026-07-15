import 'dart:io';
import 'package:flutter/material.dart';

class MealImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const MealImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else if (imagePath.isEmpty) {
      return _buildFallback();
    } else {
      return Image.file(
        File(imagePath),
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
  }

  Widget _buildFallback() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.restaurant_rounded, color: Colors.grey, size: 50),
    );
  }
}
