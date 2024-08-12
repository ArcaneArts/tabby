library tabby;

import 'dart:math';

import 'package:copy_with_material/copy_with_material.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:toxic/extensions/iterable.dart';

export 'package:copy_with_material/extensions/app_bar.dart';

enum TabbyType { bottomNavigationBar, navigationRail, topTabs, drawer, sidebar }

extension XTabbyType on TabbyType {
  bool get isHanded => switch (this) {
        TabbyType.drawer ||
        TabbyType.sidebar ||
        TabbyType.navigationRail =>
          true,
        _ => false,
      };
}

class TabbyTab {
  final String id;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final WidgetBuilder builder;
  final AppBar? Function(AppBar? parent)? appBarBuilder;
  final bool preload;

  const TabbyTab(
      {required this.icon,
      required this.label,
      required this.builder,
      this.appBarBuilder,
      this.preload = false,
      IconData? selectedIcon,
      String? id})
      : selectedIcon = selectedIcon ?? icon,
        id = id ?? label;

  AppBar? buildAppBar(AppBar? parent) => appBarBuilder?.call(parent) ?? parent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabbyTab && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TabbyTab{id: $id, icon: $icon, label: $label}';
}

extension XTabList on List<TabbyTab> {
  bool get hasDuplicateIds => map((tab) => tab.id).toSet().length != length;
}

BottomNavigationBar _defaultTabbyScaffoldBottomNavigationBarBuilder(
        BuildContext context, TabbyState state) =>
    BottomNavigationBar(
      currentIndex: state.currentIndex,
      onTap: (index) => state.currentIndex = index,
      showSelectedLabels: state.widget.bottomBarSelectedLabels,
      showUnselectedLabels: state.widget.bottomBarUnselectedLabels,
      items: state.widget.tabs
          .map((tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                activeIcon: Icon(tab.selectedIcon),
                tooltip: tab.label,
                label: tab.label,
              ))
          .toList(),
    );

Widget _defaultTabbyScaffoldNavigationRailBuilder(
        BuildContext context, TabbyState state) =>
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (state.widget.rightHanded)
          Expanded(child: state.buildBody(context, state.currentTab)),
        NavigationRail(
          labelType: state.widget.navigationRailLabelType,
          selectedIndex: state.currentIndex,
          onDestinationSelected: (index) => state.currentIndex = index,
          destinations: state.widget.tabs
              .map((tab) => NavigationRailDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
                    label: Text(tab.label),
                  ))
              .toList(),
        ),
        if (!state.widget.rightHanded)
          Expanded(child: state.buildBody(context, state.currentTab)),
      ],
    );

Widget _defaultTabbyScaffoldTopTabsBuilder(
        BuildContext context, TabbyState state) =>
    TabBarView(
      children: state.widget.tabs
          .map((tab) => state.buildBody(context, tab))
          .toList(),
    );

PreferredSizeWidget _defaultTabbyScaffoldTopTabsAppBarBottomBuilder(
        BuildContext context, TabbyState state) =>
    TabBar(
      onTap: (index) => state.currentIndex = index,
      tabs: state.widget.tabs
          .map((tab) => state.widget.inlineTabs
              ? Tab(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.widget.topTabIcons)
                        Icon(state.currentId == tab.id
                            ? tab.selectedIcon
                            : tab.icon),
                      if (state.widget.topTabIcons && state.widget.topTabLabels)
                        const Gap(7),
                      if (state.widget.topTabLabels) Text(tab.label),
                    ],
                  ),
                )
              : Tab(
                  icon: state.widget.topTabIcons
                      ? Icon(state.currentId == tab.id
                          ? tab.selectedIcon
                          : tab.icon)
                      : null,
                  text: state.widget.topTabLabels ? tab.label : null,
                ))
          .toList(),
    );

Widget _defaultTabbyScaffoldDrawerBuilder(
        BuildContext context, TabbyState state) =>
    Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: ListView(
            children: [
              ...state.widget.drawerHeaders,
              ...state.widget.tabs.map((tab) => ListTile(
                    leading: Icon(state.currentId == tab.id
                        ? tab.selectedIcon
                        : tab.icon),
                    title: Text(tab.label),
                    onTap: () {
                      state.currentId = tab.id;
                      state.expanded = false;
                    },
                  )),
              ...state.widget.drawerFooters,
            ],
          ))
        ],
      ),
    );

