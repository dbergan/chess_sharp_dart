import 'dart:async';
import 'package:chess_sharp_dart/chess_sharp_dart.dart';
import 'package:chess_sharp_dart/engine/engine_base.dart';
import 'package:test/test.dart';

void main() {
  group('ChessSharpEngine', () {
    Sharpfish? cpu;

    setUp(() async {
      cpu = SharpfishMaker.create();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });

    tearDown(() {
      cpu?.dispose();
    });

    test('can create/dispose engine', () async {
      final e = SharpfishMaker.create();
      print('Created engine of type: ${e.runtimeType}');
      print('Engine stringState: ${e.stringState}');
      for (
        int i = 0;
        (i < 100 &&
            e.state.value != SharpfishState.ready &&
            e.state.value != SharpfishState.error);
        i++
      ) {
        // Wait for engine to initialize
        await Future<void>.delayed(const Duration(milliseconds: 100));
        print(i.toString().padLeft(3, '0'));
        print('Engine stringState: ${e.stringState}');
      }
      expect(e, isNotNull);
      e.dispose();
      print('Disposed engine successfully');
    });

    test('setVariant—chess-sharp', () async {
      cpu?.setVariant('chess-sharp');
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      expect(cpu?.variant, 'chess-sharp');
    });

    test('setVariant—chess-triple-flat', () async {
      cpu?.setVariant('chess-triple-flat');
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      expect(cpu?.variant, 'chess-triple-flat');
    });

    test('chess-triple-flat—find bestmove', () async {
      cpu?.setVariant('chess-triple-flat');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(cpu?.variant, 'chess-triple-flat');
      cpu?.go(milliseconds: 2000);
      for (int i = 0; (i < 30 && (cpu?.bestMove == '')); i++) {
        // Wait for bestmove
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      print('Best Move: ${cpu?.bestMove}');
      expect(cpu?.bestMove, isNotEmpty);
    });
  });
}
