import 'package:flutter/material.dart';
import 'package:tabby/tabby.dart';

void main() => runApp(const TabbyExampleApp());

class TabbyExampleApp extends StatelessWidget {
  const TabbyExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData.light(useMaterial3: true)
            .copyWith(splashFactory: InkSparkle.splashFactory),
        debugShowCheckedModeBanner: false,
        home: TabbyTest(),
      );
}

class TabbyTest extends StatefulWidget {
  const TabbyTest({super.key});

  @override
  State<TabbyTest> createState() => _TabbyTestState();
}

class _TabbyTestState extends State<TabbyTest> {
  late TabbyType? type;
  bool rightHanded = false;

  @override
  void initState() {
    type = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: TabbyScaffold(
            rightHanded: rightHanded,
            type: type,
            appBar: AppBar(title: const Text("Tabby Example"), actions: [
              if (type?.isHanded ?? false)
                IconButton(
                  icon: Icon(rightHanded
                      ? Icons.toggle_on_rounded
                      : Icons.toggle_off_rounded),
                  onPressed: () => setState(() => rightHanded = !rightHanded),
                ),
              PopupMenuButton<TabbyType?>(
                child: const Padding(
                  padding: EdgeInsets.only(right: 7),
                  child: Icon(Icons.category_rounded),
                ),
                onSelected: (value) => setState(() => type = value),
                itemBuilder: (context) => [
                  PopupMenuItem(child: const Text("auto"), value: null),
                  ...TabbyType.values.map((e) => PopupMenuItem<TabbyType?>(
                        value: e,
                        child: Text(e.toString().split(".").last),
                      ))
                ],
              ),
            ]),
            tabs: [
              TabbyTab(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: "Home",
                  appBarBuilder: (bar) => bar!.copyWith(
                        title: const Text("Home"),
                      ),
                  builder: (context) => const Center(child: Text("Home"))),
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
                        ],
                      ),
                  builder: (context) => const Center(child: Text("Search"))),
              TabbyTab(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: "Settings",
                  appBarBuilder: (bar) =>
                      bar!.copyWith(title: const Text("Settings")),
                  builder: (context) => const Center(child: Text("Settings"))),
            ]),
      );
}
