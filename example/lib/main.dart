import 'package:chess_sharp_dart/chess_sharp_dart.dart';
import 'package:flutter/material.dart';
import 'package:chess_sharp_dart/engine/engine_base.dart'; // Adjust path to your package
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
  runApp(const EngineTestApp());
}

class EngineTestApp extends StatefulWidget {
  const EngineTestApp({super.key});

  @override
  State<EngineTestApp> createState() => _EngineTestAppState();
}

class _EngineTestAppState extends State<EngineTestApp> {
  late Sharpfish _cpu;
  late Stream<String> _broadcastStdout;
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  final _log = Logger('EngineTestApp');

  @override
  void initState() {
    super.initState();
    _cpu = SharpfishMaker.create();

    // Check if the engine wrapper provides a way to see if the process started
    _log.info('Engine Instance Created: ${_cpu.runtimeType}');
    _log.info('Engine stringState: ${_cpu.stringState}');

    _broadcastStdout = _cpu.stdout.asBroadcastStream();
    _log.info('Engine stringState: ${_cpu.stringState}');

    // 2. Main Logger
    _broadcastStdout.listen(
      (line) {
        if (mounted) {
          setState(() => _logs.add(line));
          _scrollToBottom();
        }
      },
      onError: (Object err) => setState(() => _logs.add('STREAM ERROR: $err')),
      onDone: () => setState(() => _logs.add('ENGINE PROCESS CLOSED')),
    );
  }

  Future<void> _runBenchmark() async {
    _log.info('Engine stringState: ${_cpu.stringState}');
    setState(() => _logs.add('--- Starting Benchmark ---'));
    _cpu.setVariant('chess-triple-flat');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _cpu.go(milliseconds: 2000);
    for (int i = 0; (i < 30 && (_cpu.bestMove == '')); i++) {
      // Wait for bestmove
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    _log.info('Best Move: ${_cpu.bestMove}');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _cpu.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... Your build method remains the same
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Stockfish Test')),
        body: Column(
          children: [
            Expanded(
              child: ColoredBox(
                color: Colors.black,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _logs.length,
                  itemBuilder: (context, i) => Text(
                    _logs[i],
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _runBenchmark,
              child: const Text('Run Benchmark'),
            ),
          ],
        ),
      ),
    );
  }
}
