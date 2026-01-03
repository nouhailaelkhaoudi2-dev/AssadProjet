import 'package:equatable/equatable.dart';

/// Rôle du message dans la conversation
enum MessageRole {
  user,
  assistant,
  system,
}

/// Source d'une information citée dans la réponse
class MessageSource extends Equatable {
  final String name;
  final String? url;

  const MessageSource({
    required this.name,
    this.url,
  });

  @override
  List<Object?> get props => [name, url];
}

/// Entité représentant un message dans le chat
class ChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;
  final List<MessageSource> sources;
  final String? error;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
    this.sources = const [],
    this.error,
  });

  @override
  List<Object?> get props => [id, content, role, timestamp, isLoading, sources, error];

  /// Crée un message utilisateur
  factory ChatMessage.user({
    required String id,
    required String content,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
  }

  /// Crée un message assistant
  factory ChatMessage.assistant({
    required String id,
    required String content,
    List<MessageSource> sources = const [],
  }) {
    return ChatMessage(
      id: id,
      content: content,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      sources: sources,
    );
  }

  /// Crée un message de chargement
  factory ChatMessage.loading({required String id}) {
    return ChatMessage(
      id: id,
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  /// Crée un message d'erreur
  factory ChatMessage.error({
    required String id,
    required String error,
  }) {
    return ChatMessage(
      id: id,
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      error: error,
    );
  }

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get hasError => error != null;
  bool get hasSources => sources.isNotEmpty;

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isLoading,
    List<MessageSource>? sources,
    String? error,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      sources: sources ?? this.sources,
      error: error ?? this.error,
    );
  }
}

/// Suggestions rapides pour le chatbot
class ChatSuggestion extends Equatable {
  final String label;
  final String query;
  final String? icon;

  const ChatSuggestion({
    required this.label,
    required this.query,
    this.icon,
  });

  @override
  List<Object?> get props => [label, query, icon];
}

/// Suggestions par défaut
class DefaultChatSuggestions {
  DefaultChatSuggestions._();

  static const List<ChatSuggestion> suggestions = [
    ChatSuggestion(
      label: "Matchs aujourd'hui",
      query: "Quels sont les matchs d'aujourd'hui ?",
      icon: '⚽',
    ),
    ChatSuggestion(
      label: 'Classement Groupe A',
      query: 'Donne-moi le classement du groupe A',
      icon: '📊',
    ),
    ChatSuggestion(
      label: 'Résultat Maroc',
      query: 'Quel est le dernier résultat du Maroc ?',
      icon: '🇲🇦',
    ),
    ChatSuggestion(
      label: 'Programme demain',
      query: 'Quels matchs sont programmés pour demain ?',
      icon: '📅',
    ),
    ChatSuggestion(
      label: 'Actualités CAN',
      query: 'Quelles sont les dernières actualités de la CAN 2025 ?',
      icon: '📰',
    ),
    ChatSuggestion(
      label: 'Stades du tournoi',
      query: 'Quels sont les stades de la CAN 2025 ?',
      icon: '🏟️',
    ),
    ChatSuggestion(
      label: 'Acheter des billets',
      query: 'Comment acheter des billets pour la CAN 2025 ?',
      icon: '🎫',
    ),
    ChatSuggestion(
      label: 'Fanzones',
      query: 'Où sont situées les fanzones officielles ?',
      icon: '🎉',
    ),
  ];
}
