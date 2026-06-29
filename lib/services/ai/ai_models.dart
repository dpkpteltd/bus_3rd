// Plain data types returned by the AI layer. These are intentionally small and
// UI-agnostic: screens map them onto the existing widgets (BusItem, Review, …)
// so the AI source can be swapped for the static lists with no UI change.

/// One generated arrival row (text only — plate/colour stay client-side).
class AiArrival {
  const AiArrival({required this.dest, required this.verdict, required this.sub, required this.times});

  final String dest;
  final String verdict;
  final String sub;
  final String times;

  factory AiArrival.fromJson(Map<String, dynamic> j) => AiArrival(
        dest: (j['dest'] ?? '') as String,
        verdict: (j['verdict'] ?? '') as String,
        sub: (j['sub'] ?? '') as String,
        times: (j['times'] ?? '') as String,
      );
}

/// One generated aunty/uncle review.
class AiReview {
  const AiReview({required this.initials, required this.name, required this.stars, required this.quote});

  final String initials;
  final String name;
  final int stars; // 1..5
  final String quote;

  factory AiReview.fromJson(Map<String, dynamic> j) => AiReview(
        initials: (j['initials'] ?? '?') as String,
        name: (j['name'] ?? '') as String,
        stars: ((j['stars'] ?? 1) as num).clamp(1, 5).toInt(),
        quote: (j['quote'] ?? '') as String,
      );
}

/// One "how late will you be" prediction.
class AiLatePrediction {
  const AiLatePrediction({required this.mins, required this.confidence, required this.note});

  final String mins;
  final String confidence;
  final String note;

  factory AiLatePrediction.fromJson(Map<String, dynamic> j) => AiLatePrediction(
        mins: (j['mins'] ?? '?') as String,
        confidence: (j['confidence'] ?? '?') as String,
        note: (j['note'] ?? '') as String,
      );
}

/// One prank notification (title + body).
class AiPrank {
  const AiPrank({required this.title, required this.body});

  final String title;
  final String body;

  factory AiPrank.fromJson(Map<String, dynamic> j) => AiPrank(
        title: (j['title'] ?? 'Bus 3rd') as String,
        body: (j['body'] ?? '') as String,
      );
}

/// "Roast my commute" result.
class AiRoast {
  const AiRoast({
    required this.minutesLate,
    required this.confidence,
    required this.verdict,
    required this.note,
    required this.prank,
  });

  final String minutesLate;
  final String confidence;
  final String verdict;
  final String note;
  final String prank;

  factory AiRoast.fromJson(Map<String, dynamic> j) => AiRoast(
        minutesLate: (j['minutesLate'] ?? '?') as String,
        confidence: (j['confidence'] ?? '?') as String,
        verdict: (j['verdict'] ?? '') as String,
        note: (j['note'] ?? '') as String,
        prank: (j['prank'] ?? '') as String,
      );
}

/// The "you chose peace" certificate at the end of the Give Up flow.
class AiCertificate {
  const AiCertificate({
    required this.title,
    required this.body,
    required this.stat1Label,
    required this.stat1Value,
    required this.stat2Label,
    required this.stat2Value,
  });

  final String title;
  final String body;
  final String stat1Label;
  final String stat1Value;
  final String stat2Label;
  final String stat2Value;

  factory AiCertificate.fromJson(Map<String, dynamic> j) => AiCertificate(
        title: (j['title'] ?? 'You chose peace') as String,
        body: (j['body'] ?? '') as String,
        stat1Label: (j['stat1Label'] ?? 'Buses missed today') as String,
        stat1Value: (j['stat1Value'] ?? '4') as String,
        stat2Label: (j['stat2Label'] ?? 'Minutes you will never get back') as String,
        stat2Value: (j['stat2Value'] ?? '∞') as String,
      );
}

/// A single chat turn with the bus uncle.
class UncleTurn {
  const UncleTurn({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;

  Map<String, String> toJson() => {'role': fromUser ? 'user' : 'assistant', 'text': text};
}
