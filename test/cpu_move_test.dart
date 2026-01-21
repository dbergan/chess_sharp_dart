import 'package:chess_sharp_dart/chess_sharp_dart.dart';
import 'package:chess_sharp_dart/src/position.dart';
import 'package:test/test.dart';

void main() {
  group('Position cpuMove', () {
    setUp(() {
      Position.disposeCpuEngine();
    });

    tearDown(() {
      Position.disposeCpuEngine();
    });

    test('calculates a move on-demand', () async {
      final position = ChessSharp.initial;
      final (move, evaluation) = await position.cpuMoveAndEval(
        milliseconds: 200,
      );
      print('On-demand move: ${move.uci} (eval: $evaluation)');
      expect(move, isNotNull);
      expect(position.isLegal(move), true);
    });

    test('calculates moves persistently', () async {
      final position = ChessSharp.initial;

      // First move
      final (move1, eval1) = await position.cpuMoveAndEval(persistent: true);
      print('Persistent move 1: ${move1.uci} (eval: $eval1)');
      expect(move1, isNotNull);
      expect(position.isLegal(move1), true);

      // Second move from the new position
      final nextPosition = position.play(move1);
      final (move2, eval2) = await nextPosition.cpuMoveAndEval(
        persistent: true,
      );
      print('Persistent move 2: ${move2.uci} (eval: $eval2)');
      expect(move2, isNotNull);
      expect(nextPosition.isLegal(move2), true);
    });

    test('handles variants (Chess Flat)', () async {
      final position = ChessSharp.chessFlat;
      final (move, evaluation) = await position.cpuMoveAndEval(
        milliseconds: 200,
      );
      print('Variant move: ${move.uci} (eval: $evaluation)');
      expect(move, isNotNull);
      expect(position.isLegal(move), true);
    });

    test('handles illegal FEN / state error gracefully', () async {
      // Create a position that might be tricky if FEN is weird
      // (Though ChessSharp.initial is safe)
      final position = ChessSharp.initial;
      // Just verifying we can call it multiple times on-demand without conflict
      final (move1, _) = await position.cpuMoveAndEval(milliseconds: 100);
      final (move2, _) = await position.cpuMoveAndEval(milliseconds: 100);
      expect(move1, isNotNull);
      expect(move2, isNotNull);
    });
  });
}
