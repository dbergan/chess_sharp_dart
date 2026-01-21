void main() {
  final b2 = BigInt.parse('8080808080808080', radix: 16);

  final low = (b2 & BigInt.from(0xffffffff)).toInt();
  final high = ((b2 >> 32) & BigInt.from(0xffffffff)).toInt();
  final iCorrect = ((high << 32) | low).toSigned(64);

  print('hFile bits as signed int: $iCorrect');

  const expected = -9187343239835820416; // 0x8080808080808080
  print('Expected: $expected');
  print('Equal? ${iCorrect == expected}');
}
