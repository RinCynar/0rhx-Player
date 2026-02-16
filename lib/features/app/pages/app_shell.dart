import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/models/nav_item.dart';
import '../../navigation/providers/nav_provider.dart';
import '../../home/pages/home_page.dart';
import '../../library/pages/library_page.dart';
import '../../search/pages/search_page.dart';
import '../../playlist/pages/playlist_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const List<Widget> _pages = [
    HomePage(),
    LibraryPage(),
    SearchPage(),
    PlaylistPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // NavigationRail
          NavigationRail(
            selectedIndex: context.watch<NavigationProvider>().currentIndex,
            onDestinationSelected: (index) {
              context.read<NavigationProvider>().navigate(index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: NavItem.items
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          // Content Area
          Expanded(
            child: _pages[context.watch<NavigationProvider>().currentIndex],
          ),
        ],
      ),
    );
  }
}
