import 'dart:io';
import 'dart:math';

const int gridSize = 9;
const List<int> shipSizes = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];

class GameBoard {
  List<List<String>> board;
  GameBoard() : board = List.generate(gridSize, (_) => List.filled(gridSize, '~'));

  void displayBoard({bool hideShips = false}) {
    for (var i = 0; i < gridSize; i++) {
      print("${i + 1} " + board[i].map((cell) => (hideShips && cell == 'S') ? '~' : cell).join(' '));
    }
    print("  " + List.generate(gridSize, (index) => (index + 1).toString()).join(' '));
  }

  bool placeShip(int x, int y, int size, bool horizontal) {
    x -= 1;
    y -= 1;
    if (!_canPlaceShip(x, y, size, horizontal)) {
      return false;
    }
    for (int i = 0; i < size; i++) {
      board[x + (horizontal ? 0 : i)][y + (horizontal ? i : 0)] = 'S';
    }
    return true;
  }

  bool _canPlaceShip(int x, int y, int size, bool horizontal) {
    for (int i = 0; i < size; i++) {
      int newX = x + (horizontal ? 0 : i);
      int newY = y + (horizontal ? i : 0);
      if (newX >= gridSize || newY >= gridSize || board[newX][newY] == 'S') {
        return false;
      }
    }
    return true;
  }
}

class BattleShipGame {
  final GameBoard player1Board = GameBoard();
  final GameBoard player2Board = GameBoard();
  List<List<String>> attackBoard1 = List.generate(gridSize, (_) => List.filled(gridSize, '~'));
  List<List<String>> attackBoard2 = List.generate(gridSize, (_) => List.filled(gridSize, '~'));

  void placeShips(GameBoard board) {
    for (int size in shipSizes) {
      bool placed = false;
      while (!placed) {
        board.displayBoard();
        print("Введите координаты для корабля размером $size (x y горизонтально(1) / вертикально(0)): ");
        var input = stdin.readLineSync()?.split(' ');
        if (input == null || input.length != 3) continue;
        int x = int.parse(input[0]);
        int y = int.parse(input[1]);
        bool horizontal = input[2] == '1';
        if (board.placeShip(x, y, size, horizontal)) {
          placed = true;
        } else {
          print("Некорректное размещение. Попробуйте снова.");
        }
      }
    }
  }

  bool attack(GameBoard enemyBoard, List<List<String>> attackBoard) {
    print("Введите координаты для атаки (например, 1 2):");
    while (true) {
      var input = stdin.readLineSync()?.split(' ');
      if (input == null || input.length != 2) continue;
      int x = int.parse(input[0]) - 1;
      int y = int.parse(input[1]) - 1;
      if (x < 0 || x >= gridSize || y < 0 || y >= gridSize || attackBoard[x][y] != '~') {
        print("Некорректный ход. Попробуйте снова.");
        continue;
      }
      if (enemyBoard.board[x][y] == 'S') {
        attackBoard[x][y] = 'X';
        enemyBoard.board[x][y] = '~';
        print("Попадание!");
      } else {
        attackBoard[x][y] = 'O';
        print("Мимо!");
      }
      return checkVictory(enemyBoard);
    }
  }

  bool checkVictory(GameBoard enemyBoard) {
    for (var row in enemyBoard.board) {
      if (row.contains('S')) return false;
    }
    return true;
  }

  void play() {
    print("Добро пожаловать в Морской бой!");
    placeShips(player1Board);
    placeShips(player2Board);

    bool gameOver = false;
    while (!gameOver) {
      print("\nПоле атак Игрока 1:");
      attackBoard1.forEach((row) => print(row.join(' ')));
      gameOver = attack(player2Board, attackBoard1);
      if (gameOver) {
        print("Игрок 1 победил!");
        break;
      }
      
      print("\nПоле атак Игрока 2:");
      attackBoard2.forEach((row) => print(row.join(' ')));
      gameOver = attack(player1Board, attackBoard2);
      if (gameOver) {
        print("Игрок 2 победил!");
        break;
      }
    }
  }
}

void main() {
  var game = BattleShipGame();
  game.play();
}
