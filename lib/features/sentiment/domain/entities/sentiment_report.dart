import 'package:equatable/equatable.dart';

/// Type de sentiment
enum SentimentType {
  positive,
  neutral,
  negative,
}

extension SentimentTypeExtension on SentimentType {
  String get label {
    switch (this) {
      case SentimentType.positive:
        return 'Positif';
      case SentimentType.neutral:
        return 'Neutre';
      case SentimentType.negative:
        return 'Négatif';
    }
  }

  String get emoji {
    switch (this) {
      case SentimentType.positive:
        return '😊';
      case SentimentType.neutral:
        return '😐';
      case SentimentType.negative:
        return '😞';
    }
  }
}

/// Entité représentant une analyse de sentiment
class SentimentReport extends Equatable {
  final String? teamId;
  final String? teamName;
  final DateTime date;
  final double positivePercent;
  final double neutralPercent;
  final double negativePercent;
  final int totalMentions;
  final List<String> topKeywords;
  final List<String> topHashtags;
  final String? summary;

  const SentimentReport({
    this.teamId,
    this.teamName,
    required this.date,
    required this.positivePercent,
    required this.neutralPercent,
    required this.negativePercent,
    required this.totalMentions,
    this.topKeywords = const [],
    this.topHashtags = const [],
    this.summary,
  });

  @override
  List<Object?> get props => [
        teamId,
        teamName,
        date,
        positivePercent,
        neutralPercent,
        negativePercent,
        totalMentions,
        topKeywords,
        topHashtags,
        summary,
      ];

  /// Retourne le sentiment dominant
  SentimentType get dominantSentiment {
    if (positivePercent >= neutralPercent && positivePercent >= negativePercent) {
      return SentimentType.positive;
    } else if (negativePercent >= neutralPercent) {
      return SentimentType.negative;
    }
    return SentimentType.neutral;
  }

  /// Retourne le pourcentage du sentiment dominant
  double get dominantPercent {
    switch (dominantSentiment) {
      case SentimentType.positive:
        return positivePercent;
      case SentimentType.neutral:
        return neutralPercent;
      case SentimentType.negative:
        return negativePercent;
    }
  }

  /// Validation: les pourcentages doivent totaliser 100%
  bool get isValid {
    final total = positivePercent + neutralPercent + negativePercent;
    return total >= 99.0 && total <= 101.0; // Tolérance pour les arrondis
  }

  SentimentReport copyWith({
    String? teamId,
    String? teamName,
    DateTime? date,
    double? positivePercent,
    double? neutralPercent,
    double? negativePercent,
    int? totalMentions,
    List<String>? topKeywords,
    List<String>? topHashtags,
    String? summary,
  }) {
    return SentimentReport(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      date: date ?? this.date,
      positivePercent: positivePercent ?? this.positivePercent,
      neutralPercent: neutralPercent ?? this.neutralPercent,
      negativePercent: negativePercent ?? this.negativePercent,
      totalMentions: totalMentions ?? this.totalMentions,
      topKeywords: topKeywords ?? this.topKeywords,
      topHashtags: topHashtags ?? this.topHashtags,
      summary: summary ?? this.summary,
    );
  }
}

/// Données de sentiment pour un graphique temporel
class SentimentDataPoint extends Equatable {
  final DateTime date;
  final double positivePercent;
  final double neutralPercent;
  final double negativePercent;

  const SentimentDataPoint({
    required this.date,
    required this.positivePercent,
    required this.neutralPercent,
    required this.negativePercent,
  });

  @override
  List<Object?> get props => [date, positivePercent, neutralPercent, negativePercent];
}
