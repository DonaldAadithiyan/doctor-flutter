import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AppointmentReview extends StatefulWidget {
  final DocumentSnapshot? appointment;

  const AppointmentReview({super.key, this.appointment});

  @override
  _AppointmentReviewState createState() => _AppointmentReviewState();
}

class _AppointmentReviewState extends State<AppointmentReview> {
  double starRating = 3.0; // Default star rating
  String reviewContent = ''; // Default review content
  String? userRole;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userRole = userDoc['role'];
      });
    }
  }

  Future<void> submitReview() async {
    if (widget.appointment != null) {
      final appointmentData = widget.appointment!.data() as Map<String, dynamic>;
      final doctorRef = appointmentData['doctor'];
      final userRef = appointmentData['user'];

      try {
        // Fetch the doctor document
        final doctorDoc = await doctorRef.get();
        final doctorData = doctorDoc.data() as Map<String, dynamic>;

        // Check and create 'review_count' field if not available
        int reviewCount = doctorData.containsKey('review_count') ? doctorData['review_count'] : 0;
        
        // Check and create 'star_rating' field if not available
        double doctorStarRating = doctorData.containsKey('star_rating') 
            ? (doctorData['star_rating'] as num).toDouble()  // Cast to 'num' first and then convert to 'double'
            : 0.0;

        // Create a new review document
        final reviewsCollection = FirebaseFirestore.instance.collection('reviews');
        final reviewDocRef = await reviewsCollection.add({
          'doctor': doctorRef,
          'user': userRef,
          'content': reviewContent.isNotEmpty ? reviewContent : 'No review provided',
          'star_rating': starRating,
        });

        // Add review reference to appointment's reviews array
        await widget.appointment!.reference.update({
          'reviews': FieldValue.arrayUnion([reviewDocRef]),
        });

        // Update doctor document with the review reference
        if (doctorDoc.exists) {
          await doctorRef.update({
            'reviews': FieldValue.arrayUnion([reviewDocRef]),
          });
        }

        // Increment review count
        reviewCount++;

        // Calculate new average star rating
        doctorStarRating = ((doctorStarRating * (reviewCount - 1)) + starRating) / reviewCount;

        // Round to 1 decimal place
        doctorStarRating = double.parse(doctorStarRating.toStringAsFixed(1));

        // Update doctor document with new review count and star rating
        await doctorRef.update({
          'review_count': reviewCount,
          'star_rating': doctorStarRating,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $error')),
        );
      }
    }
  }

  void showReviewPopup() {
    if (userRole != 'user') {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Permission Denied'),
            content: Text('Only users can submit reviews.'),
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: starRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(
                  CupertinoIcons.star_fill,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    starRating = rating;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Review',
                ),
                onChanged: (value) {
                  setState(() {
                    reviewContent = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: submitReview,
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        CupertinoIcons.plus,
        color: Color(0xFF0064F7),
        size: 24,
      ),
      onPressed: showReviewPopup,
    );
  }
}