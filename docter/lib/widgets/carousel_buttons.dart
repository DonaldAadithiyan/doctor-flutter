// lib/widgets/carousel_buttons.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselButtons extends StatelessWidget {
  final List<String> imageUrls;
  final Function(int) onPageChanged;

  CarouselButtons({required this.imageUrls, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.9,
        onPageChanged: (index, reason) => onPageChanged(index),
      ),
      items: imageUrls.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePage(imageUrl: imageUrl),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class ImagePage extends StatelessWidget {
  final String imageUrl;

  ImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Details'),
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
