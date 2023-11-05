import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  // App status
  String boardsize = "Petit";
  String minesnumber = "5";
  int totalFlags = 0;
  int totalMines = 0;
  int cellNum = 0;
  List<String> pastFlag = [];
  List<List<int>> flags = [];

  List<List<String>> board = [];
  bool gameIsOver = false;
  String gameWinner = '-';

  ui.Image? imagePlayer;
  ui.Image? imageOpponent;
  bool imagesReady = false;

  void resetGame() {
    board.clear();
    if (boardsize == "Petit") {
      for (int row = 0; row < 9; row++) {
        board.add([]);
        for (int col = 0; col < 9; col++) {
          board[row].add("-");
        }
      }
    } else if (boardsize == "Gran") {
      for (int row = 0; row < 15; row++) {
        board.add([]);
        for (int col = 0; col < 15; col++) {
          board[row].add("-");
        }
      }
    }
    
    totalFlags = 0;
    gameIsOver = false;
    gameWinner = '-';
    setCellNum();
  }

  void setMines() {
    Random rand = Random();
    totalMines = int.parse(minesnumber);
    setCellNum();
    for (int i = 0; i < totalMines; i++) {
      int row, col;
      do {
        row = rand.nextInt(cellNum);
        col = rand.nextInt(cellNum);
      } while (board[row][col] == 'M');

      board[row][col] = 'M';
    }
  }

  void setFlag(int row, int col) {
    if (totalFlags < totalMines) {
      if (board[row][col] == 'F') {
        for (int i = 0; i < flags.length; i++) {
          if (pastFlag[i][0] == row && pastFlag[i][1] == col) {
            board[row][col] = pastFlag[i];
            totalMines++;
            return;
          }
        }
        board[row][col] = pastFlag[0];
        totalMines++;
      } else if (board[row][col] != 'O') {
        pastFlag = [];
        pastFlag.add(board[row][col]);
        totalMines--;
        board[row][col] = 'F';
      }
    }
  }

  void removeFlag(int row, int col) {
    if (board[row][col] == 'F') {
      for (int i = 0; i < flags.length; i++) {
        if (flags[i][0] == row && flags[i][1] == col) {
          board[row][col] = pastFlag[i];
          flags.removeAt(i);
          totalMines++;
          return;
        }
      }
      board[row][col] = pastFlag[0];
      totalMines++;
    }
  }

  void setCellNum() {
    if (boardsize == "Petit") {
      cellNum = 9;
    } else if (boardsize == "Gran") {
      cellNum = 15;
    }
  }

  void recursiveCheck(int row, int col) {
    List<List<int>> directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1]
    ];

    int mineCount = 0;

    for (var direction in directions) {
      int newRow = row + direction[0];
      int newCol = col + direction[1];

      if (newRow >= 0 &&
          newRow < board.length &&
          newCol >= 0 &&
          newCol < board[newRow].length) {
        String cellState = board[newRow][newCol];
        if (cellState == 'F') {
          removeFlag(newRow, newCol);
          if (board[newRow][newCol] == 'M') {
            board[newRow][newCol] == 'F';
            mineCount++;
          }
        }
        if (cellState == 'M') {
          mineCount++;
        }
      }
    }

    if (mineCount > 0) {
      // Si hay bombas cercanas, coloca el número de bombas en lugar de "O"
      board[row][col] = mineCount.toString();
    } else {
      board[row][col] = '0';

      for (var direction in directions) {
        int newRow = row + direction[0];
        int newCol = col + direction[1];

        // Verifica si las nuevas coordenadas están dentro de los límites del tablero
        if (newRow >= 0 &&
            newRow < board.length &&
            newCol >= 0 &&
            newCol < board[newRow].length) {
          String cellState = board[newRow][newCol];
          if (cellState == '-') {
            recursiveCheck(newRow, newCol);
          }
        }
      }
    }
  }

  void nextMove(int row, int col) {
    if (board[row][col] == 'F') {
      setFlag(row, col);
      recursiveCheck(row, col);
    }
    if (board[row][col] == '-') {
      board[row][col] = 'O';
      recursiveCheck(row, col);
    }
    if (board[row][col] == 'B') {
      board[row][col] = 'X';
      gameIsOver = true;
      return;
    }

    checkGameWinner();
  }


  // Comprova si el joc ja té un tres en ratlla
  // No comprova la situació d'empat
  void checkGameWinner() {
    bool boardCleared = true;

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j] != 'M' && board[i][j] != 'X') {
          if (board[i][j] == '-') {
            boardCleared = false;
            break;
          }
          if (board[i][j] == 'F') {
            setFlag(i, j);
            if (board[i][j] == '-') {
              boardCleared = false;
              board[i][j] == 'F';
              break;
            }
          }
        }
      }
      if (!boardCleared) {
        break;
      }
    }

    if (boardCleared) {
      gameIsOver = true;
    }
  }
  

  // Carrega les imatges per dibuixar-les al Canvas
  Future<void> loadImages(BuildContext context) async {
    // Si ja estàn carregades, no cal fer res
    if (imagesReady) {
      notifyListeners();
      return;
    }

    // Força simular un loading
    await Future.delayed(const Duration(milliseconds: 500));

    Image tmpPlayer = Image.asset('assets/images/player.png');
    Image tmpOpponent = Image.asset('assets/images/opponent.png');

    // Carrega les imatges
    if (context.mounted) {
      imagePlayer = await convertWidgetToUiImage(tmpPlayer);
    }
    if (context.mounted) {
      imageOpponent = await convertWidgetToUiImage(tmpOpponent);
    }

    imagesReady = true;

    // Notifica als escoltadors que les imatges estan carregades
    notifyListeners();
  }

  // Converteix les imatges al format vàlid pel Canvas
  Future<ui.Image> convertWidgetToUiImage(Image image) async {
    final completer = Completer<ui.Image>();
    image.image.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (info, _) => completer.complete(info.image),
          ),
        );
    return completer.future;
  }
}
