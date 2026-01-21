void main() {
  int popcnt(int n) {
    var x = n;
    x = x - ((x >>> 1) & 0x5555555555555555);
    x = (x & 0x3333333333333333) + ((x >>> 2) & 0x3333333333333333);
    x = (x + (x >>> 4)) & 0x0f0f0f0f0f0f0f0f;
    x = x + (x >>> 8);
    x = x + (x >>> 16);
    x = x + (x >>> 32);
    return x & 0x7f;
  }

  print('Popcount of -1: ${popcnt(-1)}');
  print('Popcount of 0x8080808080808080: ${popcnt(-9187343239835820416)}');
}
