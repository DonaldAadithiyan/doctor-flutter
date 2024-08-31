import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../users/field.dart'; // Import the FieldPage

class CarouselFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('fields').limit(10).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0064F7)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No fields available'),
          );
        }

        final fields = snapshot.data!.docs;

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final field = fields[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FieldPage(field: field),
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        child: field['icon'] != null
                            ? Image.network(
                                field['icon'],
                                width: 60, // Adjust this value to control the image width
                                height: 60, // Adjust this value to control the image height
                                fit: BoxFit.cover, // Ensures the image covers the entire box
                              )
                            : Image.asset(
                                'assets/field_placeholder.png',
                                width: 60, // Adjust this value to control the image width
                                height: 60, // Adjust this value to control the image height
                                fit: BoxFit.cover, // Ensures the image covers the entire box
                              ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text(
                          field['name'] ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
