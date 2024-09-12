import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/horizontal_calendar.dart'; // Import the HorizontalCalendar

class DoctorPage extends StatefulWidget {
  final QueryDocumentSnapshot doctor;

  const DoctorPage({super.key, required this.doctor});

  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  bool isExpanded = false; // Controls whether the full text is shown

  @override
  Widget build(BuildContext context) {
    final doctorData = widget.doctor.data() as Map<String, dynamic>;
    final socialMediaLinks =
        doctorData['socialMediaLinks'] as Map<String, dynamic>?;

    final String aboutMe = doctorData['AboutMe'] ?? 'No information available';
    const int textLimit = 140; // Character limit for the truncated text

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Details',
          style: TextStyle(
            fontFamily: 'SFProDisplay',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black, // Adjust the color to match your theme
          ),
        ),
      ),
      body: SingleChildScrollView( // Wrap the body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300, // Adjust the color as needed
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: NetworkImage(
                            doctorData['profileImageUrl'] ??
                                'https://example.com/default-profile.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  doctorData['name'] ?? 'No name available',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F7F9).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF6F7F9)
                                          .withOpacity(1),
                                      blurRadius: 17,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.star_fill,
                                      color: Color(0xFF0064F7),
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      doctorData['star_rating'] != null
                                          ? '${doctorData['star_rating']}'
                                          : '0.0',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0064F7),
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                        Text(
                                          doctorData['review_count'] != null
                                              ? '(${doctorData['review_count']})'
                                              : '0',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black54,
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            doctorData['specialization'] ??
                                'No specialty available',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Email: ${doctorData['email'] ?? 'No email available'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Phone: ${doctorData['phoneNumber'] ?? 'Not Public'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (socialMediaLinks != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (socialMediaLinks.containsKey('Instagram') &&
                        socialMediaLinks['Instagram'] != "")
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icon/instagram.svg',
                            width: 24.0,
                            height: 24.0,
                            semanticsLabel: 'Instagram logo',
                          ),
                          const SizedBox(width: 8),
                          Text(
                            socialMediaLinks['Instagram'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0064F7),
                            ),
                          ),
                        ],
                      ),
                    if (socialMediaLinks.containsKey('Facebook') &&
                        socialMediaLinks['Instagram'] != "")
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icon/facebook.svg',
                            width: 24.0,
                            height: 24.0,
                            semanticsLabel: 'Facebook logo',
                          ),
                          const SizedBox(width: 8),
                          Text(
                            socialMediaLinks['Facebook'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0064F7),
                            ),
                          ),
                        ],
                      ),
                    if (socialMediaLinks.containsKey('Twitter') &&
                        socialMediaLinks['Instagram'] != "")
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icon/twitter.svg',
                            width: 24.0,
                            height: 24.0,
                            semanticsLabel: 'Twitter logo',
                          ),
                          const SizedBox(width: 8),
                          Text(
                            socialMediaLinks['Twitter'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0064F7),
                            ),
                          ),
                        ],
                      ),
                    if (socialMediaLinks.containsKey('Website') &&
                        socialMediaLinks['Instagram'] != "")
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                AssetImage('assets/icon/internet.png'),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            socialMediaLinks['Website'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0064F7),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              const SizedBox(height: 10),
              Text(
                'About Me',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 10),
              // Display the truncated or full text with "See More" or "See Less" appended at the end
              RichText(
                text: TextSpan(
                  text: isExpanded
                      ? aboutMe
                      : aboutMe.length > textLimit
                          ? aboutMe.substring(0, textLimit)
                          : aboutMe,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  children: [
                    if (aboutMe.length > textLimit)
                      TextSpan(
                        text: isExpanded ? '  See Less' : ' ... See More',
                        style: const TextStyle(
                          color: Color(0xFF0064F7),
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                      ),
                  ],
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20), // Add some space before the calendar
              HorizontalCalendar(doctor: widget.doctor), // Add the HorizontalCalendar widget here
            ],
          ),
        ),
      ),
    );
  }
}
