import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  static const _storage = FlutterSecureStorage();
  bool _isGuest = true;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final userType = await _storage.read(key: 'user_type');
    if (mounted) {
      setState(() => _isGuest = userType == 'guest');
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Exit App',
              style: TextStyle(color: Colors.black, letterSpacing: 0.1.sp),
            ),
            content: Text(
              'Are you sure you want to exit the app?',
              style: TextStyle(color: Colors.black, fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'No',
                  style: TextStyle(color: Colors.black, fontSize: 14.sp),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Yes',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldExit = await _onWillPop();
          if (shouldExit) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              debugPrint('Menu Clicked');
            },
            icon: Icon(Icons.menu, color: Color(0xFFCBD5E1)),
          ),
          actions: [
            IconButton(
              onPressed: () {
                debugPrint('Notifications Clicked');
              },
              icon: Icon(Icons.notifications_none, color: Color(0xFFCBD5E1)),
            ),
            SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            Image.asset(
              width: double.infinity,
              'assets/homepage/homepage_bg.png',
              fit: BoxFit.cover,
            ),

            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Image.asset(
                        'assets/homepage/spree_logo.png',
                        fit: BoxFit.cover,
                      ),
                      Text(
                        'Unleash the Untamed',
                        style: TextStyle(
                          color: Colors.white
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
