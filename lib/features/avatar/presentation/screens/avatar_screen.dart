import 'package:flutter/material.dart';
import '../../../../core/widgets/back_chevron_button.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/groq_service.dart' hide ChatMessage;
import '../../../../core/providers/services_providers.dart' hide ChatMessage;

class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});

  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  late GroqService _groqService;

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechAvailable = false;
  String _transcription = '';
  String _response = '';

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();
    _initAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _groqService = ref.read(groqServiceProvider);
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _initTts() async {
    try {
      _tts.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });

      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });

      _tts.setCancelHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });

      _tts.setErrorHandler((msg) {
        debugPrint('TTS error: $msg');
        if (mounted) setState(() => _isSpeaking = false);
      });

      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.9);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      await Future.delayed(const Duration(milliseconds: 500));

      List<dynamic>? voiceList;
      for (int i = 0; i < 5; i++) {
        final voices = await _tts.getVoices;
        if (voices != null && (voices as List).isNotEmpty) {
          voiceList = voices;
          break;
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (voiceList != null && voiceList.isNotEmpty) {
        final frenchVoices = voiceList.where((voice) {
          final locale = voice['locale']?.toString().toLowerCase() ?? '';
          final name = voice['name']?.toString().toLowerCase() ?? '';
          return locale.contains('fr') || name.contains('french');
        }).toList();

        if (frenchVoices.isNotEmpty) {
          dynamic selectedVoice;

          // Voix masculines en priorité
          selectedVoice = frenchVoices.cast<dynamic>().firstWhere(
            (v) =>
                v?['name']?.toString().toLowerCase().contains('henri') == true,
            orElse: () => null,
          );

          selectedVoice ??= frenchVoices.cast<dynamic>().firstWhere(
            (v) =>
                v?['name']?.toString().toLowerCase().contains('paul') == true,
            orElse: () => null,
          );

          selectedVoice ??= frenchVoices.cast<dynamic>().firstWhere(
            (v) =>
                v?['name']?.toString().toLowerCase().contains('google') == true,
            orElse: () => null,
          );

          selectedVoice ??= frenchVoices.cast<dynamic>().firstWhere(
            (v) =>
                v?['name']?.toString().toLowerCase().contains('thomas') == true,
            orElse: () => null,
          );

          selectedVoice ??= frenchVoices.first;

          await _tts.setVoice({
            'name': selectedVoice['name'],
            'locale': selectedVoice['locale'],
          });
        }
      }
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );
    setState(() {});
  }

  void _startListening() async {
    if (!_speechAvailable) {
      _showMessage('La reconnaissance vocale n\'est pas disponible');
      return;
    }

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcription = result.recognizedWords;
        });

        if (result.finalResult) {
          _processQuery(_transcription);
        }
      },
      localeId: 'fr_FR',
    );

    setState(() => _isListening = true);
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  String _cleanTextForTts(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|'
      r'[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|'
      r'[\u{FE00}-\u{FE0F}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FAFF}]',
      unicode: true,
    );

    String cleaned = text.replaceAll(emojiRegex, '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  void _processQuery(String query) async {
    if (query.isEmpty) return;

    try {
      final response = await _groqService.chat(query);
      setState(() => _response = response);

      final cleanedResponse = _cleanTextForTts(response);
      await _tts.speak(cleanedResponse);
    } catch (e) {
      const fallbackResponse = 'Désolé, je n\'ai pas pu traiter votre demande.';
      setState(() => _response = fallbackResponse);
      await _tts.speak(fallbackResponse);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackChevronButton(color: Colors.white),
        title: const Text('Avatar IA', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Avatar section
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/Capture_d_écran_2025-12-22_221422-removebg-preview.png',
                          width: 140,
                          height: 170,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isSpeaking ? 'Assad parle...' : 'Assad',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Message box
                    Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _transcription.isNotEmpty || _response.isNotEmpty
                            ? SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (_transcription.isNotEmpty)
                                      _buildMessageBubble(
                                        text: _transcription,
                                        isUser: true,
                                      ),
                                    if (_response.isNotEmpty)
                                      _buildMessageBubble(
                                        text: _response,
                                        isUser: false,
                                      ),
                                  ],
                                ),
                              )
                            : Text(
                                'Posez-moi une question sur la CAN 2025 !',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ),
                    // Mic button
                    GestureDetector(
                      onTapDown: (_) => _startListening(),
                      onTapUp: (_) => _stopListening(),
                      onTapCancel: () => _stopListening(),
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? AppColors.error
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble({required String text, required bool isUser}) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 8,
        left: isUser ? 40 : 0,
        right: isUser ? 0 : 40,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.white.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isUser
              ? const Radius.circular(16)
              : const Radius.circular(4),
          bottomRight: isUser
              ? const Radius.circular(4)
              : const Radius.circular(16),
        ),
        border: Border.all(
          color: isUser
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isUser)
                const Text('👤', style: TextStyle(fontSize: 14))
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/Capture_d_écran_2025-12-22_221422-removebg-preview.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                isUser ? 'Vous' : 'TikiTaka',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
