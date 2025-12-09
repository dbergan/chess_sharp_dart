import 'dart:io' as io;

import 'package:chess_sharp_dart/dartchess.dart';
import 'package:test/test.dart';
import 'db_testing_lib.dart';

void main() {
  print('♯' * 60);
  print('${'♯\tCHESS♯'.padRight(53)}♯');
  print('${'♯\tThe rules for Chess♯ can be found at:'.padRight(53)}♯');
  print('${'♯\thttps://chess-sharp.games/ChessSharp_Rules.pdf'.padRight(53)}♯');
  print('♯' * 60);

  test('Chess♯ - board starts with 16 pawns (only)', () {
    expect(Board.chessSharp.pieces.length, 16);
    expect(Board.chessSharp.materialCount(Side.white)[Role.pawn], 8);
    expect(Board.chessSharp.materialCount(Side.white)[Role.knight], 0);
    expect(Board.chessSharp.materialCount(Side.white)[Role.bishop], 0);
    expect(Board.chessSharp.materialCount(Side.white)[Role.rook], 0);
    expect(Board.chessSharp.materialCount(Side.white)[Role.queen], 0);
    expect(Board.chessSharp.materialCount(Side.white)[Role.king], 0);
    expect(Board.chessSharp.materialCount(Side.black)[Role.pawn], 8);
    expect(Board.chessSharp.materialCount(Side.black)[Role.knight], 0);
    expect(Board.chessSharp.materialCount(Side.black)[Role.bishop], 0);
    expect(Board.chessSharp.materialCount(Side.black)[Role.rook], 0);
    expect(Board.chessSharp.materialCount(Side.black)[Role.queen], 0);
    expect(Board.chessSharp.materialCount(Side.black)[Role.king], 0);
  });
  test('Chess♯ - pockets start with the 16 standard non-pawn pieces', () {
    const myPockets = Pockets.chessSharp;
    expect(myPockets.size, 16);
    expect(myPockets.countSide(Side.white), 8);
    expect(myPockets.countSide(Side.black), 8);
    expect(myPockets.count(Role.pawn), 0);
    expect(myPockets.count(Role.knight), 4);
    expect(myPockets.count(Role.bishop), 4);
    expect(myPockets.count(Role.rook), 4);
    expect(myPockets.count(Role.queen), 2);
    expect(myPockets.count(Role.king), 2);
    expect(myPockets.of(Side.white, Role.pawn), 0);
    expect(myPockets.of(Side.white, Role.knight), 2);
    expect(myPockets.of(Side.white, Role.bishop), 2);
    expect(myPockets.of(Side.white, Role.rook), 2);
    expect(myPockets.of(Side.white, Role.queen), 1);
    expect(myPockets.of(Side.white, Role.king), 1);
    expect(myPockets.of(Side.black, Role.pawn), 0);
    expect(myPockets.of(Side.black, Role.knight), 2);
    expect(myPockets.of(Side.black, Role.bishop), 2);
    expect(myPockets.of(Side.black, Role.rook), 2);
    expect(myPockets.of(Side.black, Role.queen), 1);
    expect(myPockets.of(Side.black, Role.king), 1);
    expect(myPockets.hasQuality(Side.white), true);
    expect(myPockets.hasQuality(Side.black), true);
    expect(myPockets.hasPawn(Side.white), false);
    expect(myPockets.hasPawn(Side.black), false);
    expect(myPockets.toString(), '[NNBBRRKQnnbbrrkq]');

    const doubleFlatPockets = Pockets.chessDoubleFlat;
    expect(doubleFlatPockets.toString(), '[KQkq]');
    const flatPockets = Pockets.chessFlat;
    expect(flatPockets.toString(), '[BBRRKQbbrrkq]');
    const doublesharpPockets = Pockets.chessDoubleSharp;
    expect(doublesharpPockets.toString(), '[NNBBRRKQQnnbbrrkqq]');
  });
  test('Chess♯ - inital fen', () {
    expect(ChessSharp.initial.fen,
        '8/pppppppp/8/8/8/8/PPPPPPPP/8[NNBBRRKQnnbbrrkq] w - - 0 1');

    expect(ChessSharp.chessFlat.fen,
        '8/pppppppp/8/8/8/8/PPPPPPPP/8[BBRRKQbbrrkq] w - - 0 1');

    expect(ChessSharp.chessDoubleFlat.fen,
        '8/pppppppp/8/8/8/8/PPPPPPPP/8[KQkq] w - - 0 1');

    expect(ChessSharp.chessDoubleSharp.fen,
        '8/pppppppp/8/8/8/8/PPPPPPPP/8[NNBBRRKQQnnbbrrkqq] w - - 0 1');

    final loadedPosition = ChessSharp.fromSetup(Setup.parseFen(
        '8/pppppppp/8/8/8/8/PPPPPPPP/8[NNBBRRKQnnbbrrkq] w - - 0 1'));
    expect(ChessSharp.initial.fen, loadedPosition.fen);
  });
  test('Chess♯ - kingCount', () {
    const ChessSharp a = ChessSharp.initial;
    expect(a.board.kings.size, 0);
    expect(a.pockets!.of(Side.white, Role.king), 1);
    expect(a.pockets!.of(Side.black, Role.king), 1);
  });
  test('Chess♯ - test all legal moves and drops from the beginning', () {
    Position a = ChessSharp.initial;
    printBoard(a, printLegalMoves: true);
    MyExpectations myExpectations = const MyExpectations(
        legalMoves: 0,
        legalDrops: 32,
        legalDropZone: DropZone.whiteHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook, Role.king],
        rolesThatCantDrop: [Role.pawn, Role.queen]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('K@a1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 0,
        legalDrops: 32,
        legalDropZone: DropZone.blackHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook, Role.king],
        rolesThatCantDrop: [Role.pawn, Role.queen]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('N@a8');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 9,
        legalDrops: 21,
        legalDropZone: DropZone.whiteHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook],
        rolesThatCantDrop: [Role.pawn, Role.queen, Role.king]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('a3');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 0,
        legalDrops: 28,
        legalDropZone: DropZone.blackHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook, Role.king],
        rolesThatCantDrop: [Role.pawn, Role.queen]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('N@b8');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 10,
        legalDrops: 21,
        legalDropZone: DropZone.whiteHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook],
        rolesThatCantDrop: [Role.pawn, Role.queen, Role.king]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('b3');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 0,
        legalDrops: 18,
        legalDropZone: DropZone.blackHomeRow,
        rolesThatCanDrop: [Role.bishop, Role.rook, Role.king],
        rolesThatCantDrop: [Role.knight, Role.pawn, Role.queen]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('B@c8');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 11,
        legalDrops: 21,
        legalDropZone: DropZone.whiteHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook],
        rolesThatCantDrop: [Role.pawn, Role.queen, Role.king]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('c3');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 0,
        legalDrops: 15,
        legalDropZone: DropZone.blackHomeRow,
        rolesThatCanDrop: [Role.bishop, Role.rook, Role.king],
        rolesThatCantDrop: [Role.knight, Role.pawn, Role.queen]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('B@d8');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 11,
        legalDrops: 21,
        legalDropZone: DropZone.whiteHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook],
        rolesThatCantDrop: [Role.pawn, Role.queen, Role.king]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('d3');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 0,
        legalDrops: 8,
        legalDropZone: DropZone.blackHomeRow,
        rolesThatCanDrop: [Role.rook, Role.king],
        rolesThatCantDrop: [Role.bishop, Role.knight, Role.pawn, Role.queen]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('R@e8');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 11,
        legalDrops: 21,
        legalDropZone: DropZone.whiteHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook],
        rolesThatCantDrop: [Role.pawn, Role.queen, Role.king]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('e3');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 0,
        legalDrops: 6,
        legalDropZone: DropZone.blackHomeRow,
        rolesThatCanDrop: [Role.rook, Role.king],
        rolesThatCantDrop: [Role.bishop, Role.knight, Role.pawn, Role.queen]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('R@f8');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 11,
        legalDrops: 21,
        legalDropZone: DropZone.whiteHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook],
        rolesThatCantDrop: [Role.pawn, Role.queen, Role.king]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('f3');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 0,
        legalDrops: 2,
        legalDropZone: DropZone.blackHomeRow,
        rolesThatCanDrop: [
          Role.king
        ],
        rolesThatCantDrop: [
          Role.rook,
          Role.bishop,
          Role.knight,
          Role.pawn,
          Role.queen
        ]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('K@g8');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 11,
        legalDrops: 21,
        legalDropZone: DropZone.whiteHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook],
        rolesThatCantDrop: [Role.pawn, Role.queen, Role.king]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('g3');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 12,
        legalDrops: 1,
        legalDropZone: DropZone.blackHomeRow,
        rolesThatCanDrop: [
          Role.queen
        ],
        rolesThatCantDrop: [
          Role.rook,
          Role.bishop,
          Role.knight,
          Role.pawn,
          Role.king
        ]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Nb6');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 11,
        legalDrops: 21,
        legalDropZone: DropZone.whiteHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook],
        rolesThatCantDrop: [Role.pawn, Role.queen, Role.king]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('h3');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 14,
        legalDrops: 2,
        legalDropZone: DropZone.blackHomeRow,
        rolesThatCanDrop: [
          Role.queen
        ],
        rolesThatCantDrop: [
          Role.rook,
          Role.bishop,
          Role.knight,
          Role.pawn,
          Role.king
        ]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Nc6');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
        legalMoves: 11,
        legalDrops: 21,
        legalDropZone: DropZone.whiteHomeRow,
        rolesThatCanDrop: [Role.knight, Role.bishop, Role.rook],
        rolesThatCantDrop: [Role.pawn, Role.queen, Role.king]);
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');
  });
  test(
      "Chess♯ - test that when a piece is captured it doesn't enter the pockets (like it does for Crazyhouse)",
      () {
    Position a = ChessSharp.initial;
    a = a.playSan('K@a1');
    a = a.playSan('R@h8');
    a = a.playSan('R@g1');
    expect(a.pockets.toString(), '[NNBBRQnnbbrkq]');
    printBoard(a);
    a = a.playSan('R@g8');
    a = a.playSan('g3');
    expect(a.pockets.toString(), '[NNBBRQnnbbkq]');
    printBoard(a);
    a = a.playSan('B@f8');
    a = a.playSan('g4');
    expect(a.pockets.toString(), '[NNBBRQnnbkq]');
    printBoard(a);
    a = a.playSan('B@e8');
    a = a.playSan('Rg3');
    expect(a.pockets.toString(), '[NNBBRQnnkq]');
    printBoard(a);
    a = a.playSan('N@d8');
    a = a.playSan('Rh3');
    expect(a.pockets.toString(), '[NNBBRQnkq]');
    printBoard(a);
    a = a.playSan('N@c8');
    a = a.playSan('Rxh7');
    expect(a.pockets.toString(), '[NNBBRQkq]');
    printBoard(a);
    a = a.playSan('K@a8');
    a = a.playSan('Rxh8');
    expect(a.pockets.toString(), '[NNBBRQq]');
    printBoard(a);
    a = a.playSan('Q@b8');
    a = a.playSan('Rxg8');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('a6');
    a = a.playSan('Rxf8');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('a5');
    a = a.playSan('Rxe8');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('a4');
    a = a.playSan('Rxd8');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('a3');
    a = a.playSan('Rxc8');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('axb2');
    a = a.playSan('Kxb2');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('c6');
    a = a.playSan('Rxb8');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('c5');
    a = a.playSan('Rxb7');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('c4');
    a = a.playSan('Rxd7');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('c3');
    a = a.playSan('Rxe7');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('Ka7');
    a = a.playSan('Rxf7');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('Kb7');
    a = a.playSan('Rxg7');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('Ka7');
    a = a.playSan('Kxc3');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    a = a.playSan('Kb7');
    a = a.playSan('Rxb7');
    expect(a.pockets.toString(), '[NNBBRQ]');
    printBoard(a);
    expect(a.outcome, Outcome.whiteWins);
  });
  test(
      "Chess♯ - test that you can move a pinned piece, move into check, and the game ends when you take the opponent's king\n\t(score for taking a king is 10–0 or 0–10)",
      () {
    Position a = ChessSharp.initial;
    a = a.playSan('K@a1');
    a = a.playSan('K@g8');
    a = a.playSan('B@h1');
    a = a.playSan('B@h8');
    a = a.playSan('B@g1');
    a = a.playSan('g6');
    // moves pinned pawn, exposes king to being taken
    a = a.playSan('b3');
    a = a.playSan('B@f8');
    // moves in check
    a = a.playSan('Kb2');
    // takes king
    a = a.playSan('Bxb2');
    printBoard(a);
    conditionalPrint(a.outcome);
    conditionalPrint(Outcome.toPgnStringChessSharp(a.outcome));
    expect(Outcome.toPgnStringChessSharp(a.outcome), '0–10');
  });
  test('Chess♯ - test dropping a king into check', () {
    Position a = ChessSharp.initial;
    a = a.playSan('K@a1');
    a = a.playSan('N@h8');
    a = a.playSan('B@h1');
    a = a.playSan('N@g8');
    a = a.playSan('g3');
    a = a.playSan('B@f8');
    a = a.playSan('Bxb7');
    a = a.playSan('K@a8');
    a = a.playSan('Bxa8');
    printBoard(a);
    conditionalPrint(a.outcome);
    conditionalPrint(Outcome.toPgnStringChessSharp(a.outcome));
    expect(Outcome.toPgnStringChessSharp(a.outcome), '10–0');
  });
  test('Chess♯ - test that there is no castling', () {
    Position a = ChessSharp.initial;
    a = a.playSan('K@e1');
    a = a.playSan('K@e8');
    a = a.playSan('R@a1');
    a = a.playSan('R@a8');
    a = a.playSan('R@h1');
    a = a.playSan('R@h8');
    expect(() => a.playSan('O-O'), throwsA(const TypeMatcher<PlayException>()));
    expect(
        () => a.playSan('O-O-O'), throwsA(const TypeMatcher<PlayException>()));
    a = a.playSan('e3');
    expect(() => a.playSan('O-O'), throwsA(const TypeMatcher<PlayException>()));
    expect(
        () => a.playSan('O-O-O'), throwsA(const TypeMatcher<PlayException>()));
    printBoard(a);
  });
  test('Chess♯ - test that pawns do not sprint', () {
    Position a = ChessSharp.initial;
    a = a.playSan('K@e1');
    a = a.playSan('K@e8');
    expect(() => a.playSan('a4'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('b4'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('c4'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('d4'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('e4'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('f4'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('g4'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('h4'), throwsA(const TypeMatcher<PlayException>()));
    a = a.playSan('a3');
    expect(() => a.playSan('a5'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('b5'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('c5'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('d5'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('e5'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('f5'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('g5'), throwsA(const TypeMatcher<PlayException>()));
    expect(() => a.playSan('h5'), throwsA(const TypeMatcher<PlayException>()));
    conditionalPrint('${humanReadableBoard(a.board)}\n');
  });
  test('Chess♯ - test that you cannot under-promote', () {
    Position a = ChessSharp.initial;
    a = a.playSan('K@e1');
    a = a.playSan('K@e8');
    a = a.playSan('a3');
    a = a.playSan('b6');
    a = a.playSan('a4');
    a = a.playSan('b5');
    a = a.playSan('axb5');
    a = a.playSan('h6');
    a = a.playSan('b6');
    a = a.playSan('h5');
    a = a.playSan('b7');
    a = a.playSan('h4');
    expect(
        () => a.playSan('b8=N'), throwsA(const TypeMatcher<PlayException>()));
    expect(
        () => a.playSan('b8=B'), throwsA(const TypeMatcher<PlayException>()));
    expect(
        () => a.playSan('b8=R'), throwsA(const TypeMatcher<PlayException>()));
    expect(
        () => a.playSan('b8=P'), throwsA(const TypeMatcher<PlayException>()));
    expect(
        () => a.playSan('b8=K'), throwsA(const TypeMatcher<PlayException>()));
    a = a.playSan('b8=Q');
    conditionalPrint('${humanReadableBoard(a.board)}\n');
  });
  test(
      "Chess♯ stalemates - test and scoring\n\t(since it's legal to move into check, we made an alternate test to determine stalemate...\n\tthe score for stalemating your opponent is 8–2 or 2–8)",
      () {
    // stalemate: king can't move
    Position a =
        ChessSharp.fromSetup(Setup.parseFen('1r5k/8/8/8/8/8/7r/K7 w - - 0 1'));
    printBoard(a);
    expect(a.outcome?.endType, EndType.stalemate);
    expect(a.outcome?.winner, Side.black);
    expect(Outcome.toPgnStringChessSharp(a.outcome), '2–8');

    // no stalemate: there's a piece in my pocket, and somewhere to place it
    a = ChessSharp.fromSetup(
        Setup.parseFen('1r5k/8/8/8/8/8/7r/K7[Q] w - - 0 1'));
    printBoard(a);
    expect(a.outcome, null);

    // stalemate: there's a piece in my pocket, but nowhere to place it
    a = ChessSharp.fromSetup(
        Setup.parseFen('4k3/8/8/8/8/8/7q/qqqnKnqq[NNBBRRQ] w - - 0 1'));
    printBoard(a);
    expect(Outcome.toPgnStringChessSharp(a.outcome), '2–8');

    // no stalemate: a pawn can promote
    a = ChessSharp.fromSetup(
        Setup.parseFen('1r5k/3P4/8/8/8/8/7r/K7 w - - 0 1'));
    printBoard(a);
    expect(a.outcome, null);

    // stalemate: the pawn is pinned
    a = ChessSharp.fromSetup(Setup.parseFen('6rk/KP5r/7q/8/8/8/8/8 w - - 0 1'));
    printBoard(a);
    expect(a.outcome?.endType, EndType.stalemate);
    expect(a.outcome?.winner, Side.black);
    expect(Outcome.toPgnStringChessSharp(a.outcome), '2–8');

    // no stalemate: I'm in check (and can get out of it)
    a = ChessSharp.fromSetup(
        Setup.parseFen('K5rk/1P5r/1q6/8/8/8/8/8 w - - 0 1'));
    printBoard(a);
    expect(a.outcome, null);

    // no stalemate: I'm in check (and can't get out of it)
    a = ChessSharp.fromSetup(Setup.parseFen('K5rk/7r/8/8/8/8/8/8 w - - 0 1'));
    printBoard(a);
    expect(a.outcome, null);
  });
  test(
      'Chess♯ impasses - test and scoring\n\t(games that go 50 moves without a capture or pawn-move\n\tthe score for an impasse is 7–3 or 3–7 if one side has more material\n\tor 4–6 if both sides have the same material)',
      () {
    // fen with 100 half-moves made
    Position a = ChessSharp.fromSetup(
        Setup.parseFen('4nnbk/8/8/8/8/8/8/KBNN4 w - - 100 100'));
    printBoard(a);
    expect(a.outcome?.endType, EndType.impasse);
    expect(a.outcome?.winner, Side.black);
    expect(Outcome.toPgnStringChessSharp(a.outcome), '4–6');

    // fen with 99 half-moves made (move last one manually)
    // trigger the impasse while walking into check
    a = ChessSharp.fromSetup(
        Setup.parseFen('4nnbk/8/8/8/8/8/8/KBNN4 w - - 99 100'));
    printBoard(a);
    expect(a.outcome, null);
    a = a.playSan('Ka2');
    expect(a.outcome?.endType, EndType.impasse);
    expect(a.outcome?.winner, Side.black);
    expect(Outcome.toPgnStringChessSharp(a.outcome), '4–6');

    // fen with 100 half-moves made, black more material
    a = ChessSharp.fromSetup(
        Setup.parseFen('4nnbk/8/8/8/8/8/8/KBN5 w - - 100 100'));
    printBoard(a);
    expect(a.outcome?.endType, EndType.impasseMoreMaterial);
    expect(a.outcome?.winner, Side.black);
    expect(Outcome.toPgnStringChessSharp(a.outcome), '3–7');

    // fen with 100 half-moves made, white more material
    a = ChessSharp.fromSetup(
        Setup.parseFen('5nbk/8/8/8/8/8/8/KBNN4 w - - 100 100'));
    printBoard(a);
    expect(a.outcome?.endType, EndType.impasseMoreMaterial);
    expect(a.outcome?.winner, Side.white);
    expect(Outcome.toPgnStringChessSharp(a.outcome), '7–3');

    // fen with 100 half-moves made, white more material, but black has a queen in the pocket
    // (pieces in the pocket don't count for material points)
    a = ChessSharp.fromSetup(
        Setup.parseFen('5nbk/8/8/8/8/8/8/KBNN4[q] w - - 100 100'));
    printBoard(a);
    expect(a.outcome?.endType, EndType.impasseMoreMaterial);
    expect(a.outcome?.winner, Side.white);
    expect(Outcome.toPgnStringChessSharp(a.outcome), '7–3');
  });
  test('Chess♯ - test pgn & fen import/export', () {
    void testPGN(String pgnFile, {String? finalFen}) {
      conditionalPrint('\n\n${pgnFile.replaceAll('./data/', '')}\n');
      // See if the PGN we generate is the same PGN as the original
      final String pgn =
          io.File(pgnFile).readAsStringSync().replaceAll('\r\n', '\n');
      final game = PgnGame.parsePgn(pgn);
      expect(game.makePgn(), pgn);

      // Play the moves to see if any are illegal
      int queenDropCount = 0;
      Position position = PgnGame.startingPosition(game.headers);
      for (final node in game.moves.mainline()) {
        final move = position.parseSan(node.san);
        if (move == null) {
          conditionalPrint('Illegal move: ${node.san}\n');
          conditionalPrint('Error at: ${position.fen}\n');
          printBoard(position);
          throw Exception('Illegal move');
        }
        position = position.play(move);
        try {
          position.validate();
        } catch (e) {
          conditionalPrint("Board doesn't validate after: ${node.san}\n");
          conditionalPrint('Error: $e\n');
          conditionalPrint('fen: ${position.fen}\n');
          printBoard(position);
          throw Exception('Invalid position');
        }
        if (node.san.toUpperCase().contains('Q@')) {
          queenDropCount++;
          if (queenDropCount == 2) {
            // Print board position and FEN after the 2nd queen has been dropped (so we can copy/paste it into Stockfish)
            conditionalPrint('Analyzable: ${position.fen}');
            printBoard(position);
          }
        }
      }

      // Test final fen
      if (finalFen != null) expect(position.fen, finalFen);

      conditionalPrint('Final: ${position.fen}\n${game.headers['Result']}');
      printBoard(position);
    }

    testPGN('./data/2022-03-24 DB v John.pgn',
        finalFen: '8/8/p7/8/8/8/2k5/8 w - - 0 71');

    testPGN('./data/2022-09-03 Caleb v DB.pgn',
        finalFen:
            'kbb3r1/ppp4r/4pp2/8/P1N1PB2/1BP1R1pq/1P3P1P/3Q3K w - - 0 31');

    testPGN('./data/2023-03-06 Jim v DB.pgn',
        finalFen: '8/3k4/bp2p3/4p3/PBRrP3/1P6/7P/5K2 w - - 6 53');

    testPGN('./data/2023-03-09 Raphael v DB.pgn',
        finalFen: 'r3brq1/1kp1Rp2/2bQ4/p7/p7/2PP1PP1/PP1P3P/K3RN2 b - - 0 26');

    testPGN('./data/2023-04-12 Jim v DB.pgn',
        finalFen: '3r3k/6p1/p1q3bp/8/5p2/2P2P2/PP1KQ3/7R w - - 1 42');

    testPGN('./data/2023-04-17 DB v Jim.pgn',
        finalFen: '7k/p4r1p/bp3Np1/4R1P1/1B5Q/1P5P/KBq5/8 b - - 2 43');

    testPGN('./data/2023-04-20 DB v Raphael.pgn',
        finalFen: '8/3R2pp/p3n3/P1n5/1kp5/8/2K3PP/8 w - - 8 48');

    testPGN('./data/2023-04-21 DB v Hudson.pgn',
        finalFen: '7k/1R5P/P7/8/2p5/2P5/1P3P2/K7 b - - 0 49');

    testPGN('./data/2023-04-24 Jim v DB.pgn',
        finalFen: '1k2Q1b1/1pr4p/8/8/4pP2/4P1P1/P6P/KN5q b - - 9 47');

    testPGN('./data/2023-05-01 Jim v DB.pgn',
        finalFen:
            'k4b2/p1p3pp/b1p2p2/1r1pp3/8/4P1P1/1PPP1P1P/KRBN1QR1[rq] w - - 0 18');

    testPGN('./data/2023-05-01 Jim v DB2.pgn',
        finalFen:
            '1r3B1k/2p2b2/3p1Q2/p1P1P3/3P2P1/P1n5/1rp2P2/K1R5 b - - 1 46');

    testPGN('./data/2023-08-15 Jack v Owen Chaplain.pgn',
        finalFen: '3k4/p7/4p2r/2p3p1/8/4bBP1/P6P/1Q6 w - - 0 44');

    testPGN('./data/2023-08-17 Jack v Ethan.pgn',
        finalFen:
            '6rr/ppppk1bN/4ppQ1/8/2B2P2/1BP1P3/PP1P4/2K4R[bq] b - - 13 32');

    testPGN('./data/2023-05-13 John Bergan v Joseph Wynstra.pgn',
        finalFen: 'r2r4/p1bkn1Q1/3n4/3N4/4p3/4PP2/PP1P2PP/2BR2KR b - - 0 32');

    testPGN('./data/2023-05-13 William Ristau v John Bergan.pgn',
        finalFen: '6b1/2kp3p/1pp3p1/5N2/1P2B3/1N5P/PK2R1P1/8 b - - 0 48');

    testPGN('./data/2023-05-13 John Bergan v Carlos Casanova.pgn',
        finalFen:
            '1k3n2/p1pp4/1p1np3/4Pp2/B7/2P1P2p/PP1PQ1rP/1R2B3 w - - 0 31');

    testPGN('./data/2023-05-13 David Bergan v Jim Wynstra.pgn',
        finalFen: '1kr5/pp6/3p4/1np5/4PB2/2q5/P1N3PQ/1K3R1R b - - 3 35');

    testPGN('./data/2023-05-13 David Bergan v Raphael Neff.pgn',
        finalFen: '6k1/pp1p1ppp/2p5/1q3P2/5b2/n1P5/PPP5/3BQ2R w - - 0 30');

    testPGN('./data/2023-05-13 Michael Bergan v David Bergan.pgn',
        finalFen: '8/5R2/1p2R3/1k2P3/2PP4/3K1P2/r7/8 b - - 0 50');

    testPGN('./data/2023-05-13 Raphael Neff v Jim Wynstra.pgn',
        finalFen:
            'r3q1k1/1Q3pbp/p4bp1/1p6/1NnP4/1RB1P1P1/P3NP1P/6K1 b - - 5 35');

    testPGN('./data/2023-05-13 Jim Wynstra v Michael Bergan.pgn',
        finalFen:
            'n1Q3bq/p5p1/kp1B1p1p/4pP2/3pP3/3P1N2/2P1N1PP/3K4 b - - 0 33');

    testPGN('./data/2023-05-13 Raphael Neff v Michael Bergan.pgn',
        finalFen:
            '1kb1B1q1/p1p2p1p/1n2p1p1/1NQn4/3p1P2/3P4/PPP1P3/K2R4 b - - 0 28');

    testPGN('./data/2023-06-12 Jim Wynstra v David Bergan.pgn',
        finalFen: 'q4bk1/5ppp/p7/1p2n3/3Qb3/8/PPP2PPP/1K3B2 w - - 2 28');

    testPGN('./data/2023-10-02 David Bergan v Jim Wynstra.pgn',
        finalFen: '8/pp2Bp1r/2p3p1/3pN3/3P4/2P5/PP5K/8 b - - 0 41');

    testPGN('./data/2023-10-21 David Bergan v Elliott Neff.pgn',
        finalFen: '8/8/8/3kn1pB/4p2p/4P2b/8/3K2B1 w - - 14 77');

    testPGN('./data/2023-12-13 David Bergan v Jerry Bergan.pgn',
        finalFen: '6k1/6P1/6K1/8/8/8/8/8 b - - 2 83');

    testPGN('./data/2024-01-20 Jim Wynstra v David Bergan.pgn',
        finalFen: '8/8/1n6/pk6/8/1K6/1N6/8 w - - 14 83');

    testPGN('./data/2024-03-03 Chess Double Flat.pgn',
        finalFen: 'Q7/p1ppppp1/1p5p/8/8/6P1/PPPPPP1P/K7[q] b - - 0 4');

    testPGN('./data/2024-05-13 Pawn takes King and promotes.pgn',
        finalFen:
            '3k4/pppp1ppp/8/8/8/8/PPP1PPPP/R1BBq~RNN[Qnnbbrrq] w - - 0 8');
  });
}
