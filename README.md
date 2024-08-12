## Features

* bottomNavigationBar
* navigationRail
* topTabs
* drawer
* sidebar

## Usage

```dart
Tabby(
  rightHanded: rightHanded,
  type: type,
  appBar: AppBar(title: const Text("Tabby Example")),
    tabs: [
        TabbyTab(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: "Home",
            appBarBuilder: (bar) => bar!.copyWith(
              title: const Text("Home")),
            builder: (context) => const Center(child: Text("Home"))
        ),
        TabbyTab(
            icon: Icons.search_outlined,
            selectedIcon: Icons.search_rounded,
            label: "Search",
            appBarBuilder: (bar) => bar!.copyWith(
                title: const Text("Search"),
                actions: [
                    IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                    ),
                    ...bar.actions!,
                ]
            ),
            builder: (context) => const Center(child: Text("Search"))
        ),
        TabbyTab(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            label: "Settings",
            appBarBuilder: (bar) =>
              bar!.copyWith(title: const Text("Settings")),
            builder: (context) => const Center(child: Text("Settings"))
      ),
  ]
);
```