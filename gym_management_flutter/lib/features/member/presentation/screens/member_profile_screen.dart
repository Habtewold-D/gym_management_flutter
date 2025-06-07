import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_management_flutter/core/models/user_profile.dart';
import 'package:gym_management_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:gym_management_flutter/features/member/presentation/providers/member_profile_provider.dart';

class MemberProfileScreen extends ConsumerStatefulWidget {
  const MemberProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends ConsumerState<MemberProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memberProfileProvider.notifier).loadProfile();
    });
  }

  void _initializeControllers() {
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _updateControllers(UserProfile userProfile) {
    _nameController.text = userProfile.name;
    _emailController.text = userProfile.email;
    _ageController.text = userProfile.age?.toString() ?? '';
    _heightController.text = userProfile.height?.toString() ?? '';
    _weightController.text = userProfile.weight?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(memberProfileProvider);
    final user = authState.user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in')),
      );
    }
    
    final userId = user.id is int ? user.id as int : 
                  (user.id is String ? int.tryParse(user.id as String) : null) ?? 0;
    
    final userProfile = profileState.user ?? UserProfile(
      id: userId,
      name: user.name ?? 'User',
      email: user.email,
      role: user.role?.toString() ?? 'member',
    );
    
    _updateControllers(userProfile);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Your profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          if (!profileState.isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                ref.read(memberProfileProvider.notifier).setEditing(true);
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E88E5),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userProfile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userProfile.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: profileState.isEditing
                        ? _buildEditForm(profileState, context)
                        : _buildProfileView(userProfile),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileView(UserProfile userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Personal information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (!ref.watch(memberProfileProvider).isEditing)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () {
                          ref.read(memberProfileProvider.notifier).setEditing(true);
                        },
                      ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow('Name', userProfile.name),
                const Divider(height: 24),
                _buildInfoRow('Email', userProfile.email),
                const Divider(height: 24),
                _buildInfoRow('Age', userProfile.age?.toString() ?? ''),
                const Divider(height: 24),
                _buildInfoRow('Height', userProfile.height?.toString() ?? '', unit: 'cm'),
                const Divider(height: 24),
                _buildInfoRow('Weight', userProfile.weight?.toString() ?? '', unit: 'kg'),
                const Divider(height: 24),
                _buildInfoRow('BMI', userProfile.bmi?.toStringAsFixed(1) ?? ''),
                const Divider(height: 24),
                if (userProfile.joinDate != null) ...[                  
                  const Divider(height: 24),
                  _buildInfoRow('Join Date', userProfile.joinDate!.split('T')[0]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(MemberProfileState state, BuildContext context) {
    final userProfile = state.user ?? UserProfile(
      id: 0,
      name: _nameController.text,
      email: _emailController.text,
      age: int.tryParse(_ageController.text),
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Name', _nameController, 'Enter your name'),
                  const SizedBox(height: 16),
                  _buildNumberField('Age', _ageController, 'Enter your age'),
                  const SizedBox(height: 16),
                  _buildNumberField('Height(cm):', _heightController, 'Enter height', unit: ''),
                  const SizedBox(height: 16),
                  _buildNumberField('Weight(kg):', _weightController, 'Enter weight', unit: ''),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          if (state.successMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                state.successMessage!,
                style: const TextStyle(color: Colors.green, fontSize: 14),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(memberProfileProvider.notifier).setEditing(false);
                    _updateControllers(userProfile);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF1E88E5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'cancel',
                    style: TextStyle(
                      color: Color(0xFF1E88E5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final updated = userProfile.copyWith(
                              name: _nameController.text,
                              age: int.tryParse(_ageController.text),
                              height: double.tryParse(_heightController.text),
                              weight: double.tryParse(_weightController.text),
                            );
                            
                            ref.read(memberProfileProvider.notifier).updateField('name', _nameController.text);
                            ref.read(memberProfileProvider.notifier).updateField('age', _ageController.text);
                            ref.read(memberProfileProvider.notifier).updateField('height', _heightController.text);
                            ref.read(memberProfileProvider.notifier).updateField('weight', _weightController.text);
                            
                            final success = await ref.read(memberProfileProvider.notifier).updateProfile();
                            
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              ref.read(memberProfileProvider.notifier).setEditing(false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {String? unit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        Text(
          value + (unit != null ? ' $unit' : ''),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${label.toLowerCase()}';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller,
    String hint, {
    String? unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixText: unit,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final number = double.tryParse(value);
              if (number == null) {
                return 'Please enter a valid number';
              }
              if (number <= 0) {
                return 'Value must be greater than 0';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}