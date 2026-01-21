import 'dart:async';
import 'dart:isolate';
import '../models.dart';
import '../square_set.dart';
import '../attacks.dart';
import '../castles.dart';
import '../position.dart';
import 'mutable_position.dart';

abstract class FastPerft {
  FastPerft._();

  static int execute(MutablePosition mpos, int depth) {
    return _perft(mpos, depth);
  }

  static Future<int> executeParallel(Position pos, int depth) async {
    if (depth <= 4) {
      return execute(MutablePosition(pos), depth);
    }

    final mpos = MutablePosition(pos);
    final turn = mpos.turn;
    final us = mpos.bySide(turn);
    final them = turn.opposite;
    final kingSq = mpos.kings.intersect(us).first;
    if (kingSq == null) return 0;

    final checkers = getAttackers(mpos, kingSq, them);
    final blockers = getSliderBlockers(mpos, kingSq, turn);

    final moves = <(Square, Square, Role?)>[];
    var actors = us;
    while (actors.isNotEmpty) {
      final from = actors.first!;
      final piece = mpos.boardArray[from.value]!;
      SquareSet targets;
      if (piece.role == Role.pawn) {
        targets = _generatePawnMoves(
          mpos,
          from,
          turn,
          checkers,
          blockers,
          kingSq,
        );
      } else if (piece.role == Role.king) {
        targets = _generateKingMoves(mpos, from, turn, checkers);
      } else {
        if (checkers.moreThanOne) {
          actors = actors.withoutFirst();
          continue;
        }
        targets = _generatePieceMoves(mpos, from, piece.role, turn);
        if (checkers.isNotEmpty) {
          final checkerSq = checkers.first!;
          targets &= between(checkerSq, kingSq).withSquare(checkerSq);
        }
        if (blockers.has(from)) targets &= ray(from, kingSq);
      }

      while (targets.isNotEmpty) {
        final to = targets.first!;
        if (piece.role == Role.pawn &&
            (to.rank == Rank.first || to.rank == Rank.eighth)) {
          for (final prom in const [
            Role.queen,
            Role.rook,
            Role.bishop,
            Role.knight,
          ]) {
            moves.add((from, to, prom));
          }
        } else {
          moves.add((from, to, null));
        }
        targets = targets.withoutFirst();
      }
      actors = actors.withoutFirst();
    }

    if (checkers.isEmpty) {
      var rights = mpos.castlingRights.intersect(SquareSet.backrankOf(turn));
      while (rights.isNotEmpty) {
        final rookSq = rights.first!;
        final cs = rookSq.value < kingSq.value
            ? CastlingSide.queen
            : CastlingSide.king;
        if (canCastle(mpos, turn, cs, kingSq, rookSq)) {
          moves.add((kingSq, rookSq, null));
        }
        rights = rights.withoutFirst();
      }
    }

    if (moves.isEmpty) return 0;

    final results = await Future.wait<int>(
      moves.map(
        (move) => Isolate.run<int>(() => _perftFromMove(pos, depth - 1, move)),
      ),
    );
    return results.fold<int>(0, (sum, count) => sum + count);
  }

  static int _perftFromMove(
    Position pos,
    int depth,
    (Square, Square, Role?) move,
  ) {
    final mpos = MutablePosition(pos);
    mpos.makeNormalMove(move.$1, move.$2, move.$3);
    return _perft(mpos, depth);
  }

