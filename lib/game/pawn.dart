import 'desk.dart';
import 'figure.dart';

class Pawn extends Figure {
  @override
  final String symbol = 'p';

  Pawn(String color, int row, int col) : super(color, row, col);

  @override
  bool checkMove(int fromRow, int fromCol, int toRow, int toCol) {
    if (color == 'w') {
      return checkWhiteMove(fromRow, fromCol, toRow, toCol);
    } else {
      return checkBlackMove(fromRow, fromCol, toRow, toCol);
    }
  }

  bool checkWhiteMove(int fromRow, int fromCol, int toRow, int toCol) {
    var toFigure = Desk.position[toRow][toCol];

    if (toFigure != null && toFigure.color == 'w') {
      return false;
    }

    if (fromCol == toCol) {
      if (toFigure != null) {
        return false;
      }

      if (fromRow == 6) {
        if (fromRow - toRow > 0 && fromRow - toRow <= 2) {
          if (Desk.position[5][toCol] == null) {
            return true;
          }
          return false;
        }
      } else if (fromRow - toRow == 1) {
        return true;
      }
    } else if (
      fromRow - toRow == 1 &&
      (fromCol - toCol).abs() == 1 &&
      toFigure != null
    ) {
      return true;
    }

    return false;
  }

  bool checkBlackMove(int fromRow, int fromCol, int toRow, int toCol) {
    var toFigure = Desk.position[toRow][toCol];

    if (toFigure != null && toFigure.color == 'b') {
      return false;
    }

    if (fromCol == toCol) {
      if (toFigure != null) {
        return false;
      }

      if (fromRow == 1) {
        if (toRow - fromRow > 0 && toRow - fromRow <= 2) {
          if (Desk.position[2][toCol] == null) {
            return true;
          }

          return false;
        }
      } else if (toRow - fromRow == 1) {
        return true;
      }
    } else if (
      toRow - fromRow == 1 &&
      (fromCol - toCol).abs() == 1 &&
      toFigure != null
    ) {
      return true;
    }

    return false;
  }
}