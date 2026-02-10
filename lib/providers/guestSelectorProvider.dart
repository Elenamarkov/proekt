import 'package:flutter/material.dart';

class GuestSelectorProvider with ChangeNotifier {
  int selected = 0; // 0 = Senior, 1 = Adult, 2 = Child

  void setSelected(int idx) {
    selected = idx;
    notifyListeners();
  }
}
