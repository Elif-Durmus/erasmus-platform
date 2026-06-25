import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class UploadService {
  static Future<String?> uploadProfilePhoto(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: 'profile_photo.jpg',
        ),
      });

      final res = await apiClient.dio.post(
        '/users/me/photo',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return res.data['profilePhotoUrl'] as String?;
    } catch (e) {
      return null;
    }
  }
}