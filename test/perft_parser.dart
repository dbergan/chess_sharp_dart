class Perft {
  String id;
  String fen;
  List<TestCase> cases;

  Perft(this.id, this.fen, this.cases);
}

class TestCase {
  int depth;
  int nodes;

  TestCase(this.depth, this.nodes);
}

class Parser {
  List<Perft> parse(String input) {
    final lines = input.split('\n');
    final perftBlocks = _splitBlocks(lines).map(_parsePerft);
    return perftBlocks.toList();
  }

  static Iterable<List<String>> _splitBlocks(List<String> lines) sync* {
    var block = <String>[];
    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('#')) {
        continue;
      }

      if (line.isEmpty) {
        if (block.isNotEmpty) {
          yield block;
          block = [];
        }
        continue;
      }

      block.add(line);
    }
    if (block.isNotEmpty) {
      yield block;
    }
  }

  static Perft _parsePerft(List<String> block) {
    String? id;
    String? epd;
    final cases = <TestCase>[];

    for (final line in block) {
      if (line.startsWith('id ')) {
        id = line.substring(3).trim();
      } else if (line.startsWith('epd ')) {
        epd = line.substring(4).trim();
      } else if (line.startsWith('perft ')) {
        cases.add(_parseTestCase(line));
      }
    }

    return Perft(id ?? 'unknown', epd ?? '', cases);
  }

  static TestCase _parseTestCase(String line) {
    final parts = line.trim().split(RegExp('\\s+'));
    final depth = int.parse(parts[1]);
    final nodes = int.parse(parts[2]);
    return TestCase(depth, nodes);
  }
}
