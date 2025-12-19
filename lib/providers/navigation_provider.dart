import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    // We don't want to navigate to the scan screen this way as it's a special case
    if (index == 2) return;

    _selectedIndex = index;
    notifyListeners();
  }
}
