import 'dart:io';

const int gridSize = 9;
const List<int> shipSizes = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];

void clearConsole() {
  if (Platform.isWindows) {
    Process.runSync("cls", [], runInShell: true);
  } else {
    print("\x1B[2J\x1B[0;0H");
  }
}

class GameBoard {
  List<List<String>> board;
  GameBoard() : board = List.generate(gridSize, (_) => List.filled(gridSize, '~'));

  void displayBoard({bool hideShips = false}) {
    print("\n  " + List.generate(gridSize, (index) => (index + 1).toString()).join(' '));
    for (var i = 0; i < gridSize; i++) {
      print("${i + 1} " + board[i].map((cell) => (hideShips && cell == 'S') ? '~' : cell).join(' '));
    }
  }

  bool placeShip(int x, int y, int size, bool horizontal) {
    x -= 1;
    y -= 1;
    if (!_canPlaceShip(x, y, size, horizontal)) return false;

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

      if (_isAdjacentToShip(newX, newY)) {
        return false;
      }
    }
    return true;
  }

  bool _isAdjacentToShip(int x, int y) {
    List<List<int>> directions = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],          [0, 1],
      [1, -1], [1, 0], [1, 1]
    ];

    for (var dir in directions) {
      int newX = x + dir[0];
      int newY = y + dir[1];
      if (newX >= 0 && newX < gridSize && newY >= 0 && newY < gridSize) {
        if (board[newX][newY] == 'S') return true;
      }
    }
    return false;
  }
}

class BattleShipGame {
  final GameBoard player1Board = GameBoard();
  final GameBoard player2Board = GameBoard();
  List<List<String>> attackBoard1 = List.generate(gridSize, (_) => List.filled(gridSize, '~'));
  List<List<String>> attackBoard2 = List.generate(gridSize, (_) => List.filled(gridSize, '~'));

  void placeShips(GameBoard board, String playerName) {
    print("\n$playerName, расставьте корабли.");
    for (int size in shipSizes) {
      bool placed = false;
      while (!placed) {
        board.displayBoard();
        print("Введите координаты для корабля размером $size (x y горизонтально(1) / вертикально(0)): ");
        var input = stdin.readLineSync()?.split(' ');
        if (input == null || input.length != 3) {
          print("Некорректный ввод. Попробуйте снова.");
          continue;
        }

        int? x = int.tryParse(input[0]);
        int? y = int.tryParse(input[1]);
        bool horizontal = input[2] == '1';

        if (x == null || y == null || x < 1 || x > gridSize || y < 1 || y > gridSize) {
          print("Координаты вне диапазона! Попробуйте снова.");
          continue;
        }

        if (board.placeShip(x, y, size, horizontal)) {
          placed = true;
        } else {
          print("Некорректное размещение (слишком близко к другому кораблю). Попробуйте снова.");
        }
      }
    }
    clearConsole();
  }

  bool attack(GameBoard enemyBoard, List<List<String>> attackBoard, String playerName) {
    print("\n$playerName, ваш ход.");
    
    while (true) {
      print("\n  " + List.generate(gridSize, (index) => (index + 1).toString()).join(' '));
      for (var i = 0; i < gridSize; i++) {
        print("${i + 1} " + attackBoard[i].join(' '));
      }

      print("Введите координаты для атаки (например, 1 2):");
      var input = stdin.readLineSync()?.split(' ');

      if (input == null || input.length != 2) {
        print("Некорректный ввод. Попробуйте снова.");
        continue;
      }

      int? x = int.tryParse(input[0]);
      int? y = int.tryParse(input[1]);

      if (x == null || y == null || x < 1 || x > gridSize || y < 1 || y > gridSize) {
        print("Координаты вне диапазона! Попробуйте снова.");
        continue;
      }

      x -= 1;
      y -= 1;

      if (attackBoard[x][y] != '~') {
        print("Вы уже атаковали эту клетку! Попробуйте снова.");
        continue;
      }

      if (enemyBoard.board[x][y] == 'S') {
        attackBoard[x][y] = 'X';
        enemyBoard.board[x][y] = '~';
        print("Попадание! Вы стреляете снова.");
        if (checkVictory(enemyBoard)) return true;
      } else {
        attackBoard[x][y] = 'O';
        print("Мимо! Ход переходит другому игроку.");
        return false;
      }
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

    placeShips(player1Board, "Игрок 1");
    placeShips(player2Board, "Игрок 2");

    bool gameOver = false;
    bool player1Turn = true;

    while (!gameOver) {
      if (player1Turn) {
        gameOver = attack(player2Board, attackBoard1, "Игрок 1");
      } else {
        gameOver = attack(player1Board, attackBoard2, "Игрок 2");
      }

      if (!gameOver) {
        player1Turn = !player1Turn;
      }
    }

    print(player1Turn ? "Игрок 1 победил!" : "Игрок 2 победил!");
  }
}

void main() {
  var game = BattleShipGame();
  game.play();
}
