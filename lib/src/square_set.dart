import 'models.dart';

/// A finite set of all squares on a chessboard.
///
/// All the squares are represented by a single 64-bit integer (BigInt on web),
/// where each bit corresponds to a square, using a little-endian rank-file mapping.
/// See also [Square].
///
/// The set operations are implemented as bitwise operations on the integer.
extension type const SquareSet(BigInt value) {
  /// Creates a [SquareSet] with a single [Square].
  SquareSet.fromSquare(Square square) : value = BigInt.one << square;

  /// Creates a [SquareSet] from several [Square]s.
  SquareSet.fromSquares(Iterable<Square> squares)
      : value = squares
            .map((square) => BigInt.one << square)
            .fold(BigInt.zero, (left, right) => left | right);

  /// Create a [SquareSet] containing all squares of the given rank.
  SquareSet.fromRank(Rank rank)
      : value = BigInt.parse('ff', radix: 16) << (8 * rank),
        assert(rank >= 0 && rank < 8);

  /// Create a [SquareSet] containing all squares of the given file.
  SquareSet.fromFile(File file)
      : value = BigInt.parse('0101010101010101', radix: 16) << file,
        assert(file >= 0 && file < 8);

  /// Create a [SquareSet] containing all squares of the given backrank [Side].
  SquareSet.backrankOf(Side side)
      : value = side == Side.white
            ? BigInt.parse('ff', radix: 16)
            : BigInt.parse('ff00000000000000', radix: 16);

  static final empty = SquareSet(BigInt.zero);
  static final full = SquareSet(BigInt.parse('ffffffffffffffff', radix: 16));
  static final lightSquares =
      SquareSet(BigInt.parse('55AA55AA55AA55AA', radix: 16));
  static final darkSquares =
      SquareSet(BigInt.parse('AA55AA55AA55AA55', radix: 16));
  static final diagonal =
      SquareSet(BigInt.parse('8040201008040201', radix: 16));
  static final antidiagonal =
      SquareSet(BigInt.parse('0102040810204080', radix: 16));
  static final corners = SquareSet(BigInt.parse('8100000000000081', radix: 16));
  static final center = SquareSet(BigInt.parse('0000001818000000', radix: 16));
  static final backranks =
      SquareSet(BigInt.parse('ff000000000000ff', radix: 16));
  static final firstRank = SquareSet(BigInt.parse('ff', radix: 16));
  static final eighthRank =
      SquareSet(BigInt.parse('ff00000000000000', radix: 16));
  static final aFile = SquareSet(BigInt.parse('0101010101010101', radix: 16));
  static final hFile = SquareSet(BigInt.parse('8080808080808080', radix: 16));
  static final ranksThreeToEight =
      SquareSet(BigInt.parse('ffffffffff0000', radix: 16));
  static final ranksOneToSix =
      SquareSet(BigInt.parse('ffffffffffff', radix: 16));

  /// Bitwise right shift
  SquareSet shr(int shift) {
    if (shift >= 64) return SquareSet.empty;
    if (shift > 0) return SquareSet(value >> shift);
    return this;
  }

  /// Bitwise left shift
  SquareSet shl(int shift) {
    if (shift >= 64) return SquareSet.empty;
    if (shift > 0) return SquareSet((value << shift) & full.value);
    return this;
  }

  /// Returns a new [SquareSet] with a bitwise XOR of this set and [other].
  SquareSet xor(SquareSet other) => SquareSet(value ^ other.value);
  SquareSet operator ^(SquareSet other) => SquareSet(value ^ other.value);

  /// Returns a new [SquareSet] with the squares that are in either this set or [other].
  SquareSet union(SquareSet other) => SquareSet(value | other.value);
  SquareSet operator |(SquareSet other) => SquareSet(value | other.value);

  /// Returns a new [SquareSet] with the squares that are in both this set and [other].
  SquareSet intersect(SquareSet other) => SquareSet(value & other.value);
  SquareSet operator &(SquareSet other) => SquareSet(value & other.value);

  /// Returns a new [SquareSet] with the [other] squares removed from this set.
  SquareSet minus(SquareSet other) => SquareSet(value & ~other.value);
  SquareSet operator -(SquareSet other) => SquareSet(value & ~other.value);

  /// Returns the set complement of this set.
  SquareSet complement() => SquareSet((~value) & full.value);

  /// Returns the set difference of this set and [other].
  SquareSet diff(SquareSet other) => SquareSet(value & ~other.value);

  /// Flips the set vertically.
  SquareSet flipVertical() {
    final k1 = BigInt.parse('00FF00FF00FF00FF', radix: 16);
    final k2 = BigInt.parse('0000FFFF0000FFFF', radix: 16);
    var x = ((value >> 8) & k1) | ((value & k1) << 8);
    x = ((x >> 16) & k2) | ((x & k2) << 16);
    x = (x >> 32) | (x << 32);
    return SquareSet(x & full.value);
  }

