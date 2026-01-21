import 'lib/src/position.dart';
import 'lib/src/debug.dart';

void main() {
  final pos = Chess.initial;
  final sw = Stopwatch()..start();
  final nodes = perft(pos, 4);
  print('Perft(4) = $nodes in ${sw.elapsedMilliseconds}ms');

  final sw5 = Stopwatch()..start();
  final nodes5 = perft(pos, 5);
  print('Perft(5) = $nodes5 in ${sw5.elapsedMilliseconds}ms');
}
