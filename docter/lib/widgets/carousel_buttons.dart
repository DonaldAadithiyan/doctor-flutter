// lib/widgets/carousel_buttons.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselButtons extends StatelessWidget {
  final List<String> imageUrls;
  final List<Widget> pages; // Add this list to store pages
  final Function(int) onPageChanged;

  CarouselButtons({
    required this.imageUrls,
    required this.pages, // Include pages in the constructor
    required this.onPageChanged,
  });

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
      items: imageUrls.asMap().entries.map((entry) {
        int index = entry.key;
        String imageUrl = entry.value;

        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        pages[index], // Navigate to the specific page
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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
