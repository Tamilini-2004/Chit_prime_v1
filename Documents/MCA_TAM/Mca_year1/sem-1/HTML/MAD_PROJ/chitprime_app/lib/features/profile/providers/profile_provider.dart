import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  bool isEditing = false;

  void toggleEdit() {
    isEditing = !isEditing;
    notifyListeners();
  }
}
