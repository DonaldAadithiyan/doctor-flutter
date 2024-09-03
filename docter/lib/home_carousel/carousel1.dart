//docter/lib/home_carousel/carousel1.dart

import 'package:flutter/material.dart';

class Carousel1 extends StatelessWidget {
  final String imageUrl;

  const Carousel1({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel Image'),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
