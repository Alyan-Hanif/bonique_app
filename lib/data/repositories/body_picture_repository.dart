import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';
import 'user_repository.dart';

class BodyPictureRepository {
  final SupabaseClient _client = SupabaseService.client;
  final UserRepository _userRepository = UserRepository();
  static const String _bucketName = 'personImages';

  /// Upload body picture to Supabase Storage and update user record
  /// Returns the updated UserModel on success
  Future<UserModel> uploadBodyPicture(String userId, File imageFile) async {
    try {
      // 1. Generate a unique filename (matching try-on format)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$timestamp.jpg';
      final filePath = '$userId/$fileName';

      // 2. Upload to Supabase Storage (using uploadBinary like try-on)
      final bytes = await imageFile.readAsBytes();
      await _client.storage.from(_bucketName).uploadBinary(filePath, bytes);

      // 3. Get the public URL
      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      // 4. Update user record in database
      final updatedUser = await _userRepository.updateUser(userId, {
        'has_uploaded_body_pic': true,
        'body_pic_url': publicUrl,
      });

      return updatedUser;
    } catch (e) {
      print('Error uploading body picture: $e');
      rethrow;
    }
  }

  /// Delete user's body picture from storage
  Future<void> deleteBodyPicture(String userId, String? bodyPicUrl) async {
    try {
      if (bodyPicUrl == null || bodyPicUrl.isEmpty) return;

      // Extract the file path from the URL
      final uri = Uri.parse(bodyPicUrl);
      final pathSegments = uri.pathSegments;

      // Find the path after 'personImages'
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

        // Delete from storage
        await _client.storage.from(_bucketName).remove([filePath]);
      }

      // Update user record
      await _userRepository.updateUser(userId, {
        'has_uploaded_body_pic': false,
        'body_pic_url': null,
      });
    } catch (e) {
      print('Error deleting body picture: $e');
      rethrow;
    }
  }

  /// Update/Replace body picture
  Future<UserModel> updateBodyPicture(
    String userId,
    File newImageFile,
    String? oldBodyPicUrl,
  ) async {
    try {
      // Delete old picture if exists
      if (oldBodyPicUrl != null && oldBodyPicUrl.isNotEmpty) {
        await deleteBodyPicture(userId, oldBodyPicUrl);
      }

      // Upload new picture
      return await uploadBodyPicture(userId, newImageFile);
    } catch (e) {
      print('Error updating body picture: $e');
      rethrow;
    }
  }

  /// Check if body pictures bucket exists (for setup/testing)
  Future<bool> bucketExists() async {
    try {
      final buckets = await _client.storage.listBuckets();
      return buckets.any((bucket) => bucket.name == _bucketName);
    } catch (e) {
      print('Error checking bucket existence: $e');
      return false;
    }
  }
}
