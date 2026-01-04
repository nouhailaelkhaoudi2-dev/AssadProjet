import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

/// Service Edge TTS - Utilise les voix neuronales Microsoft gratuites
class EdgeTtsService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSpeaking = false;

  // Callbacks pour le statut
  VoidCallback? onStart;
  VoidCallback? onComplete;
  VoidCallback? onError;

  bool get isSpeaking => _isSpeaking;

  EdgeTtsService() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isSpeaking = false;
        onComplete?.call();
      }
    });
  }

  /// Synthétise et joue le texte
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      // Nettoyer le texte
      final cleanedText = _cleanText(text);
      if (cleanedText.isEmpty) return;

      _isSpeaking = true;
      onStart?.call();

      // Utiliser l'API TTS gratuite de StreamElements (utilise les voix Microsoft)
      final audioUrl = await _getAudioUrl(cleanedText);

      if (audioUrl != null) {
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
      } else {
        throw Exception('Impossible de générer l\'audio');
      }
    } catch (e) {
      debugPrint('Erreur TTS: $e');
      _isSpeaking = false;
      onError?.call();
    }
  }

  /// Obtient l'URL audio via l'API StreamElements (gratuit, voix Microsoft)
  Future<String?> _getAudioUrl(String text) async {
    try {
      // Limiter la longueur du texte (max 500 caractères par requête)
      String processedText = text;
      if (text.length > 500) {
        processedText = '${text.substring(0, 497)}...';
      }

      // Encoder le texte pour l'URL
      final encodedText = Uri.encodeComponent(processedText);

      // Voix française - Brian (masculine) ou Mathieu (FR)
      // StreamElements supporte plusieurs voix, on utilise une voix française
      const voice = 'Mathieu'; // Voix française masculine naturelle

      // URL de l'API StreamElements TTS (gratuit)
      final url =
          'https://api.streamelements.com/kappa/v2/speech?voice=$voice&text=$encodedText';

      // Vérifier que l'URL est accessible
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        return url;
      }

      // Alternative : utiliser Google Translate TTS (gratuit mais qualité moindre)
      return _getGoogleTranslateTtsUrl(processedText);
    } catch (e) {
      debugPrint('Erreur génération audio: $e');
      return _getGoogleTranslateTtsUrl(text);
    }
  }

  /// Fallback : Google Translate TTS (gratuit, qualité correcte)
  String _getGoogleTranslateTtsUrl(String text) {
    String processedText = text;
    if (text.length > 200) {
      processedText = '${text.substring(0, 197)}...';
    }
    final encodedText = Uri.encodeComponent(processedText);
    return 'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=fr&q=$encodedText';
  }

  /// Nettoie le texte des emojis et caractères spéciaux
  String _cleanText(String text) {
    // Regex pour supprimer les emojis
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|'
      r'[\u{1F300}-\u{1F5FF}]|'
      r'[\u{1F680}-\u{1F6FF}]|'
      r'[\u{1F1E0}-\u{1F1FF}]|'
      r'[\u{2600}-\u{26FF}]|'
      r'[\u{2700}-\u{27BF}]|'
      r'[\u{FE00}-\u{FE0F}]|'
      r'[\u{1F900}-\u{1F9FF}]|'
      r'[\u{1FA00}-\u{1FA6F}]|'
      r'[\u{1FA70}-\u{1FAFF}]|'
      r'[\u{231A}-\u{231B}]|'
      r'[\u{23E9}-\u{23F3}]|'
      r'[\u{23F8}-\u{23FA}]|'
      r'[\u{25AA}-\u{25AB}]|'
      r'[\u{25B6}]|[\u{25C0}]|'
      r'[\u{25FB}-\u{25FE}]|'
      r'[\u{2614}-\u{2615}]|'
      r'[\u{2648}-\u{2653}]|'
      r'[\u{267F}]|[\u{2693}]|'
      r'[\u{26A1}]|[\u{26AA}-\u{26AB}]|'
      r'[\u{26BD}-\u{26BE}]|'
      r'[\u{26C4}-\u{26C5}]|'
      r'[\u{26CE}]|[\u{26D4}]|'
      r'[\u{26EA}]|[\u{26F2}-\u{26F3}]|'
      r'[\u{26F5}]|[\u{26FA}]|'
      r'[\u{26FD}]|[\u{2702}]|'
      r'[\u{2705}]|[\u{2708}-\u{270D}]|'
      r'[\u{270F}]|[\u{2712}]|'
      r'[\u{2714}]|[\u{2716}]|'
      r'[\u{271D}]|[\u{2721}]|'
      r'[\u{2728}]|[\u{2733}-\u{2734}]|'
      r'[\u{2744}]|[\u{2747}]|'
      r'[\u{274C}]|[\u{274E}]|'
      r'[\u{2753}-\u{2755}]|'
      r'[\u{2757}]|[\u{2763}-\u{2764}]|'
      r'[\u{2795}-\u{2797}]|'
      r'[\u{27A1}]|[\u{27B0}]|'
      r'[\u{27BF}]|[\u{2934}-\u{2935}]|'
      r'[\u{2B05}-\u{2B07}]|'
      r'[\u{2B1B}-\u{2B1C}]|'
      r'[\u{2B50}]|[\u{2B55}]|'
      r'[\u{3030}]|[\u{303D}]|'
      r'[\u{3297}]|[\u{3299}]',
      unicode: true,
    );

    String cleaned = text.replaceAll(emojiRegex, '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }

  /// Arrête la lecture
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isSpeaking = false;
  }

  /// Libère les ressources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
