import 'package:meta/meta.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'square_set.dart';
import 'models.dart';
import 'attacks.dart';

/// A board represented by several square sets for each piece.
@immutable
class Board {
  const Board({
    required this.occupied,
    required this.promoted,
    required this.white,
    required this.black,
    required this.pawns,
    required this.knights,
    required this.bishops,
    required this.rooks,
    required this.queens,
    required this.kings,
    required this.stars,
  });

  /// All occupied squares.
  final SquareSet occupied;

  /// All squares occupied by pieces known to be promoted.
  ///
  /// This information is relevant in chess variants like [Crazyhouse].
  final SquareSet promoted;

  /// All squares occupied by white pieces.
  final SquareSet white;

  /// All squares occupied by black pieces.
  final SquareSet black;

  /// All squares occupied by pawns.
  final SquareSet pawns;

  /// All squares occupied by knights.
  final SquareSet knights;

  /// All squares occupied by bishops.
  final SquareSet bishops;

  /// All squares occupied by rooks.
  final SquareSet rooks;

  /// All squares occupied by queens.
  final SquareSet queens;

  /// All squares occupied by kings.
  final SquareSet kings;

  /// All squares occupied by stars.
  final SquareSet stars;

  /// Standard chess starting position.
  static final standard = Board(
    occupied: SquareSet.fromBigInt(BigInt.parse('ffff00000000ffff', radix: 16)),
    promoted: SquareSet.empty,
    white: SquareSet.fromBigInt(BigInt.parse('ffff', radix: 16)),
    black: SquareSet.fromBigInt(BigInt.parse('ffff000000000000', radix: 16)),
    pawns: SquareSet.fromBigInt(BigInt.parse('00ff00000000ff00', radix: 16)),
    knights: SquareSet.fromBigInt(BigInt.parse('4200000000000042', radix: 16)),
    bishops: SquareSet.fromBigInt(BigInt.parse('2400000000000024', radix: 16)),
    rooks: SquareSet.corners,
    queens: SquareSet.fromBigInt(BigInt.parse('0800000000000008', radix: 16)),
    kings: SquareSet.fromBigInt(BigInt.parse('1000000000000010', radix: 16)),
    stars: SquareSet.empty,
  );

  /// Racing Kings start position
  static final racingKings = Board(
    occupied: SquareSet.fromBigInt(BigInt.parse('ffff', radix: 16)),
    promoted: SquareSet.empty,
    white: SquareSet.fromBigInt(BigInt.parse('f0f0', radix: 16)),
    black: SquareSet.fromBigInt(BigInt.parse('0f0f', radix: 16)),
    pawns: SquareSet.empty,
    knights: SquareSet.fromBigInt(BigInt.parse('1818', radix: 16)),
    bishops: SquareSet.fromBigInt(BigInt.parse('2424', radix: 16)),
    rooks: SquareSet.fromBigInt(BigInt.parse('4242', radix: 16)),
    queens: SquareSet.fromBigInt(BigInt.parse('0081', radix: 16)),
    kings: SquareSet.fromBigInt(BigInt.parse('8100', radix: 16)),
    stars: SquareSet.empty,
  );

  /// Horde start Position
  static final horde = Board(
    occupied: SquareSet.fromBigInt(BigInt.parse('ffff0066ffffffff', radix: 16)),
    promoted: SquareSet.empty,
    white: SquareSet.fromBigInt(BigInt.parse('00000066ffffffff', radix: 16)),
    black: SquareSet.fromBigInt(BigInt.parse('ffff000000000000', radix: 16)),
    pawns: SquareSet.fromBigInt(BigInt.parse('00ff0066ffffffff', radix: 16)),
    knights: SquareSet.fromBigInt(BigInt.parse('4200000000000000', radix: 16)),
    bishops: SquareSet.fromBigInt(BigInt.parse('2400000000000000', radix: 16)),
    rooks: SquareSet.fromBigInt(BigInt.parse('8100000000000000', radix: 16)),
    queens: SquareSet.fromBigInt(BigInt.parse('0800000000000000', radix: 16)),
    kings: SquareSet.fromBigInt(BigInt.parse('1000000000000000', radix: 16)),
    stars: SquareSet.empty,
  );

  static final chessSharp = Board(
    occupied: SquareSet.fromBigInt(BigInt.parse('00ff00000000ff00', radix: 16)),
    promoted: SquareSet.empty,
    white: SquareSet.fromBigInt(BigInt.parse('000000000000ff00', radix: 16)),
    black: SquareSet.fromBigInt(BigInt.parse('00ff000000000000', radix: 16)),
    pawns: SquareSet.fromBigInt(BigInt.parse('00ff00000000ff00', radix: 16)),
    knights: SquareSet.empty,
    bishops: SquareSet.empty,
    rooks: SquareSet.empty,
    queens: SquareSet.empty,
    kings: SquareSet.empty,
    stars: SquareSet.empty,
  );

