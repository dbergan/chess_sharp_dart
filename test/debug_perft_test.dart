import 'package:test/test.dart';
import 'package:chess_sharp_dart/chess_sharp_dart.dart';
import 'package:chess_sharp_dart/src/internal/fast_perft.dart';
import 'package:chess_sharp_dart/src/internal/mutable_position.dart';

void main() {
  test('Diff moves after c1e1', () {
    const fen = 'r1k1r2q/p1ppp1pp/8/8/8/8/P1PPP1PP/R1K1R2Q w KQkq - 4';
    final setup = Setup.parseFen(fen);
    final pos = Chess.fromSetup(setup);
    final mpos = MutablePosition(pos);

    // White castles king-side
    mpos.makeNormalMove(Square.c1, Square.e1);
    final posAfter = pos.play(const NormalMove(from: Square.c1, to: Square.e1));

    final baselineMoves = posAfter.legalMovesList.map((m) => m.uci).toSet();

    // Get FastPerft moves
    final fastMoves = <String>{};
    final us = mpos.bySide(mpos.turn);
    var actors = us;
    while (actors.isNotEmpty) {
      final from = actors.first!;
      final piece = mpos.boardArray[from.value]!;
      for (int i = 0; i < 64; i++) {
        final to = Square(i);
        if (isFastLegal(mpos, from, to)) {
          if (piece.role == Role.pawn &&
              (to.rank == Rank.first || to.rank == Rank.eighth)) {
            for (final p in ['q', 'r', 'b', 'n']) {
              fastMoves.add('${from.name}${to.name}$p');
            }
          } else {
            fastMoves.add('${from.name}${to.name}');
          }
        }
      }
      actors = actors.withoutFirst();
    }

    // Castling
    if (mpos.kings.intersect(us).isNotEmpty) {
      final kingSq = mpos.kings.intersect(us).first!;
      final rights = mpos.castlingRights.intersect(
        SquareSet.backrankOf(mpos.turn),
      );
      for (final rookSq in rights.squares) {
        final cs = rookSq.value < kingSq.value
            ? CastlingSide.queen
            : CastlingSide.king;
        if (FastPerft.canCastle(mpos, mpos.turn, cs, kingSq, rookSq)) {
          fastMoves.add('${kingSq.name}${rookSq.name}');
          // Also add king-to-king notation if applicable to match baseline
          final kingTo = kingCastlesTo(mpos.turn, cs);
          if (kingSq != kingTo) {
            fastMoves.add('${kingSq.name}${kingTo.name}');
          }
        }
      }
    }

    final extra = fastMoves.difference(baselineMoves);
    final missing = baselineMoves.difference(fastMoves);

    if (extra.isNotEmpty) {
      print('EXTRA IN FAST: $extra');
    }
    if (missing.isNotEmpty) {
      print('MISSING IN FAST: $missing');
    }

    expect(extra, isEmpty, reason: 'Extra moves found in FastPerft');
    expect(missing, isEmpty, reason: 'Missing moves found in FastPerft');
  });
}

bool isFastLegal(MutablePosition mpos, Square from, Square to) {
  final piece = mpos.boardArray[from.value];
  if (piece == null || piece.color != mpos.turn) return false;
  if (from == to) return false; // Normal moves must move
  if (mpos.bySide(mpos.turn).has(to)) return false;

  final role = piece.role;
  if (role == Role.pawn) {
    final diff = mpos.turn == Side.white ? 8 : -8;
    final forward = from.value + diff;
    if (to.value == forward) {
      if (mpos.occupied.has(to)) return false;
    } else if (to.value == forward + diff) {
      final startRank = mpos.turn == Side.white ? Rank.second : Rank.seventh;
      if (from.rank != startRank) return false;
      if (mpos.occupied.has(Square(forward)) || mpos.occupied.has(to)) {
        return false;
      }
    } else {
      if (!pawnAttacks(mpos.turn, from).has(to)) return false;
      if (!mpos.bySide(mpos.turn.opposite).has(to) && to != mpos.epSquare) {
        return false;
      }
    }
  } else if (role == Role.king) {
    if (!kingAttacks(from).has(to)) return false;
  } else {
    final targets = switch (role) {
      Role.knight => knightAttacks(from),
      Role.bishop => bishopAttacks(from, mpos.occupied),
      Role.rook => rookAttacks(from, mpos.occupied),
      Role.queen => queenAttacks(from, mpos.occupied),
      _ => SquareSet.empty,
    };
    if (!targets.has(to)) return false;
  }

  mpos.makeNormalMove(from, to);
  final kingSq = mpos.kings.intersect(mpos.bySide(mpos.turn.opposite)).first;
  bool legal = true;
  if (kingSq != null) {
    if (FastPerft.getAttackers(mpos, kingSq, mpos.turn).isNotEmpty) {
      legal = false;
    }
  }
  mpos.unmakeNormalMove(from, to);
  return legal;
}
