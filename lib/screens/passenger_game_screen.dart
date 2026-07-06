import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

/// Passenger 2048 — the Chope tab, rebuilt as a merge puzzle on a bus-seat grid
/// (4 seats per row, aisle down the middle). Swipe to slide passengers; merge
/// two of the same to evolve them up the chain to the Bus Captain.

const int kCols = 4;
const int kRows = 5;
const int kMaxTier = 9; // Bus Captain

/// A single passenger tier's presentation. Each tier is a character tile image
/// (with a baked-in coloured background) plus a fallback colour/label used if an
/// asset ever fails to load.
class Passenger {
  const Passenger(this.asset, this.label, this.color);
  final String asset; // '' for the empty seat
  final String label;
  final Color color; // fallback tint
}

const String _tiles = 'assets/images/tiles';

const List<Passenger> kTiers = [
  Passenger('', '', Colors.transparent), // 0 = empty seat
  Passenger('$_tiles/school_boy.png', 'School Boy', Color(0xFFEFE6D2)),
  Passenger('$_tiles/backpack.png', 'Poly Kid', Color(0xFFEBDCC0)),
  Passenger('$_tiles/ns_soldier.png', 'NS Boy', Color(0xFFF3B682)),
  Passenger('$_tiles/office_lady.png', 'Office Lady', Color(0xFFF0C14B)),
  Passenger('$_tiles/office_man.png', 'Office Man', Color(0xFFE98A5A)),
  Passenger('$_tiles/ahma.png', 'Ah Ma', Color(0xFFEFC94C)),
  Passenger('$_tiles/ahgong.png', 'Ah Gong', Color(0xFFEFCF5C)),
  Passenger('$_tiles/bus_conductor.png', 'Conductor', Color(0xFFE98F63)),
  Passenger('$_tiles/bus_captain.png', 'Bus Captain', Color(0xFFE2231A)),
];

/// Points value of a tier (classic 2048-style: 2^tier).
int tierValue(int tier) => tier <= 0 ? 0 : (1 << tier);

/// Slides one line of tiers toward index 0, merging equal neighbours once.
/// Returns the new line (same length, zero-padded) and the score gained.
/// Pure + deterministic → unit tested.
(List<int>, int) slidePassengerLine(List<int> line, {int maxTier = kMaxTier}) {
  final nonzero = line.where((v) => v != 0).toList();
  final result = <int>[];
  var gained = 0;
  var i = 0;
  while (i < nonzero.length) {
    if (i + 1 < nonzero.length &&
        nonzero[i] == nonzero[i + 1] &&
        nonzero[i] < maxTier) {
      final merged = nonzero[i] + 1;
      result.add(merged);
      gained += tierValue(merged);
      i += 2;
    } else {
      result.add(nonzero[i]);
      i += 1;
    }
  }
  while (result.length < line.length) {
    result.add(0);
  }
  return (result, gained);
}

enum _Dir { up, down, left, right }

class PassengerGameScreen extends StatefulWidget {
  const PassengerGameScreen({super.key});

  @override
  State<PassengerGameScreen> createState() => _PassengerGameScreenState();
}

class _PassengerGameScreenState extends State<PassengerGameScreen> {
  final Random _rng = Random();
  late List<int> _board;
  int _score = 0;
  int _best = 0;
  bool _won = false;
  bool _keepPlaying = false;
  bool _over = false;
  int _moveTick = 0; // bumps so tiles replay their pop animation

