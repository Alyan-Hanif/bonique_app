import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../viewmodel/home_viewmodel.dart';
import '../widgets/dashed_border.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/snackbar_utils.dart';

class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({super.key});

  static const route = '/add-item';

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;

  Future<void> _pickImages() async {
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
                Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),

                // Gallery option
                ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  subtitle: const Text(
                    'Choose from your photo library',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),

                // Camera option
                ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  subtitle: const Text(
                    'Take a new photo',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85, // Compress to 85% quality
      );

      if (images.isNotEmpty && mounted) {
        // Validate that all selected files are images
        final validImages = <XFile>[];
        final invalidFiles = <String>[];

        for (final image in images) {
          if (_isValidImageFile(image)) {
            validImages.add(image);
          } else {
            invalidFiles.add(image.name);
          }
        }

        if (validImages.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(validImages);
          });
        }

        // Show warning if any invalid files were selected
        if (invalidFiles.isNotEmpty && mounted) {
          SnackbarUtils.showWarning(
            context,
            title: 'Invalid Files',
            message:
                'Only image files are allowed. ${invalidFiles.length} file(s) skipped.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          title: 'Error',
          message: 'Failed to pick images: $e',
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress to 85% quality
        preferredCameraDevice: CameraDevice.rear, // Use rear camera by default
      );

      if (image != null && mounted) {
        // Validate it's an image file
        if (_isValidImageFile(image)) {
          setState(() {
            _selectedImages.add(image);
          });
        } else {
          SnackbarUtils.showError(
            context,
            title: 'Invalid File',
            message: 'Invalid file type. Only images are allowed.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          title: 'Error',
          message: 'Failed to take photo: $e',
        );
      }
    }
  }

  /// Validates that the file is a valid image type
  bool _isValidImageFile(XFile file) {
    final String fileName = file.name.toLowerCase();
    final List<String> validExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
    ];

    // Check file extension
    final bool hasValidExtension = validExtensions.any(
      (ext) => fileName.endsWith(ext),
    );

    // Check MIME type if available
    final String? mimeType = file.mimeType?.toLowerCase();
    final bool hasValidMimeType =
        mimeType == null || mimeType.startsWith('image/');

    return hasValidExtension && hasValidMimeType;
  }

  Future<File> _compressImage(File file) async {
    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // lower = smaller size, but less quality
    );

    return result as File ?? file; // fallback to original if compression fails
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _addToWardrobe() async {
    if (_selectedImages.isEmpty) {
      SnackbarUtils.showWarning(
        context,
        title: 'No Items Selected',
        message: 'Please select at least one item to add to your wardrobe.',
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get current user
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('Starting upload for user: ${user.id}');
      int successCount = 0;
      int failCount = 0;

      // Process each selected image
      for (int i = 0; i < _selectedImages.length; i++) {
        final imageFile = _selectedImages[i];
        try {
          print(
            'Processing image ${i + 1}/${_selectedImages.length}: ${imageFile.path}',
          );

          // Upload and process image via API, which will save to database with AI metadata
          await WardrobeRepository.processImageWithAPI(
            File(imageFile.path),
            user.id,
          );
          print('✅ Image processed and saved with AI metadata');

          successCount++;
        } catch (e) {
          print('❌ Error processing image ${imageFile.path}: $e');
          failCount++;
        }
      }

      if (mounted) {
        print('Setting _isUploading to false');
        setState(() {
          _isUploading = false;
          // Clear selected images if any items were successfully processed
          if (successCount > 0) {
            _selectedImages.clear();
            print('✅ Cleared selected images');
          }
        });

        // Show result message
        print('Showing success message');
        if (successCount > 0 && failCount == 0) {
          SnackbarUtils.showSuccess(
            context,
            title: 'Success!',
            message:
                'Successfully added $successCount item(s) to your wardrobe.',
          );
        } else if (successCount > 0 && failCount > 0) {
          SnackbarUtils.showWarning(
            context,
            title: 'Partial Success',
            message:
                'Added $successCount item(s) to wardrobe, but $failCount item(s) failed.',
          );
        } else {
          SnackbarUtils.showError(
            context,
            title: 'Failed',
            message: 'Failed to add items to wardrobe. Please try again.',
          );
        }

        // Navigate back to wardrobe page if at least one item was added
        if (successCount > 0) {
          print('Navigating back to wardrobe page');
          // ref.read(bottomNavigationIndexProvider.notifier).state = 0;
          // Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print('Critical error in _addToWardrobe: $e');
      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        SnackbarUtils.showError(
          context,
          title: 'Critical Error',
          message: 'An error occurred while adding items: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add new items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main upload area with dashed border
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _isUploading ? null : _pickImages,
                child: DashedBorder(
                  color: Colors.grey.shade300,
                  strokeWidth: 2.0,
                  dashLength: 8.0,
                  dashSpace: 4.0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _isUploading
                              ? const CircularProgressIndicator()
                              : Icon(
                                  Icons.upload_file,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isUploading
                              ? 'Uploading images...'
                              : 'Click here to add a new item in your wardrobe',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Preview section
            if (_selectedImages.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(
                                  File(_selectedImages[index].path),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (!_isUploading)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Add to Wardrobe button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _addToWardrobe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isUploading
                      ? Colors.grey.shade400
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Uploading...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Add to Wardrobe',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
