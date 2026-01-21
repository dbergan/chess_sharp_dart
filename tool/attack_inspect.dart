import 'package:chess_sharp_dart/chess_sharp_dart.dart';

void printBoard(int x) {
  for (var r = 7; r >= 0; r--) {
    final rowBuf = StringBuffer();
    for (var f = 0; f < 8; f++) {
      final bit = (x >>> (r * 8 + f)) & 1;
      rowBuf.write(bit == 1 ? '1' : '.');
      if (f != 7) rowBuf.write(' ');
    }
    print(rowBuf);
  }
}

void show(String label, int expected, int actual) {
  print('--- $label ---');
  print(
    'expected: 0x${BigInt.from(expected).toUnsigned(64).toRadixString(16)}',
  );
  print('actual:   0x${BigInt.from(actual).toUnsigned(64).toRadixString(16)}');
  print(
    'xor:      0x${BigInt.from(expected ^ actual).toUnsigned(64).toRadixString(16)}',
  );
  print('expected board:');
  printBoard(expected);
  print('actual board:');
  printBoard(actual);
  print('');
}

void main() {
  // Expected constants from tests
  // Wait, let me use the original values but converted to int correctly.
  // 289421164424462336 (BigInt) -> int
  final rookExpectedInt = BigInt.parse('289421164424462336').asUint64();
  final queenEmptyExpectedInt = BigInt.parse('2641485286422881314').asUint64();
  final queenOccExpectedInt = BigInt.parse('1517425062794231808').asUint64();

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
  final queenOcc = queenAttacks(
    queenSquareOcc,
    makeSquareSet('''
. . . . . . . .
. . . . . . . .
. 1 . . . . . .
. . 1 . . . . .
. . . . . . . .
. . . . . 1 . .
. . 1 . . . . .
. . . . . . . .
'''),
  );

  // For queen we also print components
  final qRook = rookAttacks(queenSquareEmpty, SquareSet.empty);
  final qBishop = bishopAttacks(queenSquareEmpty, SquareSet.empty);

  show('Rook attacks (occupied) - Square.c6', rookExpectedInt, rookR.value);
  show(
    'Queen attacks (empty) - Square.f5',
    queenEmptyExpectedInt,
    queenEmpty.value,
  );
  show(
    'Queen attacks (occupied) - Square.c6',
    queenOccExpectedInt,
    queenOcc.value,
  );

  print('--- Queen components for Square.f5 (empty) ---');
  print(
    'rook component: 0x${BigInt.from(qRook.value).toUnsigned(64).toRadixString(16)}',
  );
  printBoard(qRook.value);
  print(
    'bishop component: 0x${BigInt.from(qBishop.value).toUnsigned(64).toRadixString(16)}',
  );
  printBoard(qBishop.value);
  final expectedBishop = queenEmptyExpectedInt ^ qRook.value;
  show(
    'Derived expected bishop (from queen expected XOR rook component)',
    expectedBishop,
    qBishop.value,
  );
}

extension on BigInt {
  int asUint64() {
    return toUnsigned(64).toSigned(64).toInt();
  }
}
