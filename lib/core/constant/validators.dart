class AuthValidators {
  // EMAIL REGEX
  static final RegExp emailRegex = RegExp(
    r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  // PASSWORD REGEX — min 7 chars, uppercase, number, special char
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{7,}$',
  );

  // EMAIL VALIDATOR
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }

    return null;
  }

  // PASSWORD VALIDATOR
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (!passwordRegex.hasMatch(value)) {
      return '''
Password must contain:
• at least 7 characters
• uppercase letter
• number
• special character (@\$!%*?&)
''';
    }

    return null;
  }
}
