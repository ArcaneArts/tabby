library tabby;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TabbyTab {
  final IconData? selectedIcon;
  final IconData icon;
  final String label;
  final WidgetBuilder? builder;
  final Widget? child;
  final bool Function()? shouldShow;

  TabbyTab({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.builder,
    this.child,
    this.shouldShow,
  });

  bool get visible => shouldShow?.call() ?? true;

  BottomNavigationBarItem get bottomNavigationBarItem =>
      BottomNavigationBarItem(
        icon: Icon(icon),
        label: label,
        activeIcon: selectedIcon == null ? null : Icon(selectedIcon),
      );

  NavigationRailDestination get destination => NavigationRailDestination(
        icon: Icon(icon),
        selectedIcon: selectedIcon == null ? null : Icon(selectedIcon),
        label: Text(label),
      );
}

class Tabby extends StatefulWidget {
  final List<TabbyTab> tabs;
  final int initialIndex;
  final Function(int)? onIndexChanged;
  final double widthThreshold;
  final bool? showLabels;

  const Tabby(
      {super.key,
      this.showLabels,
      required this.tabs,
      this.initialIndex = 0,
      this.onIndexChanged,
      this.widthThreshold = 600});

  TabbyState? of(BuildContext context) =>
      context.findAncestorStateOfType<TabbyState>();

  @override
  State<Tabby> createState() => TabbyState();
}

class TabbyState extends State<Tabby> {
  late int index;
  late List<TabbyTab> tabs;

  @override
  void initState() {
    index = widget.initialIndex;
    tabs = widget.tabs.where((e) => e.visible).toList();

    if (index >= tabs.length || index < 0) {
      index = 0;
    }

    super.initState();
  }

  void setTab(int index) {
    if (index != this.index) {
      if (index >= tabs.length || index < 0) {
        index = 0;
      }

      setState(() => this.index = index);
      if (widget.onIndexChanged != null) widget.onIndexChanged!(index);
    }
  }

  Widget buildTab(BuildContext context, int index) =>
      tabs[index].builder?.call(context) ??
      tabs[index].child ??
      const SizedBox.shrink();

  @override
  Widget build(BuildContext context) =>
      MediaQuery.of(context).size.width > widget.widthThreshold
          ? Row(
              children: [
                NavigationRail(
                    onDestinationSelected: setTab,
                    destinations: tabs.map((e) => e.destination).toList(),
                    selectedIndex: index),
                Expanded(child: buildTab(context, index))
              ],
            )
          : Scaffold(
              body: buildTab(context, index),
              bottomNavigationBar: BottomNavigationBar(
                showSelectedLabels: widget.showLabels,
                showUnselectedLabels: widget.showLabels,
                currentIndex: index,
                onTap: setTab,
                items: tabs.map((e) => e.bottomNavigationBarItem).toList(),
              ),
            );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    _selectedIndex = 0; // or load from storage
    super.initState();
  }

  void _changeTab(int index) => setState(() {
        _selectedIndex = index;
        // or save to storage
      });

  @override
  Widget build(BuildContext context) => Tabby(
          initialIndex: _selectedIndex,
          onIndexChanged: _changeTab,
          // Screen widths above this threshold use navigation rail instead of bottom navigation bar
          widthThreshold: 600,
          showLabels: true,
          tabs: [
            TabbyTab(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: "Home",
                child: Text("Home Tab Content")),
            TabbyTab(
                icon: Icons.ac_unit_outlined,
                selectedIcon: Icons.ac_unit_rounded,
                builder: (context) => Text("Builder tab content"),
                label: "Builder"),
            TabbyTab(
                // Only show this tab if in debug mode
                shouldShow: () => kDebugMode,
                icon: Icons.access_time_filled,
                label: "Builder")
          ]);
}
