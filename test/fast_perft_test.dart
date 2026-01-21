import 'package:flutter_test/flutter_test.dart';
import 'package:chess_sharp_dart/src/position.dart';
import 'package:chess_sharp_dart/src/internal/mutable_position.dart';
import 'package:chess_sharp_dart/src/internal/fast_perft.dart';

void main() {
  test('fast_perft benchmark and verification', () async {
    final pos = Chess.initial;
    final mpos = MutablePosition(pos);

    final sw4 = Stopwatch()..start();
    final nodes4 = FastPerft.execute(mpos, 4);
    print('FastPerft(4) = $nodes4 in ${sw4.elapsedMilliseconds}ms');
    expect(nodes4, 197281);

    final sw5 = Stopwatch()..start();
    final nodes5 = FastPerft.execute(mpos, 5);
    print('FastPerft(5) = $nodes5 in ${sw5.elapsedMilliseconds}ms');
    expect(nodes5, 4865609);

    final sw5p = Stopwatch()..start();
    final nodes5p = await FastPerft.executeParallel(pos, 5);
    print(
      'FastPerft.executeParallel(5) = $nodes5p in ${sw5p.elapsedMilliseconds}ms',
    );
    expect(nodes5p, 4865609);
  });
}
