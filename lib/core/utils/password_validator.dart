class PasswordValidator {
  static const int minLength = 8;

  // Individual rule checks (used by the strength-indicator widget)

  static bool hasMinLength(String password) => password.length >= minLength;

  static bool hasUppercase(String password) =>
      password.contains(RegExp(r'[A-Z]'));

  static bool hasNumber(String password) => password.contains(RegExp(r'[0-9]'));

  static bool hasSpecialChar(String password) =>
      password.contains(RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]'''));

  // ── Form-field validator ──────────────────────────────────────────
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }

    final List<String> errors = [];

    if (!hasMinLength(password)) {
      errors.add('at least $minLength characters');
    }
    if (!hasUppercase(password)) {
      errors.add('1 uppercase letter');
    }
    if (!hasNumber(password)) {
      errors.add('1 number');
    }
    if (!hasSpecialChar(password)) {
      errors.add('1 special character');
    }

    if (errors.isEmpty) return null;

    return 'Password must contain: ${errors.join(', ')}';
  }
}
