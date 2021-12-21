import 'bishop.dart';
import 'figure.dart';
import 'rook.dart';

class Queen extends Figure {
  @override
  final String symbol = 'q';

  Queen(String color, int row, int col) : super(color, row, col);

  @override
  bool checkMove(int fromRow, int fromCol, int toRow, int toCol) {
    var bishop = Bishop(color, fromRow, fromCol);
    var rook = Rook(color, fromRow, fromCol);
    var bishopCheck = bishop.checkMove(fromRow, fromCol, toRow, toCol);
    var rookCheck = rook.checkMove(fromRow, fromCol, toRow, toCol);
    
    return bishopCheck || rookCheck;
  }
}