Widget _defaultTabbyScaffoldSidebarBuilder(
        BuildContext context, TabbyState state) =>
    Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (state.widget.rightHanded)
            Expanded(child: state.buildBody(context, state.currentTab)),
          Drawer(
            width: min(MediaQuery.of(context).size.width * 0.3, 300),
            child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...state.widget.sidebarHeaders,
                  Expanded(
                      child: ListView(
                    children: [
                      ...state.widget.drawerHeaders,
                      ...state.widget.tabs.map((tab) => ListTile(
                            leading: Icon(state.currentId == tab.id
                                ? tab.selectedIcon
                                : tab.icon),
                            title: Text(tab.label),
                            onTap: () {
                              state.currentId = tab.id;
                              state.expanded = false;
                            },
                          )),
                      ...state.widget.drawerFooters,
                    ],
                  )),
                  ...state.widget.sidebarFooters,
                ]),
          ),
          if (!state.widget.rightHanded)
            Expanded(child: state.buildBody(context, state.currentTab)),
        ]);

enum TabbyIndexingType { none, indexedStack, lazyIndexedStack }

class Tabby extends StatefulWidget {
  final TabbyType? type;
  final List<TabbyTab> tabs;
  final bool rightHanded;
  final TabbyIndexingType indexing;
  final AppBar? appBar;
  final String? initialTab;
  final ValueChanged<String>? onTabChanged;
  final NavigationRailLabelType navigationRailLabelType;
  final BottomNavigationBar Function(BuildContext context, TabbyState state)
      bottomNavigationBarBuilder;
  final Widget Function(BuildContext context, TabbyState state)
      navigationRailBuilder;
  final Widget Function(BuildContext context, TabbyState state) topTabsBuilder;
  final PreferredSizeWidget Function(BuildContext context, TabbyState state)
      topTabsAppBarBottomBuilder;
  final Widget Function(BuildContext context, TabbyState state) drawerBuilder;
  final Widget Function(BuildContext context, TabbyState state) sidebarBuilder;
  final bool topTabLabels;
  final bool topTabIcons;
  final bool inlineTabs;
  final bool bottomBarSelectedLabels;
  final bool bottomBarUnselectedLabels;
  final List<Widget> drawerHeaders;
  final List<Widget> drawerFooters;
  final List<Widget> sidebarHeaders;
  final List<Widget> sidebarFooters;

  const Tabby({
    super.key,
    this.type,
    required this.tabs,
    this.drawerHeaders = const [],
    this.drawerFooters = const [],
    this.sidebarHeaders = const [],
    this.sidebarFooters = const [],
    this.navigationRailLabelType = NavigationRailLabelType.none,
    this.topTabLabels = true,
    this.topTabIcons = true,
    this.rightHanded = false,
    this.inlineTabs = true,
    this.bottomBarSelectedLabels = false,
    this.bottomBarUnselectedLabels = false,
    this.indexing = TabbyIndexingType.lazyIndexedStack,
    this.initialTab,
    this.onTabChanged,
    this.appBar,
    this.bottomNavigationBarBuilder =
        _defaultTabbyScaffoldBottomNavigationBarBuilder,
    this.navigationRailBuilder = _defaultTabbyScaffoldNavigationRailBuilder,
    this.topTabsBuilder = _defaultTabbyScaffoldTopTabsBuilder,
    this.topTabsAppBarBottomBuilder =
        _defaultTabbyScaffoldTopTabsAppBarBottomBuilder,
    this.drawerBuilder = _defaultTabbyScaffoldDrawerBuilder,
    this.sidebarBuilder = _defaultTabbyScaffoldSidebarBuilder,
  }) : assert(tabs.length >= 2, "TabbyScaffold requires at least 2 tabs");

  TabbyState of(BuildContext context) =>
      context.findAncestorStateOfType<TabbyState>()!;

  @override
  State<Tabby> createState() => TabbyState();
}

class TabbyState extends State<Tabby> {
  late TabController _tabController;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  late String _currentId;
  String get currentId => _currentId;

  set currentId(String value) {
    if (value != currentId) {
      widget.onTabChanged?.call(value);
      setState(() => _currentId = value);

      if (widget.type == TabbyType.topTabs) {
        DefaultTabController.of(context)
            .animateTo(widget.tabs.indexOf(currentTab));
      }
    }
  }

  bool _drawerExpanded = false;
  bool _endDrawerExpanded = false;
  bool get drawerExpanded => _drawerExpanded;
  bool get endDrawerExpanded => _endDrawerExpanded;
  set drawerExpanded(bool opened) {
    if (opened) {
      _scaffoldKey.currentState!.openDrawer();
    } else {
      _scaffoldKey.currentState!.closeDrawer();
    }
  }

