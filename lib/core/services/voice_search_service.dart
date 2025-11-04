import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  /// Initialize speech recognition (also handles permissions)
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // speech_to_text handles permission requests automatically
      _isInitialized = await _speech.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      return false;
    }
  }

  /// Start listening for voice input
  Future<void> startListening({
    required Function(String) onResult,
    required Function() onListening,
    required Function() onNotListening,
  }) async {
    // Initialize if not already done (this will request permissions)
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Speech recognition is not available. Please check microphone permissions.');
      }
    }

    // Check if speech recognition is available
    if (!_speech.isAvailable) {
      throw Exception('Speech recognition not available on this device');
    }

    // Start listening
    onListening();
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          onNotListening();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  /// Stop listening manually
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Check if currently listening
  bool get isListening => _speech.isListening;

  /// Dispose resources
  void dispose() {
    _speech.stop();
  }
}