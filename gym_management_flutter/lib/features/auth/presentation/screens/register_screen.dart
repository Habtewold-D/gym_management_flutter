import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:gym_management_flutter/navigation/app_routes.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback? onLoginTapped; // added callback parameter
  const RegisterScreen({Key? key, this.onLoginTapped}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _age = '';
  String _height = '';
  String _weight = '';
  bool _showPassword = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.register(
        name: _name,
        email: _email,
        password: _password,
        confirmPassword: _confirmPassword,
        age: int.tryParse(_age) ?? 0,
        height: double.tryParse(_height) ?? 0.0,
        weight: double.tryParse(_weight) ?? 0.0,
      );
      if (success && mounted) {
        widget.onLoginTapped?.call(); // use provided callback to switch to login screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: const AssetImage('assets/images/gym_logo.png'),
                  backgroundColor: const Color(0xFF241A87),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    color: Color(0xFF241A87),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Join our fitness community',
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter your full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Full name is required';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters long';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]*$').hasMatch(value)) {
                          return 'Name can only contain letters and spaces';
                        }
                        return null;
                      },
                      onChanged: (value) => _name = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email address is required';
                        }
                        final emailRegex = RegExp(r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      onChanged: (value) => _email = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Create Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: !_showPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      onChanged: (value) => _password = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: !_showPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _password) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      onChanged: (value) => _confirmPassword = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        hintText: 'Enter your Age',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Age is required';
                        }
                        final ageInt = int.tryParse(value);
                        if (ageInt == null) {
                          return 'Please enter a valid number for age';
                        }
                        if (ageInt < 10) {
                          return 'You must be at least 10 years old to register';
                        }
                        if (ageInt > 100) {
                          return 'Please enter a valid age (maximum 100 years)';
                        }
                        return null;
                      },
                      onChanged: (value) => _age = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        hintText: 'Enter your height in cm',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.height),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Height is required';
                        }
                        final heightFloat = double.tryParse(value);
                        if (heightFloat == null) {
                          return 'Please enter a valid number for height';
                        }
                        if (heightFloat < 80) {
                          return 'Height must be at least 80 cm';
                        }
                        if (heightFloat > 250) {
                          return 'Height cannot exceed 250 cm';
                        }
                        return null;
                      },
                      onChanged: (value) => _height = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        hintText: 'Enter your weight in kg',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Weight is required';
                        }
                        final weightFloat = double.tryParse(value);
                        if (weightFloat == null) {
                          return 'Please enter a valid number for weight';
                        }
                        if (weightFloat < 35) {
                          return 'Weight must be at least 35 kg';
                        }
                        if (weightFloat > 200) {
                          return 'Weight cannot exceed 200 kg';
                        }
                        return null;
                      },
                      onChanged: (value) => _weight = value,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    authState.error!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
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
                  onPressed: authState.isLoading ? null : _register,
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              // "Already have an account?" row updated:
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: widget.onLoginTapped, // Calls callback to switch to Login screen
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF241A87),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}