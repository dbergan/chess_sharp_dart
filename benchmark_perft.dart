import 'package:chess_sharp_dart/chess_sharp_dart.dart';

void main() {
  final pos = Chess.initial;

  final sw4 = Stopwatch()..start();
  final nodes4 = perft(pos, 4);
  print('perft(4) = $nodes4 in ${sw4.elapsedMilliseconds}ms');

  final sw5 = Stopwatch()..start();
  final nodes5 = perft(pos, 5);
  print('perft(5) = $nodes5 in ${sw5.elapsedMilliseconds}ms');
}
