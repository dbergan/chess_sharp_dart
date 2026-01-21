import 'square_set.dart';
import 'models.dart';

/// Gets squares attacked or defended by a king on [Square].
SquareSet kingAttacks(Square square) {
  return _kingAttacks[square];
}

/// Gets squares attacked or defended by a knight on [Square].
SquareSet knightAttacks(Square square) {
  return _knightAttacks[square];
}

/// Gets squares attacked or defended by a pawn of the given [Side] on [Square].
SquareSet pawnAttacks(Side side, Square square) {
  return _pawnAttacks[side]![square];
}

/// Gets squares attacked or defended by a bishop on [Square], given `occupied`
/// squares.
SquareSet bishopAttacks(Square square, SquareSet occupied) {
  return _slidingAttacks(square, occupied, [-9, -7, 7, 9]);
}

/// Gets squares attacked or defended by a rook on [Square], given `occupied`
/// squares.
SquareSet rookAttacks(Square square, SquareSet occupied) {
  return _slidingAttacks(square, occupied, [-8, -1, 1, 8]);
}

/// Gets squares attacked or defended by a queen on [Square], given `occupied`
/// squares.
SquareSet queenAttacks(Square square, SquareSet occupied) =>
    bishopAttacks(square, occupied) ^ rookAttacks(square, occupied);

/// Gets squares attacked or defended by a `piece` on `square`, given
/// `occupied` squares.
SquareSet attacks(Piece piece, Square square, SquareSet occupied) {
  switch (piece.role) {
    case Role.pawn:
      return pawnAttacks(piece.color, square);
    case Role.knight:
      return knightAttacks(square);
    case Role.bishop:
      return bishopAttacks(square, occupied);
    case Role.rook:
      return rookAttacks(square, occupied);
    case Role.queen:
      return queenAttacks(square, occupied);
    case Role.king:
      return kingAttacks(square);
    case Role.star:
      return SquareSet.empty;
  }
}

/// Gets all squares of the rank, file or diagonal with the two squares
/// `a` and `b`, or an empty set if they are not aligned.
SquareSet ray(Square a, Square b) {
  final other = SquareSet.fromSquare(b);
  if (_rankRange[a].isIntersected(other)) {
    return _rankRange[a].withSquare(a);
  }
  if (_antiDiagRange[a].isIntersected(other)) {
    return _antiDiagRange[a].withSquare(a);
  }
  if (_diagRange[a].isIntersected(other)) {
    return _diagRange[a].withSquare(a);
  }
  if (_fileRange[a].isIntersected(other)) {
    return _fileRange[a].withSquare(a);
  }
  return SquareSet.empty;
}

/// Gets all squares between `a` and `b` (bounds not included), or an empty set
/// if they are not on the same rank, file or diagonal.
SquareSet between(Square a, Square b) => ray(a, b)
    .intersect(SquareSet.full.shl(a).xor(SquareSet.full.shl(b)))
    .withoutFirst();

// --

SquareSet _computeRange(Square square, List<int> deltas) {
  SquareSet range = SquareSet.empty;
  for (final delta in deltas) {
    final sq = square + delta;
    if (0 <= sq && sq < 64 && (square.file - Square(sq).file).abs() <= 2) {
      range = range.withSquare(Square(sq));
    }
  }
  return range;
}

List<T> _tabulate<T>(T Function(Square square) f) {
  final List<T> table = [];
  for (final square in Square.values) {
    table.insert(square, f(square));
  }
  return table;
}

final _kingAttacks =
    _tabulate((sq) => _computeRange(sq, [-9, -8, -7, -1, 1, 7, 8, 9]));
final _knightAttacks =
    _tabulate((sq) => _computeRange(sq, [-17, -15, -10, -6, 6, 10, 15, 17]));
final _pawnAttacks = {
  Side.white: _tabulate((sq) => _computeRange(sq, [7, 9])),
  Side.black: _tabulate((sq) => _computeRange(sq, [-7, -9])),
};

final _fileRange =
    _tabulate((sq) => SquareSet.fromFile(sq.file).withoutSquare(sq));
final _rankRange =
    _tabulate((sq) => SquareSet.fromRank(sq.rank).withoutSquare(sq));
final _diagRange = _tabulate((sq) {
  final shift = 8 * (sq.rank - sq.file);
  return (shift >= 0
          ? SquareSet.diagonal.shl(shift)
          : SquareSet.diagonal.shr(-shift))
      .withoutSquare(sq);
});
final _antiDiagRange = _tabulate((sq) {
  final shift = 8 * (sq.rank + sq.file - 7);
  return (shift >= 0
          ? SquareSet.antidiagonal.shl(shift)
          : SquareSet.antidiagonal.shr(-shift))
      .withoutSquare(sq);
});

SquareSet _slidingAttacks(Square square, SquareSet occupied, List<int> deltas) {
  var attacks = SquareSet.empty;
  for (final delta in deltas) {
    var cur = square;
    while (true) {
      final next = cur.offset(delta);
      if (next == null) break;
      attacks = attacks.withSquare(next);
      if (occupied.has(next)) break;
      cur = next;
    }
  }
  return attacks;
}
