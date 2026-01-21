import 'package:chess_sharp_dart/chess_sharp_dart.dart';

void main() {
  const fen =
      'r1bqk2r/pppp1ppp/2n1p3/4P3/1b1Pn3/2NB1N2/PPP2PPP/R1BQK2R[] b KQkq - 0 1';
  final pos = Crazyhouse.fromSetup(Setup.parseFen(fen));

  perft(pos, 4, shouldLog: true);
}
