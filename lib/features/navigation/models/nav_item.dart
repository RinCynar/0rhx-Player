import 'package:flutter/material.dart';

enum NavItemType {
  home,
  library,
  search,
  playlist,
}

class NavItem {
  final NavItemType type;
  final String label;
  final IconData icon;

  const NavItem({
    required this.type,
    required this.label,
    required this.icon,
  });

  static const List<NavItem> items = [
    NavItem(
      type: NavItemType.home,
      label: 'Home',
      icon: Icons.home,
    ),
    NavItem(
      type: NavItemType.library,
      label: 'Library',
      icon: Icons.folder,
    ),
    NavItem(
      type: NavItemType.search,
      label: 'Search',
      icon: Icons.search,
    ),
    NavItem(
      type: NavItemType.playlist,
      label: 'Playlist',
      icon: Icons.list,
    ),
  ];
}
