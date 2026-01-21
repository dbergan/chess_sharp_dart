import 'dart:io';

void main() {
  final file = File('lib/src/position.dart');
  var content = file.readAsStringSync();

  const target = '''
      case DropMove(to: final to, role: final role):
        return copyWith(
          halfmoves: role == Role.pawn ? 0 : halfmoves + 1,
          fullmoves: turn == Side.black ? fullmoves + 1 : fullmoves,
          turn: turn.opposite,
          board: board.setPieceAt(to, Piece(color: turn, role: role)),
          pockets: pockets?.decrement(turn, role),
        );''';

  const replacement = '''
      case DropMove(to: final to, role: final role):
        return copyWith(
          halfmoves: role == Role.pawn ? 0 : halfmoves + 1,
          fullmoves: turn == Side.black ? fullmoves + 1 : fullmoves,
          turn: turn.opposite,
          board: board.setPieceAt(to, Piece(color: turn, role: role)),
          pockets: pockets?.decrement(turn, role),
          epSquare: null,
        );''';

  if (content.contains(target)) {
    content = content.replaceFirst(target, replacement);
    file.writeAsStringSync(content);
    print('Successfully applied fix to DropMove.');
  } else {
    print('Target not found in lib/src/position.dart');
    // Try a more relaxed search
    if (content.contains('case DropMove(') &&
        content.contains('pockets: pockets?.decrement(turn, role),')) {
      print('Found partial match, attempting regex replacement...');
      final regex = RegExp(
        r'case DropMove\(to: final to, role: final role\):\s+return copyWith\(\s+halfmoves: role == Role\.pawn \? 0 : halfmoves \+ 1,\s+fullmoves: turn == Side\.black \? fullmoves \+ 1 : fullmoves,\s+turn: turn\.opposite,\s+board: board\.setPieceAt\(to, Piece\(color: turn, role: role\)\),\s+pockets: pockets\?\.decrement\(turn, role\),\s+\);',
      );
      if (regex.hasMatch(content)) {
        content = content.replaceFirst(regex, replacement);
        file.writeAsStringSync(content);
        print('Successfully applied fix via regex.');
      } else {
        print('Regex failed to match.');
      }
    }
  }
}