  set endDrawerExpanded(bool opened) {
    if (opened) {
      _scaffoldKey.currentState!.openEndDrawer();
    } else {
      _scaffoldKey.currentState!.closeEndDrawer();
    }
  }

  bool get expanded => switch (widget.type) {
        TabbyType.drawer =>
          widget.rightHanded ? endDrawerExpanded : drawerExpanded,
        TabbyType.sidebar => false, // TODO: Implement sidebar expansion
        _ => false,
      };

  set expanded(bool opened) => switch (widget.type) {
        TabbyType.drawer => widget.rightHanded
            ? endDrawerExpanded = opened
            : drawerExpanded = opened,
        TabbyType.sidebar => null, // TODO: Implement sidebar expansion
        _ => null,
      };

  int get currentIndex => widget.tabs.indexOf(currentTab);

  set currentIndex(int index) => currentId = widget.tabs[index].id;

  TabbyTab get currentTab => getTab(currentId);

  TabbyTab getTab(String id) =>
      widget.tabs.select((tab) => tab.id == id) ?? widget.tabs.first;

  @override
  void initState() {
    _scaffoldKey = GlobalKey();
    _currentId = widget.initialTab ?? widget.tabs.first.id;
    super.initState();
  }

  Widget buildBody(BuildContext context, TabbyTab tab) =>
      switch (widget.indexing) {
        TabbyIndexingType.none => tab.builder(context),
        TabbyIndexingType.indexedStack => IndexedStack(
            index: widget.tabs.indexOf(tab),
            children: widget.tabs.map((tab) => tab.builder(context)).toList(),
          ),
        TabbyIndexingType.lazyIndexedStack => LazyLoadIndexedStack(
            index: widget.tabs.indexOf(tab),
            preloadIndexes: widget.tabs
                .where((tab) => tab.preload)
                .map((tab) => widget.tabs.indexOf(tab))
                .toList(),
            children: widget.tabs.map((tab) => tab.builder(context)).toList(),
          ),
      };

  TabbyType get bestType {
    int tabCount = widget.tabs.length;
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();

    if (width > 900 && height > 300) {
      return TabbyType.sidebar;
    } else if (tabCount > 5) {
      return TabbyType.drawer;
    } else if (tabCount > 3) {
      return TabbyType.bottomNavigationBar;
    } else if (width > 400) {
      return TabbyType.topTabs;
    } else if (width > 300) {
      return TabbyType.navigationRail;
    } else {
      return TabbyType.drawer;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(!widget.tabs.hasDuplicateIds, "TabbyTab ids must be unique!");
    return switch (widget.type ?? bestType) {
      TabbyType.bottomNavigationBar => Scaffold(
          key: _scaffoldKey,
          appBar: currentTab.buildAppBar(widget.appBar),
          body: buildBody(context, currentTab),
          bottomNavigationBar: widget.bottomNavigationBarBuilder(context, this),
        ),
      TabbyType.navigationRail => Scaffold(
          key: _scaffoldKey,
          appBar: currentTab.buildAppBar(widget.appBar),
          body: widget.navigationRailBuilder(context, this),
        ),
      TabbyType.topTabs => DefaultTabController(
          length: widget.tabs.length,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: (currentTab.buildAppBar(widget.appBar) ?? AppBar())
                .copyWith(
                    bottom: widget.topTabsAppBarBottomBuilder(context, this)),
            body: widget.topTabsBuilder(context, this),
          ),
        ),
      TabbyType.drawer => Scaffold(
          key: _scaffoldKey,
          onDrawerChanged: (isOpened) => _drawerExpanded = isOpened,
          onEndDrawerChanged: (isOpened) => _endDrawerExpanded = isOpened,
          appBar: currentTab.buildAppBar(widget.appBar)?.copyWith(actions: [
            ...currentTab.buildAppBar(widget.appBar)?.actions ?? [],
            if (widget.rightHanded)
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => expanded = true,
              )
          ]),
          drawer:
              widget.rightHanded ? null : widget.drawerBuilder(context, this),
          endDrawer:
              widget.rightHanded ? widget.drawerBuilder(context, this) : null,
        ),
      TabbyType.sidebar => Scaffold(
          key: _scaffoldKey,
          appBar: currentTab.buildAppBar(widget.appBar),
          body: widget.sidebarBuilder(context, this),
        )
    };
  }
}
