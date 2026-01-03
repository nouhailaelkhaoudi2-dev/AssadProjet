import 'package:equatable/equatable.dart';

/// Entité représentant un article d'actualité
class NewsArticle extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? content;
  final String url;
  final String? imageUrl;
  final DateTime publishedAt;
  final String source;
  final String? author;

  const NewsArticle({
    required this.id,
    required this.title,
    this.description,
    this.content,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
    required this.source,
    this.author,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        url,
        imageUrl,
        publishedAt,
        source,
        author,
      ];

  /// Retourne le temps écoulé depuis la publication
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} sem.';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'maintenant';
    }
  }

  /// Retourne une version courte de la description
  String get shortDescription {
    if (description == null) return '';
    if (description!.length <= 100) return description!;
    return '${description!.substring(0, 100)}...';
  }

  NewsArticle copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? url,
    String? imageUrl,
    DateTime? publishedAt,
    String? source,
    String? author,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      source: source ?? this.source,
      author: author ?? this.author,
    );
  }
}
