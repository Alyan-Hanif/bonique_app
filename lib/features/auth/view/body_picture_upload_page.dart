import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/body_picture_repository.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/snackbar_utils.dart';

class BodyPictureUploadPage extends ConsumerStatefulWidget {
  const BodyPictureUploadPage({super.key});

  static const String route = '/body-picture-upload';

  @override
  ConsumerState<BodyPictureUploadPage> createState() =>
      _BodyPictureUploadPageState();
}

class _BodyPictureUploadPageState extends ConsumerState<BodyPictureUploadPage> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();
  final BodyPictureRepository _bodyPictureRepository = BodyPictureRepository();

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _errorMessage = null;
      });

      // Request permission based on source using PermissionService
      bool hasPermission;
      if (source == ImageSource.camera) {
        hasPermission = await PermissionService.requestCameraWithDialog(
          context,
        );
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

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Please select an image first';
      });
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final userId = authState.currentUserModel?.id;

    if (userId == null) {
      setState(() {
        _errorMessage = 'User not found. Please sign in again.';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Upload the body picture
      final updatedUser = await _bodyPictureRepository.uploadBodyPicture(
        userId,
        _selectedImage!,
      );

      // Update the auth state with the new user model
      ref.read(authViewModelProvider.notifier).updateCurrentUser(updatedUser);

      // Navigate to home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Failed to upload image: ${e.toString()}';
      });
    }
  }

  void _skipForNow() {
    // Navigate to home without uploading
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFA45A41)),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFFA45A41),
              ),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Complete Your Profile',
            style: TextStyle(
              color: Color(0xFFA45A41),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Title and description
                const Text(
                  'Upload Your Body Picture',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA45A41),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'To provide you with the best virtual try-on experience, we need a full-body picture of you.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Image preview or placeholder
                Expanded(
                  child: Center(
                    child: _selectedImage != null
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFA45A41),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9E2C6).withOpacity(0.3),
                              border: Border.all(
                                color: const Color(0xFFA45A41),
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 100,
                                  color: const Color(
                                    0xFFA45A41,
                                  ).withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No image selected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Select/Change image button
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _showImageSourceDialog,
                  icon: Icon(
                    _selectedImage == null
                        ? Icons.add_photo_alternate
                        : Icons.change_circle,
                  ),
                  label: Text(
                    _selectedImage == null ? 'Select Image' : 'Change Image',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE9E2C6),
                    foregroundColor: const Color(0xFFA45A41),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Upload button
                ElevatedButton(
                  onPressed: _isUploading || _selectedImage == null
                      ? null
                      : _uploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA45A41),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
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
                          'Upload & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 12),

                // Skip button
                TextButton(
                  onPressed: _isUploading ? null : _skipForNow,
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
