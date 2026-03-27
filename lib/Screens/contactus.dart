import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  Future<void> _makePhoneCall(String phoneNumber) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');

    if (cleanNumber.length == 10 && !cleanNumber.startsWith('+')) {
      cleanNumber = '+91$cleanNumber';
    }

    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Could not launch dialer");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 140.h,
          title: Text(
            'About Us',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40.h,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: 'spree-26',
            ).collection('ContactUs').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Something went wrong",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No contacts found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: EdgeInsets.only(bottom: 20.h),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final String rawPhone = data['Contact']?.toString() ?? '';

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 70.r,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF733CA3),
                                blurRadius: 12.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              constraints: BoxConstraints(minHeight: 100.h),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 92, 92, 92),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  topRight: Radius.circular(20.r),
                                  bottomRight: Radius.circular(20.r),
                                ),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.5.w,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      data['Name'] ?? 'Unknown',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18.h,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFB1CBF8),
                                        fontFamily: 'Cinzel',
                                      ),
                                    ),
                                    Text(
                                      "${data['Club'] ?? 'N/A'}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFFB1CBF8),
                                        fontSize: 12.h,
                                        fontFamily: 'Cinzel',
                                      ),
                                    ),
                                    Text(
                                      "${data['Position'] ?? 'N/A'}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFFB1CBF8),
                                        fontSize: 12.h,
                                        fontFamily: 'Cinzel',
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (rawPhone.isNotEmpty) {
                                          _makePhoneCall(rawPhone);
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            size: 20.h,
                                            color: const Color(0xFFB1CBF8),
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              rawPhone.isEmpty
                                                  ? 'N/A'
                                                  : rawPhone,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16.h,
                                                color: const Color(0xFFB1CBF8),
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: const Color(
                                                  0xFFB1CBF8,
                                                ),
                                                fontFamily: 'Cinzel',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
