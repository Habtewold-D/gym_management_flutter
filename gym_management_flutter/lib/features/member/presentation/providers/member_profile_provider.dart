import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/core/models/user_profile.dart';
import 'package:gym_management_flutter/core/services/member_service.dart';
import 'package:gym_management_flutter/core/services/auth_service.dart';
import 'package:gym_management_flutter/features/auth/presentation/providers/auth_provider.dart';

// State for member profile
class MemberProfileState {
  final UserProfile? user;
  final bool isLoading;
  final bool isEditing;
  final String? error;
  final String? successMessage;

  const MemberProfileState({
    this.user,
    this.isLoading = false,
    this.isEditing = false,
    this.error,
    this.successMessage,
  });

  MemberProfileState copyWith({
    UserProfile? user,
    bool? isLoading,
    bool? isEditing,
    String? error,
    String? successMessage,
  }) {
    return MemberProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      error: error,
      successMessage: successMessage,
    );
  }
}

// Provider for member profile state
final memberProfileProvider = StateNotifierProvider<MemberProfileNotifier, MemberProfileState>((ref) {
  final memberService = ref.watch(memberServiceProvider);
  final AuthNotifier authNotifier = ref.read(authProvider.notifier);
  return MemberProfileNotifier(memberService, authNotifier);
});

class MemberProfileNotifier extends StateNotifier<MemberProfileState> {
  final MemberService _memberService;
  final AuthNotifier _authNotifier;
  
  MemberProfileNotifier(this._memberService, this._authNotifier) 
      : super(const MemberProfileState()) {
    // Initial load
    loadProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setEditing(bool isEditing) {
    if (!mounted) return;
    state = state.copyWith(
      isEditing: isEditing,
      error: null,
      successMessage: null,
    );
  }

  void updateField(String field, dynamic value) {
    if (!mounted || state.user == null) return;
    
    UserProfile updatedUser;
    
    switch (field) {
      case 'name':
        updatedUser = state.user!.copyWith(name: value as String);
        break;
      case 'email':
        updatedUser = state.user!.copyWith(email: value as String);
        break;
      case 'age':
        updatedUser = state.user!.copyWith(
          age: value != null && value.isNotEmpty ? int.tryParse(value) : null,
        );
        break;
      case 'height':
        updatedUser = state.user!.copyWith(
          height: value != null && value.isNotEmpty ? double.tryParse(value) : null,
        );
        break;
      case 'weight':
        updatedUser = state.user!.copyWith(
          weight: value != null && value.isNotEmpty ? double.tryParse(value) : null,
        );
        break;
      default:
        return; // No changes if field is not recognized
    }
    
    state = state.copyWith(user: updatedUser);
  }

  Future<void> loadProfile() async {
    if (!mounted) return;
    
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Get current user from AuthNotifier
      final currentUser = _authNotifier.currentUser;
      if (currentUser == null) {
        throw Exception('User not found');
      }
      
      // Convert user ID to int if needed
      final userId = currentUser.id is int 
          ? currentUser.id as int 
          : int.tryParse(currentUser.id.toString()) ?? 0;
          
      if (userId == 0) {
        throw Exception('Invalid user ID');
      }

      // Load profile from member service
      final profile = await _memberService.getProfile(userId);
      
      if (!mounted) return;
      
      state = state.copyWith(user: profile, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> updateProfile() async {
    if (!mounted || state.user == null) return false;
    
    try {
      state = state.copyWith(isLoading: true, error: null, successMessage: null);
      
      final updatedUser = await _memberService.updateProfile(state.user!);
      
      if (!mounted) return false;
      
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
        isEditing: false,
        successMessage: 'Profile updated successfully',
      );
      
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile: $e',
      );
      return false;
    }
  }
}
