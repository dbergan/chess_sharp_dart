void main() {
  final b2 = BigInt.parse('8080808080808080', radix: 16);
  final mask = (BigInt.one << 64) - BigInt.one;

  final iCorrect = (b2 & mask).toUnsigned(64).toSigned(64).toInt();
  print('hFile bits as signed int: $iCorrect');
  print('Hex: 0x${iCorrect.toRadixString(16)}');

  // Test if it matches what we want
  const expected = -9187343239835820416; // 0x8080808080808080
  print('Expected: $expected');
  print('Equal? ${iCorrect == expected}');
}