  static const catchTheStars = Board(
    occupied: SquareSet.empty,
    promoted: SquareSet.empty,
    white: SquareSet.empty,
    black: SquareSet.empty,
    pawns: SquareSet.empty,
    knights: SquareSet.empty,
    bishops: SquareSet.empty,
    rooks: SquareSet.empty,
    queens: SquareSet.empty,
    kings: SquareSet.empty,
    stars: SquareSet.empty,
  );

  /// Empty board.
  static const empty = Board(
    occupied: SquareSet.empty,
    promoted: SquareSet.empty,
    white: SquareSet.empty,
    black: SquareSet.empty,
    pawns: SquareSet.empty,
    knights: SquareSet.empty,
    bishops: SquareSet.empty,
    rooks: SquareSet.empty,
    queens: SquareSet.empty,
    kings: SquareSet.empty,
    stars: SquareSet.empty,
  );

  /// Parse the board part of a FEN string and returns a Board.
  ///
  /// Throws a [FenException] if the provided FEN string is not valid.
  factory Board.parseFen(String boardFen) {
    Board board = Board.empty;
    int rank = 7;
    int file = 0;
    for (int i = 0; i < boardFen.length; i++) {
      final c = boardFen[i];
      if (c == '/' && file == 8) {
        file = 0;
        rank--;
      } else {
        final code = c.codeUnitAt(0);
        if (code < 57) {
          file += code - 48;
        } else {
          if (file >= 8 || rank < 0) {
            throw const FenException(IllegalFenCause.board);
          }
          final square = Square(file + rank * 8);
          final promoted = i + 1 < boardFen.length && boardFen[i + 1] == '~';
          final piece = _charToPiece(c, promoted);
          if (piece == null) throw const FenException(IllegalFenCause.board);
          if (promoted) i++;
          board = board.setPieceAt(square, piece);
          file++;
        }
      }
    }
    if (rank != 0 || file != 8) throw const FenException(IllegalFenCause.board);
    return board;
  }

  /// The square set of all rooks and queens.
  SquareSet get rooksAndQueens => rooks | queens;

  /// The square set of all bishops and queens.
  SquareSet get bishopsAndQueens => bishops | queens;

  /// The square set of all pieces that aren't a bishop
  SquareSet get nonBishops => pawns | knights | rooks | queens | kings;

  /// Board part of the Forsyth-Edwards-Notation.
  String get fen {
    final buffer = StringBuffer();
    int empty = 0;
    for (int rank = 7; rank >= 0; rank--) {
      for (int file = 0; file < 8; file++) {
        final square = Square(file + rank * 8);
        final piece = pieceAt(square);
        if (piece == null) {
          empty++;
        } else {
          if (empty > 0) {
            buffer.write(empty.toString());
            empty = 0;
          }
          buffer.write(piece.fenChar);
        }

        if (file == 7) {
          if (empty > 0) {
            buffer.write(empty.toString());
            empty = 0;
          }
          if (rank != 0) buffer.write('/');
        }
      }
    }
    return buffer.toString();
  }

  /// An iterable of each [Piece] associated to its [Square].
  Iterable<(Square, Piece)> get pieces sync* {
    for (final square in occupied.squares) {
      yield (square, pieceAt(square)!);
    }
  }

  /// Gets the number of pieces of each [Role] for the given [Side].
  IMap<Role, int> materialCount(Side side) => IMap.fromEntries(
    Role.values.map((role) => MapEntry(role, piecesOf(side, role).size)),
  );

  /// A [SquareSet] of all the pieces matching this [Side] and [Role].
  SquareSet piecesOf(Side side, Role role) {
    return bySide(side) & byRole(role);
  }

  /// Gets all squares occupied by [Side].
  SquareSet bySide(Side side) => side == Side.white ? white : black;

  /// Gets all squares occupied by [Role].
  SquareSet byRole(Role role) {
    switch (role) {
      case Role.pawn:
        return pawns;
      case Role.knight:
        return knights;
      case Role.bishop:
        return bishops;
      case Role.rook:
        return rooks;
      case Role.queen:
        return queens;
      case Role.king:
        return kings;
      case Role.star:
        return stars;
    }
  }

  /// Gets all squares occupied by [Piece].
  SquareSet byPiece(Piece piece) {
    return bySide(piece.color) & byRole(piece.role);
  }

  /// Gets the [Side] at this [Square], if any.
  Side? sideAt(Square square) {
    if (bySide(Side.white).has(square)) {
      return Side.white;
    } else if (bySide(Side.black).has(square)) {
      return Side.black;
    } else {
      return null;
    }
  }

  /// Gets the [Role] at this [Square], if any.
  Role? roleAt(Square square) {
    for (final role in Role.values) {
      if (byRole(role).has(square)) {
        return role;
      }
    }
    return null;
  }

