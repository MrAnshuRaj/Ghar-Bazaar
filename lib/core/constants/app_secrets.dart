const String _imgbbPlaceholderKey = 'PASTE_API_KEY_HERE';

const String imgbbApiKey = String.fromEnvironment(
  'IMGBB_API_KEY',
  defaultValue: '',
);

bool get hasImgbbApiKey {
  final key = imgbbApiKey.trim();
  return key.isNotEmpty && key != _imgbbPlaceholderKey;
}

const String imgbbApiKeySetupMessage =
    'ImgBB API key is missing. Run with '
    '--dart-define=IMGBB_API_KEY=your_imgbb_api_key.';
