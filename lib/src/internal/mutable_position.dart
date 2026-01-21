import '../models.dart';
import '../square_set.dart';
import '../position.dart';
import '../castles.dart';

/// A mutable version of [Position] optimized for [perft] and search.
///
/// It maintains bitboards and a piece array that are updated in-place.
class MutablePosition {
  SquareSet occupied;
  SquareSet white;
  SquareSet black;
  SquareSet pawns;
  SquareSet knights;
  SquareSet bishops;
  SquareSet rooks;
  SquareSet queens;
  SquareSet kings;

  Side turn;
  SquareSet castlingRights;
  Square? epSquare;
  int halfmoves;
  int fullmoves;

  final List<Piece?> boardArray = List.filled(64, null);
  final List<UndoState> _stack = [];

  MutablePosition(Position pos)
    : occupied = pos.board.occupied,
      white = pos.board.white,
      black = pos.board.black,
      pawns = pos.board.pawns,
      knights = pos.board.knights,
      bishops = pos.board.bishops,
      rooks = pos.board.rooks,
      queens = pos.board.queens,
      kings = pos.board.kings,
      turn = pos.turn,
      castlingRights = pos.castles.castlingRights,
      epSquare = pos.epSquare,
      halfmoves = pos.halfmoves,
      fullmoves = pos.fullmoves {
    for (int i = 0; i < 64; i++) {
      boardArray[i] = pos.board.pieceAt(Square(i));
    }
  }

  void makeMove(Move move) {
    if (move is NormalMove) {
      makeNormalMove(move.from, move.to, move.promotion);
    } else if (move is DropMove) {
      _makeDropMove(move);
    }
  }

  void makeNormalMove(Square from, Square to, [Role? promotion]) {
    final piece = boardArray[from.value]!;
    final capturedPiece = boardArray[to.value];

    // 1. Detect special moves BEFORE removing any pieces
    Square? nextEpSquare;
    CastlingSide? castlingSide;
    if (piece.role == Role.pawn) {
      if ((from.value - to.value).abs() == 16) {
        nextEpSquare = Square((from.value + to.value) >>> 1);
      }
    } else if (piece.role == Role.king) {
      castlingSide = _getCastlingSideRaw(from, to, forceToPiece: capturedPiece);
    }

    // 2. Handle captured piece
    Square? capturedSquare = to;
    Piece? actualCaptured = capturedPiece;

    if (piece.role == Role.pawn && to == epSquare) {
      capturedSquare = Square(to.value + (turn == Side.white ? -8 : 8));
      actualCaptured = boardArray[capturedSquare.value];
      _stack.add(
        UndoState(
          epSquare,
          castlingRights,
          halfmoves,
          actualCaptured,
          capturedSquare,
        ),
      );
      _removePiece(capturedSquare, actualCaptured!);
    } else {
      _stack.add(
        UndoState(
          epSquare,
          castlingRights,
          halfmoves,
          capturedPiece,
          castlingSide != null ? null : to,
          castlingSide,
        ),
      );
      if (capturedPiece != null) {
        _removePiece(to, capturedPiece);
      }
    }

    // 3. Move the piece
    if (turn == Side.black) fullmoves++;
    _removePiece(from, piece);

    // 4. Update state
    if (actualCaptured != null || piece.role == Role.pawn) {
      halfmoves = 0;
    } else {
      halfmoves++;
    }

    // 5. Execute special logic
    if (castlingSide != null) {
      final rookFrom =
          (capturedPiece != null &&
              capturedPiece.role == Role.rook &&
              capturedPiece.color == turn)
          ? to
          : _getRookFrom(turn, castlingSide)!;
      final rook = (rookFrom == to)
          ? capturedPiece!
          : boardArray[rookFrom.value]!;

      if (rookFrom != to) {
        _removePiece(rookFrom, rook);
      }

      _stack.last = _stack.last.copyWith(capturedSquare: rookFrom);

      final kingTo = kingCastlesTo(turn, castlingSide);
      final rookTo = rookCastlesTo(turn, castlingSide);

      _addPiece(rookTo, rook);
      _addPiece(
        kingTo,
        promotion != null ? piece.copyWith(role: promotion) : piece,
      );

      epSquare = null;
      castlingRights = castlingRights.diff(SquareSet.backrankOf(turn));
      turn = turn.opposite;
      return;
    }

    if (capturedPiece?.role == Role.rook) {
      castlingRights = castlingRights.withoutSquare(to);
    }
    if (piece.role == Role.rook) {
      castlingRights = castlingRights.withoutSquare(from);
    } else if (piece.role == Role.king) {
      castlingRights = castlingRights.diff(SquareSet.backrankOf(turn));
    }

    final movingPiece = promotion != null
        ? piece.copyWith(role: promotion)
        : piece;
    _addPiece(to, movingPiece);
    epSquare = nextEpSquare;
    turn = turn.opposite;
  }

  void _makeDropMove(DropMove move) {
    _stack.add(UndoState(epSquare, castlingRights, halfmoves, null));
    final piece = Piece(color: turn, role: move.role);
    _addPiece(move.to, piece);
    if (move.role == Role.pawn) {
      halfmoves = 0;
    } else {
      halfmoves++;
    }
    if (turn == Side.black) fullmoves++;
    epSquare = null;
    turn = turn.opposite;
  }

