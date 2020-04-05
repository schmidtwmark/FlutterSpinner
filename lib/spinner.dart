library spinner;

import 'package:flutter/material.dart';

typedef ContainerBuilder = Widget Function(int index);
typedef SpinnerCallback = void Function(int index);

enum SpinnerDirection { up, down, left, right }

class Spinner extends StatefulWidget {
  // Number of containers on screen
  // If this is an even number, animation speed will be adjusted so the animation
  // ends with a container directly in the middle
  final int containerCount;

  // Static length of each container in spinner direction
  // Up/Down this should be the height of each container
  // Left/Right this should be the width of each container
  final double containerSize;

  // Number of tiles to pass over during the animation sequence
  // This number can be larger than the container and will wrap around

  final int animationSpeed;

  // Builder function that takes in an int and returns a fixed size container
  final ContainerBuilder builder;

  // Animation duration
  final Duration duration;

  // Animation curve definition
  // Defaults to ease in out cubic
  final Curve curve;

  // Optional Callback function to fire at the end.
  // Fires with the index of the element that the spinner lands on
  final SpinnerCallback callback;

  // Specify zoom factor for final position of the animation
  // Defaults to 1 for no zoom
  final double zoomFactor;

  // Direction containers
  final SpinnerDirection spinDirection;

  Spinner(
      {@required this.containerCount,
      @required this.containerSize,
      @required this.animationSpeed,
      @required this.builder,
      @required this.duration,
      this.curve: Curves.easeInOutCubic,
      this.callback: emptyCallback,
      this.zoomFactor: 1.0,
      this.spinDirection: SpinnerDirection.up});

  static void emptyCallback(int index) {
    print("Ending at index $index");
  }

  @override
  State<StatefulWidget> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _curve;
  Widget _column;
  Widget _transformed;
  double _offset = 0;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      animationBehavior: AnimationBehavior.preserve,
      vsync: this,
    );
    _curve = CurvedAnimation(parent: _controller, curve: widget.curve);
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        // Execute this first to "Finish" the animation
        transformColumn(1.0);

        // Call the optional callback
        var endIndex = _index + (widget.containerCount / 2).ceil();
        widget.callback(endIndex);
      }
    });
    _controller.forward(); //start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Iterable<int> positiveIntegers(int start) sync* {
    int i = start;
    while (true) yield i++;
  }

  Widget transformColumn(double curveValue) {
    // If the number of widgets on screen is even, we need to end up halfway between widgets
    // Adjust the speed appropriately
    double trueSpeed = widget.containerCount % 2 == 0 // is even
        ? widget.animationSpeed.toDouble() + 0.5
        : widget.animationSpeed.toDouble();

    // How far to shift the entire column by
    double rawOffset = _curve.value * trueSpeed * widget.containerSize;

    // Which index should be at the top of the column?
    _index = ((rawOffset / widget.containerSize)).floor();
    if (widget.spinDirection == SpinnerDirection.down ||
        widget.spinDirection == SpinnerDirection.right) {
      _index *= -1;
    }

    // Calculate the true offset
    _offset = (rawOffset % widget.containerSize);
    if (widget.spinDirection == SpinnerDirection.up ||
        widget.spinDirection == SpinnerDirection.left) {
      _offset *= -1;
    }

    // Widget offset will be different for left/right versus up/down
    Offset widgetOffset;

    // Call the widget builder to get the children that will go in the column/row
    List<Widget> children = positiveIntegers(_index)
        .take(widget.containerCount + 2)
        .map(widget.builder)
        .toList();

    // For up/down direction, place in a column with vertical overflow
    // For left/right, use a row with overflow horizontally
    if (widget.spinDirection == SpinnerDirection.up ||
        widget.spinDirection == SpinnerDirection.down) {
      widgetOffset = Offset(0, _offset);
      _column = OverflowBox(
          maxHeight: widget.containerSize * (widget.containerCount + 2),
          child: Column(children: children));
    } else {
      widgetOffset = Offset(_offset, 0);
      _column = OverflowBox(
          maxWidth: widget.containerSize * (widget.containerCount + 2),
          child: Row(children: children));
    }

    // Translate the entire column
    var translate = Transform.translate(child: _column, offset: widgetOffset);

    // Scale the column, if necessary
    _transformed = Transform.scale(
        scale: (_curve.value * (widget.zoomFactor - 1)) + 1, child: translate);
    return _transformed;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        return transformColumn(_curve.value);
      },
    );
  }
}
