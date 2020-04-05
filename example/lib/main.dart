import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/spinner.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static const int NUM_ELEMENTS = 50;
  static const int ON_SCREEN = 10;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Spinner Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(body: Builder(builder: (ctx) {
          var height = MediaQuery.of(ctx).size.height;
          var width = MediaQuery.of(ctx).size.width;
          return Spinner(
              containerCount: ON_SCREEN,
              containerSize: height / ON_SCREEN,
              animationSpeed: 40,
              zoomFactor: 1.5,
              builder: (index) {
                var color =
                    (cos((2 * pi) * index / NUM_ELEMENTS) + 1) / 2 * 255;
                return Container(
                  height: height / ON_SCREEN,
                  color: Color.fromARGB(255, 0, 0, color.floor()),
                  child: Center(
                      child: Text(
                    "Container #${index % NUM_ELEMENTS}",
                    style: TextStyle(
                        fontSize: height / ON_SCREEN * 0.4,
                        color: Colors.white),
                  )),
                );
              },
              spinDirection: SpinnerDirection.down,
              duration: Duration(seconds: 5));
        })));
  }
}
