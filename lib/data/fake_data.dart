import 'dart:math';

import '../models/bus_models.dart';
import '../theme/app_theme.dart';

/// All content is fictional and for comedy only. No real transit operator,
/// route, or stop is referenced. Ported from the Bus 3rd prototype.
class FakeData {
  FakeData._();

  static final Random _rng = Random();

  /// Loading / "login" messages on the splash screen.
  static const List<String> loadingMsgs = [
    'Triangulating your disappointment…',
    'Asking the uncle…',
    'Downloading more buses…',
    'Recalculating (badly)…',
    'Bribing the bus captain…',
    'Waiting for 88. Still waiting…',
    'Pretending to find your location…',
    'Generating false hope…',
    'Buffering your patience…',
    'Reticulating splines (whatever that means)…',
    'Consulting the void…',
  ];

  static const List<BusItem> buses = [
    BusItem(plate: '88', color: AppColors.red, dest: 'Toa Payoh Int', verdict: '2 min (lies)', sub: 'All 3 will arrive together. As a treat.', times: 'Arr', timeColor: AppColors.green),
    BusItem(plate: 'L8', color: AppColors.red, dest: 'Eventually', verdict: 'When it feels like it', sub: 'It is in the name. You knew this.', times: '~ ~ ~', timeColor: AppColors.amberDark),
    BusItem(plate: 'M80', color: AppColors.purple, dest: 'Cancelled (vibes)', verdict: 'Driver also gave up', sub: 'Last seen heading to the kopitiam.', times: '—', timeColor: AppColors.muted2),
    BusItem(plate: '857', color: AppColors.red, dest: 'Yishun (good luck)', verdict: 'Avoid lah', sub: 'Something happened. Dun ask.', times: '12 28 51', timeColor: AppColors.ink),
    BusItem(plate: '969', color: AppColors.red, dest: 'Woodlands Checkpoint', verdict: 'Packed like sardine', sub: 'It is full. It is SO full. Bo space.', times: 'Arr', timeColor: AppColors.red),
    BusItem(plate: 'NR7', color: AppColors.ink, dest: 'Night Rider', verdict: 'You drunk. Go home.', sub: 'Last bus left without you. Typical.', times: 'Gone', timeColor: AppColors.muted2),
  ];

  static const List<String> susSubs = [
    'Replaced by a free shuttle. The shuttle is also missing.',
    'Suspended. Have you considered walking?',
    'Suspended. The driver is in counselling.',
    'Suspended. Pray.',
    'Suspended. Grab surge is now 4.2x. Coincidence?',
    'Suspended. Honestly fair enough.',
  ];

  static const List<Review> reviews = [
    Review(initials: 'AD', name: 'Auntie Doris, 61', stars: 1, avatarBg: AppColors.red, quote: 'Wait 40 min for 88, when come got three buses together. Walao. One star still too generous.'),
    Review(initials: 'UT', name: 'Uncle Tan, 67', stars: 2, avatarBg: AppColors.purple, quote: 'Driver see me running, still close door and smile. I know that man. We not friends anymore.'),
    Review(initials: 'XM', name: 'Xiao Ming, 23', stars: 5, avatarBg: AppColors.ink, quote: 'Used this app to plan my commute. Now I plan my funeral. 10/10 very realistic sia.'),
    Review(initials: 'Mei', name: 'Auntie Mei, 54', stars: 1, avatarBg: AppColors.amberDark, quote: 'App say 2 min. I aged 2 years. Bus 3rd indeed. My grandson grew up already.'),
  ];

  static const List<FeedItem> feed = [
    FeedItem('10:02', 'We are aware of a minor delay affecting all lines.'),
    FeedItem('10:09', 'Free regular bus services available at affected stations (also late).'),
    FeedItem('10:21', 'We are working hard to resolve this. (We are not.)'),
    FeedItem('10:34', 'Update: the fault has developed a fault.'),
    FeedItem('10:48', 'Our engineers have also given up. Solidarity.'),
    FeedItem('11:05', 'Have you tried walking? Swimming? Astral projection?'),
    FeedItem('11:27', 'The shuttle bus is now experiencing its own shuttle bus.'),
    FeedItem('11:52', 'We have escalated this to the uncle. He is unbothered.'),
    FeedItem('12:15', 'Service resumes shortly. "Shortly" is a social construct.'),
  ];

  static const List<SavedItem> saved = [
    SavedItem(plate: '88', color: AppColors.red, dest: 'Toa Payoh Int', note: 'Saved 3 years ago. Still hoping.'),
    SavedItem(plate: '857', color: AppColors.red, dest: 'Yishun', note: 'Why did you save this one. Why.'),
    SavedItem(plate: 'L8', color: AppColors.purple, dest: 'Eventually', note: 'A monument to your optimism.'),
  ];

  static const List<LatePrediction> latePredictions = [
    LatePrediction('37', '0%', 'rounded down to spare your feelings'),
    LatePrediction('52', 'lol', 'the 88 betrayed you again'),
    LatePrediction('19', 'none', 'optimistic. you will regret this'),
    LatePrediction('88', '−%', 'we stopped counting honestly'),
  ];

  static const List<String> mapGags = [
    'Bus is taking the scenic route 🌴',
    'Driver stopped for kaya toast ☕',
    'Recalculating… into the sea 🌊',
    'Doing a U-turn for fun 🔄',
    'Chasing another bus 🏎️',
    'Lost. Asking for directions 🗺️',
    'Driving in circles (vibes) 🌀',
    'Took a wrong exit at the roundabout 🛣️',
  ];

  static const List<String> prankTitles = [
    'Bus 3rd', 'Your bus update', 'Transit Co. alert', 'Important (not really)',
  ];

  static const List<String> prankBodies = [
    'Your bus is feeling shy today and went home 🏠',
    'Driver stopped for kaya toast. ETA: never ☕',
    'Bus 3rd arriving in -3 minutes. You missed it 😭',
    'Someone choped your seat with a tissue 🧻',
    'The bus is now a boat. Please bring floaties 🌊',
    'Surprise! No bus. Just vibes ✨',
  ];

  static String randomMapGag() => mapGags[_rng.nextInt(mapGags.length)];
  static String randomPrankTitle() => prankTitles[_rng.nextInt(prankTitles.length)];
  static String randomPrankBody() => prankBodies[_rng.nextInt(prankBodies.length)];
}
