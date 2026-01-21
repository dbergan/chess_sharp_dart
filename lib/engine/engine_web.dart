import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'engine_base.dart';

class EngineWeb implements Sharpfish {
  @override
  bool readyForCommand = true;
  @override
  String bestMove = '';
  @override
  String variant = '';
  @override
  String fen = 'startpos';
  @override
  int skillLevel = 20;
  @override
  double? evaluation;
  @override
  final List<(String, bool)> commandQueue = [('isready', true)]; // the bool is whether a response is expected

  final _state = ValueNotifier<SharpfishState>(SharpfishState.starting);
  final _stdoutController = StreamController<String>.broadcast();
  web.Worker? _worker;

  @override
  ValueListenable<SharpfishState> get state => _state;

  /// Buffer for commands sent before the engine is fully initialized.
  final List<String> _commandBuffer = [];
  bool _isInitialized = false;
  String _lineBuffer = '';

  @override
  Stream<String> get stdout => _stdoutController.stream;

  EngineWeb() {
    _init().catchError((Object e) {
      _state.value = SharpfishState.error;
      _stdoutController.addError(
        StateError('Failed to initialize Web Engine: $e'),
      );
    });
  }

  Future<void> _init() async {
    try {
      _worker = web.Worker('stockfish_worker.js'.toJS);

      _worker!.addEventListener(
        'message',
        (web.MessageEvent event) {
          final data = event.data;
          String? dataDart;
          if (data.isA<JSString>()) {
            dataDart = (data! as JSString).toDart;
          } else if (data != null) {
            dataDart = data.toString();
          }

          if (dataDart != null && !_stdoutController.isClosed) {
            _lineBuffer += dataDart;
            int newlineIndex;
            while ((newlineIndex = _lineBuffer.indexOf('\n')) != -1) {
              final line = _lineBuffer.substring(0, newlineIndex).trim();
              _lineBuffer = _lineBuffer.substring(newlineIndex + 1);
              if (line.isNotEmpty) {
                _stdoutController.add(line);
              }
            }
          }
        }.toJS,
      );

      _worker!.onerror = (web.Event event) {
        _state.value = SharpfishState.error;
      }.toJS;

      setListeners();
      _isInitialized = true;
      _state.value = SharpfishState.ready;

      // Flush buffered commands
      for (final command in _commandBuffer) {
        _worker!.postMessage(command.toJS);
      }
      _commandBuffer.clear();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void stdin(String command) {
    // Add newline as most Stockfish WASM builds expect it to terminate the command
    final cmdWithNewline = command.endsWith('\n') ? command : '$command\n';
    if (_isInitialized) {
      _worker?.postMessage(cmdWithNewline.toJS);
    } else {
      _commandBuffer.add(cmdWithNewline);
    }
  }

  @override
  void dispose() {
    _state.value = SharpfishState.disposed;
    _worker?.terminate();
    _stdoutController.close();
    _commandBuffer.clear();
  }
}

Sharpfish createEngine() => EngineWeb();
