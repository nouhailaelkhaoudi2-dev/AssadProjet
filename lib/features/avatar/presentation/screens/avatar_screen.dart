import 'dart:math' as math;
import 'package:flutter/material.dart';
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

class _AvatarScreenState extends ConsumerState<AvatarScreen> with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  late GroqService _groqService;

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechAvailable = false;
  String _transcription = '';
  String _response = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initTts() async {
    try {
      // Callbacks d'abord
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
        debugPrint('❌ Erreur TTS: $msg');
        if (mounted) setState(() => _isSpeaking = false);
      });

      // Configuration de base - la langue fr-FR forcera une voix française
      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.9);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      // Attendre un peu que les voix se chargent (problème Chrome)
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Essayer de charger les voix plusieurs fois
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
        debugPrint('════════════════════════════════════════');
        debugPrint('🎤 VOIX DISPONIBLES (${voiceList.length} total):');
        
        for (var v in voiceList) {
          final name = v['name']?.toString() ?? 'unknown';
          final locale = v['locale']?.toString() ?? 'unknown';
          debugPrint('  • $name | $locale');
        }
        
        // Chercher les voix françaises
        final frenchVoices = voiceList.where((voice) {
          final locale = voice['locale']?.toString().toLowerCase() ?? '';
          final name = voice['name']?.toString().toLowerCase() ?? '';
          return locale.contains('fr') || name.contains('french');
        }).toList();
        
        debugPrint('🇫🇷 VOIX FRANÇAISES: ${frenchVoices.length}');
        
        if (frenchVoices.isNotEmpty) {
          // Priorité aux voix MASCULINES françaises
          dynamic selectedVoice;
          
          // 1. Henri (voix Neural Microsoft masculine - la meilleure)
          selectedVoice = frenchVoices.cast<dynamic?>().firstWhere(
            (v) => v?['name']?.toString().toLowerCase().contains('henri') == true,
            orElse: () => null,
          );
          
          // 2. Paul (voix Microsoft masculine)
          selectedVoice ??= frenchVoices.cast<dynamic?>().firstWhere(
            (v) => v?['name']?.toString().toLowerCase().contains('paul') == true,
            orElse: () => null,
          );
          
          // 3. Google français (voix masculine)
          selectedVoice ??= frenchVoices.cast<dynamic?>().firstWhere(
            (v) => v?['name']?.toString().toLowerCase().contains('google') == true,
            orElse: () => null,
          );
          
          // 4. Thomas (voix masculine si disponible)
          selectedVoice ??= frenchVoices.cast<dynamic?>().firstWhere(
            (v) => v?['name']?.toString().toLowerCase().contains('thomas') == true,
            orElse: () => null,
          );
          
          // Fallback: première voix française disponible
          selectedVoice ??= frenchVoices.first;
          
          debugPrint('🔊 VOIX MASCULINE SÉLECTIONNÉE: ${selectedVoice['name']}');
          
          await _tts.setVoice({
            'name': selectedVoice['name'],
            'locale': selectedVoice['locale'],
          });
        }
        debugPrint('════════════════════════════════════════');
      } else {
        debugPrint('⚠️ Aucune voix trouvée - utilisation de la voix par défaut');
      }

    } catch (e) {
      debugPrint('❌ Erreur init TTS: $e');
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

  /// Nettoie le texte des emojis pour le TTS
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

      setState(() {
        _response = response;
      });

      // Nettoyer et parler
      final cleanedResponse = _cleanTextForTts(response);
      await _tts.speak(cleanedResponse);
    } catch (e) {
      const fallbackResponse = 'Désolé, je n\'ai pas pu traiter votre demande.';
      setState(() {
        _response = fallbackResponse;
      });
      await _tts.speak(fallbackResponse);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Avatar IA'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Avatar animé
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Fond avec effet de glow
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: _isSpeaking ? 300 : 260,
                        height: _isSpeaking ? 300 : 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _isSpeaking
                                  ? AppColors.secondary.withValues(alpha: 0.5)
                                  : AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: _isSpeaking ? 80 : 40,
                              spreadRadius: _isSpeaking ? 30 : 15,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Avatar - Mascotte officielle CAN 2025
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mascotte avec animations
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          // Animation de rebond quand parle
                          final bounceOffset = _isSpeaking 
                              ? math.sin(_pulseController.value * math.pi * 4) * 5
                              : 0.0;
                          
                          return Transform.translate(
                            offset: Offset(0, bounceOffset),
                            child: Transform.scale(
                              scale: _isSpeaking ? 1.0 + (_pulseAnimation.value - 1.0) * 0.5 : 1.0,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: (_isSpeaking ? AppColors.secondary : AppColors.primary)
                                    .withValues(alpha: 0.4),
                                blurRadius: _isSpeaking ? 50 : 30,
                                spreadRadius: _isSpeaking ? 10 : 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/Capture_d_écran_2025-12-22_221422-removebg-preview.png',
                            width: 250,
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Label avec état
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isSpeaking
                                ? [AppColors.secondary, AppColors.secondaryDark]
                                : [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: (_isSpeaking ? AppColors.secondary : AppColors.primary)
                                  .withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isSpeaking) ...[
                              _buildSoundWave(),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              _isSpeaking ? 'TikiTaka parle...' : 'TikiTaka',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          // Zone de conversation
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isListening
                          ? AppColors.error.withValues(alpha: 0.2)
                          : _isSpeaking
                              ? AppColors.secondary.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isListening ? Icons.mic : _isSpeaking ? Icons.volume_up : Icons.mic_off,
                          color: _isListening ? AppColors.error : _isSpeaking ? AppColors.secondary : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isListening ? 'Je vous écoute...' : _isSpeaking ? 'Je réponds...' : 'Appuyez pour parler',
                          style: TextStyle(
                            color: _isListening || _isSpeaking ? Colors.white : Colors.white54,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Messages
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_transcription.isNotEmpty)
                            _buildMessageBubble(text: _transcription, isUser: true),
                          if (_response.isNotEmpty)
                            _buildMessageBubble(text: _response, isUser: false),
                          if (_transcription.isEmpty && _response.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Posez-moi une question sur la CAN 2025 !',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton micro
          Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 8),
            child: GestureDetector(
              onTapDown: (_) => _startListening(),
              onTapUp: (_) => _stopListening(),
              onTapCancel: () => _stopListening(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isListening ? 85 : 75,
                height: _isListening ? 85 : 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isListening
                        ? [AppColors.error, AppColors.error.withValues(alpha: 0.7)]
                        : [AppColors.primary, AppColors.primaryDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? AppColors.error : AppColors.primary).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              _speechAvailable ? 'Maintenez le bouton pour parler' : 'Reconnaissance vocale non disponible',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundWave() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final offset = index * 0.2;
            final height = 8.0 + 8.0 * math.sin((_pulseController.value + offset) * math.pi * 2);
            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildMessageBubble({required String text, required bool isUser}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8, left: isUser ? 40 : 0, right: isUser ? 0 : 40),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? Colors.white.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
          bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
        ),
        border: Border.all(
          color: isUser ? Colors.white.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.3),
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
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}
