import 'desk.dart';
import 'figure.dart';

class Bishop extends Figure {
  @override
  final String symbol = 'b';

  Bishop(String color, int row, int col) : super(color, row, col);

  @override
  bool checkMove(int fromRow, int fromCol, int toRow, int toCol) {
    if (Desk.position[toRow][toCol] != null
        && Desk.position[toRow][toCol]!.color == Desk.position[fromRow][fromCol]!.color
    ) {
      return false;
    }

    int diff = (toRow - fromRow).abs();

    if (diff != (toCol - fromCol).abs()) {
      return false;
    }

    if (toRow > fromRow) {
      if (toCol > fromCol) {
        for (int i = 1; i < diff; i++) {
          if (Desk.position[fromRow+i][fromCol+i] != null) {
            return false;
          }
        }
        return true;
      } else {
        for (int i = 1; i < diff; i++) {
          if (Desk.position[fromRow+i][fromCol-i] != null) {
            return false;
          }
        }
        return true;
      }
    } else {
      if (toCol > fromCol) {
        for (int i = 1; i < diff; i++) {
          if (Desk.position[fromRow-i][fromCol+i] != null) {
            return false;
          }
        }
        return true;
      } else {
        for (int i = 1; i < diff; i++) {
          if (Desk.position[fromRow-i][fromCol-i] != null) {
            return false;
          }
        }
        return true;
      }
    }
  }
}