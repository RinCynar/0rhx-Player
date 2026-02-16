import 'package:flutter/material.dart';
import '../models/nav_item.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  NavItem get currentItem => NavItem.items[_currentIndex];

  void navigate(int index) {
    if (index >= 0 && index < NavItem.items.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void navigateTo(NavItemType type) {
    final index = NavItem.items.indexWhere((item) => item.type == type);
    if (index != -1) {
      navigate(index);
    }
  }
}
