import 'package:chess_sharp_dart/chess_sharp_dart.dart';
import 'package:test/test.dart';
import 'db_testing_lib.dart';

void main() {
  test('PreChess - initial position', () {
    final pos = PreChess.initial;
    printBoard(pos, printLegalMoves: true);
    expect(pos.rule, Rule.preChess);
    expect(pos.board.piecesOf(Side.white, Role.pawn).size, 8);
    expect(pos.board.piecesOf(Side.white, Role.king).size, 0);
    expect(pos.pockets?.of(Side.white, Role.king), 1);
    expect(pos.pockets?.of(Side.white, Role.queen), 1);

    const MyExpectations myExpectations = MyExpectations(
        legalMoves: 0,
        legalDrops: 40,
        legalDropZone: DropZone.whiteHomeRow,
        rolesThatCanDrop: [
          Role.knight,
          Role.bishop,
          Role.rook,
          Role.queen,
          Role.king
        ],
        rolesThatCantDrop: [
          Role.pawn,
          Role.star
        ]);
    expect(myExpectations.testLegalMoves(pos.legalMovesList), '');
  });

  test('PreChess - placement phase', () {
    Position pos = PreChess.initial;

    // White drops King
    expect(pos.legalDrops.size, 8); // first rank is empty
    pos = pos.play(const DropMove(role: Role.king, to: Square.a1));
    printBoard(pos, printLegalMoves: true);
    expect(pos.board.pieceAt(Square.a1)?.role, Role.king);
    expect(pos.turn, Side.black);

    // Black drops King
    expect(pos.legalDrops.size, 8); // eighth rank is empty
    pos = pos.play(const DropMove(role: Role.king, to: Square.h8));
    printBoard(pos, printLegalMoves: true);
    expect(pos.board.pieceAt(Square.h8)?.role, Role.king);
    expect(pos.turn, Side.white);

    // Normal moves should be illegal during placement
    expect(pos.legalMovesList.every((m) => m is DropMove), true);
  });

  test('PreChess - transition to normal play', () {
    Position pos = PreChess.initial;

    // Quickly drop all pieces for both sides (simplified for test)
    // In real Benko Pre-Chess, you have 8 pieces to drop (K, Q, RR, BB, NN)
    // Wait, Pockets.chessSharp has 8 pieces: K, Q, RR, BB, NN.

    final whitePieces = [
      Role.king,
      Role.queen,
      Role.rook,
      Role.rook,
      Role.bishop,
      Role.bishop,
      Role.knight,
      Role.knight
    ];
    final blackPieces = [
      Role.king,
      Role.queen,
      Role.rook,
      Role.rook,
      Role.bishop,
      Role.bishop,
      Role.knight,
      Role.knight
    ];

    for (int i = 0; i < 8; i++) {
      pos = pos
          .play(DropMove(role: whitePieces[i], to: Square(i))); // a1, b1, ...
      printBoard(pos, printLegalMoves: true);
      pos = pos.play(
          DropMove(role: blackPieces[i], to: Square(56 + i))); // a8, b8, ...
      printBoard(pos, printLegalMoves: true);
    }

    expect(pos.pockets?.countSide(Side.white), 0);
    expect(pos.pockets?.countSide(Side.black), 0);

    // Now normal moves should be legal
    expect(pos.legalMovesList.any((m) => m is NormalMove), true);
    expect(pos.legalMovesList.any((m) => m is DropMove), false);

    // Test checkmate in normal play phase
    // (Should act like standard Chess)
    expect(pos.isCheck, false);
  });
}
