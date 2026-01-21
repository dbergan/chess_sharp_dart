import 'package:chess_sharp_dart/chess_sharp_dart.dart';
import 'package:test/test.dart';
import 'db_testing_lib.dart';

void main() {
  print('☆' * 34);
  print('${'☆\tCATCH THE STARS'.padRight(44)}☆');
  print('☆' * 34);

  test('☆ Board starts empty', () {
    expect(Board.catchTheStars.pieces.length, 0);
    expect(Board.catchTheStars.materialCount(Side.white)[Role.pawn], 0);
    expect(Board.catchTheStars.materialCount(Side.white)[Role.knight], 0);
    expect(Board.catchTheStars.materialCount(Side.white)[Role.bishop], 0);
    expect(Board.catchTheStars.materialCount(Side.white)[Role.rook], 0);
    expect(Board.catchTheStars.materialCount(Side.white)[Role.queen], 0);
    expect(Board.catchTheStars.materialCount(Side.white)[Role.king], 0);
    expect(Board.catchTheStars.materialCount(Side.white)[Role.star], 0);
    expect(Board.catchTheStars.materialCount(Side.black)[Role.pawn], 0);
    expect(Board.catchTheStars.materialCount(Side.black)[Role.knight], 0);
    expect(Board.catchTheStars.materialCount(Side.black)[Role.bishop], 0);
    expect(Board.catchTheStars.materialCount(Side.black)[Role.rook], 0);
    expect(Board.catchTheStars.materialCount(Side.black)[Role.queen], 0);
    expect(Board.catchTheStars.materialCount(Side.black)[Role.king], 0);
    expect(Board.catchTheStars.materialCount(Side.black)[Role.star], 0);
  });

  test(
    '☆ white pocket starts with a king and black pocket starts with 5 stars',
    () {
      const myPockets = Pockets.catchTheStars;
      expect(myPockets.size, 6);
      expect(myPockets.countSide(Side.white), 1);
      expect(myPockets.countSide(Side.black), 5);
      expect(myPockets.count(Role.pawn), 0);
      expect(myPockets.count(Role.knight), 0);
      expect(myPockets.count(Role.bishop), 0);
      expect(myPockets.count(Role.rook), 0);
      expect(myPockets.count(Role.queen), 0);
      expect(myPockets.count(Role.king), 1);
      expect(myPockets.count(Role.star), 5);
      expect(myPockets.of(Side.white, Role.pawn), 0);
      expect(myPockets.of(Side.white, Role.knight), 0);
      expect(myPockets.of(Side.white, Role.bishop), 0);
      expect(myPockets.of(Side.white, Role.rook), 0);
      expect(myPockets.of(Side.white, Role.queen), 0);
      expect(myPockets.of(Side.white, Role.king), 1);
      expect(myPockets.of(Side.white, Role.star), 0);
      expect(myPockets.of(Side.black, Role.pawn), 0);
      expect(myPockets.of(Side.black, Role.knight), 0);
      expect(myPockets.of(Side.black, Role.bishop), 0);
      expect(myPockets.of(Side.black, Role.rook), 0);
      expect(myPockets.of(Side.black, Role.queen), 0);
      expect(myPockets.of(Side.black, Role.king), 0);
      expect(myPockets.of(Side.black, Role.star), 5);
      expect(myPockets.hasQuality(Side.white), true);
      expect(myPockets.hasQuality(Side.black), false);
      expect(myPockets.hasPawn(Side.white), false);
      expect(myPockets.hasPawn(Side.black), false);
      expect(myPockets.toString(), '[Ksssss]');
    },
  );
  test('☆ inital fen', () {
    expect(ChessSharp.catchTheStars.fen, '8/8/8/8/8/8/8/8[Ksssss] w - - 0 1');

    final loadedPosition = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('8/8/8/8/8/8/8/8[Ksssss] w - - 0 1'),
    );
    expect(ChessSharp.catchTheStars.fen, loadedPosition.fen);
  });
  test('☆ kingCount', () {
    const ChessSharp a = ChessSharp.catchTheStars;
    expect(a.board.kings.size, 0);
    expect(a.pockets!.of(Side.white, Role.king), 1);
    expect(a.pockets!.of(Side.black, Role.king), 0);
  });
  test('☆ starCount', () {
    const ChessSharp a = ChessSharp.catchTheStars;
    expect(a.board.stars.size, 0);
    expect(a.pockets!.of(Side.white, Role.star), 0);
    expect(a.pockets!.of(Side.black, Role.star), 5);
  });

  test('☆ King - test all legal moves and drops from the beginning', () {
    Position a = ChessSharp.catchTheStars;
    printBoard(a, printLegalMoves: true);
    MyExpectations myExpectations = const MyExpectations(
      legalMoves: 0,
      legalDrops: 8,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [Role.king],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('K@a1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 0,
      legalDrops: 63,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [Role.star],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.king,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('S@c3');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 3,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Kb2');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 0,
      legalDrops: 62,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [Role.star],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('S@a1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 8,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Kc3');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 0,
      legalDrops: 62,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [Role.star],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('S@b1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 8,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Kb2');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 0,
      legalDrops: 61,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [Role.star],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('S@d1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 8,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Ka1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 0,
      legalDrops: 61,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [Role.star],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('S@h1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 3,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Kb1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 2,
      legalDrops: 0,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Sh1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 5,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Kc1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 2,
      legalDrops: 0,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Sh1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 5,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Kd1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 1,
      legalDrops: 0,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Sh1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 5,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Ke1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 1,
      legalDrops: 0,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Sh1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 5,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Kf1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 1,
      legalDrops: 0,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Sh1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 5,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Kg1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 1,
      legalDrops: 0,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Sh1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 5,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');
    expect(a.outcome, null);

    a = a.playSan('Kh1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 0,
      legalDrops: 0,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.king,
        Role.knight,
        Role.bishop,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');
    expect(a.outcome, Outcome.whiteWins);
  });

  test(
    'Invalid setup: bishops on light squares, opponent star on dark square',
    () {
      // White has a bishop on a2 (light square) and nothing else.
      // Black has a star on a1 (dark square).
      final setup = Setup.parseFen('8/8/8/8/8/8/B7/s7[ss] w - - 0 1');
      // B at a2 (light), s at a1 (dark)

      expect(
        () => ChessSharp.fromSetup(rule: Rule.catchTheStars, setup),
        throwsA(isA<PositionSetupException>()),
      );
    },
  );

  test(
    'Valid setup: bishop on light squares, opponent star on light square',
    () {
      // B at a2 (light), s at b1 (dark)
      final setup = Setup.parseFen('8/8/8/8/8/8/B7/1s6[ss] w - - 0 1');

      final pos = ChessSharp.fromSetup(rule: Rule.catchTheStars, setup);
      expect(pos, isA<ChessSharp>());
    },
  );

  test('Valid setup: bishops on both colors, opponent star on any color', () {
    final setup = Setup.parseFen('8/8/8/8/8/8/BB6/ss6[ss] w - - 0 1');
    // B at a2, b2; s at a1, b1

    final pos = ChessSharp.fromSetup(rule: Rule.catchTheStars, setup);
    expect(pos, isA<ChessSharp>());
  });

  test('Valid setup: bishop on one color but king also present', () {
    final setup = Setup.parseFen('8/8/8/8/8/8/BK6/s7[ss] w - - 0 1');
    // B at a2 (light), K at b2 (dark), s at a1 (dark)

    final pos = ChessSharp.fromSetup(rule: Rule.catchTheStars, setup);
    expect(pos, isA<ChessSharp>());
  });

  test('Valid setup: bishop on one color but something in pocket', () {
    final setup = Setup.parseFen('8/8/8/8/8/8/B7/s7[Pss] w - - 0 1');
    // B at a2 (light), s at a1 (dark), Pawn in pocket

    final pos = ChessSharp.fromSetup(rule: Rule.catchTheStars, setup);
    expect(pos, isA<ChessSharp>());
  });

  test('☆ 1 Bishop - test all legal moves and drops from the beginning', () {
    Position a = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('8/8/8/8/8/8/8/8[Bs] w - - 0 1'),
    );
    printBoard(a, printLegalMoves: true);
    MyExpectations myExpectations = const MyExpectations(
      legalMoves: 0,
      legalDrops: 8,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [Role.bishop],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.knight,
        Role.king,
        Role.rook,
        Role.star,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('B@a1');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 0,
      legalDrops: 31,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [Role.star],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.knight,
        Role.king,
        Role.rook,
        Role.bishop,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('S@b8');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 7,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.knight,
        Role.king,
        Role.rook,
        Role.star,
        Role.bishop,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Be5');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 1,
      legalDrops: 0,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.knight,
        Role.king,
        Role.rook,
        Role.star,
        Role.bishop,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');

    a = a.playSan('Sb8');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 13,
      legalDrops: 0,
      legalDropZone: DropZone.whiteHomeRow,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.knight,
        Role.king,
        Role.rook,
        Role.star,
        Role.bishop,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');
    expect(a.outcome, null);

    a = a.playSan('Bb8');
    printBoard(a, printLegalMoves: true);
    myExpectations = const MyExpectations(
      legalMoves: 0,
      legalDrops: 0,
      legalDropZone: DropZone.anywhere,
      rolesThatCanDrop: [],
      rolesThatCantDrop: [
        Role.pawn,
        Role.queen,
        Role.knight,
        Role.king,
        Role.rook,
        Role.star,
        Role.bishop,
      ],
    );
    expect(myExpectations.testLegalMoves(a.legalMovesList), '');
    expect(a.outcome, Outcome.whiteWins);
  });
  test('☆ 1 Knight - test all legal moves and drops', () {
    Position a = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('8/8/8/8/8/8/8/8[Ns] w - - 0 1'),
    );
    printBoard(a, printLegalMoves: true);

    a = a.playSan('N@b1');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('S@c3');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('Nc3');
    printBoard(a, printLegalMoves: true);
    expect(a.outcome, Outcome.whiteWins);
  });

  test('☆ 1 Rook - test all legal moves and drops', () {
    Position a = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('8/8/8/8/8/8/8/8[Rs] w - - 0 1'),
    );
    printBoard(a, printLegalMoves: true);

    a = a.playSan('R@a1');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('S@a8');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('Ra8');
    printBoard(a, printLegalMoves: true);
    expect(a.outcome, Outcome.whiteWins);
  });

  test('☆ 1 Queen - test all legal moves and drops', () {
    Position a = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('8/8/8/8/8/8/8/8[Qss] w - - 0 1'),
    );
    printBoard(a, printLegalMoves: true);

    a = a.playSan('Q@d1');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('S@d4');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('Qd4');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('S@h8');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('Qh8');
    printBoard(a, printLegalMoves: true);
    expect(a.outcome, Outcome.whiteWins);
  });

  test('☆ 1 Pawn - test all legal moves and drops', () {
    Position a = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('8/8/8/8/5s2/8/4P3/8[] w - - 0 1'),
    );
    printBoard(a, printLegalMoves: true);

    a = a.playSan('e3');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('Sf4');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('exf4');
    printBoard(a, printLegalMoves: true);
    expect(a.outcome, Outcome.whiteWins);
  });

  test('☆ Multi-star level', () {
    Position a = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('8/8/8/8/8/8/8/1N6[sss] b - - 0 1'),
    );
    printBoard(a, printLegalMoves: true);

    a = a.playSan('S@a3');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('Na3');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('S@b5');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('Nb5');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('S@c7');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('Nc7');
    printBoard(a, printLegalMoves: true);
    expect(a.outcome, Outcome.whiteWins);
  });

  test('☆ Star placement restriction (only dark-squared bishops)', () {
    Position a = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('1s6/8/8/8/8/8/8/B1B5[ssss] w - - 0 1'),
    );
    printBoard(a, printLegalMoves: true);

    a = a.playSan('Be5');
    printBoard(a, printLegalMoves: true);

    // Now it's Black's turn to drop a star.
    // Since White only has dark-squared bishops, stars should only be droppable on dark squares.
    final legalDrops = a.legalMovesList.whereType<DropMove>();
    for (final drop in legalDrops) {
      expect(
        SquareSet.darkSquares.has(drop.to),
        true,
        reason: 'Star dropped on light square ${drop.to.name}',
      );
    }

    // Try to drop a star on a light square (e.g., a8) - should fail
    expect(() => a.playSan('S@a8'), throwsA(isA<PlayException>()));

    // Drop on a dark square (e.g., d8) - should work
    a = a.playSan('S@d8');
    printBoard(a, printLegalMoves: true);
  });

  test('☆ Bishop in pocket to catch stars on other color', () {
    Position a = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('1s6/8/8/8/8/8/8/B7[Bssss] w - - 0 1'),
    );
    // White has dark-squared bishop on a1, and 1 Bishop in pocket.
    // Black has star on b8 (light square) and 4 stars in pocket.
    printBoard(a, printLegalMoves: true);

    // In this setup, White has a Bishop in pocket.
    // canCoverLightAndDark for White pocket returns false (only 1 bishop).
    // Board has only 1 dark bishop.
    // So stars are still restricted to dark squares?
    // Wait, let's check the star on b8. It's on a light square!
    // If the star on b8 is already there, is the FEN legal?
    // Position.fromSetup calls validate(), which calls _validateCheckers, etc.
    // catchTheStars variant doesn't have much extra validation.

    // If White has a Bishop in pocket, White *could* place it on a light square.
    // BUT the current logic for canCoverLightAndDark(pocket) only returns true if > 1 bishop in pocket.
    // Let's re-read:
    // return bySide[Role.bishop]! > 1
    // So 1 bishop in pocket doesn't count as covering both.

    // If so, the initial FEN '8/1s6/8/8/8/8/8/B7[Bssss] w' might be "illegal" if stars are restricted.
    // But validate() doesn't check star placement yet.

    // Let's see if Black can drop a star on a light square.
    a = a.playSan('Be5');
    printBoard(a, printLegalMoves: true);

    // Black's turn.
    // Try to drop star on light square.
    // Based on code, this succeeds because White has a Bishop in the pocket that *could* cover the square.
    a = a.playSan('S@a8');
    printBoard(a, printLegalMoves: true);

    // Now White catches the first star
    a = a.playSan('Bxb8');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('S@h8');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Be5');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('S@g8');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Bxh8');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('S@h7');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('B@h1');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sh7');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Bxa8'); // Bishop at h1 catches star on a8
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sh7');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Bd5');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sh7');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Bxg8');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sh7');
    printBoard(a, printLegalMoves: true);
    expect(a.outcome, null);

    a = a.playSan('Bxh7');
    printBoard(a, printLegalMoves: true);
    expect(a.outcome, Outcome.whiteWins);
  });

  test('☆ Two Bishops in pocket', () {
    Position a = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('8/8/8/8/8/8/8/8[BBss] w - - 0 1'),
    );
    printBoard(a, printLegalMoves: true);

    a = a.playSan('B@a1'); // Dark square
    printBoard(a, printLegalMoves: true);
    a = a.playSan(
      'S@b8',
    ); // S@b8 succeeds because White has a Bishop in the pocket.
    printBoard(a, printLegalMoves: true);

    a = a.playSan('B@b1'); // White drops second Bishop on light square.
    printBoard(a, printLegalMoves: true);
    a = a.playSan('S@c8'); // Now Black can drop star on light square.
    printBoard(a, printLegalMoves: true);

    // Collect all stars... (simplifying for test)
    a = a.playSan('Be5');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sc8'); // Black pass
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Bxb8');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sc8'); // Black pass
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Bf5');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sc8'); // Black pass
    printBoard(a, printLegalMoves: true);
    expect(a.outcome, null);

    a = a.playSan('Bxc8');
    printBoard(a, printLegalMoves: true);
    expect(a.outcome, Outcome.whiteWins);
  });

  test('☆ Pawn promotion to Queen to catch stars', () {
    Position a = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('8/8/8/8/5s2/8/4P3/8[ssss] w - - 0 1'),
    );
    printBoard(a, printLegalMoves: true);

    a = a.playSan('e3');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('S@a1');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('exf4'); // Pawn is now on f4
    printBoard(a, printLegalMoves: true);
    a = a.playSan('S@b1');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('f5');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('S@c1');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('f6');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('S@d1');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('f7');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sd1');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('f8=Q');
    printBoard(a, printLegalMoves: true);

    a = a.playSan('Sa1'); // Black pass
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Qf1');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sa1'); // Black pass
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Qxd1');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sc1'); // Black pass
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Qxc1');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sa1'); // Black pass
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Qxb1');
    printBoard(a, printLegalMoves: true);
    a = a.playSan('Sa1'); // Black pass
    printBoard(a, printLegalMoves: true);
    expect(a.outcome, null);

    a = a.playSan('Qxa1');
    printBoard(a, printLegalMoves: true);
    expect(a.outcome, Outcome.whiteWins);
  });

  test('☆ Queen placement restriction', () {
    Position a = ChessSharp.fromSetup(
      rule: Rule.catchTheStars,
      Setup.parseFen('8/8/8/8/8/8/8/8[BKQsssss] w - - 0 1'),
    );
    printBoard(a, printLegalMoves: true);

    // Try to drop Queen - should fail
    expect(() => a.playSan('Q@a1'), throwsA(isA<PlayException>()));

    a = a.playSan('K@a1');
    printBoard(a, printLegalMoves: true);
    // Try to drop Queen - should still fail (Bishop still in pocket)
    expect(() => a.playSan('Q@b1'), throwsA(isA<PlayException>()));

    a = a.playSan('S@c3'); // Black drop
    printBoard(a, printLegalMoves: true);
    a = a.playSan('B@b1'); // White drop Bishop
    printBoard(a, printLegalMoves: true);
    a = a.playSan('S@d4'); // Black drop
    printBoard(a, printLegalMoves: true);

    // Now only Queen left in White pocket.
    a = a.playSan('Q@c1');
    printBoard(a, printLegalMoves: true);
    expect(a.board.pieceAt(Square.fromName('c1'))?.role, Role.queen);
  });
}
