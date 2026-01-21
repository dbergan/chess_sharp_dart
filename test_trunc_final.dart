void main() {
  final b2 = BigInt.parse('8080808080808080', radix: 16);

  final iCorrect = b2.toUnsigned(64).toInt().toSigned(64);
  print('hFile bits as signed int: $iCorrect');

  const expected = -9187343239835820416; // 0x8080808080808080
  print('Expected: $expected');
  print('Equal? ${iCorrect == expected}');

  final bFull = BigInt.parse('ffffffffffffffff', radix: 16);
  final iFull = bFull.toUnsigned(64).toInt().toSigned(64);
  print('Full bits as signed int: $iFull');
  print('Equal to -1? ${iFull == -1}');
}
