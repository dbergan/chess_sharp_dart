import 'package:test/test.dart';
import 'package:chess_sharp_dart/chess_sharp_dart.dart';

void main() {
  test('Log Crazyhouse move counts', () {
    const fen =
        'r1bqk2r/pppp1ppp/2n1p3/4P3/1b1Pn3/2NB1N2/PPP2PPP/R1BQK2R[] b KQkq - 0 1';
    final setup = Setup.parseFen(fen);
    final pos = Crazyhouse.fromSetup(setup);

    perft(pos, 4, shouldLog: true);
  });
}
