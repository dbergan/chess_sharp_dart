import 'package:chess_sharp_dart/chess_sharp_dart.dart';
import 'package:test/test.dart';

import 'db_testing_lib.dart';

void main() {
  test('ClassicalChessSharp - initial position', () {
    final pos = ClassicalChessSharp.initial;
    expect(pos.rule, Rule.classicalChessSharp);
    expect(pos.board, Board.standard);
    expect(pos.turn, Side.white);
  });

  test('ClassicalChessSharp - fromSetup', () {
    final setup = Setup.standard;
    final pos = ClassicalChessSharp.fromSetup(setup);
    expect(pos.rule, Rule.classicalChessSharp);
    expect(pos.board, Board.standard);
  });

  test('ClassicalChessSharp - scoring system', () {
    // Checkmate
    final pos = ClassicalChessSharp.fromSetup(
        Setup.parseFen('k7/8/K7/8/8/8/8/1Q6 w - - 0 1'));
    printBoard(pos, printLegalMoves: true);
    final mate = pos.playSan('Qb7#');
    printBoard(mate, printLegalMoves: true);
    expect(mate.isCheckmate, true);
    expect(mate.outcome?.winner, Side.white);
    expect(mate.outcome?.endType, EndType.decisive);
    expect(Outcome.toPgnStringChessSharp(mate.outcome), '10–0');

    // Stalemate
    final stalematePos = ClassicalChessSharp.fromSetup(
        Setup.parseFen('k7/8/K7/8/8/8/8/1R6 w - - 0 1'));
    printBoard(stalematePos, printLegalMoves: true);
    final stalemate = stalematePos.playSan('Rb7');
    printBoard(stalemate, printLegalMoves: true);
    expect(stalemate.isStalemate, true);
    expect(stalemate.outcome?.endType, EndType.stalemate);
    expect(Outcome.toPgnStringChessSharp(stalemate.outcome), '8–2');
  });
}
