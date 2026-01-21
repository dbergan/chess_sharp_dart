void main() {
  const int x = 0xFFFFFFFFFFFFFFFF;
  print('0xFFFFFFFFFFFFFFFF as int: $x');
  print('As hex: ${x.toRadixString(16)}');
  print('Bitwise NOT: ${(~x).toRadixString(16)}');
  print('Popcount of 0x7: ${0x7.toRadixString(2).split("1").length - 1}');
}
