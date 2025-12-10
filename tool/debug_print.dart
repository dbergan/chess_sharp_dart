import 'package:chess_sharp_dart/chess_sharp_dart.dart';

void main() {
  print('SquareSet.corners: ${SquareSet.corners.toHexString()}');
  print(
      'SquareSet.backrankOf(white): ${SquareSet.backrankOf(Side.white).toHexString()}');
  print(
      'SquareSet.backrankOf(black): ${SquareSet.backrankOf(Side.black).toHexString()}');
  print('Board.standard.rooks: ${Board.standard.rooks.toHexString()}');
  print('Board.standard.kings: ${Board.standard.kings.toHexString()}');
  // Trace parse without using Setup.parseFen to avoid immediate exception.
  traceParseCastling(Board.standard, 'KQkq');
  traceAttacks();
  _compareBishopPattern();
  // Now run the real parser to show the exception as well.
  try {
    final setup = Setup.parseFen(
        'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
    print('Parsed castling rights: ${setup.castlingRights.toHexString()}');
    print(
        'Setup.standard.castlingRights: ${Setup.standard.castlingRights.toHexString()}');
  } catch (e) {
    print('Setup.parseFen threw: $e');
    rethrow;
  }
}

// Reproduce parse logic step by step for debugging
void traceParseCastling(Board board, String castlingPart) {
  var castlingRights = SquareSet.empty;
  print('Trace parse for: $castlingPart');
  for (final rune in castlingPart.runes) {
    final c = String.fromCharCode(rune);
    final lower = c.toLowerCase();
    final side = c == lower ? Side.black : Side.white;
    final rank = side == Side.white ? Rank.first : Rank.eighth;
    print('char: $c side: $side rank: $rank');
    if ('a'.codeUnitAt(0) <= lower.codeUnitAt(0) &&
        lower.codeUnitAt(0) <= 'h'.codeUnitAt(0)) {
      final file = File.fromName(lower);
      castlingRights = castlingRights.withSquare(Square.fromCoords(file, rank));
      print(' added file notation: ${castlingRights.toHexString()}');
    } else if (lower == 'k' || lower == 'q') {
      final rooksAndKings = (board.bySide(side) & SquareSet.backrankOf(side)) &
          (board.rooks | board.kings);
      print(' rooksAndKings: ${rooksAndKings.toHexString()}');
      final candidate = lower == 'k'
          ? rooksAndKings.squares.lastOrNull
          : rooksAndKings.squares.firstOrNull;
      print(' candidate: ${candidate?.name ?? 'null'}');
      final chosen = candidate != null && board.rooks.has(candidate)
          ? candidate
          : Square.fromCoords(lower == 'k' ? File.h : File.a, rank);
      castlingRights = castlingRights.withSquare(chosen);
      print(' added: ${chosen.name} -> ${castlingRights.toHexString()}');
    } else {
      print(' invalid character: $c');
      throw const FenException(IllegalFenCause.castling);
    }
  }
  for (final color in Side.values) {
    final cnt = SquareSet.backrankOf(color).intersect(castlingRights).size;
    print(' color $color count on backrank: $cnt');
    if (cnt > 2) {
      throw const FenException(IllegalFenCause.castling);
    }
  }
  print('final rights: ${castlingRights.toHexString()}');
}

void traceAttacks() {
  print(
      'Bishop attacks d4 empty: ${bishopAttacks(Square.d4, SquareSet.empty).toHexString()}');
  print(
      'Rook attacks d4 empty: ${rookAttacks(Square.d4, SquareSet.empty).toHexString()}');
  print(
      'Queen attacks d4 empty: ${queenAttacks(Square.d4, SquareSet.empty).toHexString()}');
  // internal ranges are library-private; using public attack functions above
  // Inspect computeRange logic for king-like deltas
  const square = Square.d4;
  final deltas = [-9, -8, -7, -1, 1, 7, 8, 9];
  for (final delta in deltas) {
    final sq = square + delta;
    print('delta $delta -> sq: $sq, inBounds: ${0 <= sq && sq < 64}');
    if (0 <= sq && sq < 64) {
      final sqFile = Square(sq).file;
      final fileDiff = (square.file - sqFile).abs();
      print(
          ' square.file: ${square.file}, sq.file: $sqFile, fileDiff: $fileDiff');
    }
  }
}

SquareSet _parseAsciiSquareSet(String rep) {
  final lines = rep.trim().split('\n').map((l) => l.trim()).toList();
  SquareSet set = SquareSet.empty;
  for (var i = 0; i < lines.length; i++) {
    final rankIndex = lines.length - 1 - i; // bottom line is rank 1
    final parts = lines[i].split(RegExp(r'\s+'));
    for (var file = 0; file < parts.length; file++) {
      if (parts[file] == '1') {
        final sq = Square.fromCoords(File(file), Rank(rankIndex));
        set = set.withSquare(sq);
      }
    }
  }
  return set;
}

void _compareBishopPattern() {
  const pattern = '''
. . . . . . . 1
1 . . . . . 1 .
. 1 . . . 1 . .
. . 1 . 1 . . .
. . . . . . . .
. . 1 . 1 . . .
. 1 . . . 1 . .
1 . . . . . 1 .
''';
  final expected = _parseAsciiSquareSet(pattern);
  final actual = bishopAttacks(Square.d4, SquareSet.empty);
  print('expected bishop d4: ${expected.toHexString()}');
  print('actual   bishop d4: ${actual.toHexString()}');
}
