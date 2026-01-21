import 'dart:async';
import 'package:flutter/foundation.dart';

abstract class Sharpfish {
  ValueListenable<SharpfishState> get state;
  bool readyForCommand = true;
  String bestMove = '';
  String variant = '';
  String fen = 'startpos';
  int skillLevel = 20;
  double? evaluation;
  final List<(String, bool)> commandQueue = [
    ('isready', true),
  ]; // the bool is whether a response is expected

  /// Stream of all UCI output from the engine
  Stream<String> get stdout;

  /// Send a command (e.g., "isready", "go depth 10")
  void stdin(String command);

  /// Shut down the engine
  void dispose();

  /// Factory to create the right version for the platform
  factory Sharpfish() => throw UnsupportedError('Use factory from sub-classes');
}

extension SharpfishExtension on Sharpfish {
  void setSkillLevel(int skillLevel) {
    if (skillLevel != this.skillLevel) {
      commandQueue.add(('setoption name Skill Level value $skillLevel', false));
      this.skillLevel = skillLevel;
    }
  }

  void setFen(String fen) {
    this.fen = fen;
    if (this.fen == 'startpos') {
      commandQueue.add(('position startpos', false));
    } else {
      commandQueue.add(('position fen $fen', false));
    }
  }

  void setVariant(String newVariant) {
    if (newVariant != variant &&
        (newVariant == 'chess-sharp' ||
            newVariant == 'chess-double-sharp' ||
            newVariant == 'chess-flat' ||
            newVariant == 'chess-double-flat' ||
            newVariant == 'chess-triple-flat')) {
      commandQueue.add(('setoption name UCI_Variant value $newVariant', false));
      setFen('startpos');
    }
  }

  void go({String? fen, int? milliseconds}) {
    if (fen != null) setFen(fen);
    bestMove = '';
    evaluation = null;
    if (milliseconds != null) {
      commandQueue.add(('go movetime $milliseconds', true));
    } else {
      commandQueue.add(('go infinite', true)); // requires a stop command
    }
  }

  // Listeners
  Future<void> _processCommandQueue() async {
    while (state.value == SharpfishState.ready) {
      if (readyForCommand && commandQueue.isNotEmpty) {
        final (String, bool) nextCommand = commandQueue.removeAt(0);
        // print('command: ${nextCommand.$1}');
        stdin(nextCommand.$1);
        readyForCommand = !nextCommand.$2;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (state.value == SharpfishState.error) throw Exception();
  }

  void _processEngineOutput(String rawLine) {
    final line = rawLine.trim();
    if (line.isEmpty) return;
    // print('engine: $line');
    if (line.startsWith('info string variant chess-sharp')) {
      variant = 'chess-sharp';
    } else if (line.startsWith('info string variant chess-flat')) {
      variant = 'chess-flat';
    } else if (line.startsWith('info string variant chess-double-sharp')) {
      variant = 'chess-double-sharp';
    } else if (line.startsWith('info string variant chess-double-flat')) {
      variant = 'chess-double-flat';
    } else if (line.startsWith('info string variant chess-triple-flat')) {
      variant = 'chess-triple-flat';
    } else if (line.startsWith('bestmove')) {
      final parts = line.split(' ');
      if (parts.length > 1) {
        bestMove = parts[1];
      }
      readyForCommand = true;
    } else if (line.contains('readyok') || line.contains('uciok')) {
      readyForCommand = true;
    } else if (line.startsWith('info')) {
      final parts = line.split(' ');
      final scoreIdx = parts.indexOf('score');
      if (scoreIdx != -1 && scoreIdx + 1 < parts.length) {
        final nextPart = parts[scoreIdx + 1];
        if (nextPart == 'cp' || nextPart == 'mate') {
          if (scoreIdx + 2 < parts.length) {
            final value = int.tryParse(parts[scoreIdx + 2]);
            if (value != null) {
              if (nextPart == 'cp') {
                evaluation = value / 100.0;
              } else if (nextPart == 'mate') {
                evaluation = value >= 0 ? 1000.0 + value : -1000.0 + value;
              }
            }
          }
        } else {
          // Some engines (or variants) output score <value> directly
          final value = int.tryParse(nextPart);
          if (value != null) {
            evaluation = value / 100.0;
          }
        }
      }
    }
  }

  void setListeners() {
    state.addListener(_processCommandQueue);
    stdout.listen(_processEngineOutput);
  }

  /// Returns a string representation of the engine state.
  String get stringState {
    switch (state.value) {
      case SharpfishState.disposed:
        return 'disposed';
      case SharpfishState.error:
        return 'error';
      case SharpfishState.ready:
        return 'ready';
      case SharpfishState.starting:
        return 'starting';
    }
  }
}

/// C++ engine state.
enum SharpfishState {
  /// Engine has been stopped.
  disposed,

  /// An error occured (engine could not start).
  error,

  /// Engine is running.
  ready,

  /// Engine is starting.
  starting,
}
