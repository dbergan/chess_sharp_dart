import 'dart:async';
import 'package:chess_sharp_dart/chess_sharp_dart.dart';
import 'package:chess_sharp_dart/engine/engine_base.dart';
import 'package:test/test.dart';
import 'db_testing_lib.dart';

void main() {
  group('ChessSharpEngine', () {
    Sharpfish? cpu;

    setUp(() async {
      cpu = SharpfishMaker.create();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });

    tearDown(() {
      cpu?.dispose();
    });

    Future<void> playGame(Rule rule) async {
      Position position = Position.initialPosition(rule);
      print('FEN: ${position.fen}');

      int moveCount = 0;
      const int milliseconds = 100;
      while (!position.isGameOver) {
        moveCount++;
        final (move, eval) = await position.cpuMoveAndEval(
          persistent: true,
          milliseconds: milliseconds,
        );

        print(
          'Move $moveCount: ${move.uci} (MaterialDiff: ${position.materialDiff}, Eval: $eval)',
        );

        position = position.play(move);
        printBoard(position);
        print('Position FEN: ${position.fen}');
      }

      print('Game Over!');
      print('MaterialDiff: ${position.materialDiff}');
      print('Outcome: ${Outcome.toPgnStringChessSharp(position.outcome)}');

      Position.disposeCpuEngine();
    }

    test('can create/dispose engine', () async {
      final e = SharpfishMaker.create();
      print('Created engine of type: ${e.runtimeType}');
      print('Engine stringState: ${e.stringState}');
      for (
        int i = 0;
        (i < 100 &&
            e.state.value != SharpfishState.ready &&
            e.state.value != SharpfishState.error);
        i++
      ) {
        // Wait for engine to initialize
        await Future<void>.delayed(const Duration(milliseconds: 100));
        print(i.toString().padLeft(3, '0'));
        print('Engine stringState: ${e.stringState}');
      }
      expect(e, isNotNull);
      e.dispose();
      print('Disposed engine successfully');
    });

    test('setVariant—chess-sharp', () async {
      cpu?.setVariant('chess-sharp');
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      expect(cpu?.variant, 'chess-sharp');
    });

    test('setVariant—chess-triple-flat', () async {
      cpu?.setVariant('chess-triple-flat');
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      expect(cpu?.variant, 'chess-triple-flat');
    });

    test('chess-triple-flat—find bestmove', () async {
      cpu?.setVariant('chess-triple-flat');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(cpu?.variant, 'chess-triple-flat');
      cpu?.go(milliseconds: 2000);
      for (int i = 0; (i < 30 && (cpu?.bestMove == '')); i++) {
        // Wait for bestmove
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      print('Best Move: ${cpu?.bestMove}');
      expect(cpu?.bestMove, isNotEmpty);
    });

    test(
      'Chess Triple Flat Game - CPU vs CPU',
      () async {
        print('Starting Chess Triple Flat Game - CPU vs CPU');
        await playGame(Rule.chessTripleFlat);
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );

    test(
      'Chess Double Flat Game - CPU vs CPU',
      () async {
        print('Starting Chess Double Flat Game - CPU vs CPU');
        await playGame(Rule.chessDoubleFlat);
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );

    test('Chess Flat Game - CPU vs CPU', () async {
      print('Starting Chess Flat Game - CPU vs CPU');
      await playGame(Rule.chessFlat);
    }, timeout: const Timeout(Duration(minutes: 10)));

    test(
      'Chess Sharp Game - CPU vs CPU',
      () async {
        print('Starting Chess Sharp Game - CPU vs CPU');
        await playGame(Rule.chessSharp);
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );

    test(
      'Chess Double Sharp Game - CPU vs CPU',
      () async {
        print('Starting Chess Double Sharp Game - CPU vs CPU');
        await playGame(Rule.chessDoubleSharp);
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );

    test(
      'Classical Chess Sharp Game - CPU vs CPU',
      () async {
        print('Starting Classical Chess Sharp Game - CPU vs CPU');
        await playGame(Rule.classicalChessSharp);
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );

    test('Pre Chess Game - CPU vs CPU', () async {
      print('Starting Pre Chess Game - CPU vs CPU');
      await playGame(Rule.preChess);
    }, timeout: const Timeout(Duration(minutes: 10)));
  });
}
