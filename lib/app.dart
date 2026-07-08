import 'package:flutter/material.dart';

import 'screens/about_screen.dart';
import 'screens/ai_hub_screen.dart';
import 'screens/bus_game_screen.dart';
import 'screens/fake_map_screen.dart';
import 'screens/give_up_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';

class BusApp extends StatelessWidget {
  const BusApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      appState: appState,
      child: MaterialApp(
        title: 'Bus 3rd',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const RootGate(),
      ),
    );
  }
}

/// Shows the splash ("login") until the user taps in, then the main shell.
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  bool _entered = false;

  @override
  Widget build(BuildContext context) {
    if (!_entered) {
      return SplashScreen(onEnter: () => setState(() => _entered = true));
    }
    return const RootShell();
  }
}

/// Bottom-navigation shell. Tabs: Home, Map, AI, Drive, Give Up.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  // Bumped when entering the Give Up tab so its flow restarts from "confirm".
  int _giveUpKey = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowDisclaimer());
  }

  Future<void> _maybeShowDisclaimer() async {
    final appState = AppScope.of(context);
    if (appState.seenDisclaimer) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Welcome aboard! 🚌',
            style: T.display(18, weight: FontWeight.w800, spacing: 0)),
        content: SingleChildScrollView(
          child: Text(kParodyDisclaimer, style: T.body(14, color: AppColors.inkSoft)),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () {
              AppScope.of(context).markDisclaimerSeen();
              Navigator.of(context).pop();
            },
            child: const Text('I understand, it\'s a joke'),
          ),
        ],
      ),
    );
  }

  void _select(int i) {
    setState(() {
      if (i == 4 && _index != 4) _giveUpKey++; // restart Give Up flow
      _index = i;
    });
  }

  void _goHome() => _select(0);

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const FakeMapScreen(),
      const AiHubScreen(),
      const BusGameScreen(),
      GiveUpScreen(key: ValueKey(_giveUpKey), onGoHome: _goHome),
    ];
    return Scaffold(
      body: SafeArea(top: false, bottom: false, child: IndexedStack(index: _index, children: pages)),
      bottomNavigationBar: _BusNavBar(index: _index, onSelect: _select),
    );
  }
}

/// Red gradient bottom nav matching the prototype.
class _BusNavBar extends StatelessWidget {
  const _BusNavBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.map_outlined, Icons.map, 'Map'),
    (Icons.auto_awesome_outlined, Icons.auto_awesome, 'AI'),
    (Icons.directions_bus_outlined, Icons.directions_bus, 'Drive'),
    (Icons.flag_outlined, Icons.flag, 'Give Up'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.redHeader,
        ),
        boxShadow: [BoxShadow(color: Color(0x38AA140C), blurRadius: 14, offset: Offset(0, -3))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++) _navButton(i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(int i) {
    final active = i == index;
    final (outline, filled, label) = _items[i];
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: active ? Colors.black.withValues(alpha: 0.16) : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(active ? filled : outline, color: Colors.white, size: 23),
              const SizedBox(height: 4),
              Text(label,
                  style: T.display(10.5, color: Colors.white, weight: FontWeight.w700, spacing: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}
