import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback? onLoginSelected;
  final VoidCallback? onRegisterSelected;
  
  // Modified constructor to accept callbacks
  const SplashScreen({Key? key, this.onLoginSelected, this.onRegisterSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top blue rounded container
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF241A87),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Column(
                  children: [
                    // Circular gym logo
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: AssetImage('assets/images/gym_logo.png'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'FITNESS GYM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your journey to a healthier life starts here',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Contact Us
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Us',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.phone, size: 18),
                        SizedBox(width: 8),
                        Text('+251 90 102 0304'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.email, size: 18),
                        SizedBox(width: 8),
                        Text('info@fitnessgym.com'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.location_on, size: 18),
                        SizedBox(width: 8),
                        Expanded(child: Text('5 kilo, Addis Ababa, Ethiopia')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Featured image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/gym_logo.png',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Login and Register buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF241A87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onLoginSelected,
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF241A87), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onRegisterSelected,
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 18, color: Color(0xFF241A87)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}