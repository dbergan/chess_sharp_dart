import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'engine_base.dart';

/// A [Sharpfish] implementation that interfaces with a local executable.
///
/// This is analogous to [EngineNative] but uses [Process.start] to communicate
/// with an external engine binary (e.g., Stockfish) via standard input and output.
class EngineBinary implements Sharpfish {
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
  Process? _process;
  final _state = ValueNotifier<SharpfishState>(SharpfishState.starting);
  final _stdoutController = StreamController<String>.broadcast();

  /// Buffer for commands sent before the engine is fully initialized.
  final List<String> _commandBuffer = [];
  bool _isInitialized = false;

  @override
  ValueListenable<SharpfishState> get state => _state;

  @override
  Stream<String> get stdout => _stdoutController.stream;

  EngineBinary() {
    _init().catchError((Object e) {
      if (!_stdoutController.isClosed) {
        _stdoutController.addError(
          StateError('Failed to initialize Binary Engine: $e'),
        );
      }
    });
  }

  Future<void> _init() async {
    // Path to the Stockfish executable as specified.
    // This assumes the working directory is the project root.
    const exePath = 'lib/engine/stockfish.exe';

    try {
      if (!File(exePath).existsSync()) {
        throw const FileSystemException('Executable not found', exePath);
      }

      _process = await Process.start(exePath, []);
      setListeners();
      _state.value = SharpfishState.ready;

      // Listen to stdout and add to the stream controller.
      _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (!_stdoutController.isClosed) {
              _stdoutController.add(line);
            }
          });

      // UCI engines generally communicate via stdout, but we can listen to stderr for errors.
      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            // UCI engines usually don't use stderr for the protocol, but it may contain debug info.
          });

      _isInitialized = true;

      // Flush any commands that were sent while the process was starting.
      for (final command in _commandBuffer) {
        _process!.stdin.writeln(command);
      }
      _commandBuffer.clear();
    } catch (e) {
      _state.value = SharpfishState.error;
      if (!_stdoutController.isClosed) {
        _stdoutController.addError(
          StateError('Failed to start engine process at $exePath: $e'),
        );
      }
      rethrow;
    }
  }

  @override
  void stdin(String command) {
    if (_isInitialized) {
      _process?.stdin.writeln(command);
    } else {
      _commandBuffer.add(command);
    }
  }

  @override
  void dispose() {
    _process?.kill();
    _state.value = SharpfishState.disposed;
    _stdoutController.close();
    _commandBuffer.clear();
  }
}
