//docter/lib/home_carousel/carousel1.dart

import 'package:flutter/material.dart';

class Carousel1 extends StatelessWidget {
  final String imageUrl;

  Carousel1({required this.imageUrl});

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