  void unmakeMove(Move move) {
    if (move is NormalMove) {
      unmakeNormalMove(move.from, move.to, move.promotion);
    } else if (move is DropMove) {
      turn = turn.opposite;
      if (turn == Side.black) fullmoves--;
      final state = _stack.removeLast();
      epSquare = state.epSquare;
      castlingRights = state.castlingRights;
      halfmoves = state.halfmoves;
      _removePiece(move.to, boardArray[move.to.value]!);
    }
  }

  void unmakeNormalMove(Square from, Square to, [Role? promotion]) {
    turn = turn.opposite;
    if (turn == Side.black) fullmoves--;

    final state = _stack.removeLast();
    epSquare = state.epSquare;
    castlingRights = state.castlingRights;
    halfmoves = state.halfmoves;

    if (state.castlingSide != null) {
      final cs = state.castlingSide!;
      final kingAt = kingCastlesTo(turn, cs);
      final rookAt = rookCastlesTo(turn, cs);

      final king = boardArray[kingAt.value]!;
      final rook = boardArray[rookAt.value]!;

      _removePiece(kingAt, king);
      _removePiece(rookAt, rook);

      final rookFrom = state.capturedSquare!;
      _addPiece(
        from,
        promotion != null ? king.copyWith(role: Role.king) : king,
      );
      _addPiece(rookFrom, rook);
      return;
    }

    final movingPiece = boardArray[to.value]!;
    _removePiece(to, movingPiece);
    _addPiece(
      from,
      promotion != null ? movingPiece.copyWith(role: Role.pawn) : movingPiece,
    );

    if (state.capturedPiece != null) {
      _addPiece(state.capturedSquare ?? to, state.capturedPiece!);
    }
  }

  CastlingSide? _getCastlingSideRaw(
    Square from,
    Square to, {
    bool forceKingAtTo = false,
    Piece? forceToPiece,
  }) {
    final piece = boardArray[forceKingAtTo ? to.value : from.value];
    if (piece == null && !forceKingAtTo) {
      return null; // King might have been removed
    }

    final diff = to.value - from.value;
    if (diff == 2 || diff == -2) {
      return diff == 2 ? CastlingSide.king : CastlingSide.queen;
    }
    // Chess960: king captures own rook
    final toPiece = forceToPiece ?? boardArray[to.value];
    if (toPiece != null && toPiece.role == Role.rook && toPiece.color == turn) {
      return to.value > from.value ? CastlingSide.king : CastlingSide.queen;
    }
    return null;
  }

  Square? _getRookFrom(Side side, CastlingSide cs) {
    final rights = castlingRights.intersect(SquareSet.backrankOf(side));
    if (rights.isEmpty) return null;
    return cs == CastlingSide.queen ? rights.first : rights.last;
  }

  void _addPiece(Square sq, Piece piece) {
    boardArray[sq.value] = piece;
    final bit = SquareSet.fromSquare(sq);
    occupied = occupied | bit;
    if (piece.color == Side.white) {
      white = white | bit;
    } else {
      black = black | bit;
    }
    switch (piece.role) {
      case Role.pawn:
        pawns = pawns | bit;
      case Role.knight:
        knights = knights | bit;
      case Role.bishop:
        bishops = bishops | bit;
      case Role.rook:
        rooks = rooks | bit;
      case Role.queen:
        queens = queens | bit;
      case Role.king:
        kings = kings | bit;
      case Role.star:
        break;
    }
  }

  void _removePiece(Square sq, Piece piece) {
    boardArray[sq.value] = null;
    final bit = SquareSet.fromSquare(sq);
    occupied = occupied.diff(bit);
    if (piece.color == Side.white) {
      white = white.diff(bit);
    } else {
      black = black.diff(bit);
    }
    switch (piece.role) {
      case Role.pawn:
        pawns = pawns.diff(bit);
      case Role.knight:
        knights = knights.diff(bit);
      case Role.bishop:
        bishops = bishops.diff(bit);
      case Role.rook:
        rooks = rooks.diff(bit);
      case Role.queen:
        queens = queens.diff(bit);
      case Role.king:
        kings = kings.diff(bit);
      case Role.star:
        break;
    }
  }
}

class UndoState {
  final Square? epSquare;
  final SquareSet castlingRights;
  final int halfmoves;
  final Piece? capturedPiece;
  final Square? capturedSquare;
  final CastlingSide? castlingSide;
  const UndoState(
    this.epSquare,
    this.castlingRights,
    this.halfmoves,
    this.capturedPiece, [
    this.capturedSquare,
    this.castlingSide,
  ]);

  UndoState copyWith({
    Square? epSquare,
    SquareSet? castlingRights,
    int? halfmoves,
    Piece? capturedPiece,
    Square? capturedSquare,
    CastlingSide? castlingSide,
  }) {
    return UndoState(
      epSquare ?? this.epSquare,
      castlingRights ?? this.castlingRights,
      halfmoves ?? this.halfmoves,
      capturedPiece ?? this.capturedPiece,
      capturedSquare ?? this.capturedSquare,
      castlingSide ?? this.castlingSide,
    );
  }
}
