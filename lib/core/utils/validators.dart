class Validators {
  const Validators._();

  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, label: 'Email');
    if (requiredError != null) {
      return requiredError;
    }
    final email = value!.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, label: 'Password');
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? phone(String? value) {
    final requiredError = requiredField(value, label: 'Phone number');
    if (requiredError != null) {
      return requiredError;
    }
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Enter a valid 10 digit phone number';
    }
    return null;
  }

  static String? numeric(String? value, {String label = 'Value'}) {
    final requiredError = requiredField(value, label: label);
    if (requiredError != null) {
      return requiredError;
    }
    final parsed = num.tryParse(value!.trim());
    if (parsed == null) {
      return 'Enter a valid number';
    }
    return null;
  }
}
