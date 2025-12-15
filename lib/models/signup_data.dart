import 'package:flutter/foundation.dart';

class SignupData extends ChangeNotifier {
  String phone = '';

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }
}