  static const _kBestKey = 'p2048_best';
  SharedPreferences? _prefs;

  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _newGame();
    SharedPreferences.getInstance().then((p) {
      if (!mounted) return;
      setState(() {
        _prefs = p;
        _best = p.getInt(_kBestKey) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  int _idx(int r, int c) => r * kCols + c;

  void _newGame() {
    setState(() {
      _board = List.filled(kRows * kCols, 0);
      _score = 0;
      _won = false;
      _keepPlaying = false;
      _over = false;
      _spawn();
      _spawn();
      _moveTick++;
    });
  }

  void _spawn() {
    final empty = <int>[];
    for (var i = 0; i < _board.length; i++) {
      if (_board[i] == 0) empty.add(i);
    }
    if (empty.isEmpty) return;
    _board[empty[_rng.nextInt(empty.length)]] = _rng.nextInt(10) == 0 ? 2 : 1;
  }

  /// Returns the indices of a row/column in the order tiles move for [dir]
  /// (first index = the edge they slide toward).
  List<List<int>> _lines(_Dir dir) {
    final lines = <List<int>>[];
    switch (dir) {
      case _Dir.left:
        for (var r = 0; r < kRows; r++) {
          lines.add([for (var c = 0; c < kCols; c++) _idx(r, c)]);
        }
      case _Dir.right:
        for (var r = 0; r < kRows; r++) {
          lines.add([for (var c = kCols - 1; c >= 0; c--) _idx(r, c)]);
        }
      case _Dir.up:
        for (var c = 0; c < kCols; c++) {
          lines.add([for (var r = 0; r < kRows; r++) _idx(r, c)]);
        }
      case _Dir.down:
        for (var c = 0; c < kCols; c++) {
          lines.add([for (var r = kRows - 1; r >= 0; r--) _idx(r, c)]);
        }
    }
    return lines;
  }

  bool _boardWouldChange(_Dir dir) {
    for (final line in _lines(dir)) {
      final current = [for (final i in line) _board[i]];
      final (next, _) = slidePassengerLine(current);
      for (var k = 0; k < line.length; k++) {
        if (current[k] != next[k]) return true;
      }
    }
    return false;
  }

  void _move(_Dir dir) {
    if (_over) return;
    var changed = false;
    var gained = 0;
    for (final line in _lines(dir)) {
      final current = [for (final i in line) _board[i]];
      final (next, g) = slidePassengerLine(current);
      gained += g;
      for (var k = 0; k < line.length; k++) {
        if (_board[line[k]] != next[k]) changed = true;
        _board[line[k]] = next[k];
      }
    }
    if (!changed) return;

    setState(() {
      _score += gained;
      if (_score > _best) {
        _best = _score;
        _prefs?.setInt(_kBestKey, _best);
      }
      _spawn();
      _moveTick++;
      if (!_won && !_keepPlaying && _board.contains(kMaxTier)) _won = true;
      if (!_hasMoves()) _over = true;
    });
  }

  bool _hasMoves() {
    if (_board.contains(0)) return true;
    return _Dir.values.any(_boardWouldChange);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowUp:
            _move(_Dir.up);
          case LogicalKeyboardKey.arrowDown:
            _move(_Dir.down);
          case LogicalKeyboardKey.arrowLeft:
            _move(_Dir.left);
          case LogicalKeyboardKey.arrowRight:
            _move(_Dir.right);
          default:
            return KeyEventResult.ignored;
        }
        return KeyEventResult.handled;
      },
      child: Column(
        children: [
          const AppHeader(locationLabel: 'Boarding', locationValue: 'Bus 88 → Toa Payoh'),
          _headerRow(),
          Expanded(child: _boardArea()),
          _legend(),
        ],
      ),
    );
  }

  Widget _headerRow() {
    Widget chip(String label, String value) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Text(label.toUpperCase(),
                  style: T.body(9.5, color: AppColors.muted2, weight: FontWeight.w700)
                      .copyWith(letterSpacing: 0.6)),
              Text(value, style: T.display(18, weight: FontWeight.w900, spacing: 0)),
            ],
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Passenger 2048', style: T.display(20, weight: FontWeight.w900)),
                Text('Merge commuters → the Bus Captain 🧑‍✈️',
                    style: T.body(12, color: AppColors.muted)),
              ],
            ),
          ),
          chip('Score', '$_score'),
          const SizedBox(width: 8),
          chip('Best', '$_best'),
        ],
      ),
    );
  }

  Widget _boardArea() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: AspectRatio(
              aspectRatio: kCols / kRows,
              child: GestureDetector(
                onHorizontalDragEnd: (d) {
                  final v = d.velocity.pixelsPerSecond.dx;
                  if (v.abs() < 60) return;
                  _move(v < 0 ? _Dir.left : _Dir.right);
                },
                onVerticalDragEnd: (d) {
                  final v = d.velocity.pixelsPerSecond.dy;
                  if (v.abs() < 60) return;
                  _move(v < 0 ? _Dir.up : _Dir.down);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4DCC9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    children: [
                      for (var r = 0; r < kRows; r++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: r == kRows - 1 ? 0 : 8),
                            child: Row(
                              children: [
                                _cell(r, 0),
                                const SizedBox(width: 8),
                                _cell(r, 1),
                                const SizedBox(width: 20), // aisle
                                _cell(r, 2),
                                const SizedBox(width: 8),
                                _cell(r, 3),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_over || (_won && !_keepPlaying)) _overlay(),
      ],
    );
  }

  Widget _cell(int r, int c) {
    final tier = _board[_idx(r, c)];
    final p = kTiers[tier];
    final seat = tier == 0
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
          )
        : TweenAnimationBuilder<double>(
            // Key changes when this seat's tier changes → replays the pop.
            key: ValueKey('$r-$c-$tier-$_moveTick'),
            tween: Tween(begin: 0.7, end: 1),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutBack,
            builder: (context, s, child) => Transform.scale(scale: s, child: child),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      p.asset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: p.color,
                        alignment: Alignment.center,
                        child: Text(p.label,
                            textAlign: TextAlign.center,
                            style: T.display(10, weight: FontWeight.w800, spacing: 0)),
                      ),
                    ),
                    // Name ribbon so the merge chain is easy to learn.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                        color: Colors.black.withValues(alpha: 0.45),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(p.label,
                              style: T.display(9.5, color: Colors.white, weight: FontWeight.w800, spacing: 0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
    return Expanded(child: seat);
  }

  Widget _overlay() {
    final win = _won && !_over;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(28),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (win)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset('$_tiles/bus_captain.png',
                        width: 90, height: 90, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Text('🧑‍✈️', style: TextStyle(fontSize: 52))),
                  )
                else
                  const Text('🚌', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 8),
                Text(win ? 'You found the Bus Captain!' : 'Bus full — no moves left',
                    textAlign: TextAlign.center,
                    style: T.display(20, weight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(win ? 'Peak commuter evolution. Shiok.' : 'Score: $_score',
                    style: T.body(13, color: AppColors.muted)),
                const SizedBox(height: 18),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (win)
                      OutlinedButton(
                        onPressed: () => setState(() => _keepPlaying = true),
                        child: Text('Keep going', style: T.body(13, weight: FontWeight.w700)),
                      ),
                    if (win) const SizedBox(width: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.red),
                      onPressed: _newGame,
                      child: const Text('New game'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _legend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text('Swipe to slide • same passenger merges • aisle doesn\'t block',
                style: T.body(11.5, color: AppColors.muted)),
          ),
          const SizedBox(width: 10),
          TextButton.icon(
            onPressed: _newGame,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text('New', style: T.body(12.5, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
