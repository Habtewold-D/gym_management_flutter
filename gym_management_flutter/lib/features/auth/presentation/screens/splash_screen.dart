import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  
  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 24), // Increased icon size
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 18), // Increased font size by ~80%
          ),
        ],
      ),
    );
  }
  
  void _navigateToLogin(BuildContext context) {
    context.go('/login');
  }
  
  void _navigateToRegister(BuildContext context) {
    context.go('/register');
  }

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
                height: MediaQuery.of(context).size.height * 0.30, // Set to 30% of screen height
                decoration: const BoxDecoration(
                  color: Color(0xFF241A87),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24, top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Gym logo without white border
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/gym_logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'FITNESS GYM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29, // Reduced by ~10%
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Your journey to a healthier life starts here',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Reduced by ~10%
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                        fontSize: 22, // Increased by ~80%
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContactRow(Icons.phone, '+251 90 102 0304'),
                    _buildContactRow(Icons.email, 'info@fitnessgym.com'),
                    _buildContactRow(Icons.location_on, '5 kilo, Addis Ababa, Ethiopia'),
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
                    height: 240, // Doubled from 120
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
                        onPressed: () => _navigateToLogin(context),
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
                        onPressed: () => _navigateToRegister(context),
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