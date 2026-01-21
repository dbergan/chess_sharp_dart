void main() {
  final b2 = BigInt.parse('8080808080808080', radix: 16);

  final v = b2.toUnsigned(64);
  final low = (v & BigInt.from(0xffffffff)).toInt();
  final high = (v >> 32).toInt();
  final iCorrect = (high << 32) | low;

  print('hFile bits hex from int: 0x${iCorrect.toRadixString(16)}');

  // Test if it contains bit 63
  print('Bit 63 set? ${(iCorrect & (1 << 63)) != 0}');

  final bFull = BigInt.parse('ffffffffffffffff', radix: 16);
  final vF = bFull.toUnsigned(64);
  final iFull =
      ((vF >> 32).toInt() << 32) | (vF & BigInt.from(0xffffffff)).toInt();
  print('Full hex: 0x${iFull.toRadixString(16)}');
}
