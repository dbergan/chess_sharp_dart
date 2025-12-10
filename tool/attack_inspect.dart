import 'package:chess_sharp_dart/chess_sharp_dart.dart';

void printBoard(BigInt x) {
  for (var r = 7; r >= 0; r--) {
    final rowBuf = StringBuffer();
    for (var f = 0; f < 8; f++) {
      final bit = (x >> (r * 8 + f)) & BigInt.one;
      rowBuf.write(bit == BigInt.one ? '1' : '.');
      if (f != 7) rowBuf.write(' ');
    }
    print(rowBuf);
  }
}

void show(String label, BigInt expected, BigInt actual) {
  print('--- $label ---');
  print('expected: 0x${expected.toRadixString(16)}');
  print('actual:   0x${actual.toRadixString(16)}');
  print('xor:      0x${(expected ^ actual).toRadixString(16)}');
  print('expected board:');
  printBoard(expected);
  print('actual board:');
  printBoard(actual);
  print('');
}

void main() {
  // Expected constants from tests (decimal -> BigInt)
  final rookExpected = BigInt.parse('289421164424462336');
  final queenEmptyExpected = BigInt.parse('2641485286422881314');
  final queenOccExpected = BigInt.parse('1517425062794231808');

  // Compute actual masks
  const rookSquare = Square.c6;
  final rookOccupied = makeSquareSet('''
. . . . . . . .
. . . . . . . .
. . . . . 1 . .
. . 1 . . . . .
. . . . . . . .
. . . . . . . .
. . 1 . . . . .
. . . . . . . .
''');
  final rookR = rookAttacks(rookSquare, rookOccupied);

  const queenSquareEmpty = Square.f5;
  final queenEmpty = queenAttacks(queenSquareEmpty, SquareSet.empty);

  const queenSquareOcc = Square.c6;
  final queenOcc = queenAttacks(queenSquareOcc, makeSquareSet('''
. . . . . . . .
. . . . . . . .
. 1 . . . . . .
. . 1 . . . . .
. . . . . . . .
. . . . . 1 . .
. . 1 . . . . .
. . . . . . . .
'''));

  // For queen we also print components
  final qRook = rookAttacks(queenSquareEmpty, SquareSet.empty);
  final qBishop = bishopAttacks(queenSquareEmpty, SquareSet.empty);

  show('Rook attacks (occupied) - Square.c6', rookExpected, rookR.value);
  show('Queen attacks (empty) - Square.f5', queenEmptyExpected,
      queenEmpty.value);
  show(
      'Queen attacks (occupied) - Square.c6', queenOccExpected, queenOcc.value);

  print('--- Queen components for Square.f5 (empty) ---');
  print('rook component: 0x${qRook.value.toRadixString(16)}');
  printBoard(qRook.value);
  print('bishop component: 0x${qBishop.value.toRadixString(16)}');
  printBoard(qBishop.value);
  final expectedBishop = queenEmptyExpected ^ qRook.value;
  show('Derived expected bishop (from queen expected XOR rook component)',
      expectedBishop, qBishop.value);
}
