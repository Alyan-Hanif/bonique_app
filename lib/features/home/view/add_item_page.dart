import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../viewmodel/home_viewmodel.dart';
import '../widgets/dashed_border.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../core/services/supabase_service.dart';

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
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1A18),
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
                  title: const Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B1A18),
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
                  title: const Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B1A18),
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
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null && mounted) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _addToWardrobe() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item')),
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

          // Upload image to Supabase storage
          final imagePath = await WardrobeRepository.uploadImage(
            File(imageFile.path),
            user.id,
          );
          print('Image uploaded successfully: $imagePath');

          // Save wardrobe item to database
          await WardrobeRepository.saveWardrobeItem(
            userId: user.id,
            imagePath: imagePath,
            category: 'Shirt',
            description: 'blue colour with red pattern',
          );
          print('Wardrobe item saved successfully');

          successCount++;
        } catch (e) {
          print('Error processing image ${imageFile.path}: $e');
          failCount++;
        }
      }

      if (mounted) {
        print('Setting _isUploading to false');
        setState(() {
          _isUploading = false;
        });

        // Show result message
        String message;
        if (successCount > 0 && failCount == 0) {
          message = 'Successfully added $successCount item(s) to wardrobe';
        } else if (successCount > 0 && failCount > 0) {
          message = 'Added $successCount item(s), $failCount failed';
        } else {
          message = 'Failed to add items to wardrobe';
        }

        print('Showing success message: $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
          ),
        );

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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Critical error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
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
        title: const Text(
          'Add new items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B1A18),
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
                      : const Color(0xFF1B1A18),
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
