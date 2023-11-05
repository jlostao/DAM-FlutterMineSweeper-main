import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart'; // per a 'CustomPainter'
import 'app_data.dart';

// S'encarrega del dibuix personalitzat del joc
class WidgetBuscaminesPainter extends CustomPainter {
  final AppData appData;
  int cellNum = 0;

  WidgetBuscaminesPainter(this.appData);

  void setCellNum() {
    if (appData.boardsize == "Petit") {
      cellNum = 9;
    } else if (appData.boardsize == "Gran") {
      cellNum = 15;
    }
  }

  // Dibuixa les linies del taulell
  void drawBoardLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0;

    // Definim els punts on es creuaran les línies verticals
    final double firstVertical = size.width / cellNum;
    final double secondVertical = 2 * size.width / cellNum;
    final double thirdVertical = 3 * size.width / cellNum;
    final double fourthVertical = 4 * size.width / cellNum;
    final double fifthVertical = 5 * size.width / cellNum;
    final double sixthVertical = 6 * size.width / cellNum;
    final double seventhVertical = 7 * size.width / cellNum;
    final double eightVertical = 8 * size.width / cellNum;
    final double ninthVertical = 9 * size.width / cellNum;
    final double tenthVertical = 10 * size.height / cellNum;
    final double eleventhVertical = 11 * size.height / cellNum;
    final double twelvethVertical = 12 * size.height / cellNum;
    final double thirteenthVertical = 13 * size.height / cellNum;
    final double fourteenthVertical = 14 * size.height / cellNum;

    // Dibuixem les línies verticals
    canvas.drawLine(
        Offset(firstVertical, 0), Offset(firstVertical, size.height), paint);
    canvas.drawLine(
        Offset(secondVertical, 0), Offset(secondVertical, size.height), paint);

    // Definim els punts on es creuaran les línies horitzontals
    final double firstHorizontal = size.height / 3;
    final double secondHorizontal = 2 * size.height / 3;

    // Dibuixem les línies horitzontals
    canvas.drawLine(
        Offset(0, firstHorizontal), Offset(size.width, firstHorizontal), paint);
    canvas.drawLine(Offset(0, secondHorizontal),
        Offset(size.width, secondHorizontal), paint);
  }

  // Dibuixa la imatge centrada a una casella del taulell
  void drawImage(Canvas canvas, ui.Image image, double x0, double y0, double x1,
      double y1) {
    double dstWidth = x1 - x0;
    double dstHeight = y1 - y0;

    double imageAspectRatio = image.width / image.height;
    double dstAspectRatio = dstWidth / dstHeight;

    double finalWidth;
    double finalHeight;

    if (imageAspectRatio > dstAspectRatio) {
      finalWidth = dstWidth;
      finalHeight = dstWidth / imageAspectRatio;
    } else {
      finalHeight = dstHeight;
      finalWidth = dstHeight * imageAspectRatio;
    }

    double offsetX = x0 + (dstWidth - finalWidth) / cellNum;
    double offsetY = y0 + (dstHeight - finalHeight) / cellNum;

    final srcRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dstRect = Rect.fromLTWH(offsetX, offsetY, finalWidth, finalHeight);

    canvas.drawImageRect(image, srcRect, dstRect, Paint());
  }

  // Dibuixa el taulell de joc 
  void drawBoardStatus(Canvas canvas, Size size) {
    setCellNum();
    double cellWidth = size.width / cellNum;
    double cellHeight = size.height / cellNum;

    for (int i = 0; i < cellNum; i++) {
      for (int j = 0; j < cellNum; j++) {
        String cellValue = appData.board[i][j];
        if (cellValue != '-') {
          if (cellValue == 'F') {
            final textStyle = TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            );

            final textPainter = TextPainter(
              text: TextSpan(text: 'F', style: textStyle),
              textDirection: TextDirection.ltr,
            );

            textPainter.layout(
              maxWidth: cellWidth,
            );

            final position = Offset(
              j * cellWidth + (cellWidth - textPainter.width) / 2,
              i * cellHeight + (cellHeight - textPainter.height) / 2,
            );

            textPainter.paint(canvas, position);
          } else if (cellValue != 'M') {
            final textStyle = TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            );

            final textPainter = TextPainter(
              text: TextSpan(text: cellValue, style: textStyle),
              textDirection: TextDirection.ltr,
            );

            textPainter.layout(
              maxWidth: cellWidth,
            );

            final position = Offset(
              j * cellWidth + (cellWidth - textPainter.width) / 2,
              i * cellHeight + (cellHeight - textPainter.height) / 2,
            );

            textPainter.paint(canvas, position);
          }
        }
      }
    }
  }

  // Dibuixa el missatge de joc acabat
  void drawGameOver(Canvas canvas, Size size) {
    int cellNum = 0;
    String message = "";
    // Possible error




    int mines = 0;
    for (int i = 0; i < appData.board.length; i++) {
      for (int j = 0; j < appData.board[i].length; j++) {
        if (appData.board[i][j] == 'M') {
          mines++;
        }
      }
    }
    int minesNumber = int.parse(appData.minesnumber);
    if (mines == minesNumber) {
      message = "Joc finalitzat, ets el guanyador!";
    } else {
      message = "Joc finalitzat, has perdut...";
    }

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: message, style: textStyle),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      maxWidth: size.width,
    );

    final position = Offset(
      (size.width - textPainter.width) / cellNum - 2,
      (size.height - textPainter.height) / cellNum - 2,
    );

    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawRect(bgRect, paint);
    textPainter.paint(canvas, position);
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawBoardLines(canvas, size);
    if (appData.gameIsOver) {
      drawMines(canvas, size);
    } else {
      drawBoardStatus(canvas, size);
    }
    if (appData.gameIsOver) {
      drawGameOver(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawMines(Canvas canvas, Size size) {
    setCellNum();
    double cellWidth = size.width / cellNum;
    double cellHeight = size.height / cellNum;

    for (int i = 0; i < cellNum; i++) {
      for (int j = 0; j < cellNum; j++) {
        String cellValue = appData.board[i][j];
        if (cellValue == 'M') {
          final textStyle = TextStyle(
            color: Colors.black,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          );

          final textPainter = TextPainter(
            text: TextSpan(text: 'M', style: textStyle),
            textDirection: TextDirection.ltr,
          );

          textPainter.layout(
            maxWidth: cellWidth,
          );

          final position = Offset(
            j * cellWidth + (cellWidth - textPainter.width) / 2,
            i * cellHeight + (cellHeight - textPainter.height) / 2,
          );

          textPainter.paint(canvas, position);
        }
      }
    }
  }
}

