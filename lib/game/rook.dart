import 'desk.dart';
import 'figure.dart';

class Rook extends Figure {
  @override
  final String symbol = 'r';

  Rook(String color, int row, int col) : super(color, row, col);

  @override
  bool checkMove(int fromRow, int fromCol, int toRow, int toCol) {
    if (Desk.position[toRow][toCol] != null
        && Desk.position[toRow][toCol]!.color == Desk.position[fromRow][fromCol]!.color
    ) {
      return false;
    }

    if (fromCol == toCol) {
      if (fromRow < toRow) {
        for (int i = fromRow + 1; i < toRow; i++) {
          if (Desk.position[i][toCol] != null) {
            return false;
          }
        }
        return true;
      }
      else if (fromRow > toRow) {
        for (int i = fromRow - 1; i > toRow; i--) {
          if (Desk.position[i][toCol] != null) {
            return false;
          }
        }
        return true;
      }
    }
    else if (fromRow == toRow) {
      if (fromCol < toCol) {
        for (int i = fromCol + 1; i < toCol; i++) {
          if (Desk.position[toRow][i] != null) {
            return false;
          }
        }
        return true;
      }
      else if (fromCol > toCol) {
        for (int i = fromCol - 1; i > toCol; i--) {
          if (Desk.position[toRow][i] != null) {
            return false;
          }
        }
        return true;
      }
    }

    return false;
  }
}