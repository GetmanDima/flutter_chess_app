import 'dart:io';
import 'figure.dart';
import 'bishop.dart';
import 'king.dart';
import 'knight.dart';
import 'pawn.dart';
import 'queen.dart';
import 'rook.dart';

class Desk {
  static late String userColor;
  static int halfMoveNumber = 1;

  static String getCurrentMoveColor() {
    if (halfMoveNumber % 2 == 0) {
      return "black";
    }

    return "white";
  }

  static Figure? getFigureFromFenSymbol(String symbol, int row, int col) {
    String color = symbol == symbol.toUpperCase() ? 'w' : 'b';

    switch (symbol.toLowerCase()) {
      case 'r':
        return Rook(color, row, col);
      case 'n':
        return Knight(color, row, col);
      case 'b':
        return Bishop(color, row, col);
      case 'q':
        return Queen(color, row, col);
      case 'k':
        return King(color, row, col);
      case 'p':
        return Pawn(color, row, col);
    }
  }

  static var position = List.generate(
      8, (i) => List<Figure?>.filled(8, null, growable: false),
      growable: false);

  static String positionToFen() {
    String fen = "";

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        var square = position[i][j];

        if (square == null) {
          fen += "0";
        } else {
          fen += square.color == 'w' ? square.symbol.toUpperCase() : square.symbol;
        }
      }
    }

    return fen;
  }

  static void loadPositionFromFen(String fen) {
    for (int i = 0; i < fen.length; i++) {
      int x = i ~/ 8;
      int y = i % 8;

      if (fen[i] == '0') {
        position[x][y] = null;
      } else {
        position[x][y] = getFigureFromFenSymbol(fen[i], x, y);
      }
    }
  }

  static void initialize() {
    // Black
    position[0][0] = Rook('b', 0, 0);
    position[0][1] = Knight('b', 0, 1);
    position[0][2] = Bishop('b', 0, 2);
    position[0][3] = Queen('b', 0, 3);
    position[0][4] = King('b', 0, 4);
    position[0][5] = Bishop('b', 0, 5);
    position[0][6] = Knight('b', 0, 6);
    position[0][7] = Rook('b', 0, 7);

    // White
    position[7][0] = Rook('w', 7, 0);
    position[7][1] = Knight('w', 7, 1);
    position[7][2] = Bishop('w', 7, 2);
    position[7][3] = Queen('w', 7, 3);
    position[7][4] = King('w', 7, 4);
    position[7][5] = Bishop('w', 7, 5);
    position[7][6] = Knight('w', 7, 6);
    position[7][7] = Rook('w', 7, 7);

    for (int i = 0; i < 8; i++) {
      position[1][i] = Pawn('b', 1, i);
      position[6][i] = Pawn('w', 6, i);
    }

    for (int i = 2; i < 6; i++) {
      for (int j = 0; j < 8; j++) {
        position[i][j] = null;
      }
    }
  }

  static bool move(int fromRow, int fromCol, int toRow, int toCol) {
    var figure = position[fromRow][fromCol];

    if (figure == null || figure.color != userColor) {
      return false;
    }

    if (userColor == 'w' && halfMoveNumber % 2 == 0) {
      return false;
    }

    if (userColor == 'b' && halfMoveNumber % 2 != 0) {
      return false;
    }

    var check = figure.checkMove(fromRow, fromCol, toRow, toCol);

    if (check) {
      figure.row = toRow;
      figure.col = toCol;
      position[fromRow][fromCol] = null;
      position[toRow][toCol] = figure;
      halfMoveNumber++;
    }

    if (figure.symbol == 'p') {
      promotePawn();
    }

    if (figure.symbol == 'k') {
      castling(figure, fromRow, fromCol, toRow, toCol);
    }

    return check;
  }

  static bool moveByNotation(String from, String to) {
    var columns = {
      'a': 0,
      'b': 1,
      'c': 2,
      'd': 3,
      'e': 4,
      'f': 5,
      'g': 6,
      'h': 7
    };
    var fromRow = 8 - int.parse(from[1]);
    var fromCol = columns[from[0]] ?? 0;
    var toRow = 8 - int.parse(to[1]);
    var toCol = columns[to[0]] ?? 0;

    return move(fromRow, fromCol, toRow, toCol);
  }

  static void promotePawn() {
    for (int i = 0; i < 8; i++) {
      if (position[0][i] != null && position[0][i]!.symbol == 'p') {
        position[0][i] = Queen('w', 0, i);
      }
      if (position[7][i] != null && position[7][i]!.symbol == 'p') {
        position[7][i] = Queen('b', 7, i);
      }
    }
  }

  static void castling(figure, int fromRow, int fromCol, int toRow, int toCol) {
    // roque
    if (figure!.color == 'w' &&
        fromRow == 7 &&
        fromCol == 4 &&
        toRow == 7 &&
        toCol == 6) {
      var rook = position[7][7];

      if (rook != null) {
        rook.row = 7;
        rook.col = 5;
        position[7][7] = null;
        position[7][5] = rook;
      }
    }

    if (figure!.color == 'w' &&
        fromRow == 7 &&
        fromCol == 4 &&
        toRow == 7 &&
        toCol == 2) {
      var rook = position[7][0];

      if (rook != null) {
        rook.row = 7;
        rook.col = 3;
        position[7][0] = null;
        position[7][3] = rook;
      }
    }

    if (figure!.color == 'b' &&
        fromRow == 0 &&
        fromCol == 4 &&
        toRow == 0 &&
        toCol == 6) {
      var rook = position[0][7];

      if (rook != null) {
        rook.row = 0;
        rook.col = 5;
        position[0][7] = null;
        position[0][5] = rook;
      }
    }

    if (figure!.color == 'b' &&
        fromRow == 0 &&
        fromCol == 4 &&
        toRow == 0 &&
        toCol == 2) {
      var rook = position[0][0];

      if (rook != null) {
        rook.row = 0;
        rook.col = 3;
        position[0][0] = null;
        position[0][3] = rook;
      }
    }
  }

  static void show() {
    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 8; y++) {
        stdout.write(position[x][y]);
      }
      stdout.writeln('');
    }
  }

  static void render() {
    var blackFiguresSymbols = {
      'p': '\u{265F}',
      'r': '\u{265C}',
      'n': '\u{265E}',
      'b': '\u265D',
      'q': '\u{265B}',
      'k': '\u{265A}'
    };

    var whiteFiguresSymbols = {
      'p': '\u{2659}',
      'r': '\u{2656}',
      'n': '\u{2658}',
      'b': '\u{2657}',
      'q': '\u{2655}',
      'k': '\u{2654}'
    };

    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 8; y++) {
        if (position[x][y] != null) {
          var color = position[x][y]!.color == 'w' ? '\x1B[32m' : '\x1B[31m';
          var symbol = position[x][y]!.color == 'w'
              ? whiteFiguresSymbols[position[x][y]!.symbol]
              : blackFiguresSymbols[position[x][y]!.symbol];

          // if (position[x][y]!.color == 'w') {
          //   symbol = symbol.toString().toUpperCase();
          // }

          stdout.write(' ' + color + symbol! + '\x1B[0m');
        } else {
          stdout.write(' \u{25AD}');
        }
      }
      stdout.write('\n');
    }
  }
}
