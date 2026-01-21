import '../models.dart';

/// VM specific implementation of [SquareSet] using 64-bit [int].
extension type const SquareSet(int value) {
  SquareSet.fromBigInt(BigInt b) : value = _bigIntToBits(b);

  static int _bigIntToBits(BigInt b) {
    final v = b.toUnsigned(64);
    final low = (v & BigInt.from(0xffffffff)).toInt();
    final high = (v >> 32).toInt();
    return ((high << 32) | low).toSigned(64);
  }

  SquareSet.fromSquare(Square square)
    : value = (1 << square.value).toSigned(64);

  SquareSet.fromSquares(Iterable<Square> squares)
    : value = squares.fold(
        0,
        (acc, sq) => (acc | (1 << sq.value)).toSigned(64),
      );

  SquareSet.fromRank(Rank rank)
    : value = (0xFF << (8 * rank.value)).toSigned(64);

  SquareSet.fromFile(File file)
    : value = (0x0101010101010101 << file.value).toSigned(64);

  SquareSet.backrankOf(Side side)
    : value = side == Side.white ? 0xFF : (0xFF << 56).toSigned(64);

  static const empty = SquareSet(0);
  static const full = SquareSet(-1);
  static const lightSquares = SquareSet(0x55AA55AA55AA55AA);
  static const darkSquares = SquareSet(0xAA55AA55AA55AA55);
  static const diagonal = SquareSet(0x8040201008040201);
  static const antidiagonal = SquareSet(0x0102040810204080);
  static const corners = SquareSet(0x8100000000000081);
  static const center = SquareSet(0x0000001818000000);
  static const backranks = SquareSet(0xFF000000000000FF);
  static const firstRank = SquareSet(0xFF);
  static const eighthRank = SquareSet(0xFF00000000000000);
  static const aFile = SquareSet(0x0101010101010101);
  static const hFile = SquareSet(0x8080808080808080);
  static const ranksThreeToEight = SquareSet(0xFFFFFFFFFF0000);
  static const ranksOneToSix = SquareSet(0xFFFFFFFFFFFF);

  SquareSet shr(int shift) => shift >= 64 ? empty : SquareSet(value >>> shift);
  SquareSet shl(int shift) =>
      shift >= 64 ? empty : SquareSet((value << shift).toSigned(64));

  SquareSet xor(SquareSet other) =>
      SquareSet((value ^ other.value).toSigned(64));
  SquareSet operator ^(SquareSet other) =>
      SquareSet((value ^ other.value).toSigned(64));

  SquareSet union(SquareSet other) =>
      SquareSet((value | other.value).toSigned(64));
  SquareSet operator |(SquareSet other) =>
      SquareSet((value | other.value).toSigned(64));

  SquareSet intersect(SquareSet other) =>
      SquareSet((value & other.value).toSigned(64));
  SquareSet operator &(SquareSet other) =>
      SquareSet((value & other.value).toSigned(64));

  SquareSet minus(SquareSet other) =>
      SquareSet((value & ~other.value).toSigned(64));
  SquareSet operator -(SquareSet other) =>
      SquareSet((value & ~other.value).toSigned(64));

  SquareSet complement() => SquareSet((~value).toSigned(64));

  SquareSet diff(SquareSet other) =>
      SquareSet((value & ~other.value).toSigned(64));

  SquareSet flipVertical() {
    var x = value;
    x = (((x >>> 8) & 0x00FF00FF00FF00FF) | ((x & 0x00FF00FF00FF00FF) << 8))
        .toSigned(64);
    x = (((x >>> 16) & 0x0000FFFF0000FFFF) | ((x & 0x0000FFFF0000FFFF) << 16))
        .toSigned(64);
    return SquareSet(((x >>> 32) | (x << 32)).toSigned(64));
  }

  SquareSet mirrorHorizontal() {
    var x = value;
    x = (((x >>> 1) & 0x5555555555555555) | ((x & 0x5555555555555555) << 1))
        .toSigned(64);
    x = (((x >>> 2) & 0x3333333333333333) | ((x & 0x3333333333333333) << 2))
        .toSigned(64);
    x = (((x >>> 4) & 0x0F0F0F0F0F0F0F0F) | ((x & 0x0F0F0F0F0F0F0F0F) << 4))
        .toSigned(64);
    return SquareSet(x);
  }

