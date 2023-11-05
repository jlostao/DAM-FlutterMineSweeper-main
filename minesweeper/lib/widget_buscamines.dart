import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'widget_buscamines_painter.dart';

class WidgetBuscamines extends StatefulWidget {
  const WidgetBuscamines({Key? key}) : super(key: key);

  @override
  WidgetBuscaminesState createState() => WidgetBuscaminesState();
}

class WidgetBuscaminesState extends State<WidgetBuscamines> {
  Future<void>? _loadImagesFuture;
  TapDownDetails? firstTapDetails;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppData appData = Provider.of<AppData>(context, listen: false);
      _loadImagesFuture = appData.loadImages(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    int cellnum = 0;
    switch (appData.boardsize) {
      case "Petit":
        cellnum = 9;
        break;
      case "Gran":
        cellnum = 15;
        break;
    }

    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        final int row = (details.localPosition.dy / (context.size!.height / cellnum)).floor();
        final int col = (details.localPosition.dx / (context.size!.width / cellnum)).floor();
        appData.nextMove(row, col);
        setState(() {}); 
      },
      onDoubleTapDown: (details) {
        firstTapDetails = details;
      },
      onDoubleTap: () {
        if (firstTapDetails != null) {
          final int row = (firstTapDetails!.localPosition.dy / (context.size!.height / cellnum)).floor();
          final int col = (firstTapDetails!.localPosition.dx / (context.size!.width / cellnum)).floor();
          appData.setFlag(row, col);
          setState(() {});
        }
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 56.0,
        child: FutureBuilder(
          future: _loadImagesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            } else {
              return CustomPaint(
                painter: WidgetBuscaminesPainter(appData),
              );
            }
          },
        ),
      ),
    );
  }
}
