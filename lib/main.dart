import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens.dart';

void main() => runApp(const VentApp());

class VentApp extends StatelessWidget {
  const VentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vent',
      debugShowCheckedModeBanner: false,
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    ExploreScreen(),
    CreatePostScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _BottomBar(index: _index, onTap: (i) => setState(() => _index = i)),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    const items = <List<IconData>>[
      [Icons.home_outlined, Icons.home],
      [Icons.search, Icons.search],
      [Icons.add_box_outlined, Icons.add_box],
      [Icons.notifications_none, Icons.notifications],
      [Icons.person_outline, Icons.person],
    ];
    return Container(
      decoration: BoxDecoration(
        color: p.bg,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == index;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Icon(
                    selected ? items[i][1] : items[i][0],
                    size: 26,
                    color: selected ? p.text : p.secondary,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
