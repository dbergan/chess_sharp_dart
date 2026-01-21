import 'package:test/test.dart';
import 'package:chess_sharp_dart/chess_sharp_dart.dart';

void main() {
  test('Crazyhouse En Passant persistence bug after drop', () {
    // Setup: White pawn on e5, Black plays d5, White drops a piece, then Black still sees EP?
    // No, White to move captures EP.
    // Setup: e5, d5 (black plays), then White SHOULD be able to capture EP.
    // BUT if White DROPS a piece first, then EP should be GONE.

    const fen = 'rnbqkbnr/pppppppp/8/4P3/8/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
    final setup = Setup.parseFen(fen);
    var pos = Crazyhouse.fromSetup(setup);

    // Black plays d5
    pos = pos.play(pos.parseSan('d5')!) as Crazyhouse;
    expect(pos.epSquare, isNotNull, reason: 'EP square should be set after d5');

    // Give White a piece to drop
    pos =
        pos.copyWith(pockets: pos.pockets?.increment(Side.white, Role.knight))
            as Crazyhouse;

    // White DROPS a knight on a3
    pos =
        pos.play(const DropMove(role: Role.knight, to: Square.a3))
            as Crazyhouse;

    expect(
      pos.epSquare,
      isNull,
      reason: 'EP square should be cleared after a drop',
    );
  });
}
