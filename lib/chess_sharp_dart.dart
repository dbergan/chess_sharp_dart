/// Dart chess library for native platforms.
///
/// All classes are immutable except [PgnNode] and [PgnChildNode].
library;

export 'src/constants.dart';
export 'src/models.dart';
export 'src/square_set.dart';
export 'src/attacks.dart';
export 'src/board.dart';
export 'src/castles.dart';
export 'src/setup.dart';
export 'src/position.dart';
export 'src/debug.dart';
export 'src/pgn.dart';
export 'src/utils.dart';
import 'engine/engine_base.dart';
import 'engine/engine_web.dart' if (dart.library.io) 'engine/engine_io.dart';

/// Entry point for the Chess Sharp engine.
///
/// This class provides a platform-agnostic way to create a [Sharpfish]
/// instance. It automatically selects the correct implementation (Web or Native)
/// based on the current environment.
abstract final class SharpfishMaker {
  SharpfishMaker._();

  /// Creates a new [Sharpfish] instance.
  ///
  /// On Web: Returns an [EngineWeb] which utilizes Stockfish via WASM.
  /// On Native (Android, iOS): Returns an [EngineNative] which
  /// communicates with the C++ engine via FFI.
  /// On Desktop: Returns an [EngineBinary] which communicates with a
  /// local Stockfish executable.
  ///
  /// Throws a [StateError] if the engine fails to initialize on the current platform.
  static Sharpfish create() {
    try {
      return createEngine();
    } catch (e, stackTrace) {
      // Wrap platform-specific errors in a consistent StateError
      throw StateError(
        'Failed to initialize ChessEngine on ${_platformName()}: $e\n$stackTrace',
      );
    }
  }

  static String _platformName() {
    if (identical(0, 0.0)) return 'Web';
    return 'Native';
  }
}
