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
    if (newVariant != variant) {
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

    final parts = line.split(' ');

    if (line.startsWith('info string variant ')) {
      variant = line.substring(20).trim();
    }

    if (parts[0] == 'bestmove') {
      if (parts.length > 1) {
        bestMove = parts[1];
      }
      readyForCommand = true;
    }

    if (line.contains('readyok') || line.contains('uciok')) {
      readyForCommand = true;
    }

    final scoreIdx = parts.indexOf('score');
    if (scoreIdx != -1 && scoreIdx + 1 < parts.length) {
      final nextPart = parts[scoreIdx + 1];
      double? eval;
      if (nextPart == 'cp') {
        if (scoreIdx + 2 < parts.length) {
          final value = int.tryParse(parts[scoreIdx + 2]);
          if (value != null) {
            eval = value / 100.0;
          }
        }
      } else {
        // Handle 'mate', 'capture-their-king', 'lose-my-king', 'victory', etc.
        if (scoreIdx + 2 < parts.length) {
          final value = int.tryParse(parts[scoreIdx + 2]);
          if (value != null) {
            // Treated as mate-like score
            eval = value >= 0 ? 1000.0 + value : -1000.0 + value;
          }
        }
        // Fallback: Some engines (or variants) output score <value> directly
        if (eval == null) {
          final value = int.tryParse(nextPart);
          if (value != null) {
            eval = value / 100.0;
          }
        }
      }

      if (eval != null) {
        // Normal engine output is relative to side to move.
        // We want absolute evaluation (White positive, Black negative).
        if (fen != 'startpos' &&
            fen.split(' ').length > 1 &&
            fen.split(' ')[1] == 'b') {
          eval = -eval;
        }
        evaluation = eval;
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
