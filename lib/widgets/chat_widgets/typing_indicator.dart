import 'dart:async';

import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final String text;
  final Duration duration;

  const TypingIndicator({Key? key, this.text = "AI", this.duration = const Duration(milliseconds: 600)}) : super(key: key);

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)..addListener(() {
      setState(() {});
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotCount = (_animation.value * 3).ceil();

    return Row(
      children: [
        Text("${widget.text}", style: Theme.of(context).textTheme.bodyLarge),

        for (int i = 0; i < dotCount; i++)
          Text(".", style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}