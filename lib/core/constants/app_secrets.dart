const String _imgbbPlaceholderKey = 'PASTE_API_KEY_HERE';
const String _imgbbPlaceholderKeyAlt = 'PASTE_YOUR_IMGBB_API_KEY_HERE';

const String imgbbApiKey = _imgbbPlaceholderKeyAlt;

bool get hasImgbbApiKey {
  final key = imgbbApiKey.trim();
  return key.isNotEmpty &&
      key != _imgbbPlaceholderKey &&
      key != _imgbbPlaceholderKeyAlt;
}

const String imgbbApiKeySetupMessage =
    'ImgBB API key is missing. Set imgbbApiKey in lib/core/constants/app_secrets.dart.';

const String imgbbApiKeyRequiredForSharedModeMessage =
    'Image upload is not configured. Set imgbbApiKey to show images for all users.';