  int get size {
    var x = value;
    x = x - ((x >>> 1) & 0x5555555555555555);
    x = (x & 0x3333333333333333) + ((x >>> 2) & 0x3333333333333333);
    x = (x + (x >>> 4)) & 0x0f0f0f0f0f0f0f0f;
    x = x + (x >>> 8);
    x = x + (x >>> 16);
    x = x + (x >>> 32);
    return x & 0x7f;
  }

  bool get isEmpty => value == 0;
  bool get isNotEmpty => value != 0;

  Square? get first => value == 0 ? null : Square(_ntz64(value));
  Square? get last => value == 0 ? null : Square(63 - _nlz64(value));

  Iterable<Square> get squares => _iterateSquares();
  Iterable<Square> get squaresReversed => _iterateSquaresReversed();

  bool get moreThanOne => value != 0 && (value & (value - 1)).toSigned(64) != 0;

  Square? get singleSquare => moreThanOne ? null : first;

  bool has(Square square) => (value & (1 << square.value).toSigned(64)) != 0;

  bool isIntersected(SquareSet other) => (value & other.value) != 0;
  bool isDisjoint(SquareSet other) => (value & other.value) == 0;

  SquareSet withSquare(Square square) =>
      SquareSet((value | (1 << square.value)).toSigned(64));
  SquareSet withoutSquare(Square square) =>
      SquareSet((value & ~(1 << square.value)).toSigned(64));

  SquareSet toggleSquare(Square square) =>
      SquareSet((value ^ (1 << square.value)).toSigned(64));

  SquareSet withoutFirst() =>
      value == 0 ? empty : SquareSet((value & (value - 1)).toSigned(64));

  String toHexString() {
    if (value == 0) return '0';
    return '0x${BigInt.from(value).toUnsigned(64).toRadixString(16).toUpperCase().padLeft(16, '0')}';
  }

  Iterable<Square> _iterateSquares() sync* {
    var b = value;
    while (b != 0) {
      final sq = _ntz64(b);
      yield Square(sq);
      b = (b & (b - 1)).toSigned(64);
    }
  }

  Iterable<Square> _iterateSquaresReversed() sync* {
    var b = value;
    while (b != 0) {
      final sq = 63 - _nlz64(b);
      yield Square(sq);
      b = (b ^ (1 << sq)).toSigned(64);
    }
  }
}

int _nlz64(int x) {
  if (x == 0) return 64;
  var v = x;
  v |= v >>> 1;
  v |= v >>> 2;
  v |= v >>> 4;
  v |= v >>> 8;
  v |= v >>> 16;
  v |= v >>> 32;
  // Use a simple popcnt for internal use
  return 64 - _popcntInternal(v);
}

int _ntz64(int x) {
  if (x == 0) return 64;
  var v = x;
  int n = 0;
  if ((v & 0xFFFFFFFF) == 0) {
    n += 32;
    v >>>= 32;
  }
  if ((v & 0xFFFF) == 0) {
    n += 16;
    v >>>= 16;
  }
  if ((v & 0xFF) == 0) {
    n += 8;
    v >>>= 8;
  }
  if ((v & 0xF) == 0) {
    n += 4;
    v >>>= 4;
  }
  if ((v & 0x3) == 0) {
    n += 2;
    v >>>= 2;
  }
  if ((v & 0x1) == 0) n += 1;
  return n;
}

int _popcntInternal(int n) {
  var x = n;
  x = x - ((x >>> 1) & 0x5555555555555555);
  x = (x & 0x3333333333333333) + ((x >>> 2) & 0x3333333333333333);
  x = (x + (x >>> 4)) & 0x0f0f0f0f0f0f0f0f;
  x = x + (x >>> 8);
  x = x + (x >>> 16);
  x = x + (x >>> 32);
  return x & 0x7f;
}
