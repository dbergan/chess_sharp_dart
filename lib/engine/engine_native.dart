import 'dart:async';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'engine_base.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'native_ffi.dart';

final _logger = Logger('Stockfish');

/// A wrapper for C++ engine.
class EngineNative implements Sharpfish {
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

  final Completer<EngineNative>? completer;

  final _state = _StockfishState();
  final _stdoutController = StreamController<String>.broadcast();
  final _mainPort = ReceivePort();
  final _stdoutPort = ReceivePort();

  late StreamSubscription<dynamic> _mainSubscription;
  late StreamSubscription<String> _stdoutSubscription;

  /// Creates a C++ engine.
  ///
  /// This may throws a [StateError] if an active instance is being used.
  /// Owner must [dispose] it before a new instance can be created.
  factory EngineNative() {
    if (_instance != null) {
      throw StateError('Multiple instances are not supported');
    }

    _instance = EngineNative._();
    return _instance!;
  }

  EngineNative._({this.completer}) {
    _mainSubscription = _mainPort.listen(
      (message) => _cleanUp(message is int ? message : 1),
    );
    _stdoutSubscription = _stdoutPort.cast<String>().listen((message) {
      _logger.finest('The stdout isolate sent $message');
      _stdoutController.sink.add(message);
    });
    compute(_spawnIsolates, [_mainPort.sendPort, _stdoutPort.sendPort]).then(
      (success) {
        setListeners();
        final state = success ? SharpfishState.ready : SharpfishState.error;
        _logger.fine('The init isolate reported $state');
        _state._setValue(state);
        if (state == SharpfishState.ready) {
          completer?.complete(this);
        }
      },
      onError: (Object error) {
        _logger.severe('The init isolate encountered an error $error');
        _cleanUp(1);
      },
    );
  }

  static EngineNative? _instance;

  /// The current state of the underlying C++ engine.
  @override
  ValueListenable<SharpfishState> get state => _state;

  /// The standard output stream.
  @override
  Stream<String> get stdout => _stdoutController.stream;

  /// The standard input sink.
  @override
  void stdin(String line) {
    final stateValue = _state.value;
    if (stateValue != SharpfishState.ready) {
      throw StateError('Stockfish is not ready ($stateValue)');
    }

    final pointer = '$line\n'.toNativeUtf8();
    nativeStdinWrite(pointer);
    calloc.free(pointer);
  }

  /// Stops the C++ engine.
  @override
  void dispose() {
    stdin('quit');
  }

  void _cleanUp(int exitCode) {
    _stdoutController.close();

    _mainSubscription.cancel();
    _stdoutSubscription.cancel();

    _state._setValue(
      exitCode == 0 ? SharpfishState.disposed : SharpfishState.error,
    );

    _instance = null;
  }
}

/// Creates a C++ engine asynchronously.
///
/// This method is different from the factory method [Stockfish.new] that
/// it will wait for the engine to be ready before returning the instance.
Future<EngineNative> stockfishAsync() {
  if (EngineNative._instance != null) {
    return Future.error(StateError('Only one instance can be used at a time'));
  }

  final completer = Completer<EngineNative>();
  EngineNative._instance = EngineNative._(completer: completer);
  return completer.future;
}

class _StockfishState extends ChangeNotifier
    implements ValueListenable<SharpfishState> {
  SharpfishState _value = SharpfishState.starting;

  @override
  SharpfishState get value => _value;

  void _setValue(SharpfishState v) {
    if (v == _value) return;
    _value = v;
    notifyListeners();
  }
}

void _isolateMain(SendPort mainPort) {
  final exitCode = nativeMain();
  mainPort.send(exitCode);

  _logger.fine('nativeMain returns $exitCode');
}

void _isolateStdout(SendPort stdoutPort) {
  String previous = '';

  while (true) {
    final pointer = nativeStdoutRead();

    if (pointer.address == 0) {
      _logger.fine('nativeStdoutRead returns NULL');
      return;
    }

    final data = previous + pointer.toDartString();
    final lines = data.split('\n');
    previous = lines.removeLast();
    for (final line in lines) {
      stdoutPort.send(line);
    }
  }
}

Future<bool> _spawnIsolates(List<SendPort> mainAndStdout) async {
  final initResult = nativeInit();
  if (initResult != 0) {
    _logger.severe('initResult=$initResult');
    return false;
  }

  try {
    await Isolate.spawn(_isolateStdout, mainAndStdout[1]);
  } catch (error) {
    _logger.severe('Failed to spawn stdout isolate: $error');
    return false;
  }

  try {
    await Isolate.spawn(_isolateMain, mainAndStdout[0]);
  } catch (error) {
    _logger.severe('Failed to spawn main isolate: $error');
    return false;
  }

  return true;
}
