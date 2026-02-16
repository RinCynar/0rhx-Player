import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/models/nav_item.dart';
import '../../navigation/providers/nav_provider.dart';
import '../../library/providers/library_provider.dart';
import '../../home/pages/home_page.dart';
import '../../library/pages/library_page.dart';
import '../../search/pages/search_page.dart';
import '../../playlist/pages/playlist_page.dart';
import '../widgets/custom_title_bar.dart';
import '../../player/widgets/mini_player.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const List<Widget> _pages = [
    HomePage(),
    LibraryPage(),
    SearchPage(),
    PlaylistPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化库数据库
    Future.microtask(() {
      if (mounted) {
        context.read<LibraryProvider>().initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitleBar(title: '0rhx Player'),
      body: Column(
        children: [
          Expanded(
            child: Row(
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
          ),
          // Mini Player at bottom
          const Divider(height: 1),
          const MiniPlayer(),
        ],
      ),
    );
  }
}
