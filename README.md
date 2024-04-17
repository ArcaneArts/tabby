## Features

* A simple tab bar that switches between bottom navigation bar and navigation rail based on screen width with customizable threshold
* Each tab can support a predicate of whether it should be shown or not
* Each tab can have a label, icon, and selected icon
* Optionally use builders instead of a direct child

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:tabby/tabby.dart';

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
      // Screen widths above this threshold use navigation rail
      // Otherwise, use bottom navigation bar
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
```