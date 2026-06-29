import 'dart:math';

import 'ai_models.dart';

/// On-device, no-network gag generator. A small weighted grammar recombines
/// fragments so the humour feels endless without ever leaving the phone. This
/// is the middle fallback layer: used when AI is off or the network fails, and
/// it still beats the fixed static lists for variety.
class TemplateGagSource {
  TemplateGagSource([Random? rng]) : _rng = rng ?? Random();

  final Random _rng;

  String _pick(List<String> xs) => xs[_rng.nextInt(xs.length)];
  T _pickOf<T>(List<T> xs) => xs[_rng.nextInt(xs.length)];

  // --- fragment banks ---------------------------------------------------------

  static const _dests = [
    'Eventually', 'Cancelled (vibes)', 'Somewhere, probably', 'Nowhere Int',
    'The Void', 'Last Stop (emotionally)', 'Kopitiam Express', 'Pulau Maybe',
    'Ulu Pandai', 'Terminal Despair', 'Loop (forever)', 'Checkpoint Charlie-kia',
  ];
  static const _verdicts = [
    '2 min (lies)', 'Avoid lah', 'Driver gave up', 'When it feels like it',
    'Packed like sardine', 'Bo space sia', 'Maybe next year', 'Pray',
    'Already gone', 'Surge incoming', 'Honestly fair enough',
  ];
  static const _subs = [
    'Last seen heading to the kopitiam.', 'It is full. It is SO full. Bo space.',
    'Something happened. Dun ask.', 'Driver also gave up. Solidarity.',
    'Replaced by a shuttle. Shuttle also missing.', 'Have you considered walking?',
    'It is in the name. You knew this.', 'The driver is in counselling.',
    'Suspended. Grab surge now 4.2x. Coincidence?',
  ];
  static const _times = ['Arr', '—', 'Gone', '~ ~ ~', '12 28 51', '99', 'soon™', 'napping'];

  static const _mapVerbs = [
    'taking the scenic route 🌴', 'stopped for kaya toast ☕',
    'Recalculating… into the sea 🌊', 'doing a U-turn for fun 🔄',
    'chasing another bus 🏎️', 'lost, asking for directions 🗺️',
    'driving in circles (vibes) 🌀', 'parked at the wrong universe 🛸',
    'reversing out of spite ↩️', 'on a snack break 🍜',
  ];

  static const _prankTitles = ['Bus 3rd', 'Your bus update', 'Transit Co. alert', 'Important (not really)'];
  static const _prankBodies = [
    'Your bus is feeling shy today and went home 🏠',
    'Driver stopped for kaya toast. ETA: never ☕',
    'Bus 3rd arriving in -3 minutes. You missed it 😭',
    'Someone choped your seat with a tissue 🧻',
    'The bus is now a boat. Please bring floaties 🌊',
    'Surprise! No bus. Just vibes ✨',
    'We escalated this to the uncle. He is unbothered.',
  ];

  static const _lateMins = ['37', 'lol', 'none', '−%', '88', '∞', '12 (then 40)'];
  static const _lateConf = ['0%', 'lol', 'none', '−%', 'rounded down for your feelings'];
  static const _lateNotes = [
    'the 88 betrayed you again', 'optimistic. you will regret this',
    'we stopped counting honestly', 'spiritually you are already late',
    'bring a book. and a will.',
  ];

  static const _feedLines = [
    'We are aware of a minor delay affecting all lines.',
    'Update: the fault has developed a fault.',
    'Our engineers have also given up. Solidarity.',
    'Have you tried walking? Swimming? Astral projection?',
    'The shuttle bus is now experiencing its own shuttle bus.',
    'Service resumes shortly. "Shortly" is a social construct.',
    'We escalated this to the uncle. He is unbothered.',
  ];

  static const _reviewNames = [
    'Auntie Doris, 61', 'Uncle Tan, 67', 'Xiao Ming, 23', 'Auntie Mei, 54',
    'Ah Beng, 31', 'Mdm Lim, 58', 'Kumar, 44', 'Siti, 27',
  ];
  static const _reviewQuotes = [
    'App say 2 min. I aged 2 years. Bus 3rd indeed.',
    'Driver see me running, still close door and smile. We not friends anymore.',
    'Used this to plan my commute. Now I plan my funeral. 10/10 realistic sia.',
    'Wait 40 min, then three buses come together. As a treat. Walao.',
    'Five stars. The despair is very accurate.',
    'I gave up and walked. App was right for once.',
  ];

  String _initials(String name) {
    final first = name.trim().isNotEmpty ? name.trim()[0] : '?';
    final parts = name.split(' ');
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : 'X';
    return '$first$second'.toUpperCase();
  }

  // --- generators -------------------------------------------------------------

  List<AiArrival> arrivals(int count) => List.generate(
        count,
        (_) => AiArrival(
          dest: _pick(_dests),
          verdict: _pick(_verdicts),
          sub: _pick(_subs),
          times: _pick(_times),
        ),
      );

  List<AiReview> reviews(int count) => List.generate(count, (_) {
        final name = _pick(_reviewNames);
        return AiReview(
          initials: _initials(name),
          name: name,
          stars: _rng.nextInt(5) == 0 ? 5 : _rng.nextInt(2) + 1,
          quote: _pick(_reviewQuotes),
        );
      });

  List<AiLatePrediction> latePredictions(int count) => List.generate(
        count,
        (_) => AiLatePrediction(mins: _pick(_lateMins), confidence: _pick(_lateConf), note: _pick(_lateNotes)),
      );

  List<AiPrank> pranks(int count) =>
      List.generate(count, (_) => AiPrank(title: _pick(_prankTitles), body: _pick(_prankBodies)));

  List<String> mapGags(int count) =>
      List.generate(count, (_) => 'Bus is ${_pick(_mapVerbs)}');

  List<String> feed(int count) => List.generate(count, (_) => _pick(_feedLines));

  AiPrank prank() => _pickOf(pranks(1));
  String mapGag() => mapGags(1).first;
  AiLatePrediction latePrediction() => latePredictions(1).first;

  AiRoast roast(String destination) {
    final d = destination.trim().isEmpty ? 'wherever you are going' : destination.trim();
    return AiRoast(
      minutesLate: _pick(_lateMins),
      confidence: _pick(_lateConf),
      verdict: _pick(_verdicts),
      note: 'To reach $d: ${_pick(_lateNotes)}.',
      prank: 'Your trip to $d has been ${_pick(['cancelled', 'rerouted to the sea', 'deferred to next life'])} 🚏',
    );
  }

  AiCertificate certificate() => AiCertificate(
        title: _pick(['You chose peace', 'Serenity achieved', 'You are free now']),
        body: _pick([
          'You have been removed from the bus queue and the rat race. Congratulations.',
          'No bus can disappoint you now. You disappointed it first.',
          'The 88 will arrive. You will not be there. This is growth.',
        ]),
        stat1Label: 'Buses missed today',
        stat1Value: '${_rng.nextInt(6) + 2}',
        stat2Label: 'Minutes you will never get back',
        stat2Value: '∞',
      );

  /// Offline stand-in for the uncle chatbot — canned, in-character snark.
  String uncleReply() => _pick(const [
        'Bus? What bus. Sit down lah.',
        'I also waiting. Difference is I get paid.',
        'Aiyo. You again. It is not coming.',
        'Patience. Or walk. Walking is also transport.',
        'Last bus left. Took my dignity with it.',
        'You want comfort or you want truth. Cannot have both here.',
      ]);
}
