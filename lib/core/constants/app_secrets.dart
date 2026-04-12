import 'package:flutter/foundation.dart';

const String _imgbbPlaceholderKey = 'PASTE_API_KEY_HERE';
const String _imgbbPlaceholderKeyAlt = 'PASTE_YOUR_IMGBB_API_KEY_HERE';

const String imgbbApiKey = _imgbbPlaceholderKeyAlt;
bool _imgbbConfigLogged = false;

bool get hasImgbbApiKey {
  final key = imgbbApiKey.trim();
  return key.isNotEmpty &&
      key != _imgbbPlaceholderKey &&
      key != _imgbbPlaceholderKeyAlt;
}

String? validatedImgbbApiKey({bool logIfMissing = false}) {
  if (hasImgbbApiKey) {
    return imgbbApiKey.trim();
  }
  if (logIfMissing && kDebugMode && !_imgbbConfigLogged) {
    _imgbbConfigLogged = true;
    debugPrint('[ImgBB] $imgbbApiKeySetupMessage');
  }
  return null;
}

const String imgbbApiKeySetupMessage =
    'ImgBB API key is missing. Set imgbbApiKey in lib/core/constants/app_secrets.dart.';

const String imgbbApiKeyRequiredForSharedModeMessage =
    'Image upload is not configured. Set imgbbApiKey to show images for all users.';
