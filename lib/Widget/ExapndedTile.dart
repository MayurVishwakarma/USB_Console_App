// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ExpandableTile extends StatefulWidget {
  Widget? title;
  Widget? body;

  ExpandableTile({super.key, @required this.title, @required this.body});

  @override
  _ExpandableTileState createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _rotation = Tween<double>(begin: 0.0, end: 0.5).animate(_controller!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue.shade200 //Theme.of(context).highlightColor,
            ),
        child: ListTile(
          onTap: () {
            setState(() {
              _controller!.isDismissed
                  ? _controller!.forward()
                  : _controller!.reverse();
            });
          },
          title: widget.title,
          trailing: RotationTransition(
            turns: _rotation!,
            child: const Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
      SizeTransition(
        sizeFactor: _controller!,
        axisAlignment: 0.0,
        child: widget.body,
      ),
    ]);
  }
}
