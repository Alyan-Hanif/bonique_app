import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Service to handle runtime permissions for camera, photos, and other features
class PermissionService {
  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo/gallery permission
  /// Handles Android version differences:
  /// - Android 13+ (API 33+): Uses READ_MEDIA_IMAGES
  /// - Android 10-12 (API 29-32): Uses READ_EXTERNAL_STORAGE
  /// - Below Android 10: Uses READ_EXTERNAL_STORAGE
  static Future<bool> requestPhotoPermission() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // Android 13+ (API 33+)
        if (sdkInt >= 33) {
          final status = await Permission.photos.request();
          return status.isGranted;
        }
        // Android 10-12 (API 29-32) - needs READ_EXTERNAL_STORAGE
        else {
          // Request storage permission for Android 10-12
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      } catch (e) {
        // Fallback: Try both permissions if device info fails
        debugPrint(
          'Error getting device info: $e. Using fallback permission strategy.',
        );
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) return true;

        final photosStatus = await Permission.photos.request();
        return photosStatus.isGranted;
      }
    } else {
      // iOS and other platforms
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Check if photo permission is granted
  static Future<bool> isPhotoPermissionGranted() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // Android 13+ uses photos permission
        if (sdkInt >= 33) {
          return await Permission.photos.isGranted;
        }
        // Android 10-12 uses storage permission
        else {
          return await Permission.storage.isGranted;
        }
      } catch (e) {
        // Fallback: Check both permissions
        debugPrint('Error getting device info: $e. Checking both permissions.');
        final storage = await Permission.storage.isGranted;
        final photos = await Permission.photos.isGranted;
        return storage || photos;
      }
    } else {
      return await Permission.photos.isGranted;
    }
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
    Permission permissionToRequest = Permission.photos;

    // Determine which permission to request based on Android version
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // Android 10-12 uses storage permission
        if (sdkInt < 33) {
          permissionToRequest = Permission.storage;
        }
      } catch (e) {
        // Fallback: Use storage permission if device info fails
        debugPrint(
          'Error getting device info: $e. Using storage permission as fallback.',
        );
        permissionToRequest = Permission.storage;
      }
    }

    final status = await permissionToRequest.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permissionToRequest.request();
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
    final photos = await isPhotoPermissionGranted();
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
