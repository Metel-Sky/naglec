import 'package:flutter/material.dart';

class RoomTemplate extends StatelessWidget {
  final String imagePath;

  const RoomTemplate({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.black45,
          child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.white24)),
        ),
      ),
    );
  }
}