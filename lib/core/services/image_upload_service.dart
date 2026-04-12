import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ghar_bazaar/core/constants/app_secrets.dart';

class ImageUploadService {
  ImageUploadService({
    ImagePicker? imagePicker,
    http.Client? client,
    required bool allowLocalFallback,
  }) : _allowLocalFallback = allowLocalFallback,
       _imagePicker = imagePicker ?? ImagePicker(),
       _client = client ?? http.Client();

  final bool _allowLocalFallback;
  final ImagePicker _imagePicker;
  final http.Client _client;

  Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
  }) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: imageQuality,
    );
    if (pickedFile == null) {
      return null;
    }
    return File(pickedFile.path);
  }

  Future<String> uploadImage(File file) async {
    if (!await file.exists()) {
      throw const ImageUploadException('Selected image could not be found.');
    }
    if (!hasImgbbApiKey) {
      if (kDebugMode) {
        debugPrint('[config] $imgbbApiKeySetupMessage');
      }
      if (_allowLocalFallback) {
        return _persistImageLocally(file);
      }
      throw const ImageUploadException(imgbbApiKeyRequiredForSharedModeMessage);
    }

    try {
      return await _uploadToImgbb(file);
    } on ImageUploadException catch (error) {
      if (!_allowLocalFallback) {
        rethrow;
      }
      if (kDebugMode) {
        debugPrint(
          '[image-upload] Remote upload failed: $error. Falling back to local image path.',
        );
      }
      return _persistImageLocally(file);
    }
  }

  Future<String> _uploadToImgbb(File file) async {
    final bytes = await file.readAsBytes();
    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey'),
            body: {'image': base64Encode(bytes)},
          )
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw const ImageUploadException(
        'Image upload timed out. Please try again with a stable internet connection.',
      );
    } on SocketException {
      throw const ImageUploadException(
        'No internet connection. Please reconnect and try uploading again.',
      );
    } on http.ClientException {
      throw const ImageUploadException(
        'Unable to reach ImgBB right now. Please try again shortly.',
      );
    } catch (_) {
      throw const ImageUploadException(
        'Image upload failed before reaching ImgBB. Please try again.',
      );
    }

    if (response.statusCode != 200) {
      throw ImageUploadException(
        'Image upload failed with status ${response.statusCode}.',
      );
    }

    late final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const ImageUploadException(
        'ImgBB returned an invalid response. Please try again.',
      );
    }
    final success = payload['success'] as bool? ?? false;
    final data = payload['data'] as Map<String, dynamic>?;
    final imageUrl =
        data?['display_url'] as String? ??
        data?['url'] as String? ??
        data?['image']?['url'] as String?;

    if (!success || imageUrl == null || imageUrl.isEmpty) {
      final error = payload['error'] as Map<String, dynamic>?;
      final message =
          error?['message'] as String? ??
          'ImgBB did not return a valid image URL.';
      throw ImageUploadException(message);
    }

    return imageUrl;
  }

  Future<String> _persistImageLocally(File sourceFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final uploadsDir = Directory(
      '${appDir.path}${Platform.pathSeparator}marketplace_uploads',
    );
    if (!await uploadsDir.exists()) {
      await uploadsDir.create(recursive: true);
    }

    final extension = _extractExtension(sourceFile.path);
    final fileName =
        'img_${DateTime.now().microsecondsSinceEpoch}$extension';
    final persisted = await sourceFile.copy(
      '${uploadsDir.path}${Platform.pathSeparator}$fileName',
    );
    return persisted.path;
  }

  String _extractExtension(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex);
  }

  Future<String?> pickAndUploadImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
  }) async {
    final file = await pickImage(source: source, imageQuality: imageQuality);
    if (file == null) {
      return null;
    }
    return uploadImage(file);
  }

  void dispose() {
    _client.close();
  }
}

class ImageUploadException implements Exception {
  const ImageUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}
