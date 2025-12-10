void printBits(BigInt x) {
  final s = List<String>.filled(64, '0');
  for (var i = 0; i < 64; i++) {
    if (((x >> i) & BigInt.one) == BigInt.one) s[i] = '1';
  }
  // print rank 8..1 with files a..h (assuming little-endian index 0 = a1)
  for (var r = 7; r >= 0; r--) {
    final rowBuf = StringBuffer();
    for (var f = 0; f < 8; f++) {
      rowBuf.write(s[r * 8 + f]);
    }
    print(rowBuf);
  }
}

void diff(BigInt expected, BigInt actual, String label) {
  print('--- $label ---');
  print('expected: 0x${expected.toRadixString(16)}');
  print('actual:   0x${actual.toRadixString(16)}');
  final x = expected ^ actual;
  print('xor:      0x${x.toRadixString(16)}');
  var count = 0;
  final bits = <int>[];
  for (var i = 0; i < 64; i++) {
    if (((x >> i) & BigInt.one) == BigInt.one) {
      count++;
      bits.add(i);
    }
  }
  print('differing bits: $count -> $bits');
  print('expected board:');
  printBits(expected);
  print('actual board:');
  printBits(actual);
  print('xor board:');
  printBits(x);
  print('');
}

void main() {
  // Values from the failing tests
  final rookExpected = BigInt.parse('289421164424462336');
  final rookActual = BigInt.parse('289422229576351744');

  final queenEmptyExpected = BigInt.parse('2641485286422881314');
  final queenEmptyActual = BigInt.parse('18120145001004857849');

  final queenOccExpected = BigInt.parse('1517425062794231808');
  final queenOccActual = BigInt.parse('7995571651790012480');

  diff(rookExpected, rookActual, 'Rook attacks, occupied board');
  diff(queenEmptyExpected, queenEmptyActual, 'Queen attacks, empty board');
  diff(queenOccExpected, queenOccActual, 'Queen attacks, occupied board');
}