  static int _perft(MutablePosition mpos, int depth) {
    if (depth == 0) return 1;

    final turn = mpos.turn;
    final us = mpos.bySide(turn);
    final them = turn.opposite;
    final kingSq = mpos.kings.intersect(us).first;
    if (kingSq == null) return 0;

    final checkers = getAttackers(mpos, kingSq, them);
    final blockers = getSliderBlockers(mpos, kingSq, turn);

    if (depth == 1) {
      int count = 0;
      var actors = us;
      while (actors.isNotEmpty) {
        final from = actors.first!;
        final piece = mpos.boardArray[from.value]!;
        SquareSet targets;
        if (piece.role == Role.pawn) {
          targets = _generatePawnMoves(
            mpos,
            from,
            turn,
            checkers,
            blockers,
            kingSq,
          );
          final backrank = SquareSet.backrankOf(them);
          count += targets.size + targets.intersect(backrank).size * 3;
        } else if (piece.role == Role.king) {
          targets = _generateKingMoves(mpos, from, turn, checkers);
          count += targets.size;
        } else {
          if (checkers.moreThanOne) {
            actors = actors.withoutFirst();
            continue;
          }
          targets = _generatePieceMoves(mpos, from, piece.role, turn);
          if (checkers.isNotEmpty) {
            final checkerSq = checkers.first!;
            targets &= between(checkerSq, kingSq).withSquare(checkerSq);
          }
          if (blockers.has(from)) targets &= ray(from, kingSq);
          count += targets.size;
        }
        actors = actors.withoutFirst();
      }
      if (checkers.isEmpty) {
        var rights = mpos.castlingRights.intersect(SquareSet.backrankOf(turn));
        while (rights.isNotEmpty) {
          final rookSq = rights.first!;
          final cs = rookSq.value < kingSq.value
              ? CastlingSide.queen
              : CastlingSide.king;
          if (canCastle(mpos, turn, cs, kingSq, rookSq)) count++;
          rights = rights.withoutFirst();
        }
      }
      return count;
    }

    int nodes = 0;
    var actors = us;
    while (actors.isNotEmpty) {
      final from = actors.first!;
      final piece = mpos.boardArray[from.value]!;
      SquareSet targets;

      if (piece.role == Role.pawn) {
        targets = _generatePawnMoves(
          mpos,
          from,
          turn,
          checkers,
          blockers,
          kingSq,
        );
      } else if (piece.role == Role.king) {
        targets = _generateKingMoves(mpos, from, turn, checkers);
      } else {
        if (checkers.moreThanOne) {
          actors = actors.withoutFirst();
          continue;
        }
        targets = _generatePieceMoves(mpos, from, piece.role, turn);
        if (checkers.isNotEmpty) {
          final checkerSq = checkers.first!;
          targets &= between(checkerSq, kingSq).withSquare(checkerSq);
        }
        if (blockers.has(from)) targets &= ray(from, kingSq);
      }

      while (targets.isNotEmpty) {
        final to = targets.first!;
        if (piece.role == Role.pawn &&
            (to.rank == Rank.first || to.rank == Rank.eighth)) {
          for (final prom in const [
            Role.queen,
            Role.rook,
            Role.bishop,
            Role.knight,
          ]) {
            mpos.makeNormalMove(from, to, prom);
            nodes += _perft(mpos, depth - 1);
            mpos.unmakeNormalMove(from, to, prom);
          }
        } else {
          mpos.makeNormalMove(from, to);
          nodes += _perft(mpos, depth - 1);
          mpos.unmakeNormalMove(from, to);
        }
        targets = targets.withoutFirst();
      }
      actors = actors.withoutFirst();
    }

    if (checkers.isEmpty) {
      var rights = mpos.castlingRights.intersect(SquareSet.backrankOf(turn));
      while (rights.isNotEmpty) {
        final rookSq = rights.first!;
        final cs = rookSq.value < kingSq.value
            ? CastlingSide.queen
            : CastlingSide.king;
        if (canCastle(mpos, turn, cs, kingSq, rookSq)) {
          mpos.makeNormalMove(kingSq, rookSq);
          nodes += _perft(mpos, depth - 1);
          mpos.unmakeNormalMove(kingSq, rookSq);
        }
        rights = rights.withoutFirst();
      }
    }
    return nodes;
  }

  static SquareSet _generatePawnMoves(
    MutablePosition mpos,
    Square from,
    Side turn,
    SquareSet checkers,
    SquareSet blockers,
    Square kingSq,
  ) {
    if (checkers.moreThanOne) return SquareSet.empty;

    final them = turn.opposite;
    final diff = turn == Side.white ? 8 : -8;
    SquareSet targets = SquareSet.empty;

    // Captures
    targets |= pawnAttacks(turn, from).intersect(mpos.bySide(them));

    // Single step
    final step = from.value + diff;
    if (0 <= step && step < 64 && mpos.boardArray[step] == null) {
      targets |= SquareSet.fromSquare(Square(step));
      // Double step
      final canDouble = turn == Side.white
          ? from.rank == Rank.second
          : from.rank == Rank.seventh;
      final step2 = step + diff;
      if (canDouble && mpos.boardArray[step2] == null) {
        targets |= SquareSet.fromSquare(Square(step2));
      }
    }

    if (checkers.isNotEmpty) {
      final checkerSq = checkers.first!;
      targets &= between(checkerSq, kingSq).withSquare(checkerSq);
    }

    if (blockers.has(from)) {
      targets &= ray(from, kingSq);
    }

    if (mpos.epSquare != null && pawnAttacks(turn, from).has(mpos.epSquare!)) {
      if (_isEpLegal(mpos, from, mpos.epSquare!, kingSq)) {
        targets |= SquareSet.fromSquare(mpos.epSquare!);
      }
    }

    return targets;
  }

