import 'package:flutter/material.dart';

class AppColors {

  static const int _primaryMain = 0xFF2563EB;
  static const MaterialColor primary = MaterialColor(
    _primaryMain,
    <int, Color>{
      50: Color(0xFFEFF6FF),
      100: Color(0xFFDBEAFE),
      200: Color(0xFFBFDBFE),
      300: Color(0xFF93C5FD),
      400: Color(0xFF60A5FA),
      500: Color(0xFF3B82F6),
      600: Color(_primaryMain),
      700: Color(0xFF1D4ED8),
      800: Color(0xFF1E40AF),
      900: Color(0xFF1E3A8A),
      950: Color(0xFF172554),
    },
  );


  static const Map<int, Color> neutral = {
    0: Color(0xFFFFFFFF),
    50: Color(0xFFF8F9FA),
    100: Color(0xFFF1F3F5),
    200: Color(0xFFE9ECEF),
    300: Color(0xFFDEE2E6),
    400: Color(0xFFCED4DA),
    500: Color(0xFFADB5BD),
    600: Color(0xFF6C757D),
    700: Color(0xFF495057),
    800: Color(0xFF343A40),
    900: Color(0xFF212529),
    1000: Color(0xFF121417),
  };

  static const Color error50 = Color(0xFFFFEBEE);
  static const Color error500 = Color(0xFFDC3545);
  static const Color error800 = Color(0xFFB71C1C);

  // Success
  static const Color success50 = Color(0xFFE8F5E9);
  static const Color success500 = Color(0xFF28A745);
  static const Color success800 = Color(0xFF1B5E20);

  // Warning
  static const Color warning50 = Color(0xFFFFF8E1);
  static const Color warning500 = Color(0xFFFFC107);
  static const Color warning800 = Color(0xFFF57F17);

  // Info
  static const Color info50 = Color(0xFFE0F7FA);
  static const Color info500 = Color(0xFF17A2B8);
  static const Color info800 = Color(0xFF006064);
}
