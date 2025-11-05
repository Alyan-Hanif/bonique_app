import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service to handle runtime permissions for camera, photos, and other features
class PermissionService {
  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo/gallery permission
  static Future<bool> requestPhotoPermission() async {
    // For Android 13+ (API 33+), we need to request photos permission
    // For older versions, it will request storage permission
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Check if photo permission is granted
  static Future<bool> isPhotoPermissionGranted() async {
    return await Permission.photos.isGranted;
  }

  /// Request camera permission with user-friendly dialog
  static Future<bool> requestCameraWithDialog(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showSettingsDialog(
          context,
          title: 'Camera Permission Required',
          message:
              'Camera access is permanently denied. Please enable it in settings to take photos.',
        );
      }
      return false;
    }

    return false;
  }

  /// Request photo permission with user-friendly dialog
  static Future<bool> requestPhotoWithDialog(BuildContext context) async {
    final status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.photos.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showSettingsDialog(
          context,
          title: 'Photo Library Permission Required',
          message:
              'Photo library access is permanently denied. Please enable it in settings to select images.',
        );
      }
      return false;
    }

    return false;
  }

  /// Show dialog to guide user to app settings
  static Future<void> _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Check if all required permissions for image features are granted
  static Future<bool> hasImagePermissions() async {
    final camera = await Permission.camera.isGranted;
    final photos = await Permission.photos.isGranted;
    return camera && photos;
  }

  /// Request all image-related permissions
  static Future<bool> requestAllImagePermissions(BuildContext context) async {
    final cameraGranted = await requestCameraWithDialog(context);
    if (!cameraGranted) return false;

    final photosGranted = await requestPhotoWithDialog(context);
    return photosGranted;
  }
}
