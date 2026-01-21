import 'package:test/test.dart';
import 'package:chess_sharp_dart/chess_sharp_dart.dart';

void main() {
  test('Crazyhouse En Passant pocketing bug', () {
    // Setup a position where an EP capture is possible.
    // White to move, plays e4, then Black plays e5? No.
    // Standard EP setup:
    // 1. e4 (any)
    // 2. (any) e5? No.
    // Let's use a FEN.
    // White pawn on e5, Black plays d5.
    const fen = 'rnbqkbnr/pppppppp/8/4P3/8/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
    final setup = Setup.parseFen(fen);
    var pos = Crazyhouse.fromSetup(setup);

    print('Initial Position:');
    print(pos.fen);

    // Black plays d5
    pos = pos.play(pos.parseSan('d5')!) as Crazyhouse;
    print('\nAfter d5:');
    print(pos.fen);
    print('EP Square: ${pos.epSquare}');

    // White plays exd6 (EP capture)
    final move = pos.parseSan('exd6')!;
    print('\nMove: ${move.uci}');

    pos = pos.play(move) as Crazyhouse;
    print('\nAfter exd6 (EP capture):');
    print(pos.fen);
    print('Pocket White Pawns: ${pos.pockets?.of(Side.white, Role.pawn)}');

    expect(
      pos.pockets?.of(Side.white, Role.pawn),
      1,
      reason: 'Pawn NOT added to pocket.',
    );
  });
}
