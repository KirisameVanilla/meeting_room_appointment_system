import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _userid;

  String? get userId => _userid;

  void setUserId(String id) {
    _userid = id;
    notifyListeners();
  }
}