  static bool _isEpLegal(
    MutablePosition mpos,
    Square from,
    Square to,
    Square kingSq,
  ) {
    final epTarget = Square(to.value + (mpos.turn == Side.white ? -8 : 8));
    final occ = mpos.occupied
        .withoutSquare(from)
        .withoutSquare(epTarget)
        .withSquare(to);
    return getAttackers(
      mpos,
      kingSq,
      mpos.turn.opposite,
      occupied: occ,
    ).isEmpty;
  }

  static SquareSet _generateKingMoves(
    MutablePosition mpos,
    Square from,
    Side turn,
    SquareSet checkers,
  ) {
    SquareSet targets = kingAttacks(from).diff(mpos.bySide(turn));
    if (targets.isEmpty) return SquareSet.empty;
    final occ = mpos.occupied.withoutSquare(from);
    SquareSet safe = SquareSet.empty;
    while (targets.isNotEmpty) {
      final to = targets.first!;
      if (getAttackers(mpos, to, turn.opposite, occupied: occ).isEmpty) {
        safe = safe.withSquare(to);
      }
      targets = targets.withoutFirst();
    }
    return safe;
  }

  static SquareSet _generatePieceMoves(
    MutablePosition mpos,
    Square from,
    Role role,
    Side turn,
  ) {
    SquareSet targets;
    switch (role) {
      case Role.knight:
        targets = knightAttacks(from);
      case Role.bishop:
        targets = bishopAttacks(from, mpos.occupied);
      case Role.rook:
        targets = rookAttacks(from, mpos.occupied);
      case Role.queen:
        targets = queenAttacks(from, mpos.occupied);
      default:
        return SquareSet.empty;
    }
    return targets.diff(mpos.bySide(turn));
  }

  static bool canCastle(
    MutablePosition mpos,
    Side turn,
    CastlingSide side,
    Square kingSq,
    Square rookSq,
  ) {
    final kingTo = kingCastlesTo(turn, side);
    final rookTo = rookCastlesTo(turn, side);
    final path = between(kingSq, kingTo)
        .withSquare(kingTo)
        .union(between(rookSq, rookTo).withSquare(rookTo))
        .withoutSquare(kingSq)
        .withoutSquare(rookSq);
    if (path
        .intersect(mpos.occupied.withoutSquare(kingSq).withoutSquare(rookSq))
        .isNotEmpty) {
      return false;
    }
    var kingPath = between(kingSq, kingTo);
    while (kingPath.isNotEmpty) {
      final sq = kingPath.first!;
      final attackers = getAttackers(mpos, sq, turn.opposite);
      if (attackers.isNotEmpty) {
        return false;
      }
      kingPath = kingPath.withoutFirst();
    }

    // Check legality of the final position (King destination safe?)
    final afterOcc = mpos.occupied
        .withoutSquare(kingSq)
        .withoutSquare(rookSq)
        .withSquare(rookTo);

    if (getAttackers(
      mpos,
      kingTo,
      turn.opposite,
      occupied: afterOcc,
    ).isNotEmpty) {
      return false;
    }
    return true;
  }

  static SquareSet getAttackers(
    MutablePosition mpos,
    Square sq,
    Side attackerSide, {
    SquareSet? occupied,
  }) {
    final occ = (occupied ?? mpos.occupied).withoutSquare(sq);
    final attackers = mpos.bySide(attackerSide).intersect(occ);
    final res = attackers.intersect(
      rookAttacks(sq, occ)
          .intersect(mpos.rooks | mpos.queens)
          .union(bishopAttacks(sq, occ).intersect(mpos.bishops | mpos.queens))
          .union(knightAttacks(sq).intersect(mpos.knights))
          .union(pawnAttacks(attackerSide.opposite, sq).intersect(mpos.pawns))
          .union(kingAttacks(sq).intersect(mpos.kings)),
    );
    return res;
  }

  static SquareSet getSliderBlockers(
    MutablePosition mpos,
    Square kingSq,
    Side turn,
  ) {
    var snipers = rookAttacks(kingSq, SquareSet.empty)
        .intersect(mpos.rooks | mpos.queens)
        .union(
          bishopAttacks(
            kingSq,
            SquareSet.empty,
          ).intersect(mpos.bishops | mpos.queens),
        )
        .intersect(mpos.bySide(turn.opposite));
    SquareSet blockers = SquareSet.empty;
    while (snipers.isNotEmpty) {
      final sniperSq = snipers.first!;
      final b = between(kingSq, sniperSq).intersect(mpos.occupied);
      if (b.size == 1 && b.intersect(mpos.bySide(turn)).isNotEmpty) {
        blockers = blockers.union(b);
      }
      snipers = snipers.withoutFirst();
    }
    return blockers;
  }
}

extension FastPerftMutablePosition on MutablePosition {
  SquareSet bySide(Side s) => s == Side.white ? white : black;
}
