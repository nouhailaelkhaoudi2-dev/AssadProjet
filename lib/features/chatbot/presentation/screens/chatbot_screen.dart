import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_chevron_button.dart';
import '../../../../core/services/groq_service.dart' hide ChatMessage;
import '../../../../core/providers/services_providers.dart' hide ChatMessage;
import '../../domain/entities/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/suggestion_chips.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late GroqService _groqService;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _groqService = ref.read(groqServiceProvider);
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage.assistant(
        id: 'welcome',
        content:
            '''Bienvenue ! Je suis TikiTaka, votre assistant IA pour la CAN 2025 Morocco.

Je peux vous aider avec :
- Les matchs et résultats en temps réel
- Le classement des groupes
- Les dernières actualités
- Les informations sur les équipes
- Les stades et leur localisation
- La billetterie officielle

Comment puis-je vous aider ?''',
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage.user(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text.trim(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Appel à Groq AI
    try {
      final response = await _groqService.chat(text.trim());

      setState(() {
        _messages.add(
          ChatMessage.assistant(
            id: '${DateTime.now().millisecondsSinceEpoch}_response',
            content: response,
            sources: [
              const MessageSource(name: 'Groq AI'),
              const MessageSource(name: 'API-Football'),
            ],
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage.assistant(
            id: '${DateTime.now().millisecondsSinceEpoch}_error',
            content:
                'Désolé, une erreur s\'est produite. Réessayez votre question.',
          ),
        );
        _isLoading = false;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackChevronButton(),
        title: const Text('Assistant CAN 2025'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return MessageBubble(
                    message: ChatMessage(
                      id: 'loading',
                      content: '',
                      role: MessageRole.assistant,
                      timestamp: DateTime.now(),
                      isLoading: true,
                    ),
                  );
                }
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),

          // Suggestions
          if (_messages.length <= 1)
            SuggestionChips(
              onSuggestionTap: (suggestion) => _sendMessage(suggestion.query),
            ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Posez votre question...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
