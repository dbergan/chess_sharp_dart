import 'package:chess_sharp_dart/chess_sharp_dart.dart';

void main() {
  final stopwatch = Stopwatch()..start();
  const depth = 4;
  perft(Chess.initial, depth);
  // ignore: avoid_print
  print(
    'initial position perft at depht $depth executed in ${stopwatch.elapsed.inMilliseconds} ms',
  );
}
