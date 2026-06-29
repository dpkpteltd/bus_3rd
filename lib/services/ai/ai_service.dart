import 'ai_config.dart';
import 'ai_models.dart';
import 'live_ai_client.dart';
import 'template_gag_source.dart';

/// Single entry point for everything AI in the app.
///
/// Policy lives here and nowhere else: when online mode is on AND a backend was
/// compiled in, each call tries the live proxy first; on any failure (or when
/// offline) it falls back to the on-device [TemplateGagSource]. Methods never
/// throw — callers always get usable comedy.
class AiService {
  AiService._();
  static final AiService instance = AiService._();

  final LiveAiClient _live = LiveAiClient();
  final TemplateGagSource _template = TemplateGagSource();

  /// Toggled by the user via settings; mirrored from [AppState.aiOnline].
  bool online = false;

  /// Whether a live attempt is even possible right now.
  bool get canUseLive => AiConfig.isConfigured && online;

  /// True if the build has a backend wired in at all (controls whether the
  /// settings toggle is shown).
  bool get isConfigured => AiConfig.isConfigured;

  Future<T> _tryLive<T>(Future<T> Function() live, T Function() fallback) async {
    if (!canUseLive) return fallback();
    try {
      return await live();
    } catch (e) {
      aiDebug('live call failed, falling back: $e');
      return fallback();
    }
  }

  // --- gag generator ----------------------------------------------------------

  Future<List<AiArrival>> arrivals({int count = 6}) =>
      _tryLive(() => _live.arrivals(count), () => _template.arrivals(count));

  Future<List<AiReview>> reviews({int count = 4}) =>
      _tryLive(() => _live.reviews(count), () => _template.reviews(count));

  Future<AiLatePrediction> latePrediction() => _tryLive(
        () async => (await _live.latePredictions(1)).first,
        () => _template.latePrediction(),
      );

  Future<AiPrank> prank() => _tryLive(
        () async => (await _live.pranks(1)).first,
        () => _template.prank(),
      );

  Future<String> mapGag() => _tryLive(
        () async => (await _live.mapGags(1)).first,
        () => _template.mapGag(),
      );

  Future<List<String>> feed({int count = 9}) =>
      _tryLive(() => _live.feed(count), () => _template.feed(count));

  // --- interactive features ---------------------------------------------------

  Future<String> uncleReply(List<UncleTurn> history) => _tryLive(
        () => _live.uncle(history),
        () => _template.uncleReply(),
      );

  Future<AiRoast> roast(String destination) => _tryLive(
        () => _live.roast(destination),
        () => _template.roast(destination),
      );

  Future<AiCertificate> certificate({String? seed}) => _tryLive(
        () => _live.certificate(seed: seed),
        () => _template.certificate(),
      );

  /// True when the most recent interactive call would go to the real model —
  /// lets the UI show an "offline pretend mode" hint without lying.
  bool get liveActive => canUseLive;
}
