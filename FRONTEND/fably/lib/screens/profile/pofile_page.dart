import 'dart:convert';
import 'dart:io';

import 'package:fably/screens/auth/login.dart';
import 'package:fably/screens/home/widgets/bottom_nav_bar.dart';
import 'package:fably/screens/home/widgets/common_appbar.dart';
import 'package:fably/screens/home/widgets/common_drawer.dart';
import 'package:fably/utils/globals.dart';
import 'package:fably/utils/prefs.dart';
import 'package:fably/utils/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    getName();
  }

  void _showMessage(String message, BuildContext context) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> signOut(context) async {
    final requests = BackendRequests();
    final prefs = Prefs();

    try {
      final response = await requests.getRequest('logout');
      if (response.statusCode == 200) {
        await prefs.clearPrefs();
        _showMessage('Logged out successfully', context);
      }
    } catch (e) {
      _showMessage('Error Logging out: $e', context);
    }
  }

  Future<void> getName() async {
    final prefs = Prefs();
    final userInfo = jsonDecode(await prefs.getPrefs("userInfo") ?? '{}');
    if (userInfo != null && userInfo.isNotEmpty) {
      if (userInfo['name'] == "") {
        setState(() {
          name = 'Rita Smith';
          email = 'rita@gmail.com';
        });
        return;
      }
      setState(() {
        name = userInfo['name'];
        email = userInfo['email'];
      });
    } else {
      setState(() {
        name = 'Rita Smith';
        email = 'rita@gmail.com';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          SystemNavigator.pop(); // For Android
        } else if (Platform.isIOS) {
          exit(0); // For iOS and other platforms
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: CommonAppBar(title: 'PROFILE'),
          drawer: CommonDrawer(),
          backgroundColor: Colors.black,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Profile image and name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 163, 158, 160).withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                            child: ClipOval(
                              child: Container(
                                width: 110,
                                height: 110,
                                color: const Color.fromARGB(255, 104, 102, 103),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Section header
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Contact information
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.white70),
                                  SizedBox(width: 16),
                                  Text(
                                    'Phone',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '+5999-771-7171',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey[800], height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.email, color: Colors.white70),
                                  SizedBox(width: 16),
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                email,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Section header
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Settings options
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.dark_mode, color: Colors.white70),
                                  SizedBox(width: 16),
                                  Text(
                                    'Dark mode',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              Switch(
                                value: true,
                                onChanged: (value) {},
                                activeColor: const Color.fromARGB(255, 10, 218, 218),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey[800], height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.bug_report, color: Colors.white70),
                                  SizedBox(width: 16),
                                  Text(
                                    'TryOn debug',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              Switch(
                                value: tryOnDebugMode,
                                onChanged: (value) {
                                  setState(() {
                                    tryOnDebugMode = value;
                                  });
                                },
                                activeColor: const Color.fromARGB(255, 10, 218, 218),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Account options
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {},
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.person_outline, color: Colors.white70),
                                    SizedBox(width: 16),
                                    Text(
                                      'Profile details',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey[500]),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey[800], height: 1),
                        InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.settings, color: Colors.white70),
                                    SizedBox(width: 16),
                                    Text(
                                      'Settings',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey[500]),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey[800], height: 1),
                        InkWell(
                          onTap: () {
                            signOut(context).then((o) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            });
                          },
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.pink),
                                    SizedBox(width: 16),
                                    Text(
                                      'Log out',
                                      style: TextStyle(color: Colors.pink),
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right, color: Colors.pink[300]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          bottomNavigationBar: CommonBottomNavBar(
            currentIndex: 3,
          ),
        ),
      ),
    );
  }
}