void main() {
  final b2 = BigInt.parse('8080808080808080', radix: 16);
  final hex = b2.toRadixString(16);
  print('Hex from BigInt: $hex');

  final iParsed = int.parse(hex, radix: 16).toSigned(64);
  print('Parsed int: $iParsed');

  const expected = -9187343239835820416; // 0x8080808080808080
  print('Expected: $expected');
  print('Equal? ${iParsed == expected}');
}
