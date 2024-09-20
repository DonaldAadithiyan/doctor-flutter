import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewList extends StatelessWidget {
  final DocumentSnapshot? doctor;
  final DocumentSnapshot? appointment;

  const ReviewList({super.key, this.doctor, this.appointment});

  @override
  Widget build(BuildContext context) {
    // Determine which object (doctor or appointment) is passed
    List reviews = [];
    if (doctor != null) {
      reviews = doctor!.get('reviews') ?? [];
    } else if (appointment != null) {
      reviews = appointment!.get('reviews') ?? [];
    }

    // Check if there are any reviews to display
    if (reviews.isEmpty) {
      Container(
        padding: const EdgeInsets.all(8.0),
        child: const Text('No reviews available',
            style: TextStyle(
                fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w700)),
      );
    }

    return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait(reviews
          .map((reviewRef) => (reviewRef as DocumentReference).get())
          .toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Failed to load reviews'));
        }

        final reviewDocs = snapshot.data!;

        return SizedBox(
          height: 140, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reviewDocs.length,
            itemBuilder: (context, index) {
              final reviewData =
                  reviewDocs[index].data() as Map<String, dynamic>;
              final userRef = reviewData['user'] as DocumentReference;

              return FutureBuilder<DocumentSnapshot>(
                future: userRef.get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(); // Avoid multiple loading indicators
                  }
                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return const SizedBox();
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final String userName = userData['displayName'] ?? 'Unknown';
                  final String profileImageUrl =
                      userData['profileImageUrl'] ?? '';

                  return Container(
                    width: MediaQuery.of(context).size.width *
                        0.895, // Set width to full screen width
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFF0064F7).withOpacity(0.5)),
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
                                  : const AssetImage(
                                          'assets/default_profile.png')
                                      as ImageProvider,
                              radius: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
          ),
        );
      },
    );
  }
}
