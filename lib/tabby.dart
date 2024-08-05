library tabby;

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

  NavigationRailDestination destination(Tabby tabby) =>
      NavigationRailDestination(
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
  final bool showLabels;
  final BottomNavigationBarType? bottomNavigationBarType;

  const Tabby(
      {super.key,
      this.showLabels = true,
      required this.tabs,
      this.initialIndex = 0,
      this.bottomNavigationBarType,
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

  Widget buildTab(BuildContext context, int index) => IndexedStack(
        index: index,
        children: [
          for (var tab in tabs)
            if (tab.builder != null)
              tab.builder!(context)
            else if (tab.child != null)
              tab.child!
            else
              const SizedBox.shrink(),
        ],
      );

  @override
  Widget build(BuildContext context) =>
      MediaQuery.of(context).size.width > widget.widthThreshold
          ? Row(
              children: [
                NavigationRail(
                    onDestinationSelected: setTab,
                    destinations:
                        tabs.map((e) => e.destination(widget)).toList(),
                    selectedIndex: index),
                Expanded(child: buildTab(context, index))
              ],
            )
          : Scaffold(
              body: buildTab(context, index),
              bottomNavigationBar: BottomNavigationBar(
                type: widget.bottomNavigationBarType,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Theme.of(context).colorScheme.onSurface,
                selectedLabelStyle: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
                unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,
                selectedIconTheme:
                    IconThemeData(color: Theme.of(context).colorScheme.primary),
                unselectedIconTheme: Theme.of(context).iconTheme,
                showSelectedLabels: widget.showLabels,
                showUnselectedLabels: widget.showLabels,
                currentIndex: index,
                onTap: setTab,
                items: tabs.map((e) => e.bottomNavigationBarItem).toList(),
              ),
            );
}
