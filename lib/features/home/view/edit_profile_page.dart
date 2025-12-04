import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../data/repositories/body_picture_repository.dart';
import '../../../core/utils/snackbar_utils.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  File? _selectedBodyImage;
  bool _isLoading = false;
  bool _isUploadingBodyPic = false;
  final BodyPictureRepository _bodyPictureRepository = BodyPictureRepository();

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
    // Check permission first
    final hasPermission = await PermissionService.requestPhotoWithDialog(
      context,
    );
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo library permission is required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

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

  Future<void> _pickBodyImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Select Body Picture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // Gallery option
                ListTile(
                  leading: Icon(
                    Icons.photo_library_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickBodyImageFromSource(ImageSource.gallery);
                  },
                ),

                const Divider(),

                // Camera option
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickBodyImageFromSource(ImageSource.camera);
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickBodyImageFromSource(ImageSource source) async {
    // Check permission first
    bool hasPermission;
    if (source == ImageSource.camera) {
      hasPermission = await PermissionService.requestCameraWithDialog(context);
    } else {
      hasPermission = await PermissionService.requestPhotoWithDialog(context);
    }

    if (!hasPermission) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          title: 'Permission Required',
          message: source == ImageSource.camera
              ? 'Camera permission is required to take photos.'
              : 'Photo library permission is required to select images.',
        );
      }
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedBodyImage = File(pickedFile.path);
        });
        // Upload immediately after selection
        await _uploadBodyPicture();
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          title: 'Error',
          message: 'Failed to select image: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _uploadBodyPicture() async {
    if (_selectedBodyImage == null) return;

    setState(() {
      _isUploadingBodyPic = true;
    });

    try {
      final authState = ref.read(authViewModelProvider);
      if (!authState.isLoggedIn) {
        throw Exception('User not logged in');
      }

      final userId = authState.currentUserModel!.id;

      // Upload using BodyPictureRepository
      final updatedUser = await _bodyPictureRepository.uploadBodyPicture(
        userId,
        _selectedBodyImage!,
      );

      // Update the auth state with the new user model
      ref.read(authViewModelProvider.notifier).updateCurrentUser(updatedUser);

      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          title: 'Success!',
          message: 'Body picture updated successfully.',
        );
        setState(() {
          _selectedBodyImage = null; // Clear selection after upload
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          title: 'Upload Failed',
          message: 'Failed to upload body picture: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingBodyPic = false;
        });
      }
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

      // Refresh the user model in Riverpod state
      print('🔄 Refreshing user model in Riverpod...');
      await ref.read(authViewModelProvider.notifier).refreshUserModel();
      print('✅ Riverpod state refreshed');

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
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
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

                        const SizedBox(height: 30),

                        // Body Picture Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Body Picture for Try-On',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user?.bodyPicUrl != null
                                              ? 'Picture uploaded'
                                              : 'No picture uploaded yet',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: user?.bodyPicUrl != null
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Preview or placeholder
                              if (_selectedBodyImage != null ||
                                  user?.bodyPicUrl != null)
                                Center(
                                  child: Container(
                                    height: 150,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: _selectedBodyImage != null
                                          ? Image.file(
                                              _selectedBodyImage!,
                                              fit: BoxFit.cover,
                                            )
                                          : (user?.bodyPicUrl != null
                                                ? Image.network(
                                                    user!.bodyPicUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                          size: 40,
                                                        ),
                                                  )
                                                : null),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // Update button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isUploadingBodyPic
                                      ? null
                                      : _pickBodyImage,
                                  icon: _isUploadingBodyPic
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Icon(
                                          user?.bodyPicUrl != null
                                              ? Icons.edit
                                              : Icons.add_photo_alternate,
                                          size: 20,
                                        ),
                                  label: Text(
                                    _isUploadingBodyPic
                                        ? 'Uploading...'
                                        : (user?.bodyPicUrl != null
                                              ? 'Update Body Picture'
                                              : 'Add Body Picture'),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
