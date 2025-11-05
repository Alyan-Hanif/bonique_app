import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bonique/features/home/viewmodel/home_viewmodel.dart';
import 'package:bonique/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:bonique/data/repositories/wardrobe_repository.dart';
import 'package:bonique/core/services/permission_service.dart';
import '../widgets/home_widgets.dart'; // for TryOnBtn & SaveOutfitBtn

class TryOnPage extends ConsumerStatefulWidget {
  const TryOnPage({super.key});

  @override
  ConsumerState<TryOnPage> createState() => _TryOnPageState();
}

class _TryOnPageState extends ConsumerState<TryOnPage> {
  final ImagePicker _picker = ImagePicker();

  void _showImageSourcePicker() {
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
                  'Select Your Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),

                // Gallery option
                ListTile(
                  leading: Icon(
                    Icons.photo_library_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),

                const Divider(),

                // Camera option
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
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

  Future<void> _pickFromGallery() async {
    // Check permission first
    final hasPermission = await PermissionService.requestPhotoWithDialog(
      context,
    );
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo library permission is required')),
        );
      }
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        await _processTryOn(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
      }
    }
  }

  Future<void> _pickFromCamera() async {
    // Check permission first
    final hasPermission = await PermissionService.requestCameraWithDialog(
      context,
    );
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null && mounted) {
        await _processTryOn(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  Future<void> _processTryOn(File imageFile) async {
    final selectedItems = ref.read(tryOnItemsProvider);
    final authState = ref.read(authViewModelProvider);

    if (selectedItems.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an outfit from wardrobe'),
          ),
        );
      }
      return;
    }

    if (!authState.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please log in first')));
      }
      return;
    }

    try {
      ref.read(tryOnLoadingProvider.notifier).state = true;
      ref.read(tryOnResultProvider.notifier).state = null;

      // Upload person image to personImages bucket
      final userId = authState.currentUserModel!.id;
      final personImageUrl = await WardrobeRepository.uploadPersonImage(
        imageFile,
        userId,
      );

      print('✅ Person image uploaded: $personImageUrl');

      // Call try-on API with uploaded person image
      final resultImageUrl = await WardrobeRepository.tryOnClothing(
        clothingPath: selectedItems.first.imagePath,
        personPath: personImageUrl,
      );

      ref.read(tryOnResultProvider.notifier).state = resultImageUrl;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Try-on complete!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Try-on failed: $e')));
      }
    } finally {
      ref.read(tryOnLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _handleTryOn() async {
    final selectedItems = ref.read(tryOnItemsProvider);

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an outfit from wardrobe')),
      );
      return;
    }

    // Show image picker options
    _showImageSourcePicker();
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = ref.watch(tryOnItemsProvider);
    final tryOnResult = ref.watch(tryOnResultProvider);
    final isLoading = ref.watch(tryOnLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Text(
              'Try-On',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Image container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: selectedItems.isEmpty
                        ? Center(
                            child: Text(
                              'Select an outfit from your wardrobe to try on',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : tryOnResult != null
                        ? Image.network(
                            tryOnResult,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(Icons.broken_image, size: 40),
                                ),
                          )
                        : Image.network(
                            selectedItems.first.imagePath,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(Icons.broken_image, size: 40),
                                ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            TryOnBtn(
              text: tryOnResult != null ? "Try Another" : "Try On",
              onPressed: isLoading ? null : _handleTryOn,
              isLoading: isLoading,
            ),
            const SizedBox(height: 12),
            // SaveOutfitBtn(
            //   text: "Save Outfit",
            //   onPressed: tryOnResult == null ? null : () {},
            //   isLoading: false,
            // ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