  /// Flips the set horizontally.
  SquareSet mirrorHorizontal() {
    final k1 = BigInt.parse('5555555555555555', radix: 16);
    final k2 = BigInt.parse('3333333333333333', radix: 16);
    final k4 = BigInt.parse('0f0f0f0f0f0f0f0f', radix: 16);
    var x = ((value >> 1) & k1) | ((value & k1) << 1);
    x = ((x >> 2) & k2) | ((x & k2) << 2);
    x = ((x >> 4) & k4) | ((x & k4) << 4);
    return SquareSet(x & full.value);
  }

  /// Returns the number of squares in the set.
  int get size => _popcnt64(value);

  /// Returns true if the set is empty.
  bool get isEmpty => value == BigInt.zero;

  /// Returns true if the set is not empty.
  bool get isNotEmpty => value != BigInt.zero;

  /// Returns the first square in the set, or null if the set is empty.
  Square? get first => _getFirstSquare(value);

  /// Returns the last square in the set, or null if the set is empty.
  Square? get last => _getLastSquare(value);

  /// Returns the squares in the set as an iterable.
  Iterable<Square> get squares => _iterateSquares();

  /// Returns the squares in the set as an iterable in reverse order.
  Iterable<Square> get squaresReversed => _iterateSquaresReversed();

  /// Returns true if the set contains more than one square.
  bool get moreThanOne => isNotEmpty && size > 1;

  /// Returns square if it is single, otherwise returns null.
  Square? get singleSquare => moreThanOne ? null : last;

  /// Returns true if the [SquareSet] contains the given [square].
  bool has(Square square) {
    return (value & (BigInt.one << square)) != BigInt.zero;
  }

  /// Returns true if the square set has any square in the [other] square set.
  bool isIntersected(SquareSet other) => intersect(other).isNotEmpty;

  /// Returns true if the square set is disjoint from the [other] square set.
  bool isDisjoint(SquareSet other) => intersect(other).isEmpty;

  /// Returns a new [SquareSet] with the given [square] added.
  SquareSet withSquare(Square square) {
    return SquareSet(value | (BigInt.one << square));
  }

  /// Returns a new [SquareSet] with the given [square] removed.
  SquareSet withoutSquare(Square square) {
    return SquareSet(value & ~(BigInt.one << square));
  }

  /// Removes [Square] if present, or put it if absent.
  SquareSet toggleSquare(Square square) {
    return SquareSet(value ^ (BigInt.one << square));
  }

  /// Returns a new [SquareSet] with its first [Square] removed.
  SquareSet withoutFirst() {
    final f = first;
    return f != null ? withoutSquare(f) : empty;
  }

  /// Returns the hexadecimal string representation of the bitboard value.
  String toHexString() {
    if (value == BigInt.zero) return '0';
    return '0x${value.toRadixString(16).toUpperCase().padLeft(16, '0')}';
  }

  Iterable<Square> _iterateSquares() sync* {
    var bitboard = value;
    while (bitboard != BigInt.zero) {
      final square = _getFirstSquare(bitboard);
      bitboard ^= BigInt.one << square!;
      yield square;
    }
  }

  Iterable<Square> _iterateSquaresReversed() sync* {
    var bitboard = value;
    while (bitboard != BigInt.zero) {
      final square = _getLastSquare(bitboard);
      bitboard ^= BigInt.one << square!;
      yield square;
    }
  }

  Square? _getFirstSquare(BigInt bitboard) {
    final ntz = _ntz64(bitboard);
    return ntz >= 0 && ntz < 64 ? Square(ntz) : null;
  }

  Square? _getLastSquare(BigInt bitboard) {
    if (bitboard == BigInt.zero) return null;
    return Square(63 - _nlz64(bitboard));
  }
}

int _popcnt64(BigInt n) {
  var x = n & BigInt.parse('FFFFFFFFFFFFFFFF', radix: 16);
  var count = 0;
  while (x != BigInt.zero) {
    x = x & (x - BigInt.one);
    count++;
  }
  return count;
}

int _nlz64(BigInt x) {
  var r = x;
  r |= r >> 1;
  r |= r >> 2;
  r |= r >> 4;
  r |= r >> 8;
  r |= r >> 16;
  r |= r >> 32;
  return 64 - _popcnt64(r);
}

int _ntz64(BigInt x) {
  if (x == BigInt.zero) return 64;
  // Simple, reliable trailing-zero count for BigInt within 64 bits.
  var v = x;
  var count = 0;
  while ((v & BigInt.one) == BigInt.zero) {
    count++;
    v = v >> 1;
  }
  return count;
}
