import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_theme.dart';

/// The Chope tab, rebuilt as **BUS 3RD** — a third-person bus-driving mini-game.
///
/// The game itself is a self-contained Three.js/WebGL scene shipped as a bundled
/// asset (`assets/game/bus3rd.html` + `three.min.js`). We host it in a WebView so
/// the whole 3D experience runs offline with no CDN dependency.
class BusGameScreen extends StatefulWidget {
  const BusGameScreen({super.key});

  @override
  State<BusGameScreen> createState() => _BusGameScreenState();
}

class _BusGameScreenState extends State<BusGameScreen> {
  // Null when no WebView platform is available (e.g. widget tests, or a target
  // without a webview_flutter implementation) — we fall back to a message then.
  WebViewController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF9FD1F5)) // matches the game's sky
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _loading = false);
            },
            // Keep everything inside the bundled game; block stray web navigations.
            onNavigationRequest: (request) => request.url.startsWith('http')
                ? NavigationDecision.prevent
                : NavigationDecision.navigate,
          ),
        )
        ..loadFlutterAsset('assets/game/bus3rd.html');
    } catch (_) {
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          if (controller != null)
            Positioned.fill(child: WebViewWidget(controller: controller))
          else
            const _GameUnavailable(),
          if (controller != null && _loading) const _GameLoader(),
        ],
      ),
    );
  }
}

/// Branded loading state shown while the WebGL scene boots.
class _GameLoader extends StatelessWidget {
  const _GameLoader();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF9FD1F5),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚌', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 14),
            Text('BUS 3RD',
                style: T.display(24, color: AppColors.red, weight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('Warming up the engine…',
                style: T.body(13, color: AppColors.ink.withValues(alpha: 0.7))),
            const SizedBox(height: 18),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.red),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when this platform has no WebView (keeps the app from crashing).
class _GameUnavailable extends StatelessWidget {
  const _GameUnavailable();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF9FD1F5),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚌', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text('BUS 3RD',
                style: T.display(24, color: AppColors.red, weight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('The driving game needs a device with a WebView. Try it on the phone app 🚦',
                textAlign: TextAlign.center,
                style: T.body(13, color: AppColors.ink.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}
