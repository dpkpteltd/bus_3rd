import 'package:flutter/material.dart';

/// A (fake) bus on the arrivals board. All content is fictional / comedic.
class BusItem {
  const BusItem({
    required this.plate,
    required this.color,
    required this.dest,
    required this.verdict,
    required this.sub,
    required this.times,
    required this.timeColor,
  });

  final String plate;
  final Color color;
  final String dest;
  final String verdict;
  final String sub;
  final String times;
  final Color timeColor;
}

/// An "aunty & uncle" review.
class Review {
  const Review({
    required this.initials,
    required this.name,
    required this.stars,
    required this.avatarBg,
    required this.quote,
  });

  final String initials;
  final String name;
  final int stars; // 1..5
  final Color avatarBg;
  final String quote;
}

/// A line in the MRT-breakdown "live updates" feed.
class FeedItem {
  const FeedItem(this.time, this.message);
  final String time;
  final String message;
}

/// A saved stop (a monument to the user's optimism).
class SavedItem {
  const SavedItem({
    required this.plate,
    required this.color,
    required this.dest,
    required this.note,
  });

  final String plate;
  final Color color;
  final String dest;
  final String note;
}

/// One "how late will you be" prediction.
class LatePrediction {
  const LatePrediction(this.mins, this.confidence, this.note);
  final String mins;
  final String confidence;
  final String note;
}
