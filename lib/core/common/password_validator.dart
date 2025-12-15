String? Function(String?)? passwordValidator = (value) {
  if (value == null || value.isEmpty) {
    return 'رمز عبور نمی‌تواند خالی باشد';
  }

  // At least 8 characters
  if (value.length < 8) {
    return 'رمز عبور باید حداقل ۸ کاراکتر باشد';
  }

  // // At least one uppercase letter
  // if (!RegExp(r'[A-Z]').hasMatch(value)) {
  //   return 'رمز عبور باید حداقل یک حرف بزرگ (A-Z) داشته باشد';
  // }

  // // At least one lowercase letter
  // if (!RegExp(r'[a-z]').hasMatch(value)) {
  //   return 'رمز عبور باید حداقل یک حرف کوچک (a-z) داشته باشد';
  // }

  // // At least one number
  // if (!RegExp(r'\d').hasMatch(value)) {
  //   return 'رمز عبور باید حداقل یک عدد داشته باشد';
  // }

  // // At least one special character
  // if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
  //   return 'رمز عبور باید حداقل یک کاراکتر ویژه مانند ! یا @ داشته باشد';
  // }

  return null;
};
