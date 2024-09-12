import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewList extends StatelessWidget {
  final DocumentSnapshot? doctor;
  final DocumentSnapshot? appointment;

  const ReviewList({Key? key, this.doctor, this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine which object (doctor or appointment) is passed
    List reviews = [];
    if (doctor != null) {
      reviews = doctor!.get('reviews') ?? [];
    } else if (appointment != null) {
      reviews = appointment!.get('reviews') ?? [];
    }

    return SizedBox(
      height: 140, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final reviewRef = reviews[index] as DocumentReference;
          return FutureBuilder<DocumentSnapshot>(
            future: reviewRef.get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const SizedBox();
              }

              final reviewData = snapshot.data!.data() as Map<String, dynamic>;
              final userRef = reviewData['user'] as DocumentReference;

              return FutureBuilder<DocumentSnapshot>(
                future: userRef.get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return const SizedBox();
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final String userName = userData['displayName'] ?? 'Unknown';
                  final String profileImageUrl = userData['profileImageUrl'] ?? '';

                  return Container(
                    width: MediaQuery.of(context).size.width * 0.895, // Set width to full screen width
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF0064F7).withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : const AssetImage('assets/default_profile.png') as ImageProvider,
                              radius: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                userName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        RatingBarIndicator(
                          rating: reviewData['star_rating'].toDouble(),
                          itemBuilder: (context, index) => const Icon(
                            CupertinoIcons.star_fill,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          reviewData['content'] ?? 'No review content',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}