  /// Gets the [Piece] at this [Square], if any.
  Piece? pieceAt(Square square) {
    final side = sideAt(square);
    if (side == null) {
      return null;
    }
    final role = roleAt(square)!;
    final prom = promoted.has(square);
    return Piece(color: side, role: role, promoted: prom);
  }

  /// Finds the unique king [Square] of the given [Side], if any.
  Square? kingOf(Side side) {
    return byPiece(Piece(color: side, role: Role.king)).singleSquare;
  }

  /// Finds the squares who are attacking `square` by the `attacker` [Side].
  SquareSet attacksTo(Square square, Side attacker, {SquareSet? occupied}) =>
      bySide(attacker).intersect(
        rookAttacks(square, occupied ?? this.occupied)
            .intersect(rooksAndQueens)
            .union(
              bishopAttacks(
                square,
                occupied ?? this.occupied,
              ).intersect(bishopsAndQueens),
            )
            .union(knightAttacks(square).intersect(knights))
            .union(kingAttacks(square).intersect(kings))
            .union(pawnAttacks(attacker.opposite, square).intersect(pawns)),
      );

  /// Puts a [Piece] on a [Square] overriding the existing one, if any.
  Board setPieceAt(Square square, Piece piece) {
    final b = removePieceAt(square);
    return b.copyWith(
      occupied: b.occupied.withSquare(square),
      promoted: piece.promoted
          ? b.promoted.withSquare(square)
          : b.promoted.withoutSquare(square),
      white: piece.color == Side.white
          ? b.white.withSquare(square)
          : b.white.withoutSquare(square),
      black: piece.color == Side.black
          ? b.black.withSquare(square)
          : b.black.withoutSquare(square),
      pawns: piece.role == Role.pawn
          ? b.pawns.withSquare(square)
          : b.pawns.withoutSquare(square),
      knights: piece.role == Role.knight
          ? b.knights.withSquare(square)
          : b.knights.withoutSquare(square),
      bishops: piece.role == Role.bishop
          ? b.bishops.withSquare(square)
          : b.bishops.withoutSquare(square),
      rooks: piece.role == Role.rook
          ? b.rooks.withSquare(square)
          : b.rooks.withoutSquare(square),
      queens: piece.role == Role.queen
          ? b.queens.withSquare(square)
          : b.queens.withoutSquare(square),
      kings: piece.role == Role.king
          ? b.kings.withSquare(square)
          : b.kings.withoutSquare(square),
      stars: piece.role == Role.star
          ? b.stars.withSquare(square)
          : b.stars.withoutSquare(square),
    );
  }

  /// Removes the [Piece] at this [Square] if it exists.
  Board removePieceAt(Square square) {
    return copyWith(
      occupied: occupied.withoutSquare(square),
      promoted: promoted.withoutSquare(square),
      white: white.withoutSquare(square),
      black: black.withoutSquare(square),
      pawns: pawns.withoutSquare(square),
      knights: knights.withoutSquare(square),
      bishops: bishops.withoutSquare(square),
      rooks: rooks.withoutSquare(square),
      queens: queens.withoutSquare(square),
      kings: kings.withoutSquare(square),
      stars: stars.withoutSquare(square),
    );
  }

  /// Returns a new board with a new [promoted] square set.
  Board withPromoted(SquareSet promoted) {
    return copyWith(promoted: promoted);
  }

  /// Returns a copy of this board with some fields updated.
  Board copyWith({
    SquareSet? occupied,
    SquareSet? promoted,
    SquareSet? white,
    SquareSet? black,
    SquareSet? pawns,
    SquareSet? knights,
    SquareSet? bishops,
    SquareSet? rooks,
    SquareSet? queens,
    SquareSet? kings,
    SquareSet? stars,
  }) {
    return Board(
      occupied: occupied ?? this.occupied,
      promoted: promoted ?? this.promoted,
      white: white ?? this.white,
      black: black ?? this.black,
      pawns: pawns ?? this.pawns,
      knights: knights ?? this.knights,
      bishops: bishops ?? this.bishops,
      rooks: rooks ?? this.rooks,
      queens: queens ?? this.queens,
      kings: kings ?? this.kings,
      stars: stars ?? this.stars,
    );
  }

  @override
  String toString() => fen;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Board &&
            other.occupied == occupied &&
            other.promoted == promoted &&
            other.white == white &&
            other.black == black &&
            other.pawns == pawns &&
            other.knights == knights &&
            other.bishops == bishops &&
            other.rooks == rooks &&
            other.queens == queens &&
            other.kings == kings;
  }

  @override
  int get hashCode => Object.hash(
    occupied,
    promoted,
    white,
    black,
    pawns,
    knights,
    bishops,
    rooks,
    queens,
    kings,
  );
}

Piece? _charToPiece(String ch, bool promoted) {
  final role = Role.fromChar(ch);
  if (role != null) {
    return Piece(
      role: role,
      color: ch == ch.toLowerCase() ? Side.black : Side.white,
      promoted: promoted,
    );
  }
  return null;
}
