/// Supabase project URL + anon key for reaching the `ai` Edge Function.
///
/// Both are read from `--dart-define` at build time so real values stay out of
/// source control. To run with AI enabled:
///
/// ```bash
/// flutter run \
///   --dart-define=BUS3RD_SUPABASE_URL=https://<project-ref>.supabase.co \
///   --dart-define=BUS3RD_SUPABASE_ANON_KEY=<your anon key>
/// ```
///
/// The anon key is a publishable JWT — safe to ship in a client app. The
/// MiniMax key lives only in the Edge Function's secrets, never here.
///
/// If either value is empty the app behaves exactly as before: fully offline,
/// no network, "Data Not Collected" stays true. Online mode is also gated
/// behind a user toggle (see [AppState.aiOnline]), so AI is never used without
/// opt-in.
class AiConfig {
  AiConfig._();

  // Defaults point at the live Bus 3rd project so the app works out of the box.
  // The anon/publishable key is designed to be shipped in clients; the MiniMax
  // key stays server-side in the Edge Function's secrets. Override either with
  // --dart-define for a different environment.
  static const String supabaseUrl = String.fromEnvironment(
    'BUS3RD_SUPABASE_URL',
    defaultValue: 'https://jdaxxtnwczdijfsabuzl.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'BUS3RD_SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_WCHRDtmxMN4xqNwOuFCUMA_TYkln9dE',
  );

  /// Full URL of the `ai` Edge Function.
  static String get functionUrl => '$supabaseUrl/functions/v1/ai';

  /// True only when both a project URL and anon key were compiled in.
  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// How long to wait on the network before falling back to on-device gags.
  /// MiniMax can take several seconds, so keep this generous.
  static const Duration timeout = Duration(seconds: 20);
}
