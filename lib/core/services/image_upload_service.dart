import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ghar_bazaar/core/constants/app_secrets.dart';

class ImageUploadService {
  ImageUploadService({ImagePicker? imagePicker, http.Client? client})
    : _imagePicker = imagePicker ?? ImagePicker(),
      _client = client ?? http.Client();

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
    if (imgbbApiKey.trim().isEmpty || imgbbApiKey == 'PASTE_API_KEY_HERE') {
      throw const ImageUploadException('ImgBB API key is missing.');
    }

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
