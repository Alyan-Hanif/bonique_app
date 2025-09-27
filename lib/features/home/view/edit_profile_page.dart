import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../core/services/supabase_service.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = ref.read(authViewModelProvider);
    if (authState.isLoggedIn) {
      final user = authState.currentUserModel;
      _nameController.text = user?.fullName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      print('🔄 Starting image picker...');
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        print('✅ Image selected: ${pickedFile.path}');
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        print('❌ No image selected');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProfile() async {
    print('🔄 Starting profile update...');

    if (_nameController.text.trim().isEmpty) {
      print('❌ Name is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authViewModelProvider);
      print('🔍 Auth state: ${authState.isLoggedIn}');

      if (!authState.isLoggedIn) {
        throw Exception('User not logged in');
      }

      final userId = authState.currentUserModel!.id;
      print('👤 User ID: $userId');

      String? avatarUrl;

      // Upload new avatar if selected
      if (_selectedImage != null) {
        print('📸 Uploading avatar...');
        final fileName =
            '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'avatars/$fileName';
        print('📁 File path: $filePath');

        final bytes = await _selectedImage!.readAsBytes();
        print('📊 File size: ${bytes.length} bytes');

        try {
          print('⬆️ Uploading to storage...');
          await SupabaseService.client.storage
              .from('avatar')
              .uploadBinary(filePath, bytes);
          print('✅ Upload successful');

          avatarUrl = SupabaseService.client.storage
              .from('avatar')
              .getPublicUrl(filePath);
          print('🔗 Avatar URL: $avatarUrl');
        } catch (storageError) {
          print('❌ Storage upload error: $storageError');
          throw Exception('Failed to upload image: $storageError');
        }
      } else {
        print('ℹ️ No new image selected, skipping upload');
      }

      // Update user metadata in auth
      print('🔄 Updating auth metadata...');
      final updatedMetadata = {
        'full_name': _nameController.text.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };
      print('📝 Metadata to update: $updatedMetadata');

      try {
        await SupabaseService.client.auth.updateUser(
          UserAttributes(data: updatedMetadata),
        );
        print('✅ Auth metadata updated');
      } catch (authError) {
        print('❌ Auth update error: $authError');
        throw Exception('Failed to update auth metadata: $authError');
      }

      // Also update the users table directly
      print('🔄 Updating users table...');
      final updateData = {
        'full_name': _nameController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };
      print('📝 Users table data: $updateData');

      try {
        await SupabaseService.client
            .from('users')
            .update(updateData)
            .eq('id', userId);
        print('✅ Users table updated');
      } catch (dbError) {
        print('❌ Database update error: $dbError');
        throw Exception('Failed to update users table: $dbError');
      }

      if (mounted) {
        print('✅ Profile update completed successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Profile update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.currentUserModel;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Black background section
          Container(
            height: 200,
            color: Colors.black,
            child: SafeArea(
              child: Column(
                children: [
                  // Custom title bar with white text
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // White content section with proper layout
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar positioned to overlap both sections
                Positioned(
                  top: -50, // Half in black, half in white
                  left: 0,
                  right: 0,
                  child: Center(
                    child: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(50),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (user?.avatarUrl != null
                                      ? NetworkImage(user!.avatarUrl!)
                                      : null),
                            child:
                                _selectedImage == null &&
                                    user?.avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          // Camera icon overlay
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content area
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 50), // Space for avatar
                        // Tap to change photo text
                        InkWell(
                          onTap: _pickImage,
                          child: const Text(
                            'Tap to change photo',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Name Field
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1B1A18),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                color: Color(0xFF1B1A18),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Email Field (read-only)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            initialValue: user?.email ?? '',
                            enabled: false,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Update Profile Button at bottom
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B1A18),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Update Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
